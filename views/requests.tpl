<!-- DEBUG: This is the requests template -->
<h2>HTTP Request Client</h2>
<p>Postman-like interface for sending HTTP requests</p>

<div class="main-content">
    <!-- History Sidebar -->
    <div class="history-sidebar">
        <div class="sidebar-title">
            <span>Request History</span>
            <button class="clear-history-btn" onclick="clearRequestHistory()">Clear</button>
        </div>
        {{if .RecentRequests}}
            {{range .RecentRequests}}
            <div class="history-item" onclick="resendRequest({{.ID}})">
                <div class="history-header">
                    <span class="history-method method-{{.Method}}">{{.Method}}</span>
                    <span class="history-status {{if ge .ResponseStatus 200}}{{if lt .ResponseStatus 400}}status-success{{else}}status-error{{end}}{{else}}status-error{{end}}">
                        {{if .ResponseStatus}}{{.ResponseStatus}}{{else}}ERR{{end}}
                    </span>
                </div>
                <div class="history-url">{{.URL}}</div>
                <div class="history-time">{{.RequestTime.Format "2006-01-02 15:04:05"}}</div>
            </div>
            {{end}}
        {{else}}
            <p class="no-history">No request history yet.</p>
        {{end}}
    </div>
    
    <!-- Request Form Area -->
    <div class="request-form-area">
        <form method="POST" action="/requests/send" class="postman-container">
            <!-- URL Bar -->
            <div class="url-section">
                <select id="method" name="method" class="method-select">
                    <option value="GET" {{if eq .RequestMethod "GET"}}selected{{end}}>GET</option>
                    <option value="POST" {{if eq .RequestMethod "POST"}}selected{{end}}>POST</option>
                    <option value="PUT" {{if eq .RequestMethod "PUT"}}selected{{end}}>PUT</option>
                    <option value="DELETE" {{if eq .RequestMethod "DELETE"}}selected{{end}}>DELETE</option>
                    <option value="PATCH" {{if eq .RequestMethod "PATCH"}}selected{{end}}>PATCH</option>
                    <option value="HEAD" {{if eq .RequestMethod "HEAD"}}selected{{end}}>HEAD</option>
                    <option value="OPTIONS" {{if eq .RequestMethod "OPTIONS"}}selected{{end}}>OPTIONS</option>
                </select>
                <input type="text" id="url" name="url" value="{{.RequestURL}}" placeholder="Enter URL" class="url-input" required>
                <button type="submit" class="send-btn">Send</button>
            </div>
            
            <!-- Tab Navigation -->
            <div class="tabs">
                <div class="tab active" data-tab="params">Params</div>
                <div class="tab" data-tab="headers">Headers</div>
                <div class="tab" data-tab="cookies">Cookies</div>
                <div class="tab" data-tab="body">Body</div>
                <div class="tab" data-tab="settings">Settings</div>
            </div>
            
            <!-- Params Tab -->
            <div class="tab-content active" id="params-tab">
                <div class="form-group">
                    <label>Query Parameters</label>
                    <textarea id="get_params" name="get_params" placeholder="Key=Value&#10;One parameter per line">{{.RequestGetParams}}</textarea>
                </div>
            </div>
            
            <!-- Headers Tab -->
            <div class="tab-content" id="headers-tab">
                <div class="form-group">
                    <label>Headers</label>
                    <textarea id="headers" name="headers" placeholder="Key: Value&#10;One header per line">{{.RequestHeaders}}</textarea>
                </div>
            </div>
            
            <!-- Cookies Tab -->
            <div class="tab-content" id="cookies-tab">
                <div class="form-group">
                    <label>Cookies</label>
                    <textarea id="cookies" name="cookies" placeholder="Key=Value&#10;One cookie per line">{{.RequestCookies}}</textarea>
                </div>
            </div>
            
            <!-- Body Tab -->
            <div class="tab-content" id="body-tab">
                <div class="form-group">
                    <label>Request Body</label>
                    <textarea id="body" name="body" placeholder="Enter request body">{{.RequestBody}}</textarea>
                </div>
            </div>
            
            <!-- Settings Tab -->
            <div class="tab-content" id="settings-tab">
                <div class="settings-panel">
                    <div class="settings-col">
                        <div class="form-group">
                            <label for="timeout">Timeout (seconds):</label>
                            <input type="number" id="timeout" name="timeout" value="{{.RequestTimeout}}" min="1" max="300">
                        </div>
                    </div>
                    <div class="settings-col">
                        <div class="form-group checkbox-group">
                            <input type="checkbox" id="allow_redirects" name="allow_redirects" {{if .RequestAllowRedirects}}checked{{end}}>
                            <label for="allow_redirects">Follow Redirects</label>
                        </div>
                        <div class="form-group checkbox-group">
                            <input type="checkbox" id="verify_ssl" name="verify_ssl" {{if .RequestVerifySSL}}checked{{end}}>
                            <label for="verify_ssl">Verify SSL Certificate</label>
                        </div>
                    </div>
                </div>
            </div>
        </form>

        <!-- Response Section -->
        {{if .ErrorMessage}}
        <div class="response-section">
            <div class="response-header">
                <span>Response</span>
                <span class="response-status error">Error</span>
            </div>
            <div class="response-body">
                <div class="response-container error">
                    <h3>Error:</h3>
                    <pre class="response-content">{{.ErrorMessage}}</pre>
                </div>
            </div>
        </div>
        {{else if .ResponseBody}}
        <div class="response-section">
            <div class="response-header">
                <span>Response</span>
                <span class="response-status success">Status: {{.ResponseStatusCode}}</span>
                <button class="copy-response-btn" onclick="copyResponse()">Copy</button>
            </div>
            <div class="response-tabs">
                <div class="response-tab active" data-tab="body">Body</div>
                <div class="response-tab" data-tab="headers">Headers</div>
            </div>
            <div class="response-body">
                <div class="response-tab-content active" id="response-body-tab">
                    <div class="response-container">
                        <pre class="response-content">{{.ResponseBody}}</pre>
                    </div>
                </div>
                <div class="response-tab-content" id="response-headers-tab">
                    <div class="response-container">
                        <pre class="response-content">{{range $key, $values := .ResponseHeaders}}{{$key}}: {{range $values}}{{.}} {{end}}
{{end}}</pre>
                    </div>
                </div>
            </div>
        </div>
        {{end}}
    </div>
