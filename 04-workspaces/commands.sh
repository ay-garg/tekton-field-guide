# Apply storage resources
$ kubectl apply -f 04-workspace-resources.yaml

# Verify PVC was created (it will be Pending until a task claims it)
$ kubectl get pvc pipeline-workspace-pvc

# Apply the pipeline
$ kubectl apply -f 04-workspace-pipeline.yaml

# Start the pipeline run
$ kubectl apply -f 04-pipelinerun.yaml

# Follow logs across all tasks
$ tkn pipelinerun logs workspace-demo-run-001 -f

# Inspect workspace bindings in the PipelineRun spec
$ kubectl get pipelinerun workspace-demo-run-001 -o yaml | grep -A 20 workspaces

# After completion — PVC is still there with the built artifact
$ kubectl get pvc pipeline-workspace-pvc

# Show workspace types: emptyDir variant
$ tkn pipeline start workspace-demo-pipeline \
  --workspace name=source,emptyDir="" \
  --workspace name=build-config,config=build-config \
  --param app-name="emptydir-test" \
  --showlog

# Create a registry secret to demonstrate optional workspace binding
$ kubectl create secret docker-registry registry-push-secret \
  --docker-server=quay.io \
  --docker-username=myuser \
  --docker-password=mypassword