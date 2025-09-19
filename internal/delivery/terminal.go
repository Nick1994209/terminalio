package delivery

import (
	"encoding/base64"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/exec"
	"sync"
	"terminalio/internal/repository"
	"terminalio/internal/service"

	beego "github.com/beego/beego/v2/server/web"
	"github.com/creack/pty"
	"github.com/gorilla/websocket"
)

type TerminalController struct {
	beego.Controller
	CommandService service.CommandService
}

// Session represents a terminal session with a persistent shell
type Session struct {
	pty     *os.File
	cmd     *exec.Cmd
	ws      *websocket.Conn
	writeMu sync.Mutex // Mutex for WebSocket writes
	shellMu sync.Mutex // Mutex for shell operations
}

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func (c *TerminalController) Get() {
	c.TplName = "terminal.tpl"
	c.Layout = "layout.tpl"
}

func sendUpdatedHistory(session *Session, commandService service.CommandService) {
	// Load command history
	commands, err := commandService.GetRecentCommands(50)
	if err != nil {
		log.Println("Error loading command history:", err)
		return
	}

	// Convert commands to string slice
	history := make([]string, len(commands))
	for i, cmd := range commands {
		history[i] = cmd.Command
	}

	// Send history to client
	// Ensure we never send null data
	if history == nil {
		history = []string{}
	}

	session.writeMu.Lock()
	defer session.writeMu.Unlock()
	if err := session.ws.WriteJSON(map[string]interface{}{
		"type": "history",
		"data": history,
	}); err != nil {
		log.Println("Error sending history:", err)
	}
}

// startShellSession creates a new shell session with PTY
func startShellSession() (*Session, error) {
	// Start a shell process
	cmd := exec.Command("/bin/bash")

	// Start the command with a pty
	ptmx, err := pty.Start(cmd)
	if err != nil {
		return nil, err
	}

	// Set initial terminal size
	pty.Setsize(ptmx, &pty.Winsize{
		Rows: 24,
		Cols: 80,
	})

	session := &Session{
		pty: ptmx,
		cmd: cmd,
	}

	return session, nil
}

// writeToShell writes data to the shell session
func (s *Session) writeToShell(data string) error {
	s.shellMu.Lock()
	defer s.shellMu.Unlock()

	_, err := s.pty.Write([]byte(data + "\n"))
	return err
}

// writeRawToShell writes raw data to the shell session without adding a newline
func (s *Session) writeRawToShell(data []byte) error {
	s.shellMu.Lock()
	defer s.shellMu.Unlock()

	_, err := s.pty.Write(data)
	return err
}

// resizeTerminal resizes the terminal PTY
func (s *Session) resizeTerminal(rows, cols uint16) error {
	s.shellMu.Lock()
	defer s.shellMu.Unlock()

	return pty.Setsize(s.pty, &pty.Winsize{
		Rows: rows,
		Cols: cols,
	})
}

// readFromShell reads data from the shell session and sends it to the WebSocket
func (s *Session) readFromShell() {
	buf := make([]byte, 1024)
	for {
		n, err := s.pty.Read(buf)
		if err != nil {
			// Handle EOF or other errors
			break
		}

		if n > 0 {
			// Send raw binary data
			s.writeMu.Lock()
			s.ws.WriteJSON(map[string]interface{}{
				"type": "output",
				"data": string(buf[:n]),
			})
			s.writeMu.Unlock()
		}
	}
}

// close terminates the shell session
func (s *Session) close() {
	s.shellMu.Lock()
	defer s.shellMu.Unlock()

	if s.pty != nil {
		s.pty.Close()
	}
	if s.cmd != nil && s.cmd.Process != nil {
		s.cmd.Process.Kill()
	}
}

