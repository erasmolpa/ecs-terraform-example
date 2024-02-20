package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/joho/godotenv"
	"github.com/stretchr/testify/require"
)

// An example of how to test the Terraform module in examples/terraform-backend-example using Terratest.
func TestTerraformBackendExample(t *testing.T) {
	t.Parallel()
	godotenv.Load()
	awsRegion := aws.GetRandomRegion(t, nil, nil)
	uniqueId := random.UniqueId()
	bucketName := fmt.Sprintf("test-terraform-backend-example-%s", strings.ToLower(uniqueId))
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform/modules/backend",
		Vars: map[string]interface{}{
			"backend": map[string]interface{}{
				"bucket_name":    bucketName,
				"region":         awsRegion,
				"dynamodb_table": "test",
			},
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	dynamodb_table_name := terraform.OutputRequired(t, terraformOptions, "dynamodb_table_name")
	backend_bucket_name := terraform.OutputRequired(t, terraformOptions, "backend_bucket_name")
	require.Equal(t, "test-lock", dynamodb_table_name)
	require.Equal(t, fmt.Sprintf("%s-tf-learn", bucketName), backend_bucket_name)
}

func cleanupS3Bucket(t *testing.T, awsRegion string, bucketName string) {
	aws.EmptyS3Bucket(t, awsRegion, bucketName)
	aws.DeleteS3Bucket(t, awsRegion, bucketName)
}
