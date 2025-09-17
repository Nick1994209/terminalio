<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server for Requests</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        nav {
            text-align: center;
            margin-bottom: 20px;
        }
        nav a {
            display: inline-block;
            padding: 10px 20px;
            margin: 0 10px;
            background-color: #007cba;
            color: white;
            text-decoration: none;
            border-radius: 3px;
        }
        nav a:hover {
            background-color: #005a87;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="text"], input[type="number"], textarea, select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 3px;
            box-sizing: border-box;
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
        button {
            background-color: #007cba;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }
        button:hover {
            background-color: #005a87;
        }
        .response-container {
            margin-top: 20px;
            padding: 15px;
            background-color: #f9f9f9;
            border-left: 4px solid #007cba;
        }
        .history-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .history-table th, .history-table td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        .history-table th {
            background-color: #f2f2f2;
        }
        .terminal-container {
            display: flex;
            height: 500px;
        }
        .terminal-output {
            flex: 3;
            background-color: #000;
            color: #00ff00;
            padding: 10px;
            font-family: monospace;
            overflow-y: auto;
            white-space: pre-wrap;
        }
        .terminal-history {
            flex: 1;
            background-color: #f5f5f5;
            padding: 10px;
            overflow-y: auto;
            border-left: 1px solid #ddd;
        }
        .terminal-input {
            width: 100%;
            padding: 10px;
            font-family: monospace;
            border: 1px solid #ddd;
            border-radius: 3px;
            margin-bottom: 10px;
        }
        .copy-btn {
            background-color: #555;
            padding: 5px 10px;
            font-size: 12px;
            margin: 2px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Server for Requests</h1>
        <nav>
            <a href="/">Home</a>
            <a href="/requests">Requests</a>
            <a href="/terminal">Terminal</a>
        </nav>
        {{.LayoutContent}}
    </div>
</body>
</html>