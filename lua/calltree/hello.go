package main

import "fmt"

func main() {
	b()
}

func b() {
	c()

}

func c() {
	fmt.Println("hello")

}
