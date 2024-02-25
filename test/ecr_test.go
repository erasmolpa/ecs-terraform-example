package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)
func TestEcrIsCreatedWithDefaultValues(t *testing.T){
	t.Parallel()
	repositoryName := "test_ecr_repo"
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform/modules/ecr_resgistry",
		Vars: map[string]interface{}{
			"repository_name": repositoryName,
		},
	})

	defer terraform.Destroy(t,terraformOptions)

	terraform.InitAndApply(t,terraformOptions)
	actualRepositoryName := terraform.Output(t, terraformOptions, "repository_name")
	require.Equal(t, repositoryName, actualRepositoryName)

	repositoryURL := terraform.Output(t, terraformOptions, "repository_url")
	require.NotEmpty(t, repositoryURL)


	repositoryEncryptionEnabled := terraform.Output(t, terraformOptions, "repository_encryption_enabled")
	require.Equal(t, "true", repositoryEncryptionEnabled)
}