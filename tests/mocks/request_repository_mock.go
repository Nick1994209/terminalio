package mocks

import (
	"terminalio/internal/repository"
)

// MockRequestRepository is a mock implementation of RequestRepository interface
type MockRequestRepository struct {
	CreateRequestFunc       func(req *repository.Request) error
	GetRecentRequestsFunc   func(limit int) ([]repository.Request, error)
	GetRequestsByFilterFunc func(urlFilter, methodFilter string, limit int) ([]repository.Request, error)
	DeleteRequestFunc       func(id int) error
	GetRequestByIDFunc      func(id int) (*repository.Request, error)
	UpdateRequestFunc       func(req *repository.Request) error
}

// CreateRequest is a mock implementation
func (m *MockRequestRepository) CreateRequest(req *repository.Request) error {
	if m.CreateRequestFunc != nil {
		return m.CreateRequestFunc(req)
	}
	return nil
}

// GetRecentRequests is a mock implementation
func (m *MockRequestRepository) GetRecentRequests(limit int) ([]repository.Request, error) {
	if m.GetRecentRequestsFunc != nil {
		return m.GetRecentRequestsFunc(limit)
	}
	return []repository.Request{}, nil
}

// GetRequestsByFilter is a mock implementation
func (m *MockRequestRepository) GetRequestsByFilter(urlFilter, methodFilter string, limit int) ([]repository.Request, error) {
	if m.GetRequestsByFilterFunc != nil {
		return m.GetRequestsByFilterFunc(urlFilter, methodFilter, limit)
	}
	return []repository.Request{}, nil
}

// DeleteRequest is a mock implementation
func (m *MockRequestRepository) DeleteRequest(id int) error {
	if m.DeleteRequestFunc != nil {
		return m.DeleteRequestFunc(id)
	}
	return nil
}

// GetRequestByID is a mock implementation
func (m *MockRequestRepository) GetRequestByID(id int) (*repository.Request, error) {
	if m.GetRequestByIDFunc != nil {
		return m.GetRequestByIDFunc(id)
	}
	return &repository.Request{}, nil
}

// UpdateRequest is a mock implementation
func (m *MockRequestRepository) UpdateRequest(req *repository.Request) error {
	if m.UpdateRequestFunc != nil {
		return m.UpdateRequestFunc(req)
	}
	return nil
}
