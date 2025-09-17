{{template "layout.tpl" .}}

<style>
    .form-row {
        display: flex;
        gap: 15px;
        margin-bottom: 15px;
    }
    .form-col {
        flex: 1;
    }
</style>

<h2>HTTP Request Form</h2>

<form method="POST" action="/requests/send">
    <div class="form-group">
        <label for="url">URL:</label>
        <input type="text" id="url" name="url" value="{{.RequestURL}}" required>
    </div>
    
    <div class="form-row">
        <div class="form-col">
            <div class="form-group">
                <label for="method">Method:</label>
                <select id="method" name="method">
                    <option value="GET" {{if eq .RequestMethod "GET"}}selected{{end}}>GET</option>
                    <option value="POST" {{if eq .RequestMethod "POST"}}selected{{end}}>POST</option>
                    <option value="PUT" {{if eq .RequestMethod "PUT"}}selected{{end}}>PUT</option>
                    <option value="DELETE" {{if eq .RequestMethod "DELETE"}}selected{{end}}>DELETE</option>
                    <option value="PATCH" {{if eq .RequestMethod "PATCH"}}selected{{end}}>PATCH</option>
                    <option value="HEAD" {{if eq .RequestMethod "HEAD"}}selected{{end}}>HEAD</option>
                    <option value="OPTIONS" {{if eq .RequestMethod "OPTIONS"}}selected{{end}}>OPTIONS</option>
                </select>
            </div>
        </div>
        
        <div class="form-col">
            <div class="form-group">
                <label for="timeout">Timeout (seconds):</label>
                <input type="number" id="timeout" name="timeout" value="{{.RequestTimeout}}" min="1" max="300">
            </div>
        </div>
    </div>
    
    <div class="form-row">
        <div class="form-col">
            <div class="form-group checkbox-group">
                <input type="checkbox" id="allow_redirects" name="allow_redirects" {{if .RequestAllowRedirects}}checked{{end}}>
                <label for="allow_redirects">Allow Redirects</label>
            </div>
        </div>
        
        <div class="form-col">
            <div class="form-group checkbox-group">
                <input type="checkbox" id="verify_ssl" name="verify_ssl" {{if .RequestVerifySSL}}checked{{end}}>
                <label for="verify_ssl">Verify SSL</label>
            </div>
        </div>
    </div>
    
    <div class="form-group">
        <label for="headers">Headers (one per line, format: Key: Value):</label>
        <textarea id="headers" name="headers">{{.RequestHeaders}}</textarea>
    </div>
    
    <div class="form-group">
        <label for="cookies">Cookies (one per line, format: Key=Value):</label>
        <textarea id="cookies" name="cookies">{{.RequestCookies}}</textarea>
    </div>
    
    <div class="form-group">
        <label for="get_params">GET Parameters (one per line, format: Key=Value):</label>
        <textarea id="get_params" name="get_params">{{.RequestGetParams}}</textarea>
    </div>
    
    <div class="form-group">
        <label for="body">Body:</label>
        <textarea id="body" name="body">{{.RequestBody}}</textarea>
    </div>
    
    <button type="submit">Send Request</button>
</form>

{{if .ErrorMessage}}
<div class="response-container" style="border-left-color: #dc3545;">
    <h3>Error:</h3>
    <pre>{{.ErrorMessage}}</pre>
</div>
{{else if .ResponseBody}}
<div class="response-container">
    <h3>Response:</h3>
    <p><strong>Status Code:</strong> {{.ResponseStatusCode}}</p>
    <p><strong>Headers:</strong></p>
    <pre>{{range $key, $values := .ResponseHeaders}}{{$key}}: {{range $values}}{{.}} {{end}}
{{end}}</pre>
    <p><strong>Body:</strong></p>
    <pre>{{.ResponseBody}}</pre>
</div>
{{end}}

<div style="margin-top: 30px;">
    <a href="/requests/history" style="display: inline-block; padding: 10px 15px; background-color: #28a745; color: white; text-decoration: none; border-radius: 3px;">View Request History</a>
</div>