{{/*
Expand the name of the chart.
*/}}
{{- define "mychart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mychart.fullname" -}}
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
{{- define "mychart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mychart.labels" -}}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "mychart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mychart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mychart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mychart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mychart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* 
포드 환경 변수 세트 생성 
*/}}
{{- define "mychart.podEnvVars" -}}
{{- range $key, $val := .Values.env }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- end }}
{{- if .Values.aws.ssmParameterStore.enabled }}
{{- range .Values.aws.ssmParameterStore.parameters }}
- name: {{ .name }}
  valueFrom:
    secretKeyRef:
      name: {{ include "mychart.fullname" $ }}-aws-secrets
      key: {{ .name }}
{{- end }}
{{- end }}
{{- end }}

{{/* 
리소스 설정 헬퍼
*/}}
{{- define "mychart.resources" -}}
{{- if .resources }}
resources:
  {{- toYaml .resources | nindent 2 }}
{{- else if $.Values.resources }}
resources:
  {{- toYaml $.Values.resources | nindent 2 }}
{{- end }}
{{- end }}

{{/* 
컴포넌트 볼륨과 볼륨 마운트 생성 
*/}}
{{- define "mychart.volumes" -}}
{{- if or .volumes $.Values.volumes }}
volumes:
{{- if .volumes }}
{{- toYaml .volumes | nindent 2 }}
{{- end }}
{{- if $.Values.volumes }}
{{- toYaml $.Values.volumes | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
컴포넌트 볼륨 마운트 생성
*/}}
{{- define "mychart.volumeMounts" -}}
{{- if or .volumeMounts $.Values.volumeMounts }}
volumeMounts:
{{- if .volumeMounts }}
{{- toYaml .volumeMounts | nindent 2 }}
{{- end }}
{{- if $.Values.volumeMounts }}
{{- toYaml $.Values.volumeMounts | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
