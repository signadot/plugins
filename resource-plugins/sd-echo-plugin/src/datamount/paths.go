package datamount

import "path/filepath"

var root = "/signadot"
var pvnDir = filepath.Join(root, "provision")
var inputDir = filepath.Join(pvnDir, "input")
var outputDir = filepath.Join(pvnDir, "output")

func SignadotRootDir() string {
	return root
}
func ProvisionDir() string {
	return pvnDir
}
func InputDir() string {
	return inputDir
}
func OutputDir() string {
	return outputDir
}
