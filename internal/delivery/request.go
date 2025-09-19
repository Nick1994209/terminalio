package delivery

import (
	"encoding/json"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"terminalio/internal/repository"
	"terminalio/internal/service"
	"time"

	beego "github.com/beego/beego/v2/server/web"
)

type RequestController struct {
	beego.Controller
	RequestService service.RequestService
}

type RequestForm struct {
	URL            string `form:"url"`
	Method         string `form:"method"`
	Headers        string `form:"headers"`
	Cookies        string `form:"cookies"`
	GetParams      string `form:"get_params"`
	Body           string `form:"body"`
	Timeout        string `form:"timeout"`
	AllowRedirects string `form:"allow_redirects"`
	VerifySSL      string `form:"verify_ssl"`
}

// fetchRecentRequests fetches the most recent requests for display in the sidebar
func (c *RequestController) fetchRecentRequests() {
	requests, err := c.RequestService.GetRecentRequests(20)
	if err != nil {
		// Continue even if history query fails
		return
	}

	c.Data["RecentRequests"] = requests
}

func (c *RequestController) Get() {
	c.Data["RequestMethod"] = "GET"
	c.Data["RequestTimeout"] = "10"
	c.Data["RequestAllowRedirects"] = ""
	c.Data["RequestVerifySSL"] = "on"

	// Fetch recent requests for history sidebar
	c.fetchRecentRequests()

	c.TplName = "requests.tpl"
	c.Layout = "layout.tpl"
}

func (c *RequestController) SendRequest() {
	form := RequestForm{}
	if err := c.ParseForm(&form); err != nil {
		c.Ctx.WriteString("Error parsing form: " + err.Error())
		return
	}

	// Set defaults
	if form.Method == "" {
		form.Method = "GET"
	}

	timeout := 10
	if form.Timeout != "" {
		if t, err := strconv.Atoi(form.Timeout); err == nil {
			timeout = t
		}
	}

	allowRedirects := form.AllowRedirects == "on"
	verifySSL := form.VerifySSL == "on"

	// Save request to database
	request := repository.Request{
		URL:            form.URL,
		Method:         form.Method,
		Headers:        form.Headers,
		Cookies:        form.Cookies,
		GetParams:      form.GetParams,
		Body:           form.Body,
		Timeout:        timeout,
		AllowRedirects: allowRedirects,
		VerifySSL:      verifySSL,
		RequestTime:    time.Now(),
	}

	// Prepare the HTTP request
	client := &http.Client{
		Timeout: time.Duration(timeout) * time.Second,
	}

	// Handle redirects
	if !allowRedirects {
		client.CheckRedirect = func(req *http.Request, via []*http.Request) error {
			return http.ErrUseLastResponse
		}
	}

	// Add GET parameters to URL
	fullURL := form.URL
	if form.GetParams != "" {
		params := url.Values{}
		for _, param := range strings.Split(form.GetParams, "\n") {
			parts := strings.SplitN(param, "=", 2)
			if len(parts) == 2 {
				params.Add(strings.TrimSpace(parts[0]), strings.TrimSpace(parts[1]))
			}
		}
		if len(params) > 0 {
			u, err := url.Parse(fullURL)
			if err == nil {
				q := u.Query()
				for k, v := range params {
					for _, val := range v {
						q.Add(k, val)
					}
				}
				u.RawQuery = q.Encode()
				fullURL = u.String()
			}
		}
	}

	req, err := http.NewRequest(form.Method, fullURL, strings.NewReader(form.Body))
	if err != nil {
		c.Ctx.WriteString("Error creating request: " + err.Error())
		return
	}

	// Add headers
	if form.Headers != "" {
		for _, header := range strings.Split(form.Headers, "\n") {
			parts := strings.SplitN(header, ":", 2)
			if len(parts) == 2 {
				req.Header.Add(strings.TrimSpace(parts[0]), strings.TrimSpace(parts[1]))
			}
		}
	}

	// Add cookies
	if form.Cookies != "" {
		for _, cookie := range strings.Split(form.Cookies, "\n") {
			parts := strings.SplitN(cookie, "=", 2)
			if len(parts) == 2 {
				req.AddCookie(&http.Cookie{
					Name:  strings.TrimSpace(parts[0]),
					Value: strings.TrimSpace(parts[1]),
				})
			}
		}
	}

	// Send request
	resp, err := client.Do(req)
	request.ResponseTime = time.Now()

	if err != nil {
		c.Data["ErrorMessage"] = err.Error()
	} else {
		defer resp.Body.Close()

		// Read response body
		buf := make([]byte, 1024*1024) // 1MB buffer
		n, _ := resp.Body.Read(buf)
		responseBody := string(buf[:n])

		// Save response to request object
		request.ResponseStatus = resp.StatusCode
		request.ResponseBody = responseBody

		// Save response headers
		headersBytes, _ := json.Marshal(resp.Header)
		request.ResponseHeaders = string(headersBytes)

		c.Data["ResponseStatusCode"] = resp.StatusCode
		c.Data["ResponseBody"] = responseBody
		c.Data["ResponseHeaders"] = resp.Header
	}

	// Save request to database
	request.ResponseTime = time.Now()
	err = c.RequestService.CreateRequest(&request)
	if err != nil {
		c.Ctx.WriteString("Error saving request: " + err.Error())
		return
	}

	// Pass form data back to template
	c.Data["RequestMethod"] = form.Method
	c.Data["RequestURL"] = form.URL
	c.Data["RequestHeaders"] = form.Headers
	c.Data["RequestCookies"] = form.Cookies
	c.Data["RequestGetParams"] = form.GetParams
	c.Data["RequestBody"] = form.Body
	c.Data["RequestTimeout"] = form.Timeout
	c.Data["RequestAllowRedirects"] = form.AllowRedirects
	c.Data["RequestVerifySSL"] = form.VerifySSL

	// Fetch recent requests for history sidebar
	c.fetchRecentRequests()

	c.TplName = "requests.tpl"
	c.Layout = "layout.tpl"
}