</div>

<div class="history-link-container">
    <a href="/requests/history" class="history-link">View Full Request History</a>
</div>

<script>
    // Tab switching functionality
    document.addEventListener('DOMContentLoaded', function() {
        // Request tabs
        const tabs = document.querySelectorAll('.tab');
        const tabContents = document.querySelectorAll('.tab-content');
        
        tabs.forEach(tab => {
            tab.addEventListener('click', () => {
                // Remove active class from all tabs and contents
                tabs.forEach(t => t.classList.remove('active'));
                tabContents.forEach(tc => tc.classList.remove('active'));
                
                // Add active class to clicked tab
                tab.classList.add('active');
                
                // Show corresponding content
                const tabId = tab.getAttribute('data-tab');
                document.getElementById(`${tabId}-tab`).classList.add('active');
            });
        });
        
        // Response tabs
        const responseTabs = document.querySelectorAll('.response-tab');
        const responseTabContents = document.querySelectorAll('.response-tab-content');
        
        responseTabs.forEach(tab => {
            tab.addEventListener('click', () => {
                // Remove active class from all tabs and contents
                responseTabs.forEach(t => t.classList.remove('active'));
                responseTabContents.forEach(tc => tc.classList.remove('active'));
                
                // Add active class to clicked tab
                tab.classList.add('active');
                
                // Show corresponding content
                const tabId = tab.getAttribute('data-tab');
                document.getElementById(`response-${tabId}-tab`).classList.add('active');
            });
        });
    });
    
    // Function to resend a request
    function resendRequest(id) {
        if (confirm('Resend this request?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = `/requests/resend/${id}`;
            document.body.appendChild(form);
            form.submit();
        }
    }
    
    // Function to clear request history
    function clearRequestHistory() {
        // Confirm with user before clearing
        if (!confirm('Are you sure you want to clear all request history?')) {
            return;
        }
        
        // Send request to clear history
        fetch('/requests/clear-history', {
            method: 'POST'
        })
        .then(response => {
            if (response.ok) {
                // Clear the history display
                const historySidebar = document.querySelector('.history-sidebar');
                const historyItems = historySidebar.querySelectorAll('.history-item');
                historyItems.forEach(item => item.remove());
                
                // Show a message that history is cleared
                const noHistoryMsg = document.createElement('p');
                noHistoryMsg.className = 'no-history';
                noHistoryMsg.textContent = 'No request history yet.';
                historySidebar.appendChild(noHistoryMsg);
            } else {
                alert('Failed to clear request history');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error clearing request history');
        });
    }
    
    // Function to copy response to clipboard
    function copyResponse() {
        const responseContent = document.querySelector('.response-content').textContent;
        navigator.clipboard.writeText(responseContent)
            .then(() => {
                // Show temporary confirmation
                const copyBtn = document.querySelector('.copy-response-btn');
                const originalText = copyBtn.textContent;
                copyBtn.textContent = 'Copied!';
                setTimeout(() => {
                    copyBtn.textContent = originalText;
                }, 2000);
            })
            .catch(err => {
                console.error('Failed to copy: ', err);
                alert('Failed to copy response to clipboard');
            });
    }
</script>
