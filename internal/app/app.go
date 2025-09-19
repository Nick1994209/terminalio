package app

import (
	"terminalio/internal/delivery"
	"terminalio/internal/repository"
	"terminalio/internal/service"

	beego "github.com/beego/beego/v2/server/web"
)

// InitRoutes initializes all application routes
func InitRoutes() {
	// Initialize repositories
	requestRepo := &repository.DatabaseRequestRepository{}
	commandRepo := &repository.DatabaseCommandRepository{}

	// Initialize services
	requestService := service.NewRequestService(requestRepo)
	commandService := service.NewCommandService(commandRepo)

	// Initialize controllers with their dependencies
	mainController := &delivery.MainController{}
	requestController := &delivery.RequestController{
		RequestService: requestService,
	}
	terminalController := &delivery.TerminalController{
		CommandService: commandService,
	}

	// Register routes
	beego.Router("/", mainController, "get:Get")
	beego.Router("/requests", requestController, "get:Get")
	beego.Router("/requests/send", requestController, "post:SendRequest")
	beego.Router("/requests/history", requestController, "get:History")
	beego.Router("/requests/delete/:id", requestController, "post:DeleteRequest")
	beego.Router("/requests/resend/:id", requestController, "post:ResendRequest")
	beego.Router("/requests/clear-history", requestController, "post:ClearHistory")
	beego.Router("/terminal", terminalController, "get:Get")
	beego.Router("/ws/terminal", terminalController, "get:WebSocket")
}
