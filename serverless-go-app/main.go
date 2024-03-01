package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/go-sql-driver/mysql"
	"github.com/gofiber/fiber/v3"
	"github.com/spf13/viper"
)

func main() {
	app := fiber.New()
	config, err := LoadConfig(".")
	if err != nil {
		log.Fatal("cannot load config:", err)
	}
	app.Get("/", func(c fiber.Ctx) error {
		dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s",
			config.DBUsername, config.DBPassword, config.DBAddress, config.DBPort, config.DBName,
		)
		fmt.Println(dsn)
		db, err := sql.Open(config.DBDriver, dsn)
		if err != nil {
			panic(err)
		}

		err = db.Ping()
		if err != nil {
			panic(err)
		}
		return c.SendString("Hello, World 👋!")
	})

	app.Listen(":80")
}

func LoadConfig(path string) (config DBConfig, err error) {
	viper.AddConfigPath(path)
	viper.SetConfigName("app")
	viper.SetConfigType("env")

	viper.AutomaticEnv()

	err = viper.ReadInConfig()
	if err != nil {
		return
	}

	err = viper.Unmarshal(&config)
	return
}
