<style>
    .history-page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        flex-wrap: wrap;
        gap: 10px;
    }
    
    .history-page-title {
        margin: 0;
    }
    
    .back-to-requests-btn {
        background-color: #007cba;
        color: white;
        padding: 8px 15px;
        text-decoration: none;
        border-radius: 3px;
        font-size: 0.9rem;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    
    .back-to-requests-btn:hover {
        background-color: #005a87;
    }
    
    .filter-form {
        background-color: #f8f9fa;
        padding: 20px;
        border-radius: 5px;
        margin-bottom: 20px;
        border: 1px solid #dee2e6;
    }
    
    .filter-form h3 {
        margin-top: 0;
        color: #333;
    }
    
    .filter-row {
        display: flex;
        gap: 15px;
        margin-bottom: 15px;
        flex-wrap: wrap;
    }
    
    .filter-col {
        flex: 1;
        min-width: 200px;
    }
    
    .filter-actions {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
    }
    
    .clear-filters-btn {
        padding: 8px 15px;
        background-color: #6c757d;
        color: white;
        text-decoration: none;
        border-radius: 3px;
        font-size: 0.9rem;
        display: inline-flex;
        align-items: center;
    }
    
    .clear-filters-btn:hover {
        background-color: #5a6268;
    }
    
    .history-table-container {
        overflow-x: auto;
        border: 1px solid #dee2e6;
        border-radius: 5px;
        margin-bottom: 20px;
    }
    
    .history-table {
        width: 100%;
        border-collapse: collapse;
        margin: 0;
        font-size: 0.9rem;
    }
    
    .history-table th, .history-table td {
        border: 1px solid #dee2e6;
        padding: 12px;
        text-align: left;
        vertical-align: top;
    }
    
    .history-table th {
        background-color: #f8f9fa;
        font-weight: 600;
        color: #495057;
        position: sticky;
        top: 0;
    }
    
    .history-table tr:nth-child(even) {
        background-color: #f8f9fa;
    }
    
    .history-table tr:hover {
        background-color: #e9ecef;
    }
    
    .method-badge {
        font-weight: bold;
        padding: 4px 8px;
        border-radius: 3px;
        font-size: 0.8rem;
        display: inline-block;
        min-width: 60px;
        text-align: center;
    }
    
    .method-GET { background-color: #d1ecf1; color: #0c5460; }
    .method-POST { background-color: #d4edda; color: #155724; }
    .method-PUT { background-color: #fff3cd; color: #856404; }
    .method-DELETE { background-color: #f8d7da; color: #721c24; }
    .method-PATCH { background-color: #cce5ff; color: #004085; }
    .method-HEAD { background-color: #e2e3e5; color: #383d41; }
    .method-OPTIONS { background-color: #d1ecf1; color: #0c5460; }
    
    .status-badge {
        font-weight: bold;
        padding: 4px 8px;
        border-radius: 3px;
        font-size: 0.8rem;
        display: inline-block;
        min-width: 40px;
        text-align: center;
    }
    
    .status-success { background-color: #d4edda; color: #155724; }
    .status-error { background-color: #f8d7da; color: #721c24; }
    .status-warning { background-color: #fff3cd; color: #856404; }
    
    .parameters-cell {
        font-family: monospace;
        font-size: 0.8rem;
        max-width: 200px;
        word-break: break-word;
    }
    
    .parameter-section {
        margin-bottom: 5px;
    }
    
    .parameter-section:last-child {
        margin-bottom: 0;
    }
    
    .parameter-label {
        font-weight: bold;
        color: #495057;
        display: block;
        margin-bottom: 2px;
    }
    
    .parameter-value {
        background-color: #e9ecef;
        padding: 3px 5px;
        border-radius: 3px;
        display: block;
        white-space: pre-wrap;
        word-break: break-word;
    }
    
    .empty-parameter {
        color: #6c757d;
        font-style: italic;
    }
    
    .action-buttons {
        display: flex;
        gap: 5px;
        flex-wrap: wrap;
    }
    
    .action-btn {
        padding: 6px 12px;
        border: none;
        border-radius: 3px;
        cursor: pointer;
        font-size: 0.85rem;
        display: inline-flex;
        align-items: center;
        gap: 4px;
    }
    
    .resend-btn {
        background-color: #007cba;
        color: white;
    }
    
    .resend-btn:hover {
        background-color: #005a87;
    }
    
    .delete-btn {
        background-color: #dc3545;
        color: white;
    }
    
    .delete-btn:hover {
        background-color: #c82333;
    }
    
    .no-requests-message {
        text-align: center;
        padding: 40px 20px;
        color: #6c757d;
        font-style: italic;
    }
    
    .no-requests-message p {
        margin: 0;
        font-size: 1.1rem;
    }
    
    /* Responsive adjustments */
    @media (max-width: 767px) {
        .filter-row {
            flex-direction: column;
            gap: 10px;
        }
        
        .filter-col {
            min-width: 100%;
        }
        
        .history-table th, .history-table td {
            padding: 8px 6px;
            font-size: 0.8rem;
        }
        
        .method-badge, .status-badge {
            font-size: 0.7rem;
            padding: 2px 6px;
        }
        
        .action-buttons {
            flex-direction: column;
            gap: 3px;
        }
        
        .action-btn {
            width: 100%;
            justify-content: center;
            font-size: 0.8rem;
            padding: 4px 8px;
        }
        
        .history-page-header {
            flex-direction: column;
            align-items: stretch;
        }
        
        .parameters-cell {
            max-width: 150px;
            font-size: 0.7rem;
        }
        
        .parameter-label {
            font-size: 0.75rem;
        }
        
        .parameter-value {
            padding: 2px 4px;
        }
    }
</style>

<div class="history-page-header">
    <h2 class="history-page-title">Request History</h2>
    <a href="/requests" class="back-to-requests-btn">← Back to Requests</a>
</div>

<div class="filter-form">
    <h3>Filter Requests</h3>
    <form method="GET" action="/requests/history">
        <div class="filter-row">
            <div class="filter-col">
                <div class="form-group">
                    <label for="url">URL:</label>
                    <input type="text" id="url" name="url" value="{{.URLFilter}}" placeholder="Filter by URL">
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
        <div class="filter-actions">
            <button type="submit" class="action-btn resend-btn">Apply Filters</button>
            <a href="/requests/history" class="clear-filters-btn">Clear Filters</a>
        </div>
    </form>
</div>

{{if .Requests}}
<div class="history-table-container">
    <table class="history-table">
        <thead>
            <tr>
                <th>ID</th>
                <th>URL</th>
                <th>Method</th>
                <th>Parameters</th>
                <th>Status</th>
                <th>Request Time</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            {{range .Requests}}
            <tr>
                <td>{{.ID}}</td>
                <td style="word-break: break-word; max-width: 200px;">{{.URL}}</td>
                <td><span class="method-badge method-{{.Method}}">{{.Method}}</span></td>
                <td class="parameters-cell">
                    {{if or .GetParams .Headers .Cookies .Body}}
                        {{if .GetParams}}
                        <div class="parameter-section">
                            <span class="parameter-label">GET:</span>
                            <span class="parameter-value">{{.GetParams}}</span>
                        </div>
                        {{end}}
                        {{if .Headers}}
                        <div class="parameter-section">
                            <span class="parameter-label">Headers:</span>
                            <span class="parameter-value">{{.Headers}}</span>
                        </div>
                        {{end}}
                        {{if .Cookies}}
                        <div class="parameter-section">
                            <span class="parameter-label">Cookies:</span>
                            <span class="parameter-value">{{.Cookies}}</span>
                        </div>
                        {{end}}
                        {{if .Body}}
                        <div class="parameter-section">
                            <span class="parameter-label">Body:</span>
                            <span class="parameter-value">{{.Body}}</span>
                        </div>
                        {{end}}
                    {{else}}
                        <span class="empty-parameter">No parameters</span>
                    {{end}}
                </td>
                <td>
                    {{if .ResponseStatus}}
                        <span class="status-badge {{if ge .ResponseStatus 200}}{{if lt .ResponseStatus 400}}status-success{{else}}status-error{{end}}{{else}}status-error{{end}}">
                            {{.ResponseStatus}}
                        </span>
                    {{else}}
                        <span class="status-badge status-error">ERR</span>
                    {{end}}
                </td>
                <td>{{.RequestTime.Format "2006-01-02 15:04:05"}}</td>
                <td>
                    <div class="action-buttons">
                        <form method="POST" action="/requests/resend/{{.ID}}" style="display: inline;">
                            <button type="submit" class="action-btn resend-btn">Resend</button>
                        </form>
                        <form method="POST" action="/requests/delete/{{.ID}}" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this request?')">
                            <button type="submit" class="action-btn delete-btn">Delete</button>
                        </form>
                    </div>
                </td>
            </tr>
            {{end}}
        </tbody>
    </table>
</div>
{{else}}
<div class="no-requests-message">
    <p>No requests found matching your criteria.</p>
</div>
{{end}}