package test

import (
	"bufio"
	"os/exec"
	"syscall"
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var vcSim *exec.Cmd

func TestClusters(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Cluster Suite")
}

var _ = BeforeSuite(func() {
	By("bootstrapping test environment")
	vcSim = exec.Command("vcsim") //, "a-z", "A-Z")
	stdout, err := vcSim.StdoutPipe()
	Expect(err).NotTo(HaveOccurred())
	err = vcSim.Start()
	Expect(err).NotTo(HaveOccurred())
	scanner := bufio.NewScanner(stdout)
	scanner.Scan()
	line := scanner.Text()
	GinkgoLogr.Info(line)

	/*  // Beware needs rewrite hacks in go.mod
	ctx := context.Background()
	req := testcontainers.ContainerRequest{
		Image:        "vmware/vcsim:latest",
		ExposedPorts: []string{":8989:8989"},
		WaitingFor:   wait.ForLog("export GOVC_URL="),
	}

	vcSim, err = testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: req,
		Started:          true,
	})
	Expect(err).NotTo(HaveOccurred())
	Expect(vcSim).NotTo(BeNil())
	*/

})
var _ = AfterSuite(func() {
	By("tearing down the test environment")
	err := vcSim.Process.Signal(syscall.SIGTERM)
	// err := vcSim.Terminate(ctx)
	Expect(err).NotTo(HaveOccurred())
})
