# TerminalIO Project Architecture

This document describes the architecture of the TerminalIO project after refactoring in accordance with the principles of clean architecture.

## Project Structure

```
.
├── cmd/
│   └── main.go                 # Application entry point
├── internal/
│   ├── app/                    # Application initialization and routes
│   ├── delivery/               # Delivery layer (controllers)
│   ├── repository/             # Data access layer
│   └── service/                # Business logic
├── views/                      # View templates
├── static/                     # Static files
├── conf/                       # Configuration files
├── go.mod                      # Go module
├── go.sum                      # Go dependency sums
├── Dockerfile                  # Application Docker image
├── README.md                   # Main documentation
└── README_ARCHITECTURE.md      # Architecture documentation
```

## Architecture Components

### 1. Entry Point Layer (cmd/)

Contains the application entry point `main.go`, which:
- Initializes the database
- Configures the Beego framework
- Registers routes
- Starts the server

### 2. Application Layer (internal/app/)

Contains application initialization logic:
- `app.go` - route and dependency initialization

### 3. Delivery Layer (internal/delivery/)

Contains controllers that handle HTTP requests:
- `main.go` - main page controller
- `request.go` - controller for working with HTTP requests
- `terminal.go` - controller for working with the terminal

Controllers depend on services and do not contain business logic.

### 4. Service Layer (internal/service/)

Contains the application's business logic:
- `request_service.go` - service for working with HTTP requests
- `command_service.go` - service for working with terminal commands

Services depend on repositories and contain all business logic.

### 5. Repository Layer (internal/repository/)

Contains data access logic:
- `database.go` - working with SQLite database

Repositories implement interfaces that are used by services.

## Clean Architecture Principles

### 1. Separation of Responsibility

Each layer has a clearly defined responsibility:
- **Delivery** - HTTP request processing
- **Service** - business logic
- **Repository** - data access

### 2. Dependencies Directed Inward

Dependencies are directed from outer layers to inner layers:
```
Delivery -> Service -> Repository
```

### 3. Interface Usage

All dependencies are passed through interfaces, which allows:
- Easy replacement of implementations
- Simplifies testing
- Adheres to the dependency inversion principle

### 4. Framework Independence

Business logic does not depend on a specific web framework and can be easily transferred.

## Data Flow

1. **HTTP request** arrives at the controller (delivery)
2. **Controller** calls the corresponding service method
3. **Service** executes business logic and interacts with the repository
4. **Repository** works with the database
5. **Result** is returned back to the client through the chain

## Advantages of the New Architecture

1. **Testability** - each component can be tested separately
2. **Maintainability** - changes in one layer do not affect others
3. **Flexibility** - easy to replace implementations or add new features
4. **Scalability** - easy to add new layers or components