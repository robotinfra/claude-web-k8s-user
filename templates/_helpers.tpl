{{/*
Expand the name of the chart.
*/}}
{{- define "claude-web-k8s-user.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "claude-web-k8s-user.fullname" -}}
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
Create the namespace name
*/}}
{{- define "claude-web-k8s-user.namespace" -}}
{{- if .Values.namespace.name }}
{{- .Values.namespace.name }}
{{- else }}
{{- printf "claude-%s" .Values.userid }}
{{- end }}
{{- end }}

{{/*
Create the ServiceAccount name
*/}}
{{- define "claude-web-k8s-user.serviceAccountName" -}}
{{- printf "claude-%s" .Values.userid }}
{{- end }}

{{/*
Create the ClusterRole name
*/}}
{{- define "claude-web-k8s-user.clusterRoleName" -}}
{{- printf "claude-%s-admin" .Values.userid }}
{{- end }}

{{/*
Create the ClusterRoleBinding name
*/}}
{{- define "claude-web-k8s-user.clusterRoleBindingName" -}}
{{- printf "claude-%s-binding" .Values.userid }}
{{- end }}
