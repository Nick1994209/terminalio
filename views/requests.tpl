<style>
    /* Postman-like styling */
    .postman-container {
        display: flex;
        flex-direction: column;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    
    /* URL bar section */
    .url-section {
        display: flex;
        margin-bottom: 20px;
        background: #f8f9fa;
        padding: 15px;
        border-radius: 4px;
        border: 1px solid #e0e0e0;
    }
    
    .method-select {
        width: 100px;
        margin-right: 10px;
        border: 1px solid #ddd;
        border-radius: 3px;
        padding: 8px;
        background: white;
    }
    
    .url-input {
        flex: 1;
        padding: 8px 12px;
        border: 1px solid #ddd;
        border-radius: 3px;
        font-size: 14px;
    }
    
    .send-btn {
        margin-left: 10px;
        background: #007cba;
        color: white;
        border: none;
        border-radius: 3px;
        padding: 0 20px;
        font-weight: bold;
        cursor: pointer;
    }
    
    .send-btn:hover {
        background: #005a87;
    }
    
    /* Tab navigation */
    .tabs {
        display: flex;
        border-bottom: 1px solid #e0e0e0;
        margin-bottom: 20px;
        background: #f8f9fa;
    }
    
    .tab {
        padding: 10px 15px;
        cursor: pointer;
        border-right: 1px solid #e0e0e0;
        font-size: 14px;
    }
    
    .tab.active {
        background: white;
        border-bottom: 2px solid #007cba;
        font-weight: bold;
    }
    
    .tab-content {
        display: none;
        padding: 15px;
        background: white;
        border: 1px solid #e0e0e0;
        border-top: none;
        flex: 1;
        overflow-y: auto;
    }
    
    .tab-content.active {
        display: block;
    }
    
    /* Form elements */
    .form-row {
        display: flex;
        gap: 15px;
        margin-bottom: 15px;
    }
    
    .form-col {
        flex: 1;
    }
    
    .form-group {
        margin-bottom: 15px;
    }
    
    label {
        display: block;
        margin-bottom: 5px;
        font-weight: 600;
        color: #333;
        font-size: 13px;
    }
    
    input[type="text"], input[type="number"], textarea, select {
        width: 100%;
        padding: 8px;
        border: 1px solid #ddd;
        border-radius: 3px;
        box-sizing: border-box;
        font-size: 13px;
    }
    
    textarea {
        min-height: 100px;
        font-family: monospace;
    }
    
    .checkbox-group {
        display: flex;
        align-items: center;
    }
    
    .checkbox-group input {
        width: auto;
        margin-right: 10px;
    }
    
    /* Response section */
    .response-section {
        margin-top: 20px;
        border: 1px solid #e0e0e0;
        border-radius: 4px;
        overflow: hidden;
    }
    
    .response-header {
        background: #f8f9fa;
        padding: 10px 15px;
        border-bottom: 1px solid #e0e0e0;
        font-weight: bold;
    }
    
    .response-body {
        padding: 15px;
        background: #fff;
    }
    
    .response-container {
        margin-top: 0;
        border-left: none;
        background: #f8f9fa;
    }
    
    .response-container.error {
        border-left-color: #dc3545;
        background: #fdf2f2;
    }
    
    /* Settings panel */
    .settings-panel {
        display: flex;
        gap: 20px;
        margin-top: 20px;
        background: #f8f9fa;
        padding: 15px;
        border-radius: 4px;
        border: 1px solid #e0e0e0;
    }
    
    .settings-col {
        flex: 1;
    }
    
    /* History link */
    .history-link {
        display: inline-block;
        padding: 10px 15px;
        background-color: #28a745;
        color: white;
        text-decoration: none;
        border-radius: 3px;
        margin-top: 20px;
    }
    
    .history-link:hover {
        background-color: #218838;
    }
    
    /* KV Pair Editor (for headers, params, etc.) */
    .kv-editor {
        margin-bottom: 15px;
    }
    
    .kv-row {
        display: flex;
        gap: 10px;
        margin-bottom: 8px;
    }
    
    .kv-key, .kv-value {
        flex: 1;
        padding: 6px 8px;
        border: 1px solid #ddd;
        border-radius: 3px;
        font-size: 13px;
    }
    
    .kv-actions {
        width: 80px;
        display: flex;
        gap: 5px;
    }
    
    .kv-btn {
        padding: 6px 10px;
        border: 1px solid #ddd;
        background: white;
        border-radius: 3px;
        cursor: pointer;
        font-size: 12px;
    }
    
    .kv-btn.add {
        background: #28a745;
        color: white;
        border-color: #28a745;
    }
    
    .kv-btn.remove {
        background: #dc3545;
        color: white;
        border-color: #dc3545;
    }
</style>

<h2>HTTP Request Client</h2>
<p>Postman-like interface for sending HTTP requests</p>

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
    <div class="response-header">Response</div>
    <div class="response-body">
        <div class="response-container error">
            <h3>Error:</h3>
            <pre>{{.ErrorMessage}}</pre>
        </div>
    </div>
</div>
{{else if .ResponseBody}}
<div class="response-section">
    <div class="response-header">Response • Status: {{.ResponseStatusCode}}</div>
    <div class="response-body">
        <div class="response-container">
            <p><strong>Headers:</strong></p>
            <pre>{{range $key, $values := .ResponseHeaders}}{{$key}}: {{range $values}}{{.}} {{end}}
{{end}}</pre>
            <p><strong>Body:</strong></p>
            <pre>{{.ResponseBody}}</pre>
        </div>
    </div>
</div>
{{end}}

<div>
    <a href="/requests/history" class="history-link">View Request History</a>
</div>

<script>
    // Tab switching functionality
    document.addEventListener('DOMContentLoaded', function() {
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
    });
</script>