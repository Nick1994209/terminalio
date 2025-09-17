package controllers

import (
	"bufio"
	"log"
	"net/http"
	"os/exec"
	"server-for-requests/models"
	"strings"

	beego "github.com/beego/beego/v2/server/web"
	"github.com/gorilla/websocket"
)

type TerminalController struct {
	beego.Controller
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

func sendUpdatedHistory(ws *websocket.Conn) {
	// Load command history
	rows, err := models.DB.Query("SELECT command FROM commands ORDER BY created_at DESC LIMIT 50")
	if err != nil {
		log.Println("Error loading command history:", err)
		return
	}
	defer rows.Close()

	var history []string
	for rows.Next() {
		var cmd string
		if err := rows.Scan(&cmd); err != nil {
			continue
		}
		history = append(history, cmd)
	}

	// Send history to client
	if err := ws.WriteJSON(map[string]interface{}{
		"type": "history",
		"data": history,
	}); err != nil {
		log.Println("Error sending history:", err)
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
	rows, err := models.DB.Query("SELECT command FROM commands ORDER BY created_at DESC LIMIT 50")
	if err != nil {
		log.Println("Error loading command history:", err)
		return
	}
	defer rows.Close()

	var history []string
	for rows.Next() {
		var cmd string
		if err := rows.Scan(&cmd); err != nil {
			continue
		}
		history = append(history, cmd)
	}

	// Send history to client
	if err := ws.WriteJSON(map[string]interface{}{
		"type": "history",
		"data": history,
	}); err != nil {
		log.Println("Error sending history:", err)
		return
	}

	// Send connection confirmation
	ws.WriteJSON(map[string]interface{}{
		"type": "output",
		"data": "[Connected to terminal]",
	})

	for {
		// Read message from client
		_, message, err := ws.ReadMessage()
		if err != nil {
			log.Println("WebSocket read error:", err)
			break
		}

		cmdStr := string(message)

		// Save command to database
		stmt, err := models.DB.Prepare("INSERT INTO commands(command, created_at) VALUES(?, datetime('now'))")
		if err != nil {
			log.Println("Error preparing statement:", err)
			continue
		}

		_, err = stmt.Exec(cmdStr)
		if err != nil {
			log.Println("Error saving command:", err)
		}
		stmt.Close()

		// Reload and send updated history
		go sendUpdatedHistory(ws)

		// Execute command
		parts := strings.Fields(cmdStr)
		if len(parts) == 0 {
			continue
		}

		name := parts[0]
		args := parts[1:]

		cmd := exec.Command(name, args...)
		stdout, err := cmd.StdoutPipe()
		if err != nil {
			ws.WriteJSON(map[string]interface{}{
				"type": "output",
				"data": "Error creating stdout pipe: " + err.Error(),
			})
			continue
		}

		stderr, err := cmd.StderrPipe()
		if err != nil {
			ws.WriteJSON(map[string]interface{}{
				"type": "output",
				"data": "Error creating stderr pipe: " + err.Error(),
			})
			continue
		}

		if err := cmd.Start(); err != nil {
			ws.WriteJSON(map[string]interface{}{
				"type": "output",
				"data": "Error starting command: " + err.Error(),
			})
			continue
		}

		// Send output to client
		scanner := bufio.NewScanner(stdout)
		for scanner.Scan() {
			output := scanner.Text()
			ws.WriteJSON(map[string]interface{}{
				"type": "output",
				"data": output,
			})
		}

		errScanner := bufio.NewScanner(stderr)
		for errScanner.Scan() {
			output := errScanner.Text()
			ws.WriteJSON(map[string]interface{}{
				"type": "output",
				"data": output,
			})
		}

		if err := cmd.Wait(); err != nil {
			ws.WriteJSON(map[string]interface{}{
				"type": "output",
				"data": "Command finished with error: " + err.Error(),
			})
		}
		// We don't send a "Command finished successfully" message anymore
		// The frontend will add a new prompt after receiving any "Command finished" message
	}

	// Prevent Beego from trying to render a template
	c.StopRun()
}
