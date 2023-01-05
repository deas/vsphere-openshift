package test

import (
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

var _ = Describe("Management", func() {
	It("should fully apply from scratch", func() {
		varFiles := []string{"test.tfvars"}
		t := GinkgoT()
		tfDir := "./examples/demo"
		tfVars := map[string]interface{}{
			// "openshift_gen": "touch openshift/bootstrap.ign && touch openshift/master.ign && touch openshift/worker.ign",
		}
		tfMainOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: tfDir,
			Vars:         tfVars,
			VarFiles:     varFiles,
		})

		defer terraform.Destroy(t, tfMainOptions)

		terraform.InitAndApply(t, tfMainOptions)

		output := terraform.Output(t, tfMainOptions, "cluster")
		Expect(output).NotTo(BeNil())
	})
})
