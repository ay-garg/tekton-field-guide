# Apply all task definitions
$ kubectl apply -f 03-tasks.yaml

# Verify tasks are registered
$ tkn task list

# Apply the pipeline
$ kubectl apply -f 03-pipeline.yaml

# Describe pipeline — shows param definitions and task graph
$ tkn pipeline describe code-quality-pipeline

# Start pipeline interactively (tkn prompts for param values)
$ tkn pipeline start code-quality-pipeline --showlog

# Or apply the PipelineRun declaratively
$ kubectl apply -f 03-pipelinerun.yaml

# Watch the PipelineRun status
$ tkn pipelinerun list
$ tkn pipelinerun logs quality-pipeline-run-001 -f

# Describe the run — see task results and pipeline result
$ tkn pipelinerun describe quality-pipeline-run-001

# See the underlying TaskRuns created by the pipeline
$ kubectl get taskruns --selector=tekton.dev/pipelineRun=quality-pipeline-run-001

# See the DAG in the Dashboard
$ kubectl port-forward -n tekton-pipelines svc/tekton-dashboard 9097:9097
# Open http://localhost:9097 and navigate to the PipelineRun