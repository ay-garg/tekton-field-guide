# Install Tekton Chains
$ kubectl apply -f https://storage.googleapis.com/tekton-releases/chains/latest/release.yaml

# Wait for Chains controller to be ready
$ kubectl wait --for=condition=ready pod \
  --selector=app=tekton-chains-controller \
  --namespace=tekton-chains \
  --timeout=120s

# Install cosign
$ brew install cosign  # macOS
# or: go install github.com/sigstore/cosign/cmd/cosign@latest

# Generate a cosign key pair, stored directly in Kubernetes as a Secret
$ cosign generate-key-pair k8s://tekton-chains/signing-secrets

# The public key is in cosign.pub (save this for verification)
# The private key is in the 'signing-secrets' Secret in tekton-chains namespace

# Configure Chains
$ kubectl apply -f 08-chains-config.yaml

# Restart Chains to pick up the new config
$ kubectl rollout restart deployment tekton-chains-controller -n tekton-chains

# Apply and run the signing task
$ kubectl apply -f 08-signing-pipeline.yaml
$ tkn task start simulate-build-and-push \
  --param image-name="quay.io/myorg/myapp:v1.0" \
  --showlog

# Watch for Chains to annotate the TaskRun (may take 30-60 seconds)
$ kubectl get taskruns --watch
# Look for: chains.tekton.dev/signed: "true"

# Once signed, verify the image signature
$ cosign verify --key cosign.pub quay.io/myorg/myapp:v1.0

# Verify and inspect the SLSA attestation
$ cosign verify-attestation \
  --key cosign.pub \
  --type slsaprovenance \
  quay.io/myorg/myapp:v1.0 | jq .

# The attestation contains:
# - builder.id (your Tekton pipeline)
# - invocation.parameters (what params were used)
# - materials (the git repo and commit SHA)
# - buildType (tekton.dev/v1/TaskRun)