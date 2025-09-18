<style>
    .terminal-container {
        display: flex;
        height: 600px;
        margin-top: 20px;
    }
    .terminal-output {
        flex: 3;
        background-color: #000;
        color: #00ff00;
        padding: 10px;
        font-family: monospace;
        overflow-y: auto;
        white-space: pre;
        border: 1px solid #ddd;
        outline: none;
        display: flex;
        flex-direction: column;
    }
    .terminal-content {
        flex: 1;
        overflow-y: auto;
        margin-bottom: 10px;
        white-space: pre;
        font-family: monospace;
    }
    .terminal-input-line {
        flex-shrink: 0;
    }
    .terminal-history {
        flex: 1;
        background-color: #f5f5f5;
        padding: 10px;
        overflow-y: auto;
        border: 1px solid #ddd;
        margin-left: 10px;
    }
    .terminal-prompt {
        color: #00ff00;
    }
    .terminal-input {
        background-color: transparent;
        color: #00ff00;
        border: none;
        outline: none;
        font-family: monospace;
        width: calc(100% - 20px);
    }
    .terminal-line {
        display: flex;
    }
    .terminal-cursor {
        display: inline-block;
        width: 8px;
        height: 16px;
        background-color: #00ff00;
        animation: blink 1s infinite;
        vertical-align: middle;
    }
    .copy-btn {
        background-color: #555;
        color: white;
        border: none;
        padding: 5px 10px;
        font-size: 12px;
        cursor: pointer;
        margin: 2px;
        border-radius: 3px;
        width: 100%;
        text-align: left;
        font-family: monospace;
    }
    .copy-btn:hover {
        background-color: #333;
    }
    @keyframes blink {
        0%, 100% { opacity: 1; }
        50% { opacity: 0; }
    }
</style>

<h2>Terminal</h2>
<p>Linux-style terminal emulator.</p>

<div class="terminal-container">
    <div class="terminal-output" id="output" tabindex="0">
        <div class="terminal-content" id="terminal-content"></div>
        <div class="terminal-input-line" id="input-line-container"></div>
    </div>
    <div class="terminal-history">
        <h3>Command History</h3>
        <div id="history"></div>
    </div>
</div>

