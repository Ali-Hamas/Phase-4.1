# Start-LocalDev.ps1 - Keeps port-forwards running
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Todo Chat Bot - Local Dev Mode  " -ForegroundColor Cyan  
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Get pod names
$backendPod = kubectl get pods -n todo-app -l app=todo-backend -o jsonpath='{.items[0].metadata.name}'
$frontendPod = kubectl get pods -n todo-app -l app=todo-frontend -o jsonpath='{.items[0].metadata.name}'

Write-Host "Backend pod: $backendPod" -ForegroundColor Green
Write-Host "Frontend pod: $frontendPod" -ForegroundColor Green
Write-Host ""

# Start port-forwards as background jobs
Write-Host "Starting port-forwards..." -ForegroundColor Yellow

$backendJob = Start-Job -ScriptBlock {
    param($pod)
    while ($true) {
        kubectl port-forward pod/$pod 8000:8000 -n todo-app 2>&1
        Start-Sleep -Seconds 1
    }
} -ArgumentList $backendPod

$frontendJob = Start-Job -ScriptBlock {
    param($pod)
    while ($true) {
        kubectl port-forward pod/$pod 3000:3000 -n todo-app 2>&1
        Start-Sleep -Seconds 1
    }
} -ArgumentList $frontendPod

Write-Host ""
Write-Host "Port-forwards started!" -ForegroundColor Green
Write-Host "  Backend:  http://localhost:8000" -ForegroundColor White
Write-Host "  Frontend: http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "Open http://localhost:3000 in your browser" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop..." -ForegroundColor Yellow
Write-Host ""

# Keep script running and monitor jobs
try {
    while ($true) {
        Start-Sleep -Seconds 5
        
        # Check job status
        $backendState = (Get-Job -Id $backendJob.Id).State
        $frontendState = (Get-Job -Id $frontendJob.Id).State
        
        if ($backendState -ne "Running") {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Restarting backend port-forward..." -ForegroundColor Yellow
            Remove-Job -Id $backendJob.Id -Force -ErrorAction SilentlyContinue
            $backendJob = Start-Job -ScriptBlock {
                param($pod)
                while ($true) {
                    kubectl port-forward pod/$pod 8000:8000 -n todo-app 2>&1
                    Start-Sleep -Seconds 1
                }
            } -ArgumentList $backendPod
        }
        
        if ($frontendState -ne "Running") {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Restarting frontend port-forward..." -ForegroundColor Yellow
            Remove-Job -Id $frontendJob.Id -Force -ErrorAction SilentlyContinue
            $frontendJob = Start-Job -ScriptBlock {
                param($pod)
                while ($true) {
                    kubectl port-forward pod/$pod 3000:3000 -n todo-app 2>&1
                    Start-Sleep -Seconds 1
                }
            } -ArgumentList $frontendPod
        }
    }
}
finally {
    Write-Host "Stopping port-forwards..." -ForegroundColor Yellow
    Stop-Job -Id $backendJob.Id -ErrorAction SilentlyContinue
    Stop-Job -Id $frontendJob.Id -ErrorAction SilentlyContinue
    Remove-Job -Id $backendJob.Id -ErrorAction SilentlyContinue
    Remove-Job -Id $frontendJob.Id -ErrorAction SilentlyContinue
    Write-Host "Done!" -ForegroundColor Green
}
