# Kubernetes Architecture (Minikube)

## Goal
[cite_start]Deploy the Todo Chatbot on a local Minikube cluster using Helm Charts[cite: 502].

## Infrastructure Components
1.  **Namespace**: `todo-app`
2.  **Secrets Management**:
    -   `todo-secrets`: Stores `OPENAI_API_KEY`, `DATABASE_URL`, and `BETTER_AUTH_SECRET`.
3.  **Backend Deployment**:
    -   Image: `todo-backend:local`
    -   Replicas: 1
    -   Liveness Probe: `GET /health` (or root `/`)
4.  **Frontend Deployment**:
    -   Image: `todo-frontend:local`
    -   Replicas: 1
5.  **Networking**:
    -   Service type: `ClusterIP` (we will use port-forwarding for local access).