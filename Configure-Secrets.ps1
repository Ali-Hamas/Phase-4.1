# Configure-Secrets.ps1 - Sets up Kubernetes secrets from .env file
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Configuring Kubernetes Secrets  " -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Read .env file
$envFile = ".\backend\.env"
if (-not (Test-Path $envFile)) {
    Write-Host "ERROR: .env file not found at $envFile" -ForegroundColor Red
    exit 1
}

# Parse .env file
$envVars = @{}
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^([^#][^=]+)=(.*)$') {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        # Remove quotes if present
        $value = $value -replace '^["'']|["'']$', ''
        $envVars[$key] = $value
    }
}

# Get values with defaults
$openaiKey = $envVars['OPENAI_API_KEY']
$databaseUrl = if ($envVars['DATABASE_URL']) { $envVars['DATABASE_URL'] } else { "" }
$betterAuthSecret = if ($envVars['BETTER_AUTH_SECRET']) { $envVars['BETTER_AUTH_SECRET'] } else { "local-dev-secret" }

if (-not $openaiKey) {
    Write-Host "ERROR: OPENAI_API_KEY not found in .env file" -ForegroundColor Red
    exit 1
}

Write-Host "Found OPENAI_API_KEY: $($openaiKey.Substring(0, 10))..." -ForegroundColor Green
Write-Host ""

# Delete existing secret if it exists
Write-Host "Updating Kubernetes secret..." -ForegroundColor Yellow
kubectl delete secret todo-secrets -n todo-app 2>$null

# Create new secret
kubectl create secret generic todo-secrets `
    --from-literal=OPENAI_API_KEY=$openaiKey `
    --from-literal=DATABASE_URL=$databaseUrl `
    --from-literal=BETTER_AUTH_SECRET=$betterAuthSecret `
    -n todo-app

if ($LASTEXITCODE -eq 0) {
    Write-Host "Secret created successfully!" -ForegroundColor Green
}
else {
    Write-Host "ERROR: Failed to create secret" -ForegroundColor Red
    exit 1
}

# Restart backend pod
Write-Host ""
Write-Host "Restarting backend pod..." -ForegroundColor Yellow
kubectl rollout restart deployment/todo-backend -n todo-app

Write-Host ""
Write-Host "Waiting for pod to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

kubectl get pods -n todo-app

Write-Host ""
Write-Host "==================================" -ForegroundColor Green
Write-Host "  Configuration Complete!        " -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""
Write-Host "Now run these commands in separate terminals:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Terminal 1 (Backend):" -ForegroundColor White
Write-Host "  kubectl port-forward svc/todo-backend 8000:8000 -n todo-app" -ForegroundColor Yellow
Write-Host ""
Write-Host "Terminal 2 (Frontend):" -ForegroundColor White
Write-Host "  minikube service todo-frontend -n todo-app" -ForegroundColor Yellow
Write-Host ""
