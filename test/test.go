package main

import (
	"bufio"
	"flag"
	"fmt"
	"net"
	"time"
)

func main() {

	connect := flag.String("connect", "", "ip:port to connect to. ex: 127.0.0.1:80")
	flag.Parse()

	counter := 0

	for true {
		conn, err := net.Dial("tcp", *connect)
		if err != nil {
			// handle error
		}
		fmt.Fprintf(conn, "GET / HTTP/1.0\r\n\r\n")
		status, err := bufio.NewReader(conn).ReadString('\n')
		fmt.Printf("%d - %s\n", counter, status)
		conn.Close()
		counter++
		time.Sleep(time.Second * 5)
	}
}
