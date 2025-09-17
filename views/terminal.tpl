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
    }
    .terminal-history {
        flex: 1;
        background-color: #f5f5f5;
        padding: 10px;
        overflow-y: auto;
        border: 1px solid #ddd;
        margin-left: 10px;
    }
    .terminal-input {
        width: 100%;
        padding: 10px;
        font-family: monospace;
        border: 1px solid #ddd;
        border-radius: 3px;
        margin-bottom: 10px;
        box-sizing: border-box;
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
    }
    .copy-btn:hover {
        background-color: #333;
    }
</style>

<h2>Terminal</h2>
<p>Execute commands in real-time using the terminal below.</p>

<div class="terminal-container">
    <div class="terminal-output" id="output"></div>
    <div class="terminal-history">
        <h3>Command History</h3>
        <div id="history"></div>
    </div>
</div>

<input type="text" class="terminal-input" id="command" placeholder="Enter command..." autofocus>

<script>
    let ws;
    let history = [];
    
    function connect() {
        ws = new WebSocket('ws://' + window.location.host + '/ws/terminal');
        
        ws.onopen = function() {
            document.getElementById('output').innerHTML += '[Connected to terminal]\n';
        };
        
        ws.onmessage = function(event) {
            const data = JSON.parse(event.data);
            
            if (data.type === 'history') {
                // Load command history
                history = data.data;
                updateHistory();
            } else {
                // Display output
                document.getElementById('output').innerHTML += data + '\n';
                document.getElementById('output').scrollTop = document.getElementById('output').scrollHeight;
            }
        };
        
        ws.onclose = function() {
            document.getElementById('output').innerHTML += '[Connection closed]\n';
            setTimeout(connect, 5000); // Reconnect after 5 seconds
        };
        
        ws.onerror = function(error) {
            document.getElementById('output').innerHTML += '[Connection error]\n';
        };
    }
    
    function updateHistory() {
        const historyDiv = document.getElementById('history');
        historyDiv.innerHTML = '';
        
        history.forEach(cmd => {
            const btn = document.createElement('button');
            btn.className = 'copy-btn';
            btn.textContent = cmd;
            btn.onclick = function() {
                document.getElementById('command').value = cmd;
                document.getElementById('command').focus();
            };
            historyDiv.appendChild(btn);
            historyDiv.appendChild(document.createElement('br'));
        });
    }
    
    document.getElementById('command').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            const cmd = this.value.trim();
            if (cmd && ws && ws.readyState === WebSocket.OPEN) {
                ws.send(cmd);
                this.value = '';
            }
        }
    });
    
    // Connect to WebSocket
    connect();
</script>