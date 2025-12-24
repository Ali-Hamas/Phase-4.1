# Local Minikube Deployment Script for Todo App
# This script builds Docker images inside Minikube and deploys using Helm

Write-Host "=== Todo App Local Deployment ===" -ForegroundColor Green
Write-Host ""

# Step 1: Configure Docker to use Minikube's Docker daemon
Write-Host "Step 1: Configuring Docker to use Minikube's daemon..." -ForegroundColor Cyan
minikube -p minikube docker-env | Invoke-Expression

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to configure Minikube Docker environment" -ForegroundColor Red
    Write-Host "Make sure Minikube is running: minikube start" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Docker environment configured" -ForegroundColor Green
Write-Host ""

# Step 2: Build backend image
Write-Host "Step 2: Building backend Docker image..." -ForegroundColor Cyan
docker build -t todo-backend:local ./backend

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to build backend image" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Backend image built: todo-backend:local" -ForegroundColor Green
Write-Host ""

# Step 3: Build frontend image
Write-Host "Step 3: Building frontend Docker image..." -ForegroundColor Cyan
docker build -t todo-frontend:local ./frontend

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to build frontend image" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Frontend image built: todo-frontend:local" -ForegroundColor Green
Write-Host ""

# Step 4: Deploy with Helm
Write-Host "Step 4: Deploying to Kubernetes with Helm..." -ForegroundColor Cyan
helm upgrade --install todo-v1 ./k8s/chart -n todo-app --create-namespace

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to deploy with Helm" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Helm deployment successful" -ForegroundColor Green
Write-Host ""

# Summary
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "To check the deployment status:" -ForegroundColor Yellow
Write-Host "  kubectl get pods -n todo-app" -ForegroundColor White
Write-Host ""
Write-Host "To view services:" -ForegroundColor Yellow
Write-Host "  kubectl get svc -n todo-app" -ForegroundColor White
Write-Host ""
Write-Host "To access the application:" -ForegroundColor Yellow
Write-Host "  minikube service todo-frontend -n todo-app" -ForegroundColor White
Write-Host ""
