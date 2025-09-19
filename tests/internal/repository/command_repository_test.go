package repository

import (
	"testing"
	"time"

	"terminalio/internal/repository"

	_ "github.com/mattn/go-sqlite3"
)

// createTestCommand creates a sample command for testing
func createTestCommand() *repository.Command {
	return &repository.Command{
		ID:        1,
		Command:   "ls -la",
		CreatedAt: time.Now(),
	}
}

func TestDatabaseCommandRepository_CreateCommand(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	// Set the global DB variable for testing
	oldDB := repository.DB
	repository.DB = db
	defer func() { repository.DB = oldDB }()

	repo := &repository.DatabaseCommandRepository{}
	command := createTestCommand()

	err := repo.CreateCommand(command)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}

	// Verify the command was saved
	var count int
	err = db.QueryRow("SELECT COUNT(*) FROM commands").Scan(&count)
	if err != nil {
		t.Errorf("Failed to count commands: %v", err)
	}
	if count != 1 {
		t.Errorf("Expected 1 command, got %d", count)
	}
}

func TestDatabaseCommandRepository_GetRecentCommands(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	// Set the global DB variable for testing
	oldDB := repository.DB
	repository.DB = db
	defer func() { repository.DB = oldDB }()

	repo := &repository.DatabaseCommandRepository{}

	// Insert test data using the repository method to ensure proper timestamps
	command1 := &repository.Command{
		Command: "ls -la",
	}

	command2 := &repository.Command{
		Command: "pwd",
	}

	err := repo.CreateCommand(command1)
	if err != nil {
		t.Fatalf("Failed to create command1: %v", err)
	}

	// Small delay to ensure different timestamps
	time.Sleep(10 * time.Millisecond)

	err = repo.CreateCommand(command2)
	if err != nil {
		t.Fatalf("Failed to create command2: %v", err)
	}

	// Test retrieving recent commands
	commands, err := repo.GetRecentCommands(5)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}
	if len(commands) != 2 {
		t.Errorf("Expected 2 commands, got %d", len(commands))
	}

	// Check that we got the expected commands (order may vary due to timing)
	foundLs := false
	foundPwd := false
	for _, cmd := range commands {
		if cmd.Command == "ls -la" {
			foundLs = true
		}
		if cmd.Command == "pwd" {
			foundPwd = true
		}
	}

	if !foundLs {
		t.Error("Expected to find 'ls -la' command")
	}
	if !foundPwd {
		t.Error("Expected to find 'pwd' command")
	}
}

func TestDatabaseCommandRepository_DeleteAllCommands(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	// Set the global DB variable for testing
	oldDB := repository.DB
	repository.DB = db
	defer func() { repository.DB = oldDB }()

	repo := &repository.DatabaseCommandRepository{}

	// Insert test data
	command1 := &repository.Command{
		Command: "ls -la",
	}

	command2 := &repository.Command{
		Command: "pwd",
	}

	err := repo.CreateCommand(command1)
	if err != nil {
		t.Fatalf("Failed to create command1: %v", err)
	}

	err = repo.CreateCommand(command2)
	if err != nil {
		t.Fatalf("Failed to create command2: %v", err)
	}

	// Verify commands exist
	var count int
	err = db.QueryRow("SELECT COUNT(*) FROM commands").Scan(&count)
	if err != nil {
		t.Fatalf("Failed to count commands: %v", err)
	}
	if count != 2 {
		t.Fatalf("Expected 2 commands, got %d", count)
	}

	// Test deleting all commands
	err = repo.DeleteAllCommands()
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}

	// Verify commands were deleted
	err = db.QueryRow("SELECT COUNT(*) FROM commands").Scan(&count)
	if err != nil {
		t.Fatalf("Failed to count commands: %v", err)
	}
	if count != 0 {
		t.Errorf("Expected 0 commands, got %d", count)
	}
}
