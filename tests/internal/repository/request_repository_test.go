package repository

import (
	"database/sql"
	"testing"
	"time"

	"terminalio/internal/repository"

	_ "github.com/mattn/go-sqlite3"
)

// setupTestDB creates an in-memory database for testing
func setupTestDB(t *testing.T) *sql.DB {
	db, err := sql.Open("sqlite3", ":memory:")
	if err != nil {
		t.Fatalf("Failed to open in-memory database: %v", err)
	}

	// Create tables
	createRequestsTable := `
	CREATE TABLE IF NOT EXISTS requests (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		url TEXT NOT NULL,
		method TEXT NOT NULL DEFAULT 'GET',
		headers TEXT,
		cookies TEXT,
		get_params TEXT,
		body TEXT,
		timeout INTEGER DEFAULT 10,
		allow_redirects BOOLEAN DEFAULT FALSE,
		verify_ssl BOOLEAN DEFAULT TRUE,
		request_time DATETIME,
		response_time DATETIME,
		response_status INTEGER,
		response_body TEXT,
		response_headers TEXT
	);`

	_, err = db.Exec(createRequestsTable)
	if err != nil {
		t.Fatalf("Failed to create requests table: %v", err)
	}

	// Create commands table
	createCommandsTable := `
	CREATE TABLE IF NOT EXISTS commands (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		command TEXT NOT NULL,
		created_at DATETIME DEFAULT CURRENT_TIMESTAMP
	);`

	_, err = db.Exec(createCommandsTable)
	if err != nil {
		t.Fatalf("Failed to create commands table: %v", err)
	}

	return db
}

// createTestRequest creates a sample request for testing
func createTestRequest() *repository.Request {
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

func TestDatabaseRequestRepository_CreateRequest(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	// Set the global DB variable for testing
	oldDB := repository.DB
	repository.DB = db
	defer func() { repository.DB = oldDB }()

	repo := &repository.DatabaseRequestRepository{}
	request := createTestRequest()

	err := repo.CreateRequest(request)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}

	// Verify the request was saved
	var count int
	err = db.QueryRow("SELECT COUNT(*) FROM requests").Scan(&count)
	if err != nil {
		t.Errorf("Failed to count requests: %v", err)
	}
	if count != 1 {
		t.Errorf("Expected 1 request, got %d", count)
	}
}

func TestDatabaseRequestRepository_GetRecentRequests(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	// Set the global DB variable for testing
	oldDB := repository.DB
	repository.DB = db
	defer func() { repository.DB = oldDB }()

	repo := &repository.DatabaseRequestRepository{}

	// Insert test data
	request1 := &repository.Request{
		URL:            "http://example1.com",
		Method:         "GET",
		RequestTime:    time.Now().Add(-time.Hour),
		ResponseStatus: 200,
	}

	request2 := &repository.Request{
		URL:            "http://example2.com",
		Method:         "POST",
		RequestTime:    time.Now(),
		ResponseStatus: 201,
	}

	err := repo.CreateRequest(request1)
	if err != nil {
		t.Fatalf("Failed to create request1: %v", err)
	}

	err = repo.CreateRequest(request2)
	if err != nil {
		t.Fatalf("Failed to create request2: %v", err)
	}

	// Test retrieving recent requests
	requests, err := repo.GetRecentRequests(5)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}
	if len(requests) != 2 {
		t.Errorf("Expected 2 requests, got %d", len(requests))
	}

	// Check that requests are ordered by time (most recent first)
	if requests[0].URL != "http://example2.com" {
		t.Errorf("Expected most recent request first, got %s", requests[0].URL)
	}
}

