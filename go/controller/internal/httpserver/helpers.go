package httpserver

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	common "github.com/kagent-dev/kagent/go/controller/internal/utils"
)

// Common HTTP response helpers
func respondWithJSON(w http.ResponseWriter, code int, payload interface{}) {
	response, err := json.Marshal(payload)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "Error marshalling JSON response")
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	w.Write(response)
}

func respondWithError(w http.ResponseWriter, code int, message string) {
	respondWithJSON(w, code, map[string]string{"error": message})
}

func getUserID(r *http.Request) (string, error) {
	userID := r.URL.Query().Get("user_id")
	if userID == "" {
		return "", fmt.Errorf("user_id is required")
	}
	return userID, nil
}

func parseNamespacedName(namespacedName string) (namespace, name string) {
	parts := strings.Split(namespacedName, "/")
	if len(parts) == 2 {
		namespace = parts[0]
		name = parts[1]
	} else {
		namespace = common.GetResourceNamespace()
		name = namespacedName
	}
	return
}
