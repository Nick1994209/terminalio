{{template "layout.tpl" .}}

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
        white-space: pre-wrap;
        border: 1px solid #ddd;
        outline: none;
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
    <div class="terminal-output" id="output" tabindex="0"></div>
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
        ws = new WebSocket('ws://' + window.location.host + '/ws/terminal');
        
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
        const output = document.getElementById('output');
        output.innerHTML += text + '\n';
        output.scrollTop = output.scrollHeight;
    }
    
    function appendCommandEcho(command) {
        const output = document.getElementById('output');
        output.innerHTML += prompt + command + '\n';
        output.scrollTop = output.scrollHeight;
    }
    
    function appendPrompt() {
        const output = document.getElementById('output');
        output.innerHTML += '<div class="terminal-line"><span class="terminal-prompt">' + prompt + '</span><span id="input-line"></span><span class="terminal-cursor"></span></div>';
        output.scrollTop = output.scrollHeight;
        currentInput = '';
        updateInputLine();
    }
    
    function updateInputLine() {
        const inputLine = document.getElementById('input-line');
        if (inputLine) {
            inputLine.textContent = currentInput;
        }
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
                updateInputLine();
                // Focus the terminal
                document.getElementById('output').focus();
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
    
    document.addEventListener('DOMContentLoaded', function() {
        const output = document.getElementById('output');
        
        output.addEventListener('keydown', function(e) {
            // Only handle keys when at the end of the document
            const isAtEnd = output.scrollTop + output.clientHeight >= output.scrollHeight;
            
            if (!isAtEnd && e.key !== 'ArrowUp' && e.key !== 'ArrowDown') {
                // Allow scrolling when not at the end, except for arrow keys
                return;
            }
            
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
                // Clear the input line content but keep the container
                const inputLine = document.getElementById('input-line');
                if (inputLine) {
                    inputLine.textContent = '';
                }
            } else if (e.key === 'Backspace') {
                e.preventDefault();
                if (currentInput.length > 0) {
                    currentInput = currentInput.slice(0, -1);
                    updateInputLine();
                }
            } else if (e.key === 'Tab') {
                e.preventDefault();
                // Could implement tab completion here
            } else if (e.key.length === 1) {
                e.preventDefault();
                currentInput += e.key;
                updateInputLine();
            }
        });
        
        // Focus the terminal on load
        output.focus();
        
        // Connect to WebSocket
        connect();
        
        // Add initial prompt after a short delay to ensure connection
        setTimeout(function() {
            appendPrompt();
        }, 100);
    });
</script>