func TestDatabaseRequestRepository_GetRequestsByFilter(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	// Set the global DB variable for testing
	oldDB := repository.DB
	repository.DB = db
	defer func() { repository.DB = oldDB }()

	repo := &repository.DatabaseRequestRepository{}

	// Insert test data
	request1 := &repository.Request{
		URL:            "http://example.com/api/v1/users",
		Method:         "GET",
		RequestTime:    time.Now(),
		ResponseStatus: 200,
	}

	request2 := &repository.Request{
		URL:            "http://example.com/api/v1/posts",
		Method:         "POST",
		RequestTime:    time.Now(),
		ResponseStatus: 201,
	}

	request3 := &repository.Request{
		URL:            "http://other.com/api/v1/users",
		Method:         "GET",
		RequestTime:    time.Now(),
		ResponseStatus: 200,
	}

	err := repo.CreateRequest(request1)
	if err != nil {
		t.Fatalf("Failed to create request1: %v", err)
	}

	err = repo.CreateRequest(request2)
	if err != nil {
		t.Fatalf("Failed to create request2: %v", err)
	}

	err = repo.CreateRequest(request3)
	if err != nil {
		t.Fatalf("Failed to create request3: %v", err)
	}

	// Test filtering by URL
	requests, err := repo.GetRequestsByFilter("example.com", "", 10)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}
	if len(requests) != 2 {
		t.Errorf("Expected 2 requests with example.com, got %d", len(requests))
	}

	// Test filtering by method
	requests, err = repo.GetRequestsByFilter("", "GET", 10)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}
	if len(requests) != 2 {
		t.Errorf("Expected 2 GET requests, got %d", len(requests))
	}

	// Test filtering by both URL and method
	requests, err = repo.GetRequestsByFilter("example.com", "GET", 10)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}
	if len(requests) != 1 {
		t.Errorf("Expected 1 request with example.com and GET, got %d", len(requests))
	}
}

func TestDatabaseRequestRepository_DeleteRequest(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	// Set the global DB variable for testing
	oldDB := repository.DB
	repository.DB = db
	defer func() { repository.DB = oldDB }()

	repo := &repository.DatabaseRequestRepository{}

	// Insert test data
	request := createTestRequest()
	err := repo.CreateRequest(request)
	if err != nil {
		t.Fatalf("Failed to create request: %v", err)
	}

	// Verify request exists
	var count int
	err = db.QueryRow("SELECT COUNT(*) FROM requests").Scan(&count)
	if err != nil {
		t.Fatalf("Failed to count requests: %v", err)
	}
	if count != 1 {
		t.Fatalf("Expected 1 request, got %d", count)
	}

	// Test deleting request
	err = repo.DeleteRequest(1)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}

	// Verify request was deleted
	err = db.QueryRow("SELECT COUNT(*) FROM requests").Scan(&count)
	if err != nil {
		t.Fatalf("Failed to count requests: %v", err)
	}
	if count != 0 {
		t.Errorf("Expected 0 requests, got %d", count)
	}
}

func TestDatabaseRequestRepository_GetRequestByID(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	// Set the global DB variable for testing
	oldDB := repository.DB
	repository.DB = db
	defer func() { repository.DB = oldDB }()

	repo := &repository.DatabaseRequestRepository{}

	// Insert test data
	request := &repository.Request{
		URL:            "http://example.com",
		Method:         "GET",
		Headers:        "Content-Type: application/json",
		Cookies:        "session=abc123",
		GetParams:      "param1=value1",
		Body:           `{"key": "value"}`,
		Timeout:        30,
		AllowRedirects: true,
		VerifySSL:      true,
	}

	err := repo.CreateRequest(request)
	if err != nil {
		t.Fatalf("Failed to create request: %v", err)
	}

	// Test retrieving request by ID
	retrievedRequest, err := repo.GetRequestByID(1)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}
	if retrievedRequest == nil {
		t.Error("Expected request, got nil")
	}
	if retrievedRequest.URL != "http://example.com" {
		t.Errorf("Expected URL http://example.com, got %s", retrievedRequest.URL)
	}
	if retrievedRequest.Method != "GET" {
		t.Errorf("Expected method GET, got %s", retrievedRequest.Method)
	}
}
