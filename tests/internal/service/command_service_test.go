package service

import (
	"errors"
	"testing"
	"time"

	"terminalio/internal/repository"
	"terminalio/internal/service"
	"terminalio/tests/mocks"
)

// createTestCommand creates a sample command for testing
func createTestCommand() *repository.Command {
	return &repository.Command{
		ID:        1,
		Command:   "ls -la",
		CreatedAt: time.Now(),
	}
}

// createTestCommands creates a slice of sample commands for testing
func createTestCommands(count int) []repository.Command {
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

func TestCommandService_CreateCommand(t *testing.T) {
	// Test successful creation
	t.Run("Successful creation", func(t *testing.T) {
		mockRepo := &mocks.MockCommandRepository{
			CreateCommandFunc: func(cmd *repository.Command) error {
				return nil
			},
		}

		svc := service.NewCommandService(mockRepo)
		command := createTestCommand()

		err := svc.CreateCommand(command)
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
	})

	// Test error handling
	t.Run("Error handling", func(t *testing.T) {
		expectedErr := errors.New("database error")
		mockRepo := &mocks.MockCommandRepository{
			CreateCommandFunc: func(cmd *repository.Command) error {
				return expectedErr
			},
		}

		svc := service.NewCommandService(mockRepo)
		command := createTestCommand()

		err := svc.CreateCommand(command)
		if err == nil {
			t.Error("Expected error, got nil")
		}
		if err != expectedErr {
			t.Errorf("Expected error %v, got %v", expectedErr, err)
		}
	})
}

func TestCommandService_GetRecentCommands(t *testing.T) {
	// Test successful retrieval
	t.Run("Successful retrieval", func(t *testing.T) {
		expectedCommands := createTestCommands(5)
		mockRepo := &mocks.MockCommandRepository{
			GetRecentCommandsFunc: func(limit int) ([]repository.Command, error) {
				return expectedCommands, nil
			},
		}

		svc := service.NewCommandService(mockRepo)

		commands, err := svc.GetRecentCommands(5)
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		if len(commands) != len(expectedCommands) {
			t.Errorf("Expected %d commands, got %d", len(expectedCommands), len(commands))
		}
	})

	// Test error handling
	t.Run("Error handling", func(t *testing.T) {
		expectedErr := errors.New("database error")
		mockRepo := &mocks.MockCommandRepository{
			GetRecentCommandsFunc: func(limit int) ([]repository.Command, error) {
				return nil, expectedErr
			},
		}

		svc := service.NewCommandService(mockRepo)

		commands, err := svc.GetRecentCommands(5)
		if err == nil {
			t.Error("Expected error, got nil")
		}
		if err != expectedErr {
			t.Errorf("Expected error %v, got %v", expectedErr, err)
		}
		if commands != nil {
			t.Error("Expected nil commands, got non-nil")
		}
	})
}

func TestCommandService_DeleteAllCommands(t *testing.T) {
	// Test successful deletion
	t.Run("Successful deletion", func(t *testing.T) {
		mockRepo := &mocks.MockCommandRepository{
			DeleteAllCommandsFunc: func() error {
				return nil
			},
		}

		svc := service.NewCommandService(mockRepo)

		err := svc.DeleteAllCommands()
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
	})

	// Test error handling
	t.Run("Error handling", func(t *testing.T) {
		expectedErr := errors.New("database error")
		mockRepo := &mocks.MockCommandRepository{
			DeleteAllCommandsFunc: func() error {
				return expectedErr
			},
		}

		svc := service.NewCommandService(mockRepo)

		err := svc.DeleteAllCommands()
		if err == nil {
			t.Error("Expected error, got nil")
		}
		if err != expectedErr {
			t.Errorf("Expected error %v, got %v", expectedErr, err)
		}
	})
}
