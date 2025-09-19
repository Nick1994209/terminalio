package main

import (
	"path/filepath"
	"runtime"
	"terminalio/internal/app"
	"terminalio/internal/repository"

	"github.com/beego/beego/v2/core/logs"
	"github.com/beego/beego/v2/server/web"
)

func main() {
	logs.Info("Starting terminalio application")

	// Initialize database
	repository.InitDB()

	// Configure Beego
	_, filename, _, _ := runtime.Caller(0)
	dir := filepath.Dir(filename)
	web.BConfig.WebConfig.ViewsPath = filepath.Join(dir, "..", "views")
	web.BConfig.WebConfig.StaticDir["/static"] = filepath.Join(dir, "..", "static")
	web.BConfig.WebConfig.TemplateLeft = "{{"
	web.BConfig.WebConfig.TemplateRight = "}}"

	// Initialize routes
	app.InitRoutes()

	// Run the application
	web.Run()
}
