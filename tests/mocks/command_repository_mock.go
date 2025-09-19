package mocks

import (
	"terminalio/internal/repository"
)

// MockCommandRepository is a mock implementation of CommandRepository interface
type MockCommandRepository struct {
	CreateCommandFunc     func(cmd *repository.Command) error
	GetRecentCommandsFunc func(limit int) ([]repository.Command, error)
	DeleteAllCommandsFunc func() error
}

// CreateCommand is a mock implementation
func (m *MockCommandRepository) CreateCommand(cmd *repository.Command) error {
	if m.CreateCommandFunc != nil {
		return m.CreateCommandFunc(cmd)
	}
	return nil
}

// GetRecentCommands is a mock implementation
func (m *MockCommandRepository) GetRecentCommands(limit int) ([]repository.Command, error) {
	if m.GetRecentCommandsFunc != nil {
		return m.GetRecentCommandsFunc(limit)
	}
	return []repository.Command{}, nil
}

// DeleteAllCommands is a mock implementation
func (m *MockCommandRepository) DeleteAllCommands() error {
	if m.DeleteAllCommandsFunc != nil {
		return m.DeleteAllCommandsFunc()
	}
	return nil
}
