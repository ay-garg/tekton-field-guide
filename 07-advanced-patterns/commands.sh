# Apply the pipeline
$ kubectl apply -f 07-advanced-pipeline.yaml

# Run 1: Normal run (all tasks execute)
$ tkn pipeline start advanced-patterns-pipeline \
  --param app-name="myapp" \
  --param skip-tests="false" \
  --param run-security-scan="true" \
  --workspace name=source,emptyDir="" \
  --showlog

# Run 2: Skip tests using when expression
$ kubectl apply -f 07-pipelinerun-skip-tests.yaml
$ tkn pipelinerun logs advanced-run-skip-tests -f

# After run — see which tasks were SKIPPED vs COMPLETED
$ tkn pipelinerun describe advanced-run-skip-tests

# See that finally tasks ran even if main tasks are in any state
$ kubectl get taskruns --selector=tekton.dev/pipelineRun=advanced-run-skip-tests

# Test retry behavior — temporarily break a task to see retries
# Edit the pipeline, change security-scan to exit 1, apply, run again

# Check matrix TaskRuns (one per platform)
$ kubectl get taskruns --selector=tekton.dev/pipelineTask=build-multiarch