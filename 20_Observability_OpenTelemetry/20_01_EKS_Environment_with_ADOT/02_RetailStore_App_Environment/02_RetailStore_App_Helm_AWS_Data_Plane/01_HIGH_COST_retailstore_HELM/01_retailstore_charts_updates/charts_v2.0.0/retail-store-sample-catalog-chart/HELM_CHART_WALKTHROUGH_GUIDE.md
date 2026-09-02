# Helm Chart Walkthrough Guide

This guide suggests the best order for reviewing this Helm chart so you can understand how the chart is structured, how values flow into templates, and how the rendered Kubernetes resources work together.

## Big Picture

Think of a Helm chart like a recipe book for Kubernetes.

- `Chart.yaml` describes the chart itself.
- `values.yaml` contains the configurable inputs.
- `templates/` contains Kubernetes manifests with Helm template logic.
- Helm combines the values and templates to generate final Kubernetes YAML.

```text
Chart metadata
  -> default values
    -> helper templates
      -> rendered Kubernetes resources
        -> install notes and tests
```

## Recommended Review Order

### 1. Chart Metadata

Start with:

- `Chart.yaml`

This file explains the identity of the chart.

Look for:

- Chart name
- Chart version
- Application version
- Chart type
- Dependencies, if any

Key idea: before studying what the chart creates, first understand what the chart is.

---

### 2. Default Configuration

Next review:

- `values.yaml`

This is one of the most important files in any Helm chart. It defines the default configuration used by the templates.

Look for:

- Image settings
- Replica counts
- Service settings
- Resource requests and limits
- Environment variables
- Database settings
- Secret settings
- AWS-specific settings
- Feature flags such as `enabled` or `create`

Key idea: most templates are controlled by values from this file.

---

### 3. Shared Template Helpers

Then review:

- `templates/_helpers.tpl`

This file usually defines reusable Helm template snippets.

Look for helpers that create:

- Resource names
- Full names
- Common labels
- Selector labels
- Service account names

You will often see these helpers used with syntax like:

```yaml
{{ include "catalog.fullname" . }}
{{ include "catalog.labels" . }}
{{ include "catalog.selectorLabels" . }}
```

Key idea: helpers keep names and labels consistent across all Kubernetes resources.

---

### 4. Kubernetes Identity

Review:

- `templates/serviceaccount.yaml`

This file defines the Kubernetes ServiceAccount used by the application pods.

Look for:

- Whether the ServiceAccount is created conditionally
- Which values control its name
- Any annotations, especially AWS IAM-related annotations

Key idea: the ServiceAccount controls the Kubernetes identity the workload runs with.

---

### 5. Application Configuration

Review:

- `templates/configmap.yml`

This file usually provides non-sensitive configuration to the application.

Look for:

- Environment-specific settings
- Application config values
- References to `.Values`
- How the Deployment consumes the ConfigMap

Key idea: ConfigMaps are for non-secret application configuration.

---

### 6. Kubernetes Secrets

Review:

- `templates/secret.yaml`

This file defines Kubernetes-native Secret resources.

Look for:

- Which values become secrets
- Whether values are encoded
- Whether secret creation is conditional
- How the Deployment or database consumes the Secret

Key idea: Secrets store sensitive values, but they still need careful handling because Kubernetes Secrets are only base64-encoded by default.

---

### 7. External Secrets Integration

Review:

- `templates/secretproviderclass.yaml`

This file is related to the Secrets Store CSI Driver, commonly used with AWS Secrets Manager.

Look for:

- SecretProviderClass name
- AWS provider configuration
- Referenced AWS Secrets Manager objects
- Sync behavior into Kubernetes Secrets
- Mount configuration used later by the Deployment

Key idea: this chart may support pulling secrets from AWS instead of only storing them directly in Kubernetes.

---

### 8. Main Application Workload

Review:

- `templates/deployment.yaml`

This is the core application workload.

Look for:

- Pod labels and selectors
- Container image
- Container ports
- Environment variables
- ConfigMap references
- Secret references
- Volumes and mounts
- ServiceAccount usage
- Health probes
- Resource requests and limits

Key idea: the Deployment ties together many earlier files, including values, helpers, ConfigMaps, Secrets, and ServiceAccounts.

---

### 9. Application Networking

Review:

- `templates/service.yaml`

This file exposes the application inside the Kubernetes cluster, and possibly outside it depending on service type.

Look for:

- Service type
- Ports
- Target ports
- Selectors
- How selectors match the Deployment pod labels

Key idea: the Service sends traffic to the pods created by the Deployment.

```text
Client
  -> Kubernetes Service
    -> Pods selected by labels
      -> Application container
```

---

### 10. Database Workload

Review:

- `templates/mysql-statefulset.yaml`

This file defines the MySQL database workload.

Look for:

- StatefulSet name
- MySQL container image
- Persistent volume configuration
- Environment variables
- Secret usage
- Volume claim templates
- Pod identity and labels

Key idea: StatefulSets are used for stateful workloads that need stable identity and storage.

---

### 11. Database Networking

Review:

- `templates/mysql-service.yaml`

This file exposes MySQL inside the Kubernetes cluster.

Look for:

