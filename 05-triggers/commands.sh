# Install Tekton Triggers
$ kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
$ kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml

# Wait for triggers components to be ready
$ kubectl wait --for=condition=ready pod \
  --selector=app=tekton-triggers-controller \
  --namespace=tekton-pipelines \
  --timeout=120s

# Apply RBAC, secret, and trigger resources in order
$ kubectl apply -f 05-webhook-secret.yaml
$ kubectl apply -f 05-triggers-rbac.yaml
$ kubectl apply -f 05-triggerbinding.yaml
$ kubectl apply -f 05-triggertemplate.yaml
$ kubectl apply -f 05-eventlistener.yaml

# Verify EventListener pod is running
$ kubectl get pods | grep el-github-push-listener
$ kubectl get eventlistener github-push-listener

# Port-forward the EventListener service for local testing
$ kubectl port-forward svc/el-github-push-listener 8080:8080 &

# Simulate a GitHub push webhook with curl.
# The GitHub interceptor validates the HMAC-SHA256 signature — it MUST match
# the webhook secret. Compute it from the exact payload bytes before sending.

$ PAYLOAD='{"ref":"refs/heads/main","head_commit":{"id":"abc123def456"},"repository":{"name":"my-repo","clone_url":"https://github.com/myorg/my-repo"},"pusher":{"name":"developer1"}}'
$ SECRET="my-super-secret-webhook-key-change-this"
$ SIG=$(printf '%s' "$PAYLOAD" | openssl dgst -sha256 -hmac "$SECRET" | awk '{print $2}')

$ curl -v -X POST http://localhost:8080 \
  -H 'Content-Type: application/json' \
  -H 'X-GitHub-Event: push' \
  -H "X-Hub-Signature-256: sha256=${SIG}" \
  -d "$PAYLOAD"

# Watch the PipelineRun get created automatically
$ kubectl get pipelineruns -w

# For real GitHub integration — use ngrok to expose the service
$ ngrok http 8080
# Copy the https ngrok URL and add it in:
# GitHub repo Settings > Webhooks > Add webhook
# Payload URL: https://your-ngrok-url.ngrok.io
# Content type: application/json
# Secret: my-super-secret-webhook-key-change-this
# Events: Just the push event