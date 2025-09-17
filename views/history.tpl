{{template "layout.tpl" .}}

<style>
    .filter-form {
        background-color: #f8f9fa;
        padding: 15px;
        border-radius: 5px;
        margin-bottom: 20px;
    }
    .filter-row {
        display: flex;
        gap: 15px;
        margin-bottom: 10px;
    }
    .filter-col {
        flex: 1;
    }
</style>

<h2>Request History</h2>

<div class="filter-form">
    <h3>Filter Requests</h3>
    <form method="GET" action="/requests/history">
        <div class="filter-row">
            <div class="filter-col">
                <div class="form-group">
                    <label for="url">URL:</label>
                    <input type="text" id="url" name="url" value="{{.URLFilter}}">
                </div>
            </div>
            <div class="filter-col">
                <div class="form-group">
                    <label for="method">Method:</label>
                    <select id="method" name="method">
                        <option value="">All Methods</option>
                        <option value="GET" {{if eq .MethodFilter "GET"}}selected{{end}}>GET</option>
                        <option value="POST" {{if eq .MethodFilter "POST"}}selected{{end}}>POST</option>
                        <option value="PUT" {{if eq .MethodFilter "PUT"}}selected{{end}}>PUT</option>
                        <option value="DELETE" {{if eq .MethodFilter "DELETE"}}selected{{end}}>DELETE</option>
                        <option value="PATCH" {{if eq .MethodFilter "PATCH"}}selected{{end}}>PATCH</option>
                        <option value="HEAD" {{if eq .MethodFilter "HEAD"}}selected{{end}}>HEAD</option>
                        <option value="OPTIONS" {{if eq .MethodFilter "OPTIONS"}}selected{{end}}>OPTIONS</option>
                    </select>
                </div>
            </div>
        </div>
        <button type="submit">Filter</button>
        <a href="/requests/history" style="margin-left: 10px;">Clear Filters</a>
    </form>
</div>

{{if .Requests}}
<table class="history-table">
    <thead>
        <tr>
            <th>ID</th>
            <th>URL</th>
            <th>Method</th>
            <th>Status</th>
            <th>Request Time</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
        {{range .Requests}}
        <tr>
            <td>{{.ID}}</td>
            <td>{{.URL}}</td>
            <td>{{.Method}}</td>
            <td>{{.ResponseStatus}}</td>
            <td>{{.RequestTime.Format "2006-01-02 15:04:05"}}</td>
            <td>
                <form method="POST" action="/requests/resend/{{.ID}}" style="display: inline;">
                    <button type="submit" style="padding: 5px 10px; font-size: 12px;">Resend</button>
                </form>
                <form method="POST" action="/requests/delete/{{.ID}}" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this request?')">
                    <button type="submit" style="padding: 5px 10px; font-size: 12px; background-color: #dc3545;">Delete</button>
                </form>
            </td>
        </tr>
        {{end}}
    </tbody>
</table>
{{else}}
<p>No requests found.</p>
{{end}}

<div style="margin-top: 20px;">
    <a href="/requests" style="display: inline-block; padding: 10px 15px; background-color: #007cba; color: white; text-decoration: none; border-radius: 3px;">Back to Requests</a>
</div>