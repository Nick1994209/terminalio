# TerminalIO v0.0.1 Release Notes

## Overview
TerminalIO is a web-based HTTP client service built with Go and the Beego framework that allows users to send HTTP requests with customizable parameters, view responses, and maintain a history of requests. Additionally, it provides a real-time terminal interface for executing system commands through a web browser.

## Key Features

### HTTP Request Client
- **Full HTTP Method Support**: GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS
- **Customizable Request Parameters**:
  - Custom headers
  - Cookies
  - GET parameters
  - Request body
  - Timeout settings
  - Redirect and SSL options
- **Request History Management**:
  - View history of all sent requests
  - Filter by URL or method
  - Resend previous requests
  - Delete request records
- **Response Handling**:
  - Detailed response status and headers
  - Response body display
  - Error handling

### Real-time Terminal
- **WebSocket-based Terminal**:
  - Interactive command execution
  - Automatic protocol detection (ws/wss)
  - Support for shell builtins (cd, export, etc.)
- **Persistent Sessions**:
  - Continuous shell session
  - Command history storage
- **Advanced Terminal Features**:
  - Command history with recall
  - Terminal resizing
  - Raw key event handling (arrows, tab, etc.)
  - ANSI escape sequence support

### Data Persistence
- **SQLite Database Storage**:
  - All requests and responses stored locally
  - Command history persistence
  - Easy data management

### Deployment Options
- **Docker Support**:
  - Root user deployment
  - Non-root user deployment (enhanced security)
- **Cross-platform Compatibility**:
  - Runs on Linux systems
  - Containerized deployment

## Technologies Used
- **Backend**: Go with Beego framework
- **Frontend**: HTML/CSS with responsive design
- **Database**: SQLite
- **Real-time Communication**: WebSocket
- **Containerization**: Docker

## Getting Started
1. Clone the repository
2. Run with `go run main.go` or use Docker
3. Access the application at `http://localhost:8080`

## Initial Release
This is the first official release of TerminalIO, featuring a complete HTTP client interface and a real-time terminal emulator accessible through a web browser.