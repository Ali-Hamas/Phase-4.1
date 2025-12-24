# Docker Container Specification

## Backend Container (Python FastAPI)
- **Base Image**: `python:3.12-slim`
- **Working Dir**: `/app`
- **Dependencies**: Copy `requirements.txt` (or `pyproject.toml`) and run `pip install --no-cache-dir`.
- **System Dependencies**: Install `curl` (for health checks).
- **Copy Source**: Copy the `app/` (or root backend files) into `/app`.
- **Command**: `uvicorn main:app --host 0.0.0.0 --port 8000`
- **Expose**: Port 8000

## Frontend Container (Next.js)
- **Base Image**: `node:20-alpine`
- **Strategy**: Multi-stage build (Builder stage -> Runner stage) to keep image small.
- **Builder**: Install dependencies (`npm ci`), copy source, run `npm run build`.
- **Runner**: Copy `.next/standalone` and `public` folders.
- **Command**: `node server.js`
- **Env Vars**: Accept `NEXT_PUBLIC_API_URL` as a build argument.
- **Expose**: Port 3000