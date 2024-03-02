package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAlbt *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../terraform/modules/alb",
	}
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	albArn := terraform.Output(t, terraformOptions, "my_alb_arn")
	assertAlbActive(t, albArn)
}

func assertAlbActive(t *testing.T, albArn string) {

	description := aws.GetAlbDescription(t, albArn, "us-west-2")

	for i := 0; i < 12; i++ {
		if description.State == "active" {
			return
		}
		time.Sleep(5 * time.Second)
		description = aws.GetAlbDescription(t, albArn, "us-west-2")
	}

	assert.Fail(t, fmt.Sprintf("ALB with ARN %s is not in active state", albArn))
}