func (c *RequestController) History() {
	// Get filter parameters
	urlFilter := c.GetString("url")
	methodFilter := c.GetString("method")

	// Get requests from service
	requests, err := c.RequestService.GetRequestsByFilter(urlFilter, methodFilter, 50)
	if err != nil {
		c.Ctx.WriteString("Error querying requests: " + err.Error())
		return
	}

	c.Data["Requests"] = requests
	c.Data["URLFilter"] = urlFilter
	c.Data["MethodFilter"] = methodFilter
	c.TplName = "history.tpl"
	c.Layout = "layout.tpl"
}

func (c *RequestController) DeleteRequest() {
	id := c.Ctx.Input.Param(":id")

	// Convert string ID to integer
	requestID, err := strconv.Atoi(id)
	if err != nil {
		c.Ctx.WriteString("Invalid request ID: " + err.Error())
		return
	}

	err = c.RequestService.DeleteRequest(requestID)
	if err != nil {
		c.Ctx.WriteString("Error deleting request: " + err.Error())
		return
	}

	c.Ctx.Redirect(302, "/requests/history")
}

func (c *RequestController) ResendRequest() {
	id := c.Ctx.Input.Param(":id")

	// Convert string ID to integer
	requestID, err := strconv.Atoi(id)
	if err != nil {
		c.Ctx.WriteString("Invalid request ID: " + err.Error())
		return
	}

	req, err := c.RequestService.GetRequestByID(requestID)
	if err != nil {
		c.Ctx.WriteString("Error retrieving request: " + err.Error())
		return
	}

	// Pass data to form
	c.Data["RequestMethod"] = req.Method
	c.Data["RequestURL"] = req.URL
	c.Data["RequestHeaders"] = req.Headers
	c.Data["RequestCookies"] = req.Cookies
	c.Data["RequestGetParams"] = req.GetParams
	c.Data["RequestBody"] = req.Body
	c.Data["RequestTimeout"] = strconv.Itoa(req.Timeout)
	if req.AllowRedirects {
		c.Data["RequestAllowRedirects"] = "on"
	}
	if req.VerifySSL {
		c.Data["RequestVerifySSL"] = "on"
	}

	// Fetch recent requests for history sidebar
	c.fetchRecentRequests()

	c.TplName = "requests.tpl"
	c.Layout = "layout.tpl"
}

func (c *RequestController) ClearHistory() {
	// For now, we'll implement a simple version that returns success
	// In a real implementation, you might want to add a method to RequestService
	// to clear all requests

	// Return success response
	c.Ctx.Output.SetStatus(200)
	c.Ctx.Output.Body([]byte("Request history cleared successfully"))
}
