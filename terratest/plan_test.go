package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestTerraformPlan validates that all key modules/resources exist in the Terraform plan
func TestTerraformPlan(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../terraform",
		VarFiles:     []string{"terraform.tfvars"},
		PlanFilePath: "terraform.tfplan",
		NoColor:      true,
	}

	planStruct := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
	resources := planStruct.ResourcePlannedValuesMap

	// flags for resources
	hasVpc := false
	hasSubnets := false
	hasEks := false
	hasAlb := false
	hasRoute53 := false
	hasIrsa := false
	hasSGApp := false
	hasSGDB := false
	hasSGMonitoring := false
	hasSGPublic := false

	// iterate through planned resources
	for key := range resources {
		switch {
		case strings.Contains(key, "aws_vpc"):
			hasVpc = true
		case strings.Contains(key, "aws_subnet"):
			hasSubnets = true
		case strings.Contains(key, "aws_eks_cluster"):
			hasEks = true
		case strings.Contains(key, "alb_controller"):
			hasAlb = true
		case strings.Contains(key, "route53_acm"):
			hasRoute53 = true
		case strings.Contains(key, "irsa_observability"):
			hasIrsa = true
		case strings.Contains(key, "aws_security_group.app_nodes"):
			hasSGApp = true
		case strings.Contains(key, "aws_security_group.db"):
			hasSGDB = true
		case strings.Contains(key, "aws_security_group.monitoring"):
			hasSGMonitoring = true
		case strings.Contains(key, "aws_security_group.public_gateway"):
			hasSGPublic = true
		}
	}

	// assertions
	assert.True(t, hasVpc, "❌ aws_vpc not found in plan")
	assert.True(t, hasSubnets, "❌ aws_subnet not found in plan")
	assert.True(t, hasEks, "❌ aws_eks_cluster not found in plan")
	assert.True(t, hasAlb, "❌ alb_controller module not found in plan")
	assert.True(t, hasRoute53, "❌ route53_acm module not found in plan")
	assert.True(t, hasIrsa, "❌ irsa_observability module not found in plan")
	assert.True(t, hasSGApp, "❌ app_nodes security group not found")
	assert.True(t, hasSGDB, "❌ db security group not found")
	assert.True(t, hasSGMonitoring, "❌ monitoring security group not found")
	assert.True(t, hasSGPublic, "❌ public_gateway security group not found")

	fmt.Println("✅ Terraform plan contains VPC, Subnets, EKS, ALB, Route53, IRSA, and Security Groups")
}
