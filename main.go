package main

import (
	"terminalio/models"
	_ "terminalio/routers"

	"github.com/beego/beego/v2/core/logs"
	"github.com/beego/beego/v2/server/web"
)

func main() {
	logs.Info("Starting terminalio application")

	// Initialize database
	models.InitDB()

	// Configure Beego
	web.BConfig.WebConfig.ViewsPath = "views"
	web.BConfig.WebConfig.StaticDir["/static"] = "static"
	web.BConfig.WebConfig.TemplateLeft = "{{"
	web.BConfig.WebConfig.TemplateRight = "}}"

	// Run the application
	web.Run()
}
