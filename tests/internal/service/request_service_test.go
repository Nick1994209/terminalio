package service

import (
	"errors"
	"testing"
	"time"

	"terminalio/internal/repository"
	"terminalio/internal/service"
	"terminalio/tests/mocks"
)

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

// createTestRequests creates a slice of sample requests for testing
func createTestRequests(count int) []repository.Request {
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

func TestRequestService_CreateRequest(t *testing.T) {
	// Test successful creation
	t.Run("Successful creation", func(t *testing.T) {
		mockRepo := &mocks.MockRequestRepository{
			CreateRequestFunc: func(req *repository.Request) error {
				return nil
			},
		}

		svc := service.NewRequestService(mockRepo)
		request := createTestRequest()

		err := svc.CreateRequest(request)
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
	})

	// Test error handling
	t.Run("Error handling", func(t *testing.T) {
		expectedErr := errors.New("database error")
		mockRepo := &mocks.MockRequestRepository{
			CreateRequestFunc: func(req *repository.Request) error {
				return expectedErr
			},
		}

		svc := service.NewRequestService(mockRepo)
		request := createTestRequest()

		err := svc.CreateRequest(request)
		if err == nil {
			t.Error("Expected error, got nil")
		}
		if err != expectedErr {
			t.Errorf("Expected error %v, got %v", expectedErr, err)
		}
	})
}

func TestRequestService_GetRecentRequests(t *testing.T) {
	// Test successful retrieval
	t.Run("Successful retrieval", func(t *testing.T) {
		expectedRequests := createTestRequests(5)
		mockRepo := &mocks.MockRequestRepository{
			GetRecentRequestsFunc: func(limit int) ([]repository.Request, error) {
				return expectedRequests, nil
			},
		}

		svc := service.NewRequestService(mockRepo)

		requests, err := svc.GetRecentRequests(5)
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		if len(requests) != len(expectedRequests) {
			t.Errorf("Expected %d requests, got %d", len(expectedRequests), len(requests))
		}
	})

	// Test error handling
	t.Run("Error handling", func(t *testing.T) {
		expectedErr := errors.New("database error")
		mockRepo := &mocks.MockRequestRepository{
			GetRecentRequestsFunc: func(limit int) ([]repository.Request, error) {
				return nil, expectedErr
			},
		}

		svc := service.NewRequestService(mockRepo)

		requests, err := svc.GetRecentRequests(5)
		if err == nil {
			t.Error("Expected error, got nil")
		}
		if err != expectedErr {
			t.Errorf("Expected error %v, got %v", expectedErr, err)
		}
		if requests != nil {
			t.Error("Expected nil requests, got non-nil")
		}
	})
}

func TestRequestService_GetRequestsByFilter(t *testing.T) {
	// Test successful filtered retrieval
	t.Run("Successful filtered retrieval", func(t *testing.T) {
		expectedRequests := createTestRequests(3)
		mockRepo := &mocks.MockRequestRepository{
			GetRequestsByFilterFunc: func(urlFilter, methodFilter string, limit int) ([]repository.Request, error) {
				return expectedRequests, nil
			},
		}

		svc := service.NewRequestService(mockRepo)

		requests, err := svc.GetRequestsByFilter("example.com", "GET", 10)
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		if len(requests) != len(expectedRequests) {
			t.Errorf("Expected %d requests, got %d", len(expectedRequests), len(requests))
		}
	})

	// Test error handling
	t.Run("Error handling", func(t *testing.T) {
		expectedErr := errors.New("database error")
		mockRepo := &mocks.MockRequestRepository{
			GetRequestsByFilterFunc: func(urlFilter, methodFilter string, limit int) ([]repository.Request, error) {
				return nil, expectedErr
			},
		}

		svc := service.NewRequestService(mockRepo)

		requests, err := svc.GetRequestsByFilter("example.com", "GET", 10)
		if err == nil {
			t.Error("Expected error, got nil")
		}
		if err != expectedErr {
			t.Errorf("Expected error %v, got %v", expectedErr, err)
		}
		if requests != nil {
			t.Error("Expected nil requests, got non-nil")
		}
	})
}

func TestRequestService_DeleteRequest(t *testing.T) {
	// Test successful deletion
	t.Run("Successful deletion", func(t *testing.T) {
		mockRepo := &mocks.MockRequestRepository{
			DeleteRequestFunc: func(id int) error {
				return nil
			},
		}

		svc := service.NewRequestService(mockRepo)

		err := svc.DeleteRequest(1)
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
	})

	// Test error handling
	t.Run("Error handling", func(t *testing.T) {
		expectedErr := errors.New("database error")
		mockRepo := &mocks.MockRequestRepository{
			DeleteRequestFunc: func(id int) error {
				return expectedErr
			},
		}

		svc := service.NewRequestService(mockRepo)

		err := svc.DeleteRequest(1)
		if err == nil {
			t.Error("Expected error, got nil")
		}
		if err != expectedErr {
			t.Errorf("Expected error %v, got %v", expectedErr, err)
		}
	})
}

func TestRequestService_GetRequestByID(t *testing.T) {
	// Test successful retrieval by ID
	t.Run("Successful retrieval by ID", func(t *testing.T) {
		expectedRequest := createTestRequest()
		mockRepo := &mocks.MockRequestRepository{
			GetRequestByIDFunc: func(id int) (*repository.Request, error) {
				return expectedRequest, nil
			},
		}

		svc := service.NewRequestService(mockRepo)

		request, err := svc.GetRequestByID(1)
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		if request == nil {
			t.Error("Expected request, got nil")
		}
	})

	// Test error handling
	t.Run("Error handling", func(t *testing.T) {
		expectedErr := errors.New("database error")
		mockRepo := &mocks.MockRequestRepository{
			GetRequestByIDFunc: func(id int) (*repository.Request, error) {
				return nil, expectedErr
			},
		}

		svc := service.NewRequestService(mockRepo)

		request, err := svc.GetRequestByID(1)
		if err == nil {
			t.Error("Expected error, got nil")
		}
		if err != expectedErr {
			t.Errorf("Expected error %v, got %v", expectedErr, err)
		}
		if request != nil {
			t.Error("Expected nil request, got non-nil")
		}
	})
}
