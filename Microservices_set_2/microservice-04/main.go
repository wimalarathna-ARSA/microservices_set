package main

import (
	"context"
	"fmt"
	"log"
	"math"
	"net/http"
	"os"
	"os/signal"
	"runtime"
	"strconv"
	"sync/atomic"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
)

var (
	incomingRequests   int64
	processingRequests int64
	startTime          time.Time
)

func main() {
	startTime = time.Now()

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

	if os.Getenv("GIN_MODE") == "" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()

	r.Use(func(c *gin.Context) {
		atomic.AddInt64(&incomingRequests, 1)
		defer atomic.AddInt64(&processingRequests, 1)
		c.Next()
	})

	r.GET("/", func(c *gin.Context) {
		c.String(http.StatusOK, "Hello from Microservice 04 (Go Gin) - Deployed on Render")
	})

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "healthy",
			"service":   serviceName,
			"platform":  platform,
			"uptime":    time.Since(startTime).String(),
			"timestamp": time.Now().UTC().Format(time.RFC3339),
		})
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

		numCPU := runtime.NumCPU()
		numGoroutine := runtime.NumGoroutine()
		cpuEst := math.Min(100.0, float64(numGoroutine)*5.0)

		var m runtime.MemStats
		runtime.ReadMemStats(&m)

		c.JSON(http.StatusOK, gin.H{
			"platform":            platform,
			"service":             serviceName,
			"timestamp":           time.Now().UTC().Format(time.RFC3339),
			"uptime":              time.Since(startTime).String(),
			"cpu_usage_percent":   math.Round(cpuEst*100) / 100,
			"memory_usage_mb":     math.Round(float64(m.Alloc)/1024/1024*100) / 100,
			"incoming_requests":   inc,
			"processing_requests": proc,
			"queue_length":        queue,
			"measurement_method":  "application_runtime",
			"cpu_allocation":      fmt.Sprintf("%dvCPU", numCPU),
			"goroutines":          numGoroutine,
		})
	})

	srv := &http.Server{
		Addr:    ":" + port,
		Handler: r,
	}

	go func() {
		log.Printf("Microservice 04 starting on port %s (platform: %s)", port, platform)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start server: %s", err)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("Server forced to shutdown: ", err)
	}

	log.Println("Server exiting")
}