# Apply the full pipeline
$ kubectl apply -f 09-production-pipeline.yaml

# Create a PVC for the shared source workspace
$ kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: production-pipeline-pvc
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 1Gi
EOF

# Create registry credentials.
# Key MUST be "config.json" — buildah looks for that exact filename.
# "kubectl create secret docker-registry" creates ".dockerconfigjson" which
# buildah cannot find. Use "kubectl create secret generic" instead.

# Option A — reuse existing local Docker / Podman login:
$ kubectl create secret generic registry-push-credentials \
  --from-file=config.json=$HOME/.docker/config.json

# Option B — inline for docker.io (replace USER and TOKEN):
$ AUTH=$(echo -n "YOUR_USERNAME:YOUR_TOKEN" | base64)
$ kubectl create secret generic registry-push-credentials \
  --from-literal=config.json="{\"auths\":{\"https://index.docker.io/v1/\":{\"auth\":\"$AUTH\"}}}"

# ── Sample repo: traefik/whoami ────────────────────────────────
# A tiny Go HTTP server with a self-contained two-stage Dockerfile.
# - Go project  → unit test step (go test ./...) runs successfully
# - No external pip/npm deps  → fast, reliable build
# - dockerfile-path overrides the pipeline default (./Containerfile)
# - git-revision is empty so git-clone uses HEAD of the default branch
# - git-auth uses emptyDir because the repo is public (no credentials needed)
# - skip-vuln-scan=true skips Trivy for local dev (remove to enable scanning)

$ tkn pipeline start production-container-pipeline \
  --param git-url="https://github.com/traefik/whoami" \
  --param git-revision="" \
  --param image-name="docker.io/YOUR_DOCKERHUB_USERNAME/whoami-prod" \
  --param dockerfile-path="./Dockerfile" \
  --param skip-tests="false" \
  --param skip-vuln-scan="true" \
  --workspace name=source,claimName=production-pipeline-pvc \
  --workspace name=registry-auth,secret=registry-push-credentials \
  # --workspace name=git-auth,secret=git-credentials \  # uncomment for private repos
  --showlog

# View all task logs in sequence as they complete
$ tkn pipelinerun logs --last -f

# Debug a specific failed task
$ tkn taskrun logs --last -f

# After completion — verify Chains signed the image
$ kubectl get taskruns --selector=tekton.dev/pipelineTask=build-container
# Look for: chains.tekton.dev/signed: "true"

# Install Tekton PaC (Pipeline as Code) for the .tekton/ directory approach
$ kubectl apply -f https://raw.githubusercontent.com/openshift-pipelines/pipelines-as-code/stable/release.k8s.yaml