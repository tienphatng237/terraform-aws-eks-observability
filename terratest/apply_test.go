package test

import (
	"fmt"
	"os/exec"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestEKSInfra applies Terraform, checks outputs, and then destroys resources
func TestEKSInfra(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../terraform", // thư mục chứa main.tf
		VarFiles:     []string{"terraform.tfvars"},
	}

	// Destroy at the end
	defer terraform.Destroy(t, terraformOptions)

	// Init & Apply
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	clusterName := terraform.Output(t, terraformOptions, "eks_cluster_name")
	publicSubnets := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	privateSubnets := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	region := terraform.Output(t, terraformOptions, "region")

	// Validate VPC
	assert.NotEmpty(t, vpcID)
	assert.Contains(t, vpcID, "vpc-")

	// Validate Subnets
	assert.Equal(t, 3, len(publicSubnets), "Should have 3 public subnets")
	assert.Equal(t, 3, len(privateSubnets), "Should have 3 private subnets")

	// Validate EKS cluster status using AWS CLI
	cmd := exec.Command("aws", "eks", "describe-cluster",
		"--region", region,
		"--name", clusterName,
		"--query", "cluster.status",
		"--output", "text")

	output, err := cmd.Output()
	assert.NoError(t, err)

	status := strings.TrimSpace(string(output))
	assert.Equal(t, "ACTIVE", status, "EKS Cluster should be ACTIVE")

	fmt.Printf("✅ Test passed: VPC=%s, Cluster=%s (%s), Subnets=%d/%d\n",
		vpcID, clusterName, status, len(publicSubnets), len(privateSubnets))

	time.Sleep(5 * time.Second)
}