- Service name
- MySQL port
- Selectors
- Whether it is a normal Service or headless Service
- How the application connects to it

Key idea: the application reaches MySQL through a Kubernetes Service name instead of a hardcoded pod IP.

---

### 12. AWS Pod Security Group Integration

Review:

- `templates/security-group.yaml`

This file defines a `SecurityGroupPolicy`, which is an AWS VPC CNI feature for assigning security groups to pods.

Look for:

- The condition that controls whether it is created
- Pod selector labels
- Security group IDs from values
- How selected pods receive AWS security group behavior

Key idea: this is AWS-specific networking configuration, not a standard Kubernetes resource.

Example structure:

```yaml
{{- if .Values.securityGroups.create }}
apiVersion: vpcresources.k8s.aws/v1beta1
kind: SecurityGroupPolicy
...
{{- end }}
```

This means the resource is rendered only when `securityGroups.create` is enabled in `values.yaml`.

---

### 13. Autoscaling

Review:

- `templates/hpa.yaml`

This file defines a HorizontalPodAutoscaler.

Look for:

- Whether autoscaling is enabled conditionally
- Minimum replicas
- Maximum replicas
- CPU or memory target metrics
- Which Deployment is being scaled

Key idea: the HPA changes the number of application pods based on resource usage or configured metrics.

---

### 14. Availability During Disruptions

Review:

- `templates/pdb.yaml`

This file defines a PodDisruptionBudget.

Look for:

- Minimum available pods or maximum unavailable pods
- Selector labels
- Whether it is enabled conditionally

Key idea: a PDB helps keep enough pods running during voluntary disruptions, such as node upgrades.

---

### 15. Helm Test Hook

Review:

- `templates/tests/test-connection.yaml`

This file defines a Helm test resource.

Look for:

- Helm hook annotations
- What command the test pod runs
- Which Service it tries to reach

Key idea: Helm tests can verify that the installed chart works at a basic level.

Run tests with:

```bash
helm test <release-name>
```

---

### 16. Post-Install Notes

Review:

- `templates/NOTES.txt`

This file controls the message Helm prints after installing the chart.

Look for:

- Access instructions
- Service information
- Conditional logic based on service type
- Helpful commands generated for the user

Key idea: `NOTES.txt` is not a Kubernetes resource. It is user-facing output after `helm install`.

---

### 17. Packaging Ignore Rules

Review last:

- `.helmignore`

This file controls which files are excluded when the chart is packaged.

Look for:

- Temporary files
- Local editor files
- Git files
- Test or generated files that should not be included in the packaged chart

Key idea: `.helmignore` is similar to `.gitignore`, but for `helm package`.

---

## Suggested Learning Flow

Use this order when studying the chart:

```text
1. Chart.yaml
2. values.yaml
3. templates/_helpers.tpl
4. templates/serviceaccount.yaml
5. templates/configmap.yml
6. templates/secret.yaml
7. templates/secretproviderclass.yaml
8. templates/deployment.yaml
9. templates/service.yaml
10. templates/mysql-statefulset.yaml
11. templates/mysql-service.yaml
12. templates/security-group.yaml
13. templates/hpa.yaml
14. templates/pdb.yaml
15. templates/tests/test-connection.yaml
16. templates/NOTES.txt
17. .helmignore
```

## How To Think About The Chart

A useful way to read any Helm chart is to ask these questions:

1. What does this chart install?
2. Which values control the installation?
3. Which templates are always rendered?
4. Which templates are conditional?
5. Which Kubernetes resources depend on each other?
6. Which parts are standard Kubernetes?
7. Which parts are AWS-specific?
8. How would I override this chart for another environment?

## Render The Chart Locally

After reviewing the files, you can render the chart without installing it:

```bash
helm template catalog .
```

This shows the final Kubernetes YAML that Helm would generate.

You can also render with a custom values file:

```bash
helm template catalog . -f custom-values.yaml
```

## Install Flow Summary

```text
helm install
  -> reads Chart.yaml
  -> loads values.yaml
  -> applies any override values
  -> renders templates/
  -> sends Kubernetes manifests to the cluster
  -> prints templates/NOTES.txt
```

## Quick Comparison Table

| File or Folder | What it does | When to study it |
|---|---|---|
| `Chart.yaml` | Defines chart metadata | First |
| `values.yaml` | Defines default inputs | Second |
| `templates/_helpers.tpl` | Defines reusable template snippets | Before other templates |
| `templates/deployment.yaml` | Creates the main application pods | After config and secrets |
| `templates/service.yaml` | Exposes the application pods | After Deployment |
| `templates/mysql-statefulset.yaml` | Creates the MySQL workload | After app workload |
| `templates/mysql-service.yaml` | Exposes MySQL inside the cluster | After MySQL StatefulSet |
| `templates/security-group.yaml` | Adds AWS pod security group behavior | After core app resources |
| `templates/hpa.yaml` | Adds autoscaling | After Deployment |
| `templates/pdb.yaml` | Adds disruption protection | After Deployment |
| `templates/tests/` | Defines Helm test resources | Near the end |
| `templates/NOTES.txt` | Prints install instructions | Near the end |
| `.helmignore` | Excludes files from chart package | Last |
