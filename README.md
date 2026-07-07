# tekton-field-guide

**📖 [Browse the Interactive Reference Guide](https://ay-garg.github.io/tekton-field-guide/)**

A practical Tekton reference for engineers building or contributing to Kubernetes-native CI/CD pipelines. Covers 9 topics from cluster setup through a production-grade container build pipeline — with apply-ready YAML manifests and shell commands for every topic.

> Designed for engineers working on or contributing to [Konflux](https://konflux-ci.dev/), though all topics apply to any Tekton installation.

## Architecture

[![Tekton Architecture](https://raw.githubusercontent.com/ay-garg/tekton-field-guide/refs/heads/main/Tekton-Architecture.png)](https://github.com/ay-garg/tekton-field-guide/blob/main/Tekton-Architecture.png)

---

## Contents

| # | Topic | Difficulty | Files |
|---|-------|-----------|-------|
| 01 | [Architecture & Installation](#01-architecture--installation) | Beginner | `kind-config.yaml` |
| 02 | [Tasks & TaskRuns](#02-tasks--taskruns) | Beginner | `02-hello-task.yaml` · `02-taskrun.yaml` · `02-build-info-task.yaml` |
| 03 | [Pipelines & PipelineRuns](#03-pipelines--pipelineruns) | Beginner | `03-tasks.yaml` · `03-pipeline.yaml` · `03-pipelinerun.yaml` |
| 04 | [Workspaces](#04-workspaces) | Intermediate | `04-workspace-resources.yaml` · `04-workspace-pipeline.yaml` · `04-pipelinerun.yaml` |
| 05 | [Triggers](#05-triggers) | Intermediate | `05-triggers-rbac.yaml` · `05-triggerbinding.yaml` · `05-triggertemplate.yaml` · `05-eventlistener.yaml` · `05-webhook-secret.yaml` |
| 06 | [Artifact Hub & Community Tasks](#06-artifact-hub--community-tasks) | Intermediate | `06-registry-secret.yaml` · `06-ci-pipeline-catalog.yaml` · `06-pipeline-pvc.yaml` · `06-pipelinerun.yaml` |
| 07 | [Advanced Patterns](#07-advanced-patterns) | Advanced | `07-advanced-pipeline.yaml` · `07-pipelinerun-skip-tests.yaml` |
| 08 | [Chains & Security](#08-chains--security) | Advanced | `08-chains-config.yaml` · `08-signing-pipeline.yaml` |
| 09 | [Container Build Pipeline](#09-container-build-pipeline) | Advanced | `09-production-pipeline.yaml` · `.tekton/push.yaml` |

Each directory also contains a `commands.yaml` file with the exact commands for that topic.

---

## Prerequisites

- `kubectl` installed and configured
- A local or remote Kubernetes cluster (see [Cluster Options](#cluster-options) below)
- Basic Kubernetes familiarity (Pods, Namespaces, CRDs)
- `tkn` CLI — [installation instructions](https://tekton.dev/docs/cli/)

Topics 06–09 additionally require:
- A container registry account (Docker Hub, Quay.io, etc.)
- `cosign` — for topic 08 ([installation](https://docs.sigstore.dev/cosign/system_config/installation/))

---

## Cluster Options

All `kubectl` and `tkn` commands are identical across cluster types — only the setup step differs.

| Cluster | Notes |
|---------|-------|
| [Kind](https://kind.sigs.k8s.io/) | Recommended. Docker-based, no VM, ~30s setup. Config file provided in `01-installation/`. |
| [Minikube](https://minikube.sigs.k8s.io/docs/start/) | Single-node with built-in addons. `minikube start --cpus=4 --memory=8192` |
| [CRC — OpenShift Local](https://developers.redhat.com/products/openshift-local/overview) | Full OpenShift experience locally. Closest to Konflux production. Requires ≥18 GB RAM. |
| [OpenShift](https://www.redhat.com/en/technologies/cloud-computing/openshift) | Tekton pre-installed as OpenShift Pipelines. No separate install needed. |

---

## Repository Structure

```
tekton-field-guide/
├── 01-installation/
│   ├── kind-config.yaml
│   └── commands.yaml
├── 02-tasks-and-taskruns/
│   ├── 02-hello-task.yaml
│   ├── 02-taskrun.yaml
│   ├── 02-build-info-task.yaml
│   └── commands.yaml
├── 03-pipelines-and-pipelineruns/
│   ├── 03-tasks.yaml
│   ├── 03-pipeline.yaml
│   ├── 03-pipelinerun.yaml
│   └── commands.yaml
├── 04-workspaces/
│   ├── 04-workspace-resources.yaml
│   ├── 04-workspace-pipeline.yaml
│   ├── 04-pipelinerun.yaml
│   └── commands.yaml
├── 05-triggers/
│   ├── 05-triggers-rbac.yaml
│   ├── 05-triggerbinding.yaml
│   ├── 05-triggertemplate.yaml
│   ├── 05-eventlistener.yaml
│   ├── 05-webhook-secret.yaml
│   └── commands.yaml
├── 06-artifact-hub/
│   ├── 06-registry-secret.yaml
│   ├── 06-ci-pipeline-catalog.yaml
│   ├── 06-pipeline-pvc.yaml
│   ├── 06-pipelinerun.yaml
│   └── commands.yaml
├── 07-advanced-patterns/
│   ├── 07-advanced-pipeline.yaml
│   ├── 07-pipelinerun-skip-tests.yaml
│   └── commands.yaml
├── 08-chains-and-security/
│   ├── 08-chains-config.yaml
│   ├── 08-signing-pipeline.yaml
│   └── commands.yaml
└── 09-container-build-pipeline/
    ├── 09-production-pipeline.yaml
    ├── .tekton/
    │   └── push.yaml
    └── commands.yaml
```

> **Note:** Directory names above reflect the recommended naming convention. Your local clone may use the longer descriptive names — the file contents are identical.

---

## Topics

### 01 Architecture & Installation

Install Tekton on a local Kubernetes cluster and explore the API surface.

**You will learn:**
- Why Tekton exists and how it differs from Jenkins/GitHub Actions
- Tekton's four components: Pipelines, Triggers, Chains, Dashboard
- How Tekton maps to Kubernetes primitives (CRDs, Pods, PVCs)
- Installing Tekton Pipelines, the Dashboard, and the `tkn` CLI
- Browsing Tekton CRDs with `kubectl explain`

**Key facts:**
- Tekton is Kubernetes-native — every resource is a CRD
- Every pipeline run becomes real Kubernetes Pods
- Tekton v1 API is stable — use `tekton.dev/v1`

---

### 02 Tasks & TaskRuns

Build Tasks of increasing complexity and understand how Tekton executes them.

**You will learn:**
- Task anatomy: steps, params, results, workspaces, stepTemplate
- How each Step becomes a container in a Pod
- Declaring and consuming Parameters with `$(params.name)` syntax
- Writing Task Results to `$(results.name.path)`
- Running TaskRuns imperatively (`tkn task start`) and declaratively

**Key facts:**
- Task = reusable unit of work defined as a CRD
- Steps run sequentially in the same Pod
- TaskRun = one execution instance of a Task
- `stepTemplate` reduces repetition across steps

---

### 03 Pipelines & PipelineRuns

Chain Tasks into a DAG with sequential and parallel execution.

**You will learn:**
- Pipeline structure and how it references Tasks via `taskRef`
- Sequential vs parallel execution with `runAfter`
- Passing Task results to downstream tasks with `$(tasks.<name>.results.<key>)`
- Pipeline-level params and results
- Visualising the DAG in Tekton Dashboard

**Key facts:**
- Pipeline = ordered DAG of Task instances
- Tasks without a shared `runAfter` dependency run in parallel
- PipelineRun = one execution of a Pipeline
- `taskRunSpecs` sets per-task resource limits

---

### 04 Workspaces

Share files, secrets, and configuration between Tasks using Workspaces.

**You will learn:**
- Why Task Results aren't enough — you need Workspaces for large data
- Four workspace types: PVC, emptyDir, ConfigMap, Secret
- Declaring workspaces in Tasks and Pipelines
- Binding workspace types in a PipelineRun
- The clone-then-build pattern
- Optional workspaces with `$(workspaces.name.bound)` conditional logic

**Key facts:**
- PVC = persistent, shared across Tasks; emptyDir = ephemeral, per-TaskRun
- ConfigMap/Secret workspaces inject config as files
- Always use `$(workspaces.name.path)` — never hardcode paths

---

### 05 Triggers

Fire pipelines automatically from GitHub webhook events.

**You will learn:**
- The three Trigger CRDs: EventListener, TriggerBinding, TriggerTemplate
- How HTTP webhooks become PipelineRuns
- Extracting values from webhook payloads with TriggerBinding
- RBAC setup required for the EventListener ServiceAccount
- Computing a valid HMAC-SHA256 signature for local testing with curl
- Exposing the EventListener to GitHub with ngrok

**Key facts:**
- EventListener = HTTP server that receives webhook events
- TriggerBinding extracts; TriggerTemplate creates
- RBAC is the most common reason Triggers fail silently
- GitHub interceptor validates HMAC-SHA256 — `SKIP_FOR_LOCAL_TEST` does not work

---

### 06 Artifact Hub & Community Tasks

Use community-maintained catalog Tasks via resolvers — no hub install needed.

**You will learn:**
- Why Tekton Hub (`hub.tekton.dev`) is deprecated and offline
- Browsing Tasks on [Artifact Hub](https://artifacthub.io/packages/search?kind=7)
- Installing catalog Tasks directly from `tektoncd/catalog` on GitHub
- Using the `git-clone` and `buildah` catalog Tasks
- The `http` resolver — Tekton fetches Task definitions at runtime

**Key facts:**
- `tkn hub search` no longer works — Tekton Hub API is offline
- `kubectl apply -f <raw-github-url>` is the reliable install method
- Resolvers (http, git, bundle) fetch tasks at runtime with no pre-installation
- Registry secret key must be named `config.json`, not `.dockerconfigjson`, for buildah

---

### 07 Advanced Patterns

Conditional execution, guaranteed cleanup, fan-out builds, and retries.

**You will learn:**
- `when` expressions for conditional task skipping
- `finally` block for cleanup and notifications that always run
- `matrix` for fan-out parallel execution over a list of values
- Inline `taskSpec` vs external `taskRef`
- `retries` and `timeout` on pipeline tasks

**Key facts:**
- `when` skips tasks conditionally — a skipped task is not a failure
- `finally` always runs, even if the pipeline fails or is cancelled
- `matrix` creates one TaskRun per value in the list, all in parallel
- Finally tasks can read `$(context.pipelineRun.name)` and `$(context.pipelineRun.namespace)`

---

### 08 Chains & Security

Automatically sign images and generate SLSA provenance with Tekton Chains.

**You will learn:**
- What SLSA is and why supply chain security matters
- How Chains works as a passive observer — zero pipeline changes needed
- Installing and configuring Tekton Chains
- Generating a cosign key pair stored as a Kubernetes Secret
- Verifying image signatures and SLSA attestations with `cosign verify`

**Key facts:**
- Chains watches TaskRuns for `IMAGE_URL` and `IMAGE_DIGEST` results
- Attestations are stored as OCI artifacts alongside the image
- `artifacts.oci.format` only accepts `simplesigning` — not `slsa/v1`
- `artifacts.taskrun.format` and `artifacts.pipelinerun.format` use `in-toto`
- This is the foundation for SLSA Level 3 — what Konflux achieves in production

---

### 09 Container Build Pipeline

A production-grade end-to-end pipeline: clone → test → build → SBOM → scan → sign → push.

**You will learn:**
- Composing all previous topics into one production pipeline
- Correct task ordering for a secure CI/CD pipeline
- SBOM generation with syft running in parallel with vulnerability scanning
- Vulnerability scanning with Trivy before pushing to production
- Pipeline as Code — storing pipeline definitions in `.tekton/` in the app repo
- Parameterisation for reuse across multiple applications

**Sample repo for testing:** [`traefik/whoami`](https://github.com/traefik/whoami) — a minimal Go HTTP server with a self-contained Dockerfile, no broken dependencies, builds in under a minute.

**Key facts:**
- Scan after build, before promoting to production registries
- SBOM generation runs in parallel with scanning — saves time
- `anchore/syft:latest` is distroless — use `alpine` and install syft inline
- Registry secret key must be named `config.json` for the inline buildah task
- `.tekton/push.yaml` is how Tekton Pipeline as Code (PaC) triggers per-push builds
- This pipeline structure directly maps to Konflux's production build pipeline

---

## Konflux Connection

Each topic maps directly to how [Konflux](https://konflux-ci.dev/) works internally:

| Topic | Konflux equivalent |
|-------|--------------------|
| Installation | Tekton Pipelines + Triggers + Chains installed cluster-wide on OpenShift |
| Tasks & TaskRuns | Every Konflux build task (`clone-repository`, `build-container`, etc.) follows this exact pattern |
| Pipelines | Konflux build pipeline: ~12 tasks, DAG with parallel scanning |
| Workspaces | `workspace` (PVC), `git-auth` (Secret), `registry-auth` (Secret) in every build PipelineRun |
| Triggers | PaC controller registers webhooks and creates PipelineRuns on push |
| Artifact Hub | Konflux uses OCI bundle references from `quay.io/konflux-ci/tekton-catalog` |
| Advanced Patterns | `when` guards for `skip-checks`, `matrix` for multi-arch builds, `finally` for SBOM upload |
| Chains | Every Konflux build is automatically signed and attested at SLSA Level 3 |
| Build Pipeline | The production pipeline here is a simplified version of Konflux's default build pipeline |

---

## Notes

- **Tekton Hub is offline.** `tkn hub search` and `tkn hub install` no longer work. Use [Artifact Hub](https://artifacthub.io/packages/search?kind=7) or apply task YAMLs directly from [tektoncd/catalog](https://github.com/tektoncd/catalog) on GitHub.
- **Registry credentials.** The `buildah` task requires the secret key to be named `config.json`. Use `kubectl create secret generic` with `--from-file=config.json` — not `kubectl create secret docker-registry` which creates `.dockerconfigjson`.
- **`optional: true` on workspace bindings.** This field is only valid on pipeline-level workspace declarations (`spec.workspaces[*]`) and inline taskSpec workspace declarations. It is not valid on `spec.tasks[*].workspaces[*]` and will cause a strict decoding error.
- **All YAMLs tested** against Tekton Pipelines `latest` on a Kind cluster.
