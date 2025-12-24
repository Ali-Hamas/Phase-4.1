# PowerShell script to force rebuild backend with CORS fix
Write-Host "Starting CORS fix deployment..." -ForegroundColor Cyan

# Step 1: Connect to Minikube Docker
Write-Host "Connecting to Minikube Docker..." -ForegroundColor Yellow
minikube -p minikube docker-env | Invoke-Expression

# Step 2: Force delete the old image
Write-Host "Deleting old backend image..." -ForegroundColor Yellow
docker rmi todo-backend:local -f

# Step 3: Rebuild the backend with no cache
Write-Host "Rebuilding backend with no cache..." -ForegroundColor Yellow
docker build -t todo-backend:local ./backend --no-cache

# Step 4: Delete the existing backend pod to force restart
Write-Host "Deleting backend pod to force restart..." -ForegroundColor Yellow
kubectl delete pod -n todo-app -l app.kubernetes.io/name=todo-backend

# Step 5: Wait for new pod to start
Write-Host "Waiting 10 seconds for new pod to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Done
Write-Host "Update Complete - Restart your tunnels now." -ForegroundColor Green