func (c *TerminalController) WebSocket() {
	ws, err := upgrader.Upgrade(c.Ctx.ResponseWriter, c.Ctx.Request, nil)
	if err != nil {
		log.Println("WebSocket upgrade error:", err)
		return
	}
	defer ws.Close()

	// Load command history
	commands, err := c.CommandService.GetRecentCommands(50)
	if err != nil {
		log.Println("Error loading command history:", err)
		return
	}

	// Convert commands to string slice
	history := make([]string, len(commands))
	for i, cmd := range commands {
		history[i] = cmd.Command
	}

	// Send history to client
	// Ensure we never send null data
	if history == nil {
		history = []string{}
	}

	if err := ws.WriteJSON(map[string]interface{}{
		"type": "history",
		"data": history,
	}); err != nil {
		log.Println("Error sending history:", err)
		return
	}

	// Start a new shell session
	session, err := startShellSession()
	if err != nil {
		log.Println("Error starting shell session:", err)
		ws.WriteJSON(map[string]interface{}{
			"type": "output",
			"data": "Error starting shell session: " + err.Error(),
		})
		return
	}

	// Set the WebSocket in the session
	session.ws = ws

	// Start reading from the shell in a goroutine
	go session.readFromShell()

	// Send connection confirmation
	ws.WriteJSON(map[string]interface{}{
		"type": "output",
		"data": "[Connected to terminal - Persistent session active]",
	})

	// Handle incoming messages
	for {
		// Read message from client
		_, message, err := ws.ReadMessage()
		if err != nil {
			log.Println("WebSocket read error:", err)
			break
		}

		cmdStr := string(message)

		// Check if this is a raw input message or a command before saving to history
		var msgData map[string]interface{}
		if json.Unmarshal([]byte(cmdStr), &msgData) == nil {
			// This is a JSON message, check if it's a raw key event, resize, or clear_history
			if msgType, ok := msgData["type"].(string); ok && (msgType == "raw" || msgType == "resize" || msgType == "clear_history") {
				// Skip saving raw key events, resize commands, and clear_history to history
				// But still process them
				if msgType, ok := msgData["type"].(string); ok && msgType == "raw" {
					// Handle raw input
					if data, ok := msgData["data"].(string); ok {
						// Decode base64 encoded raw data
						decodedData, err := base64.StdEncoding.DecodeString(data)
						if err != nil {
							log.Println("Error decoding raw data:", err)
						} else {
							if err := session.writeRawToShell(decodedData); err != nil {
								log.Println("Error writing raw data to shell:", err)
								session.writeMu.Lock()
								ws.WriteJSON(map[string]interface{}{
									"type": "output",
									"data": "Error writing raw data to shell: " + err.Error(),
								})
								session.writeMu.Unlock()
							}
						}
					}
				} else if msgType, ok := msgData["type"].(string); ok && msgType == "resize" {
					// Handle terminal resize
					if rows, ok := msgData["rows"].(float64); ok {
						if cols, ok := msgData["cols"].(float64); ok {
							if err := session.resizeTerminal(uint16(rows), uint16(cols)); err != nil {
								log.Println("Error resizing terminal:", err)
							}
						}
					}
				} else if msgType, ok := msgData["type"].(string); ok && msgType == "clear_history" {
					// Handle clear history request - clear database and send confirmation back to client
					err := c.CommandService.DeleteAllCommands()
					if err != nil {
						log.Println("Error clearing terminal history:", err)
						session.writeMu.Lock()
						ws.WriteJSON(map[string]interface{}{
							"type": "output",
							"data": "Error clearing terminal history: " + err.Error(),
						})
						session.writeMu.Unlock()
					} else {
						session.writeMu.Lock()
						ws.WriteJSON(map[string]interface{}{
							"type": "clear_history",
						})
						session.writeMu.Unlock()
					}
				}
				continue
			}
		}

		// Save command to database (only for non-raw, non-resize, non-clear_history commands)
		cmd := repository.Command{
			Command: cmdStr,
		}
		err = c.CommandService.CreateCommand(&cmd)
		if err != nil {
			log.Println("Error saving command:", err)
		}

		// Reload and send updated history
		go sendUpdatedHistory(session, c.CommandService)

		// Now process the command (if it's not a raw message or resize)
		if json.Unmarshal([]byte(cmdStr), &msgData) != nil {
			// This is not a JSON message, treat it as a regular command
			if err := session.writeToShell(cmdStr); err != nil {
				log.Println("Error writing to shell:", err)
				session.writeMu.Lock()
				ws.WriteJSON(map[string]interface{}{
					"type": "output",
					"data": "Error writing to shell: " + err.Error(),
				})
				session.writeMu.Unlock()
			}
		}
	}

	// Clean up the session when WebSocket closes
	session.close()

	// Prevent Beego from trying to render a template
	c.StopRun()
}
