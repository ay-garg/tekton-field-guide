# ── Tekton Hub is fully deprecated — tkn hub commands do NOT work ──
# The hub.tekton.dev API is offline. The tkn hub CLI has no working
# replacement for search/install yet. Use one of these two approaches:

# ── OPTION A: Browse Artifact Hub in your browser ───────────────
# https://artifacthub.io/packages/search?kind=7
# Find a task, click it, copy the raw GitHub YAML URL from the Install tab.

# ── OPTION B (preferred): Apply task YAML directly from GitHub ───
# No hub needed — point kubectl at the raw file in tektoncd/catalog.
$ kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml
$ kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/buildah/0.7/buildah.yaml

# Verify tasks landed in the cluster
$ tkn task list
$ tkn task describe git-clone   # shows params, workspaces, results

# ── OPTION C (most modern): http resolver — zero installation ────
# The pipeline in 06-ci-pipeline-catalog.yaml already uses this.
# Tekton fetches the task YAML from GitHub at runtime per PipelineRun,
# so you never need to kubectl apply the tasks at all.

# Create the PVC
$ kubectl apply -f 06-pipeline-pvc.yaml

# Create registry credentials.
# IMPORTANT: buildah looks for a file named "config.json" at the workspace
# root — NOT ".dockerconfigjson". Use "kubectl create secret generic" with
# --from-file=config.json, NOT "kubectl create secret docker-registry".

# Option A — reuse an existing local Docker/Podman login (simplest):
$ kubectl create secret generic registry-credentials \
  --from-file=config.json=$HOME/.docker/config.json

# Option B — create inline for docker.io (replace USER and TOKEN):
$ AUTH=$(echo -n "YOUR_USERNAME:YOUR_TOKEN" | base64)
$ kubectl create secret generic registry-credentials \
  --from-literal=config.json="{\"auths\":{\"https://index.docker.io/v1/\":{\"auth\":\"$AUTH\"}}}"

# Option C — create inline for quay.io:
$ AUTH=$(echo -n "YOUR_USERNAME:YOUR_TOKEN" | base64)
$ kubectl create secret generic registry-credentials \
  --from-literal=config.json="{\"auths\":{\"quay.io\":{\"auth\":\"$AUTH\"}}}"

# Apply and run the pipeline
$ kubectl apply -f 06-ci-pipeline-catalog.yaml
$ kubectl apply -f 06-pipelinerun.yaml

# Follow the logs
$ tkn pipelinerun logs container-ci-run-001 -f

# When complete, check the results (image URL and digest)
$ tkn pipelinerun describe container-ci-run-001