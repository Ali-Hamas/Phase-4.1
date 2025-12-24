@echo off
echo Starting port-forwards...
echo.
echo IMPORTANT: Keep this window open!
echo Press Ctrl+C to stop.
echo.

:loop
echo [%time%] Starting backend port-forward...
start /B kubectl port-forward svc/todo-backend 8000:8000 -n todo-app

echo [%time%] Starting frontend port-forward...  
start /B kubectl port-forward svc/todo-frontend 3000:3000 -n todo-app

echo.
echo Port-forwards started!
echo - Backend: http://localhost:8000
echo - Frontend: http://localhost:3000
echo.
echo Open http://localhost:3000 in your browser.
echo.

pause
goto loop
