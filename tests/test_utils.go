package utils

import (
	"terminalio/internal/repository"
	"time"
)

// CreateTestRequest creates a sample request for testing
func CreateTestRequest() *repository.Request {
	return &repository.Request{
		ID:              1,
		URL:             "http://example.com",
		Method:          "GET",
		Headers:         "Content-Type: application/json",
		Cookies:         "session=abc123",
		GetParams:       "param1=value1",
		Body:            `{"key": "value"}`,
		Timeout:         30,
		AllowRedirects:  true,
		VerifySSL:       true,
		RequestTime:     time.Now(),
		ResponseTime:    time.Now().Add(time.Second),
		ResponseStatus:  200,
		ResponseBody:    "OK",
		ResponseHeaders: "Content-Type: text/plain",
	}
}

// CreateTestCommand creates a sample command for testing
func CreateTestCommand() *repository.Command {
	return &repository.Command{
		ID:        1,
		Command:   "ls -la",
		CreatedAt: time.Now(),
	}
}

// CreateTestRequests creates a slice of sample requests for testing
func CreateTestRequests(count int) []repository.Request {
	requests := make([]repository.Request, count)
	for i := 0; i < count; i++ {
		requests[i] = repository.Request{
			ID:             i + 1,
			URL:            "http://example.com",
			Method:         "GET",
			RequestTime:    time.Now(),
			ResponseStatus: 200,
		}
	}
	return requests
}

// CreateTestCommands creates a slice of sample commands for testing
func CreateTestCommands(count int) []repository.Command {
	commands := make([]repository.Command, count)
	for i := 0; i < count; i++ {
		commands[i] = repository.Command{
			ID:        i + 1,
			Command:   "command" + string(rune(i+'0')),
			CreatedAt: time.Now(),
		}
	}
	return commands
}
