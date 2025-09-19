package service

import (
	"terminalio/internal/repository"
)

// RequestService defines the interface for request-related operations
type RequestService interface {
	CreateRequest(req *repository.Request) error
	GetRecentRequests(limit int) ([]repository.Request, error)
	GetRequestsByFilter(urlFilter, methodFilter string, limit int) ([]repository.Request, error)
	DeleteRequest(id int) error
	GetRequestByID(id int) (*repository.Request, error)
}

// requestService implements RequestService interface
type requestService struct {
	repo repository.RequestRepository
}

// NewRequestService creates a new instance of RequestService
func NewRequestService(repo repository.RequestRepository) RequestService {
	return &requestService{repo: repo}
}

// CreateRequest saves a new request to the database
func (s *requestService) CreateRequest(req *repository.Request) error {
	return s.repo.CreateRequest(req)
}

// GetRecentRequests retrieves the most recent requests from the database
func (s *requestService) GetRecentRequests(limit int) ([]repository.Request, error) {
	return s.repo.GetRecentRequests(limit)
}

// GetRequestsByFilter retrieves requests based on filters
func (s *requestService) GetRequestsByFilter(urlFilter, methodFilter string, limit int) ([]repository.Request, error) {
	return s.repo.GetRequestsByFilter(urlFilter, methodFilter, limit)
}

// DeleteRequest deletes a request by ID
func (s *requestService) DeleteRequest(id int) error {
	return s.repo.DeleteRequest(id)
}

// GetRequestByID retrieves a request by its ID
func (s *requestService) GetRequestByID(id int) (*repository.Request, error) {
	return s.repo.GetRequestByID(id)
}
