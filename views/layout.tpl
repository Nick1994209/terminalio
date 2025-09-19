<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TerminalIO</title>
    <link rel="icon" type="image/svg+xml" href="/static/favicon.svg">
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <div class="container">
        <div class="header-container">
            <div class="logo-container">
                <img src="/static/favicon.svg" alt="TerminalIO Icon">
                <h1>TerminalIO</h1>
            </div>
            <nav>
                <a href="/">Home</a>
                <a href="/requests">Requests</a>
                <a href="/terminal">Terminal</a>
            </nav>
        </div>
        {{.LayoutContent}}
    </div>
</body>
</html>