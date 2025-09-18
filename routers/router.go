package routers

import (
	"terminalio/controllers"

	beego "github.com/beego/beego/v2/server/web"
)

func init() {
	// Main page
	beego.Router("/", &controllers.MainController{}, "get:Get")

	// Requests page
	beego.Router("/requests", &controllers.RequestController{}, "get:Get")
	beego.Router("/requests/send", &controllers.RequestController{}, "post:SendRequest")
	beego.Router("/requests/history", &controllers.RequestController{}, "get:History")
	beego.Router("/requests/delete/:id", &controllers.RequestController{}, "post:DeleteRequest")
	beego.Router("/requests/resend/:id", &controllers.RequestController{}, "post:ResendRequest")
	beego.Router("/requests/clear-history", &controllers.RequestController{}, "post:ClearHistory")

	// Terminal page
	beego.Router("/terminal", &controllers.TerminalController{}, "get:Get")

	// WebSocket for terminal
	beego.Router("/ws/terminal", &controllers.TerminalController{}, "get:WebSocket")
}
