{{/*
Expand the name of the chart.
*/}}
{{- define "permify.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "permify.fullname" -}}
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
{{- define "permify.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "permify.labels" -}}
helm.sh/chart: {{ include "permify.chart" . }}
{{ include "permify.selectorLabels" . }}
{{- with (include "permify.versionLabel" .) }}
app.kubernetes.io/version: {{ . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "permify.selectorLabels" -}}
app.kubernetes.io/name: {{ include "permify.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "permify.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "permify.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Container image reference. A digest pins the image immutably and replaces the tag,
mirroring OCI reference semantics.
*/}}
{{- define "permify.image" -}}
{{- if .Values.image.digest -}}
{{- printf "%s@%s" .Values.image.repository (.Values.image.digest | toString) -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default .Chart.AppVersion | toString) -}}
{{- end -}}
{{- end }}

{{/*
Value for the app.kubernetes.io/version label. Kubernetes label values are limited to
63 characters and must match [A-Za-z0-9]([-_.A-Za-z0-9]*[A-Za-z0-9])?, so an image
digest can never be used verbatim. Prefer the tag, strip any inline digest, and omit
the label entirely if nothing valid remains.
*/}}
{{- define "permify.versionLabel" -}}
{{- $version := .Values.image.tag | default .Chart.AppVersion | toString | splitList "@" | first | trunc 63 | trimAll "-_." -}}
{{- if regexMatch "^[A-Za-z0-9]([-_.A-Za-z0-9]*[A-Za-z0-9])?$" $version -}}
{{- $version -}}
{{- end -}}
{{- end }}
