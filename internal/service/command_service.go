package service

import (
	"terminalio/internal/repository"
)

// CommandService defines the interface for command-related operations
type CommandService interface {
	CreateCommand(cmd *repository.Command) error
	GetRecentCommands(limit int) ([]repository.Command, error)
	DeleteAllCommands() error
}

// commandService implements CommandService interface
type commandService struct {
	repo repository.CommandRepository
}

// NewCommandService creates a new instance of CommandService
func NewCommandService(repo repository.CommandRepository) CommandService {
	return &commandService{repo: repo}
}

// CreateCommand saves a new command to the database
func (s *commandService) CreateCommand(cmd *repository.Command) error {
	return s.repo.CreateCommand(cmd)
}

// GetRecentCommands retrieves the most recent commands from the database
func (s *commandService) GetRecentCommands(limit int) ([]repository.Command, error) {
	return s.repo.GetRecentCommands(limit)
}

// DeleteAllCommands deletes all commands from the database
func (s *commandService) DeleteAllCommands() error {
	return s.repo.DeleteAllCommands()
}
