{{/*
Expand the name of the chart.
*/}}
{{- define "github-mcp-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "github-mcp-server.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "github-mcp-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "github-mcp-server.labels" -}}
helm.sh/chart: {{ include "github-mcp-server.chart" . }}
{{ include "github-mcp-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "github-mcp-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "github-mcp-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Generate the URL for a given toolset
*/}}
{{- define "github-mcp-server.toolUrl" -}}
{{- $toolset := .toolset -}}
{{- $readonly := .readonly -}}
{{- $baseUrl := .context.Values.baseUrl -}}
{{- if eq $toolset "all" -}}
{{- $baseUrl }}/
{{- else -}}
{{- $baseUrl }}/x/{{ include "github-mcp-server.toolsetPath" $toolset }}
{{- end -}}
{{- if $readonly }}/readonly{{- end -}}
{{- end }}

{{/*
Generate the resource name for a given toolset
*/}}
{{- define "github-mcp-server.resourceName" -}}
{{- $toolset := .toolset -}}
{{- $readonly := .readonly -}}
{{- $baseName := include "github-mcp-server.fullname" .context -}}
{{- $suffix := "" -}}
{{- if eq $toolset "all" -}}
{{- $suffix = "all" -}}
{{- else -}}
{{- if eq $toolset "pullRequests" -}}
{{- $suffix = "pull-requests" -}}
{{- else if eq $toolset "codeSecurity" -}}
{{- $suffix = "code-security" -}}
{{- else if eq $toolset "secretProtection" -}}
{{- $suffix = "secret-protection" -}}
{{- else -}}
{{- $suffix = $toolset | lower -}}
{{- end -}}
{{- end -}}
{{- if $readonly -}}
{{- $suffix = printf "%s-readonly" $suffix -}}
{{- end -}}
{{- printf "%s-%s" $baseName $suffix | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Generate the description for a given toolset
*/}}
{{- define "github-mcp-server.description" -}}
{{- $toolset := .toolset -}}
{{- $readonly := .readonly -}}
{{- $config := .config -}}
{{- $descriptionPrefix := .context.Values.descriptionPrefix -}}
{{- if $config.description -}}
{{- $config.description -}}
{{- else -}}
{{- $toolsetName := "" -}}
{{- if eq $toolset "all" -}}
{{- $toolsetName = "all available tools" -}}
{{- else if eq $toolset "actions" -}}
{{- $toolsetName = "GitHub Actions workflows and CI/CD operations" -}}
{{- else if eq $toolset "codeSecurity" -}}
{{- $toolsetName = "code security related tools" -}}
{{- else if eq $toolset "dependabot" -}}
{{- $toolsetName = "Dependabot tools" -}}
{{- else if eq $toolset "discussions" -}}
{{- $toolsetName = "GitHub Discussions related tools" -}}
{{- else if eq $toolset "experiments" -}}
{{- $toolsetName = "experimental features" -}}
{{- else if eq $toolset "issues" -}}
{{- $toolsetName = "GitHub Issues related tools" -}}
{{- else if eq $toolset "notifications" -}}
{{- $toolsetName = "GitHub Notifications related tools" -}}
{{- else if eq $toolset "organizations" -}}
{{- $toolsetName = "GitHub Organization related tools" -}}
{{- else if eq $toolset "pullRequests" -}}
{{- $toolsetName = "GitHub Pull Request related tools" -}}
{{- else if eq $toolset "repositories" -}}
{{- $toolsetName = "GitHub Repository related tools" -}}
{{- else if eq $toolset "secretProtection" -}}
{{- $toolsetName = "secret protection related tools" -}}
{{- else if eq $toolset "users" -}}
{{- $toolsetName = "GitHub User related tools" -}}
{{- else -}}
{{- $toolsetName = printf "%s tools" $toolset -}}
{{- end -}}
{{- $mode := "read-write" -}}
{{- if $readonly -}}
{{- $mode = "read-only" -}}
{{- end -}}
{{- printf "%s - %s (%s)" $descriptionPrefix $toolsetName $mode -}}
{{- end -}}
{{- end }}

{{/*
Get the token secret name for a toolset
*/}}
{{- define "github-mcp-server.tokenSecretName" -}}
{{- $config := .config -}}
{{- $global := .context.Values.tokenSecret -}}
{{- $globalRef := .context.Values.tokenSecretRef -}}
{{- $toolset := .toolset -}}
{{- if $config.tokenSecretRef -}}
{{- if $config.tokenSecretRef.name -}}
{{- $config.tokenSecretRef.name -}}
{{- else -}}
{{- $global.name -}}
{{- end -}}
{{- else if $config.tokenSecret -}}
{{- if $config.tokenSecret.name -}}
{{- $config.tokenSecret.name -}}
{{- else if $config.tokenSecret.value -}}
{{- printf "%s-token" (include "github-mcp-server.resourceName" (dict "toolset" $toolset "readonly" false "context" .context)) -}}
{{- else -}}
{{- $global.name -}}
{{- end -}}
{{- else if $globalRef.name -}}
{{- $globalRef.name -}}
{{- else -}}
{{- $global.name -}}
{{- end -}}
{{- end }}

{{/*
Get the token secret key for a toolset
*/}}
{{- define "github-mcp-server.tokenSecretKey" -}}
{{- $config := .config -}}
{{- $global := .context.Values.tokenSecret -}}
{{- $globalRef := .context.Values.tokenSecretRef -}}
{{- if $config.tokenSecretRef -}}
{{- if $config.tokenSecretRef.key -}}
{{- $config.tokenSecretRef.key -}}
{{- else -}}
{{- $global.key -}}
{{- end -}}
{{- else if $config.tokenSecret -}}
{{- if $config.tokenSecret.key -}}
{{- $config.tokenSecret.key -}}
{{- else -}}
{{- $global.key -}}
{{- end -}}
{{- else if $globalRef.key -}}
{{- $globalRef.key -}}
{{- else -}}
{{- $global.key -}}
{{- end -}}
{{- end }}

{{/*
Get the timeout for a toolset
*/}}
{{- define "github-mcp-server.timeout" -}}
{{- $config := .config -}}
{{- $global := .context.Values.timeout -}}
{{- if $config.timeout -}}
{{- $config.timeout -}}
{{- else -}}
{{- $global -}}
{{- end -}}
{{- end }}

{{/*
Convert camelCase toolset names to URL path format
*/}}
{{- define "github-mcp-server.toolsetPath" -}}
{{- $toolset := . -}}
{{- if eq $toolset "codeSecurity" -}}
code_security
{{- else if eq $toolset "pullRequests" -}}
pull_requests
{{- else if eq $toolset "secretProtection" -}}
secret_protection
{{- else if eq $toolset "organizations" -}}
orgs
{{- else if eq $toolset "repositories" -}}
repos
{{- else -}}
{{ $toolset }}
{{- end -}}
{{- end }}
