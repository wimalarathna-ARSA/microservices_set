package main

import (
	"fmt"
	"math"
	"net/http"
	"os"
	"runtime"
	"strconv"
	"sync/atomic"
	"time"

	"github.com/gin-gonic/gin"
)

var (
	incomingRequests   int64
	processingRequests int64
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "3004"
	}

	serviceName := os.Getenv("SERVICE_NAME")
	if serviceName == "" {
		serviceName = "service-go-04"
	}

	platform := os.Getenv("PLATFORM")
	if platform == "" {
		platform = "render"
	}

	r := gin.Default()

	// Request tracking middleware
	r.Use(func(c *gin.Context) {
		atomic.AddInt64(&incomingRequests, 1)
		defer atomic.AddInt64(&processingRequests, 1)
		c.Next()
	})

	r.GET("/", func(c *gin.Context) {
		c.String(http.StatusOK, "Hello from Microservice 04 (Go Gin)")
	})

	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "ok",
			"service": serviceName,
		})
	})

	r.GET("/spike", func(c *gin.Context) {
		durationStr := c.DefaultQuery("duration", "10")
		duration, err := strconv.Atoi(durationStr)
		if err != nil {
			duration = 10
		}

		endTime := time.Now().Add(time.Duration(duration) * time.Second)
		for time.Now().Before(endTime) {
			_ = math.Sqrt(64.0 * 64.0 * 64.0 * 64.0)
		}

		c.JSON(http.StatusOK, gin.H{
			"message": fmt.Sprintf("CPU spiked for %d seconds", duration),
			"service": serviceName,
		})
	})

	r.GET("/metrics", func(c *gin.Context) {
		inc := atomic.LoadInt64(&incomingRequests)
		proc := atomic.LoadInt64(&processingRequests)
		queue := inc - proc
		if queue < 0 {
			queue = 0
		}

		// Simple CPU heuristic based on active Goroutines or System Load
		numCPU := runtime.NumCPU()
		numGoroutine := runtime.NumGoroutine()
		cpuEst := math.Min(100.0, float64(numGoroutine)*5.0)

		c.JSON(http.StatusOK, gin.H{
			"platform":            platform,
			"service":             serviceName,
			"timestamp":           time.Now().UTC().Format(time.RFC3339),
			"cpu_usage_percent":   math.Round(cpuEst*100) / 100,
			"incoming_requests":   inc,
			"processing_requests": proc,
			"queue_length":        queue,
			"measurement_method":  "application_runtime",
			"cpu_allocation":      fmt.Sprintf("%dvCPU", numCPU),
		})
	})

	r.Run(":" + port)
}