package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/joho/godotenv"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestTerrafortmRdsCreation(t *testing.T) {
	t.Parallel()
	godotenv.Load()
	databaseName := fmt.Sprintf("terratestAwsRDSExample%s", strings.ToLower(random.UniqueId()))
	username := "username"
	password := "password"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform/modules/rds",
		Vars: map[string]interface{}{
			"rds_storage":         10,
			"rds_db_name":         databaseName,
			"rds_engine":          "mysql",
			"instance_class":      "db.t2.micro",
			"rds_username":        username,
			"rds_password":        password,
			"skip_final_snapshot": true,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	db_name := terraform.OutputRequired(t, terraformOptions, "db_name")
	db_port := terraform.OutputRequired(t, terraformOptions, "db_port")
	address := terraform.OutputRequired(t, terraformOptions, "db_address")

	assert.NotNil(t, address)
	require.Equal(t, databaseName, db_name)
	require.Equal(t, "3306", db_port)
}
