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

	// Create an S3 bucket where we can store state
	bucketName := fmt.Sprintf("test-terraform-backend-example-%s", strings.ToLower(uniqueId))
	defer cleanupS3Bucket(t, awsRegion, bucketName)
	aws.CreateS3Bucket(t, awsRegion, bucketName)

	key := fmt.Sprintf("%s/terraform.tfstate", uniqueId)
	// data := fmt.Sprintf("data-for-test-%s", uniqueId)

	// Deploy the module, configuring it to use the S3 bucket as an S3 backend
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform/modules/backend",
		Vars: map[string]interface{}{
			"backend": map[string]interface{}{
				"bucket_name":    bucketName,
				"region":         awsRegion,
				"dynamodb_table": "test",
			},
		},
		BackendConfig: map[string]interface{}{
			"bucket": bucketName,
			"key":    key,
			"region": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Check a state file actually got stored and contains our data in it somewhere (since that data is used in an
	// output of the Terraform code)
	// contents := aws.GetS3ObjectContents(t, awsRegion, bucketName, key)
	// require.Contains(t, contents, data)

	// The module doesn't really *do* anything, so we just check a dummy output here and move on
	dynamodb_table_name := terraform.OutputRequired(t, terraformOptions, "dynamodb_table_name")
	// backend_bucket_arn := terraform.OutputRequired(t, terraformOptions, "backend_bucket_arn")
	require.Equal(t, "test-lock", dynamodb_table_name)
}

func cleanupS3Bucket(t *testing.T, awsRegion string, bucketName string) {
	aws.EmptyS3Bucket(t, awsRegion, bucketName)
	aws.DeleteS3Bucket(t, awsRegion, bucketName)
}
