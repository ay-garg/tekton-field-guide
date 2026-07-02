# ── STEP 1: Install Kind ──────────────────────────────────────
# macOS
$ brew install kind

# Linux
$ curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind

# Windows (PowerShell)
# choco install kind

# Verify
$ kind --version

# ── STEP 2: Create the Kind cluster ───────────────────────────
$ kind create cluster --config kind-config.yaml

# Verify the cluster is up and kubectl context is set
$ kubectl cluster-info --context kind-tekton-demo
$ kubectl get nodes

# ── STEP 3: Install Tekton Pipelines (latest stable) ──────────
$ kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Wait for Tekton controller to be ready
$ kubectl wait --for=condition=ready pod \
  --selector=app=tekton-pipelines-controller \
  --namespace=tekton-pipelines \
  --timeout=180s

# Verify all Tekton pods are Running
$ kubectl get pods -n tekton-pipelines

# ── STEP 4: Install Tekton Dashboard ──────────────────────────
$ kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml

# ── STEP 5: Install tkn CLI ───────────────────────────────────
# macOS
$ brew install tektoncd-cli

# Linux — check https://github.com/tektoncd/cli/releases for the latest version
$ curl -LO https://github.com/tektoncd/cli/releases/latest/download/tkn_Linux_x86_64.tar.gz
$ tar xzf tkn_Linux_x86_64.tar.gz -C /usr/local/bin tkn

# ── STEP 6: Verify everything ─────────────────────────────────
$ tkn version
$ kubectl get pods -n tekton-pipelines

# Explore Tekton CRDs installed in the cluster
$ kubectl get crds | grep tekton

# Explain the Task CRD fields
$ kubectl explain task.spec
$ kubectl explain task.spec.steps

# ── STEP 7: Open the Dashboard ────────────────────────────────
$ kubectl port-forward -n tekton-pipelines svc/tekton-dashboard 9097:9097
# Open: http://localhost:9097

# ── ALTERNATIVE cluster setups (commands above are identical after this) ──
# Minikube:
#   minikube start --cpus=4 --memory=8192 --disk-size=30g
#   minikube addons enable ingress
#
# CRC (OpenShift Local):
#   crc start --cpus 4 --memory 12288
#   eval $(crc oc-env)          # OpenShift Pipelines (Tekton) already installed
#
# OpenShift / Any Kubernetes:
#   oc login https://api.your-cluster.example.com
#   # On OpenShift, install OpenShift Pipelines Operator from OperatorHub instead:
#   # OperatorHub > OpenShift Pipelines > Install