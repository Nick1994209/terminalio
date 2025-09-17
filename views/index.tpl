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
    </style>
</head>
<body>
    <div class="container">
        <h1>Server for Requests</h1>
        <nav>
            <a href="/requests">Requests</a>
            <a href="/terminal">Terminal</a>
        </nav>
        <div style="text-align: center; padding: 50px;">
            <h2>Welcome to Server for Requests</h2>
            <p>This application allows you to send HTTP requests and execute terminal commands.</p>
            
            <div style="margin-top: 30px;">
                <a href="/requests" style="display: inline-block; padding: 15px 30px; background-color: #007cba; color: white; text-decoration: none; border-radius: 5px; margin: 10px;">Go to Requests Page</a>
                <a href="/terminal" style="display: inline-block; padding: 15px 30px; background-color: #007cba; color: white; text-decoration: none; border-radius: 5px; margin: 10px;">Go to Terminal Page</a>
            </div>
        </div>
    </div>
</body>
</html>