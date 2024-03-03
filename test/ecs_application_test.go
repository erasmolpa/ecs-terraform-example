package test

import (
    "testing"

    "github.com/gruntwork-io/terratest/modules/aws"
    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformECSInfrastructure(t *testing.T) {
    terraformOptions := &terraform.Options{
        // Path to your Terraform code
        TerraformDir: "../terraform/modules/ecr_application",

        // Variables to pass to Terraform using -var options
        Vars: map[string]interface{}{
            "aws_region":                       "us-east-1",
            "name":                             "test-" + random.UniqueId(),
            "ecs_task_execution_role": map[string]interface{}{
                "policy_document": map[string]interface{}{
                    "actions":     []string{"sts:AssumeRole"},
                    "effect":      "Allow",
                    "type":        "Service",
                    "identifiers": []string{"ecs-tasks.amazonaws.com"},
                },
                "iam_role_name":  "task-execution-role",
                "iam_policy_arn": "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
            },
            "ecs_task": map[string]interface{}{
                "family":                   "ecs-task-family",
                "container_image_name":     "serverless-go-app",
                "container_image":          "your-ecr-repository-url:latest",
                "cpu":                      256,
                "memory":                   512,
                "requires_compatibilities": []string{"FARGATE"},
                "network_mode":             "awsvpc",
                "container_image_port":     80,
            },
            "ecs_service": map[string]interface{}{
                "name":            "ecs_service",
                "cluster":         "your-ecs-cluster-id",
                "launch_type":     "FARGATE",
                "desired_count":   3,
                "egress_all_id":   "your-security-group-id",
                "private_subnets": []string{"your-private-subnet-ids"},
            },
            "vpc_id":                 "your-vpc-id",
            "alb_arn":                "your-alb-arn",
            "ecs_autoscale_role": map[string]interface{}{
                "policy_document": map[string]interface{}{
                    "actions":     []string{"sts:AssumeRole"},
                    "effect":      "Allow",
                    "type":        "Service",
                    "identifiers": []string{"application-autoscaling.amazonaws.com"},
                },
                "iam_role_name":  "ecs-scale-application",
                "iam_policy_arn": "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole",
            },
            "cloudwatch_metric_alarm_name":                         "/ecs/my-app",
            "cloudwatch_alarm_actions":                             []string{"arn:aws:sns:us-east-1:123456789012:my-alerts"},
            "cloudwatch_metric_alarm_cpu_utilization_threshold":    80,
            "cloudwatch_metric_alarm_memory_utilization_threshold": 80,
        },
    }

    // At the end of the test, run `terraform destroy` to clean up any resources that were created
    defer terraform.Destroy(t, terraformOptions)

    // Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
    terraform.InitAndApply(t, terraformOptions)

    // Validate your Terraform changes with actual testing scenarios
    // For example, you can use `aws.AssertECSServiceExists` from Terratest to validate that your ECS service was created successfully
    validateECSService(t, terraformOptions)
}

// Validate your ECS service
func validateECSService(t *testing.T, terraformOptions *terraform.Options) {
    // Get the output variables from Terraform
    ecsServiceName := terraform.Output(t, terraformOptions, "ecs_service_name")

    // Check if the ECS service exists
    aws.AssertECSServiceExists(t, ecsServiceName, "us-east-1")
}
