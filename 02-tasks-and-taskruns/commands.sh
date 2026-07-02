# Apply the Task definition
$ kubectl apply -f 02-hello-task.yaml

# List tasks in the cluster
$ tkn task list

# Describe the task (shows params, results, steps)
$ tkn task describe hello-world

# Run declaratively
$ kubectl apply -f 02-taskrun.yaml

# Follow logs in real time
$ tkn taskrun logs hello-world-run-001 -f

# Describe the run — see status, results, pod name
$ tkn taskrun describe hello-world-run-001

# Inspect the underlying Pod
$ kubectl get pods | grep hello-world-run-001
$ kubectl describe pod hello-world-run-001-pod

# Run imperatively with the CLI (creates TaskRun automatically)
$ tkn task start hello-world \
  --param name="Konflux Engineer" \
  --param language="spanish" \
  --showlog

# Apply and run the second task
$ kubectl apply -f 02-build-info-task.yaml
$ tkn task start build-info \
  --param image-name="my-app" \
  --param git-revision="abc1234" \
  --param registry="quay.io/myorg" \
  --showlog

# See the results captured by Tekton
$ tkn taskrun describe --last