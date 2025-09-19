<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TerminalIO</title>
    <link rel="icon" type="image/svg+xml" href="/static/favicon.svg">
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
    </style>
</head>
<body>
    <div class="container">
        <div style="display: flex; align-items: center; justify-content: center; gap: 15px;">
            <img src="/static/favicon.svg" alt="TerminalIO Icon" style="width: 40px; height: 40px;">
            <h1>TerminalIO</h1>
        </div>
        <nav>
            <a href="/requests">Requests</a>
            <a href="/terminal">Terminal</a>
        </nav>
        <div style="text-align: center; padding: 30px;">
            <h2>Welcome to TerminalIO</h2>
            
            <!-- Two-column layout for comics -->
            <div style="display: flex; flex-wrap: wrap; gap: 30px; justify-content: center; margin: 30px 0;">
                <!-- Requests page comic -->
                <div style="flex: 1; min-width: 300px; max-width: 500px; text-align: center;">
                    <h3>How to Use the Requests Page</h3>
                    <p>Send HTTP requests like a pro!</p>
                    <a href="/requests" style="display: block;">
                        <img src="/static/requests_comic.svg" alt="How to use Requests Page" style="max-width: 100%; height: auto; border: 1px solid #ddd; border-radius: 5px; cursor: pointer;">
                    </a>
                </div>
                
                <!-- Terminal page comic -->
                <div style="flex: 1; min-width: 300px; max-width: 500px; text-align: center;">
                    <h3>How to Use the Terminal Page</h3>
                    <p>Execute commands in a Linux-style terminal emulator!</p>
                    <a href="/terminal" style="display: block;">
                        <img src="/static/terminal_comic.svg" alt="How to use Terminal Page" style="max-width: 100%; height: auto; border: 1px solid #ddd; border-radius: 5px; cursor: pointer;">
                    </a>
                </div>
            </div>
            
            <div style="margin-top: 30px;">
                <a href="/requests" style="display: inline-block; padding: 15px 30px; background-color: #007cba; color: white; text-decoration: none; border-radius: 5px; margin: 10px;">Go to Requests Page</a>
                <a href="/terminal" style="display: inline-block; padding: 15px 30px; background-color: #007cba; color: white; text-decoration: none; border-radius: 5px; margin: 10px;">Go to Terminal Page</a>
            </div>
        </div>
    </div>
</body>
</html>