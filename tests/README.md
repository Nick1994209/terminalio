# TerminalIO Tests

This directory contains unit tests for the TerminalIO application.

## Structure

```
tests/
├── internal/
│   ├── service/          # Service layer tests
│   │   ├── request_service_test.go
│   │   └── command_service_test.go
│   └── repository/       # Repository layer tests
│       ├── request_repository_test.go
│       └── command_repository_test.go
├── mocks/                # Mock implementations for testing
│   ├── request_repository_mock.go
│   └── command_repository_mock.go
└── test_utils.go         # Utility functions for testing
```

## Running Tests

To run all tests:

```bash
go test ./tests/...
```

To run service layer tests:

```bash
go test ./tests/internal/service/...
```

To run repository layer tests:

```bash
go test ./tests/internal/repository/...
```

## Test Coverage

The tests cover:

1. **Service Layer**:
   - Request service operations (CreateRequest, GetRecentRequests, etc.)
   - Command service operations (CreateCommand, GetRecentCommands, etc.)

2. **Repository Layer**:
   - Request repository operations with an in-memory SQLite database
   - Command repository operations with an in-memory SQLite database

## Mocks

The `mocks/` directory contains mock implementations of the repository interfaces for testing the service layer without depending on actual database operations.