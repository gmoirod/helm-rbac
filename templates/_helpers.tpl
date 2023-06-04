{{/*
Expand the name of the chart.
*/}}
{{- define "helm-rbac.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helm-rbac.fullname" -}}
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
{{- define "helm-rbac.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "helm-rbac.labels" -}}
helm.sh/chart: {{ include "helm-rbac.chart" . }}
{{ include "helm-rbac.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helm-rbac.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helm-rbac.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "helm-rbac.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "helm-rbac.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the Role apiGroup
*/}}
{{- define "role.apiGroup" -}}
{{ regexSplit "/v[0-9]+" $.Values.global.apiVersion.role 2 | first }}
{{- end }}

{{/*
Create the ClusterRole apiGroup
*/}}
{{- define "clusterRole.apiGroup" -}}
{{ regexSplit "/v[0-9]+" $.Values.global.apiVersion.clusterRole 2 | first }}
{{- end }}

{{/*
Create the RoleBinding apiGroup
*/}}
{{- define "roleBinding.apiGroup" -}}
{{ regexSplit "/v[0-9]+" $.Values.global.apiVersion.roleBinding 2 | first }}
{{- end }}

{{/*
Create the ClusterRoleBinding apiGroup
*/}}
{{- define "clusterRoleBinding.apiGroup" -}}
{{ regexSplit "/v[0-9]+" $.Values.global.apiVersion.clusterRoleBinding 2 | first }}
{{- end }}

{{/*
Create the group apiGroup
*/}}
{{- define "group.apiGroup" -}}
{{ regexSplit "/v[0-9]+" $.Values.global.apiVersion.group 2 | first }}
{{- end }}

{{/*
Create the user apiGroup
*/}}
{{- define "user.apiGroup" -}}
{{ regexSplit "/v[0-9]+" $.Values.global.apiVersion.user 2 | first }}
{{- end }}