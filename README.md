# Server for Requests

A web-based HTTP client service built with Go and the Beego framework that allows users to send HTTP requests with customizable parameters, view responses, and maintain a history of requests.

## Features

- **HTTP Request Form**: Send requests with full parameter control:
  - URL input
  - Method selection (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS)
  - Custom headers
  - Cookies
  - GET parameters
  - Request body
  - Timeout settings
  - Redirect and SSL options

- **Request History**: Store and manage previous requests:
  - View history of all sent requests
  - Filter by URL or method
  - Resend previous requests
  - Delete request records

- **Real-time Terminal**: Execute system commands through a web interface:
  - WebSocket-based terminal
  - Command history storage
  - Interactive command execution

- **Database Storage**: All requests and terminal commands are stored in an SQLite database for persistence.

## Technologies Used

- **Backend**: Go with Beego framework
- **Frontend**: HTML/CSS with responsive design
- **Database**: SQLite
- **Real-time Communication**: WebSocket

## Getting Started

### Prerequisites

- Go 1.16 or higher
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```bash
   cd server-for-requests
   ```

3. Run the application:
   ```bash
   go run main.go
   ```

4. Access the application in your browser at `http://localhost:8080`

### Docker

The application can also be run using Docker:

```bash
docker build -t server-for-requests .
docker run -p 8080:8080 server-for-requests
```

## Usage

1. **Main Page**: Navigate between the Requests and Terminal interfaces
2. **Requests**: Fill out the form with your desired HTTP parameters and send requests
3. **History**: View and manage your request history
4. **Terminal**: Execute system commands in real-time

## API Endpoints

- `/` - Main page
- `/requests` - HTTP request form
- `/requests/send` - Send HTTP request (POST)
- `/requests/history` - View request history
- `/requests/resend/:id` - Resend a previous request (POST)
- `/requests/delete/:id` - Delete a request from history (POST)
- `/terminal` - Terminal interface
- `/ws/terminal` - WebSocket connection for terminal

## License

This project is licensed under the MIT License.