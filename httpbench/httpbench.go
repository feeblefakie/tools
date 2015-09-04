package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"runtime"
	"strconv"
	"strings"
	"time"
)

var (
	file        = flag.String("file", "", "a file which has list of URLs to be accessed")
	tmpfile     = "/tmp/" + strconv.FormatInt(int64(os.Getpid()), 10) + ".err"
	efile       = flag.String("error_to", tmpfile, "a file for error messages")
	concurrency = flag.Int("concurrency", 1, "concurrency")
)

type httpStats struct {
	doneRequests   int64
	numSucceeded   int64
	numFailed      int64
	accumLatencies int64
}

type controls struct {
	request   chan string
	latency   chan int64
	succeeded chan struct{}
	failed    chan error
	done      chan struct{}
}

func main() {
	flag.Parse()

	if *file == "" {
		flag.Usage()
		return
	}

	f, err := os.Open(*file)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer f.Close()

	ef, err := os.Create(*efile)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer ef.Close()

	runtime.GOMAXPROCS(runtime.NumCPU())

	control := &controls{
		request:   make(chan string),
		latency:   make(chan int64),
		succeeded: make(chan struct{}),
		failed:    make(chan error),
		done:      make(chan struct{}),
	}

	requestCnt := make(chan int64)

	// concurrently read a file with a channel
	go func() {
		scanner := bufio.NewScanner(f)
		cnt := int64(0)
		for scanner.Scan() {
			control.request <- scanner.Text()
			cnt++
		}
		// closes all workers on their next iteration -- no more lines
		close(control.request)
		// report to the main loop how many requests we did
		requestCnt <- cnt
	}()

	for i := 0; i < *concurrency; i++ {
		go httpRequest(control)
	}

	stats := &httpStats{}
	start := time.Now()
	requests := int64(0)
	hadError := false

	// ticks once per sec -- more efficient than sleep (doesnt hold the cpu)
	tick := time.NewTicker(1 * time.Second)
	defer tick.Stop()

	// main loop
	for {
		select {
		case <-tick.C:
			if stats.doneRequests > 0 {
				interval := time.Now().Sub(start).Nanoseconds()
				printStats(stats, interval)
			}
		case latency := <-control.latency:
			stats.accumLatencies += latency
		case <-control.succeeded:
			stats.doneRequests++
			stats.numSucceeded++
		case err := <-control.failed:
			stats.doneRequests++
			stats.numFailed++
			ef.WriteString(err.Error() + "\n")
			hadError = true
		case requests = <-requestCnt:
			// now we know -- now we can wait for all the success or failures
		}
		if requests > 0 && stats.doneRequests == requests {
			break
		}
	}

	// print one last time
	interval := time.Now().Sub(start).Nanoseconds()
	printStats(stats, interval)
	fmt.Println()

	// wait for everyone to check in
	for *concurrency > 0 {
		<-control.done
		*concurrency--
	}

	if hadError {
		fmt.Println("errors written to:", tmpfile)
	} else {
		os.Remove(tmpfile)
	}
}

func httpRequest(control *controls) {
	defer func() {
		// signal for shutdown procedure
		control.done <- struct{}{}
	}()

	var (
		line   string
		client = new(http.Client)
		ok     bool
	)

	for {
		line, ok = <-control.request
		if !ok {
			// no more requests -- channel closed
			return
		}

		// format: [Method URL BodyParameters(for POST)]
		items := strings.Split(line, " ")
		var body io.Reader
		if len(items) > 2 {
			body = strings.NewReader(items[2])
		}

		req, _ := http.NewRequest(items[0], items[1], body)
		req.Close = true

		// measure turn around time in each request
		start := time.Now()
		resp, err := client.Do(req)
		control.latency <- time.Now().Sub(start).Nanoseconds()

		if err != nil {
			control.failed <- err
			continue
		}

		control.succeeded <- struct{}{}
		resp.Body.Close()
	}
}

func printStats(stats *httpStats, interval int64) {
	fmt.Printf("ok: %6d,  errors: %6d,  reqs/s: %6d,  aveLat(ms): %6d\r",
		stats.numSucceeded,
		stats.numFailed,
		(stats.numSucceeded*1000000000)/interval,
		stats.accumLatencies/stats.numSucceeded/1000000)
}
