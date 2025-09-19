package routers

import (
	"terminalio/internal/delivery"

	beego "github.com/beego/beego/v2/server/web"
)

func init() {
	// Main page
	beego.Router("/", &delivery.MainController{}, "get:Get")

	// Requests page
	beego.Router("/requests", &delivery.RequestController{}, "get:Get")
	beego.Router("/requests/send", &delivery.RequestController{}, "post:SendRequest")
	beego.Router("/requests/history", &delivery.RequestController{}, "get:History")
	beego.Router("/requests/delete/:id", &delivery.RequestController{}, "post:DeleteRequest")
	beego.Router("/requests/resend/:id", &delivery.RequestController{}, "post:ResendRequest")
	beego.Router("/requests/clear-history", &delivery.RequestController{}, "post:ClearHistory")

	// Terminal page
	beego.Router("/terminal", &delivery.TerminalController{}, "get:Get")

	// WebSocket for terminal
	beego.Router("/ws/terminal", &delivery.TerminalController{}, "get:WebSocket")
}
