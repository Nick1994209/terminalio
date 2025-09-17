package models

import (
	"database/sql"
	"log"
	"os"
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

func InitDB() {
	var err error
	// Use environment variable for database path, fallback to default if not set
	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = "./requests.db"
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
