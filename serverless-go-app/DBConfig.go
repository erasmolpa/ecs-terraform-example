package main

type DBConfig struct {
	DBDriver   string `mapstructure:"DB_DRIVER"`
	DBUsername string `mapstructure:"DB_USERNAME"`
	DBPassword string `mapstructure:"DB_PASSWORD"`
	DBAddress  string `mapstructure:"DB_ADDRESS"`
	DBPort     int    `mapstructure:"DB_PORT"`
	DBName     string `mapstructure:"DB_NAME"`
}
