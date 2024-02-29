package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/gofiber/fiber/v3"
)

func main() {
	app := fiber.New()

	app.Get("/", func(c fiber.Ctx) error {
		db, err := sql.Open("mysql",
			fmt.Sprintf("%s:%s@tcp%s:%s)/%s",
				os.Getenv("username"),
				os.Getenv("password"),
				os.Getenv("address"),
				os.Getenv("port"),
				os.Getenv("dbname")))
		if err != nil {
			log.Fatal(err)
		}
		defer db.Close()
		pingErr := db.Ping()
		if pingErr != nil {
			log.Fatal(pingErr)
		}
		fmt.Println("Connected!")
		return c.SendString("Hello, World 👋!")
	})

	app.Listen(":80")
}
