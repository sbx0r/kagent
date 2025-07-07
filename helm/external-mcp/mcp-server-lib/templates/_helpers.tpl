{{/*
Expand the name of the chart.
*/}}
{{- define "mcp-server-lib.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mcp-server-lib.fullname" -}}
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
{{- define "mcp-server-lib.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mcp-server-lib.labels" -}}
helm.sh/chart: {{ include "mcp-server-lib.chart" . }}
{{ include "mcp-server-lib.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mcp-server-lib.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mcp-server-lib.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mcp-server-lib.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mcp-server-lib.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the MCP server URL for HTTP mode
*/}}
{{- define "mcp-server-lib.serverUrl" -}}
{{- if include "mcp-server-lib.needsDeployment" . }}
{{- printf "http://%s.%s.svc.cluster.local:%d%s" (include "mcp-server-lib.fullname" .) .Release.Namespace (.Values.service.port | int) (.Values.http.path | default "") }}
{{- end }}
{{- end }}

{{/*
Determine if HTTP deployment is needed (sse or streamable-http)
*/}}
{{- define "mcp-server-lib.needsDeployment" -}}
{{- or (eq .Values.serverType "sse") (eq .Values.serverType "streamable-http") }}
{{- end }}

{{/*
Determine if stdio mode is used
*/}}
{{- define "mcp-server-lib.isStdio" -}}
{{- eq .Values.serverType "stdio" }}
{{- end }}

{{/*
Determine if SSE mode is used
*/}}
{{- define "mcp-server-lib.isSSE" -}}
{{- eq .Values.serverType "sse" }}
{{- end }}

{{/*
Determine if streamable-http mode is used
*/}}
{{- define "mcp-server-lib.isStreamableHttp" -}}
{{- eq .Values.serverType "streamable-http" }}
{{- end }}

{{/*
Create the container name
*/}}
{{- define "mcp-server-lib.containerName" -}}
{{- include "mcp-server-lib.name" . }}
{{- end }}

{{/*
Generate headersFrom entries for HTTP modes
*/}}
{{- define "mcp-server-lib.headersFrom" -}}
{{- range $key, $value := .Values.config }}
- name: {{ $key | quote }}
  valueFrom:
    type: ConfigMap
    valueRef: {{ include "mcp-server-lib.fullname" . }}
    key: {{ $key | quote }}
{{- end }}
{{- range $key, $value := .Values.secrets.stringData }}
- name: {{ $key | quote }}
  valueFrom:
    type: Secret
    valueRef: {{ include "mcp-server-lib.fullname" . }}
    key: {{ $key | quote }}
{{- end }}
{{- range .Values.http.headersFrom }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Generate envFrom entries for stdio mode
*/}}
{{- define "mcp-server-lib.envFrom" -}}
{{- range $key, $value := .Values.config }}
- name: {{ $key | quote }}
  valueFrom:
    type: ConfigMap
    valueRef: {{ include "mcp-server-lib.fullname" . }}
    key: {{ $key | quote }}
{{- end }}
{{- range $key, $value := .Values.secrets.stringData }}
- name: {{ $key | quote }}
  valueFrom:
    type: Secret
    valueRef: {{ include "mcp-server-lib.fullname" . }}
    key: {{ $key | quote }}
{{- end }}
{{- range .Values.stdio.envFrom }}
{{- toYaml . }}
{{- end }}
{{- end }}