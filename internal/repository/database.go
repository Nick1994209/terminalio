package repository

import (
	"database/sql"
	"log"
	"os"
	"path/filepath"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

var DB *sql.DB

type Request struct {
	ID              int       `json:"id"`
	URL             string    `json:"url"`
	Method          string    `json:"method"`
	Headers         string    `json:"headers"`
	Cookies         string    `json:"cookies"`
	GetParams       string    `json:"get_params"`
	Body            string    `json:"body"`
	Timeout         int       `json:"timeout"`
	AllowRedirects  bool      `json:"allow_redirects"`
	VerifySSL       bool      `json:"verify_ssl"`
	RequestTime     time.Time `json:"request_time"`
	ResponseTime    time.Time `json:"response_time"`
	ResponseStatus  int       `json:"response_status"`
	ResponseBody    string    `json:"response_body"`
	ResponseHeaders string    `json:"response_headers"`
}

type Command struct {
	ID        int       `json:"id"`
	Command   string    `json:"command"`
	CreatedAt time.Time `json:"created_at"`
}

// RequestRepository defines the interface for request-related database operations
type RequestRepository interface {
	CreateRequest(req *Request) error
	GetRecentRequests(limit int) ([]Request, error)
	GetRequestsByFilter(urlFilter, methodFilter string, limit int) ([]Request, error)
	DeleteRequest(id int) error
	GetRequestByID(id int) (*Request, error)
	UpdateRequest(req *Request) error
}

// DatabaseRequestRepository implements RequestRepository interface
type DatabaseRequestRepository struct{}

// CreateRequest saves a new request to the database
func (r *DatabaseRequestRepository) CreateRequest(req *Request) error {
	stmt, err := DB.Prepare(`INSERT INTO requests(url, method, headers, cookies, get_params, body, timeout, allow_redirects, verify_ssl, request_time, response_time, response_status, response_body, response_headers) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()

	_, err = stmt.Exec(
		req.URL,
		req.Method,
		req.Headers,
		req.Cookies,
		req.GetParams,
		req.Body,
		req.Timeout,
		req.AllowRedirects,
		req.VerifySSL,
		req.RequestTime,
		req.ResponseTime,
		req.ResponseStatus,
		req.ResponseBody,
		req.ResponseHeaders,
	)
	return err
}

// GetRecentRequests retrieves the most recent requests from the database
func (r *DatabaseRequestRepository) GetRecentRequests(limit int) ([]Request, error) {
	query := "SELECT id, url, method, request_time, response_status FROM requests ORDER BY request_time DESC LIMIT ?"
	rows, err := DB.Query(query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var requests []Request
	for rows.Next() {
		var req Request
		err := rows.Scan(
			&req.ID,
			&req.URL,
			&req.Method,
			&req.RequestTime,
			&req.ResponseStatus,
		)
		if err != nil {
			return nil, err
		}
		requests = append(requests, req)
	}

	return requests, nil
}

// GetRequestsByFilter retrieves requests based on filters
func (r *DatabaseRequestRepository) GetRequestsByFilter(urlFilter, methodFilter string, limit int) ([]Request, error) {
	// Build query with filters
	query := "SELECT id, url, method, headers, cookies, get_params, body, timeout, allow_redirects, verify_ssl, request_time, response_time, response_status FROM requests WHERE 1=1"
	args := []interface{}{}

	if urlFilter != "" {
		query += " AND url LIKE ?"
		args = append(args, "%"+urlFilter+"%")
	}

	if methodFilter != "" {
		query += " AND method = ?"
		args = append(args, methodFilter)
	}

	query += " ORDER BY request_time DESC LIMIT ?"
	args = append(args, limit)

	rows, err := DB.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var requests []Request
	for rows.Next() {
		var req Request
		err := rows.Scan(
			&req.ID,
			&req.URL,
			&req.Method,
			&req.Headers,
			&req.Cookies,
			&req.GetParams,
			&req.Body,
			&req.Timeout,
			&req.AllowRedirects,
			&req.VerifySSL,
			&req.RequestTime,
			&req.ResponseTime,
			&req.ResponseStatus,
		)
		if err != nil {
			return nil, err
		}
		requests = append(requests, req)
	}

	return requests, nil
}

// DeleteRequest deletes a request by ID
func (r *DatabaseRequestRepository) DeleteRequest(id int) error {
	_, err := DB.Exec("DELETE FROM requests WHERE id = ?", id)
	return err
}

// GetRequestByID retrieves a request by its ID
func (r *DatabaseRequestRepository) GetRequestByID(id int) (*Request, error) {
	row := DB.QueryRow("SELECT url, method, headers, cookies, get_params, body, timeout, allow_redirects, verify_ssl FROM requests WHERE id = ?", id)

	var req Request
	err := row.Scan(
		&req.URL,
		&req.Method,
		&req.Headers,
		&req.Cookies,
		&req.GetParams,
		&req.Body,
		&req.Timeout,
		&req.AllowRedirects,
		&req.VerifySSL,
	)

	if err != nil {
		return nil, err
	}

	return &req, nil
}

// UpdateRequest updates an existing request in the database
func (r *DatabaseRequestRepository) UpdateRequest(req *Request) error {
	stmt, err := DB.Prepare(`UPDATE requests SET url=?, method=?, headers=?, cookies=?, get_params=?, body=?, timeout=?, allow_redirects=?, verify_ssl=?, request_time=?, response_time=?, response_status=?, response_body=?, response_headers=? WHERE id=?`)
	if err != nil {
		return err
	}
	defer stmt.Close()

	_, err = stmt.Exec(
		req.URL,
		req.Method,
		req.Headers,
		req.Cookies,
		req.GetParams,
		req.Body,
		req.Timeout,
		req.AllowRedirects,
		req.VerifySSL,
		req.RequestTime,
		req.ResponseTime,
		req.ResponseStatus,
		req.ResponseBody,
		req.ResponseHeaders,
		req.ID,
	)
	return err
}

// GetDB returns the database connection
func GetDB() *sql.DB {
	return DB
}

func InitDB() {
	var err error
	// Use environment variable for database path, fallback to default if not set
	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		// Get the directory of the current executable
		ex, err := os.Executable()
		if err != nil {
			log.Fatal(err)
		}
		exPath := filepath.Dir(ex)
		dbPath = filepath.Join(exPath, "requests.db")
	}

	DB, err = sql.Open("sqlite3", dbPath)
	if err != nil {
		log.Fatal(err)
	}

	// Create requests table
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

	_, err = DB.Exec(createRequestsTable)
	if err != nil {
		log.Fatal(err)
	}

	// Create commands table
	createCommandsTable := `
	CREATE TABLE IF NOT EXISTS commands (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		command TEXT NOT NULL,
		created_at DATETIME DEFAULT CURRENT_TIMESTAMP
	);`

	_, err = DB.Exec(createCommandsTable)
	if err != nil {
		log.Fatal(err)
	}
}

// CommandRepository defines the interface for command-related database operations
type CommandRepository interface {
	CreateCommand(cmd *Command) error
	GetRecentCommands(limit int) ([]Command, error)
	DeleteAllCommands() error
}

// DatabaseCommandRepository implements CommandRepository interface
type DatabaseCommandRepository struct{}

// CreateCommand saves a new command to the database
func (r *DatabaseCommandRepository) CreateCommand(cmd *Command) error {
	stmt, err := DB.Prepare("INSERT INTO commands(command, created_at) VALUES(?, datetime('now'))")
	if err != nil {
		return err
	}
	defer stmt.Close()

	_, err = stmt.Exec(cmd.Command)
	return err
}

// GetRecentCommands retrieves the most recent commands from the database
func (r *DatabaseCommandRepository) GetRecentCommands(limit int) ([]Command, error) {
	query := "SELECT command FROM commands ORDER BY created_at DESC LIMIT ?"
	rows, err := DB.Query(query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var commands []Command
	for rows.Next() {
		var cmd Command
		err := rows.Scan(&cmd.Command)
		if err != nil {
			return nil, err
		}
		commands = append(commands, cmd)
	}

	return commands, nil
}

// DeleteAllCommands deletes all commands from the database
func (r *DatabaseCommandRepository) DeleteAllCommands() error {
	_, err := DB.Exec("DELETE FROM commands")
	return err
}
