package common

import (
	"os"
)

func GetResourceNamespace() string {
	if val := os.Getenv("POD_NAMESPACE"); val != "" {
		return val
	}
	return "kagent"
}