<script>
    let ws;
    let currentInput = '';
    let prompt = '$ ';
    let history = [];
    
    function connect() {
        const protocol = window.location.protocol === 'https:' ? 'wss://' : 'ws://';
        ws = new WebSocket(protocol + window.location.host + '/ws/terminal');
        
        ws.onopen = function() {
            // Connection confirmation now comes from backend
        };
        
        ws.onmessage = function(event) {
            let data;
            try {
                // Try to parse as JSON first
                data = JSON.parse(event.data);
                
                if (data.type === 'history') {
                    // Load command history
                    history = data.data;
                    updateHistory();
                } else if (data.type === 'output') {
                    // Display command output
                    appendOutput(data.data);
                    
                    // If this is the "Command finished" message, add a new prompt
                    if (data.data.includes('Command finished')) {
                        finishCommand();
                        // Update history after command execution
                        requestHistoryUpdate();
                    }
                }
            } catch (e) {
                // If not JSON, treat as plain text (backward compatibility)
                appendOutput(event.data);
                
                // If this is the "Command finished" message, add a new prompt
                if (event.data.includes('Command finished')) {
                    finishCommand();
                    // Update history after command execution
                    requestHistoryUpdate();
                }
            }
        };
        
        ws.onclose = function() {
            appendOutput('[Connection closed]');
            setTimeout(connect, 5000); // Reconnect after 5 seconds
        };
        
        ws.onerror = function(error) {
            appendOutput('[Connection error]');
        };
    }
    
    function appendOutput(text) {
        const content = document.getElementById('terminal-content');
        const htmlText = convertAnsiToHtml(text);
        content.innerHTML += htmlText + '\n';
        scrollToBottom();
    }
    
    // Simple ANSI to HTML converter
    function convertAnsiToHtml(text) {
        // Replace common ANSI escape sequences with HTML
        // This is a simplified version - a full implementation would be more complex
        
        // Handle carriage return + line feed
        text = text.replace(/\r\n/g, '\n');
        
        // Handle carriage return (move cursor to beginning of line)
        text = text.replace(/\r/g, '');
        
        // Handle common escape sequences that cause display issues
        // Clear screen and home cursor
        text = text.replace(/\x1b\[2J\x1b\[H/g, '');
        
        // Handle cursor positioning (simplified)
        text = text.replace(/\x1b\[(\d+);(\d+)H/g, '');
        
        // Handle other common escape sequences
        text = text.replace(/\x1b\[([0-9;]*)m/g, ''); // Color codes
        text = text.replace(/\x1b\[K/g, ''); // Clear to end of line
        text = text.replace(/\x1b\[\?25[lh]/g, ''); // Hide/show cursor
        text = text.replace(/\x1b\[([0-9;]*)[ABCDEFG]/g, ''); // Cursor movement
        
        // Escape HTML characters
        text = text.replace(/&/g, '&')
                     .replace(/</g, '<')
                     .replace(/>/g, '>');
        
        return text;
    }
    
    function appendCommandEcho(command) {
        const content = document.getElementById('terminal-content');
        const htmlText = convertAnsiToHtml(prompt + command);
        content.innerHTML += htmlText + '\n';
        scrollToBottom();
    }
    
    function appendPrompt() {
        const inputLineContainer = document.getElementById('input-line-container');
        inputLineContainer.innerHTML = '<div class="terminal-line"><span class="terminal-prompt">' + prompt + '</span><span id="input-text"></span><span class="terminal-cursor"></span></div>';
        currentInput = '';
        updateInputText();
        scrollToBottom();
    }
    
    function updateInputText() {
        const inputText = document.getElementById('input-text');
        if (inputText) {
            inputText.textContent = currentInput;
        }
    }
    
    function scrollToBottom() {
        const output = document.getElementById('output');
        const content = document.getElementById('terminal-content');
        
        // Scroll the main output container to bottom
        output.scrollTop = output.scrollHeight;
        
        // Also scroll the content container to bottom
        content.scrollTop = content.scrollHeight;
    }
    
    function updateHistory() {
        const historyDiv = document.getElementById('history');
        historyDiv.innerHTML = '';
        
        history.forEach(cmd => {
            const btn = document.createElement('button');
            btn.className = 'copy-btn';
            btn.textContent = cmd;
            btn.onclick = function() {
                // Copy command to current input
                currentInput = cmd;
                updateInputText();
                // Focus the terminal and scroll to bottom
                const output = document.getElementById('output');
                output.focus();
                scrollToBottom();
            };
            historyDiv.appendChild(btn);
            historyDiv.appendChild(document.createElement('br'));
        });
    }
    
    function requestHistoryUpdate() {
        // In a real implementation, we would request updated history from the server
        // For now, we'll simulate by requesting a history refresh
        if (ws && ws.readyState === WebSocket.OPEN) {
            // Send a special command to request history update
            // This is a simplified approach - in a real app, you might have a separate endpoint
        }
    }
    
    function finishCommand() {
        // Add a new prompt for the next command
        appendPrompt();
    }
    
    // sendRawKey sends raw key events to the terminal
    function sendRawKey(e) {
        if (!ws || ws.readyState !== WebSocket.OPEN) {
            return;
        }
        
        // Convert key event to ANSI escape sequences or raw bytes
        let rawData;
        
        // Handle special keys
        if (e.key === 'ArrowUp') {
            rawData = '\x1b[A';
        } else if (e.key === 'ArrowDown') {
            rawData = '\x1b[B';
        } else if (e.key === 'ArrowRight') {
            rawData = '\x1b[C';
        } else if (e.key === 'ArrowLeft') {
            rawData = '\x1b[D';
        } else if (e.key === 'Backspace') {
            rawData = '\x7f'; // DEL character
        } else if (e.key === 'Tab') {
            rawData = '\t';
        } else if (e.key === 'Escape') {
            rawData = '\x1b';
        } else if (e.ctrlKey) {
            // Handle Ctrl+key combinations
            if (e.key === 'c') {
                rawData = '\x03'; // Ctrl+C
            } else if (e.key === 'd') {
                rawData = '\x04'; // Ctrl+D
            } else if (e.key === 'z') {
                rawData = '\x1a'; // Ctrl+Z
            } else if (e.key === 'a') {
                rawData = '\x01'; // Ctrl+A
            } else if (e.key === 'e') {
                rawData = '\x05'; // Ctrl+E
            } else if (e.key === 'k') {
                rawData = '\x0b'; // Ctrl+K
            } else if (e.key === 'u') {
                rawData = '\x15'; // Ctrl+U
            } else if (e.key === 'w') {
                rawData = '\x17'; // Ctrl+W
            } else {
                // For other Ctrl+key combinations, convert to control character
                const charCode = e.key.charCodeAt(0);
                if (charCode >= 65 && charCode <= 90) { // A-Z
                    rawData = String.fromCharCode(charCode - 64);
                } else if (charCode >= 97 && charCode <= 122) { // a-z
                    rawData = String.fromCharCode(charCode - 96);
                } else {
                    rawData = e.key;
                }
            }
        } else {
            rawData = e.key;
        }
        
        // Send as raw input message
        const msg = {
            type: 'raw',
            data: btoa(rawData) // Base64 encode the data
        };
        ws.send(JSON.stringify(msg));
    }
    
    // resizeTerminal sends a resize message to the terminal
    function resizeTerminal() {
        if (!ws || ws.readyState !== WebSocket.OPEN) {
            return;
        }
        
        const output = document.getElementById('output');
        const content = document.getElementById('terminal-content');
        
        // Calculate terminal size based on container dimensions
        // This is a rough estimation - you might want to adjust based on your font size
        const charWidth = 8; // Approximate character width in pixels
        const charHeight = 16; // Approximate character height in pixels
        
        const cols = Math.floor(output.clientWidth / charWidth);
        const rows = Math.floor((output.clientHeight - 30) / charHeight); // Subtract some pixels for padding
        
        // Send resize message
        const msg = {
            type: 'resize',
            rows: rows,
            cols: cols
        };
        ws.send(JSON.stringify(msg));
    }
    
    document.addEventListener('DOMContentLoaded', function() {
        const output = document.getElementById('output');
        
        output.addEventListener('keydown', function(e) {
            // Only handle keys when at the end of the document
            const isAtEnd = output.scrollTop + output.clientHeight >= output.scrollHeight;
            
            if (!isAtEnd && e.key !== 'ArrowUp' && e.key !== 'ArrowDown') {
                // Allow scrolling when not at the end, except for arrow keys
                return;
            }
            
            // Handle special keys that should be sent to the terminal
            if (e.key === 'Enter') {
                e.preventDefault();
                if (currentInput.trim() !== '') {
                    // Echo the command in the terminal
                    appendCommandEcho(currentInput);
                    
                    // Send command to server
                    if (ws && ws.readyState === WebSocket.OPEN) {
                        ws.send(currentInput);
                    }
                    currentInput = '';
                } else {
                    appendOutput(prompt);
                }
                // Clear the input text content but keep the container
                const inputText = document.getElementById('input-text');
                if (inputText) {
                    inputText.textContent = '';
                }
                // Scroll to bottom after command execution
                setTimeout(scrollToBottom, 10);
            } else if (e.key === 'Backspace') {
                e.preventDefault();
                if (currentInput.length > 0) {
                    currentInput = currentInput.slice(0, -1);
                    updateInputText();
                    scrollToBottom();
                } else {
                    // Send backspace to terminal when input is empty
                    sendRawKey(e);
                }
            } else if (e.key === 'Tab') {
                e.preventDefault();
                // Send tab to terminal
                sendRawKey(e);
            } else if (e.key === 'ArrowUp' || e.key === 'ArrowDown' || e.key === 'ArrowLeft' || e.key === 'ArrowRight') {
                e.preventDefault();
                // Send arrow keys to terminal
                sendRawKey(e);
            } else if (e.key === 'Escape') {
                e.preventDefault();
                // Send escape to terminal
                sendRawKey(e);
            } else if (e.ctrlKey) {
                e.preventDefault();
                // Send Ctrl+key combinations to terminal
                sendRawKey(e);
            } else if (e.key.length === 1) {
                e.preventDefault();
                currentInput += e.key;
                updateInputText();
                scrollToBottom();
            }
        });
        
        // Handle window resize
        window.addEventListener('resize', function() {
            resizeTerminal();
        });
        
        // Focus the terminal on load
        output.focus();
        
        // Connect to WebSocket
        connect();
        
        // Add initial prompt after a short delay to ensure connection
        setTimeout(function() {
            appendPrompt();
            scrollToBottom();
            // Send initial resize
            resizeTerminal();
        }, 100);
    });
</script>