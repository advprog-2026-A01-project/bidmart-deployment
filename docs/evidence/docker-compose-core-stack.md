# Docker Compose Evidence: Core BidMart Stack

## Purpose

This document records deployment evidence for the core BidMart microservice stack.

## Services

~~~text
frontend-bidmart
bidmart-api-gateway
bidmart-auth-service
auth-db
~~~

## Verified Command

~~~bash
docker compose up -d --build
./scripts/smoke-docker-compose.sh
~~~

## Verified Architecture

External path:

~~~text
Browser -> Frontend -> API Gateway
~~~

Internal REST/JWKS path:

~~~text
API Gateway -> Auth Service REST/JWKS
~~~

Internal gRPC path:

~~~text
API Gateway -> Auth Service gRPC
~~~

Database path:

~~~text
Auth Service -> auth-db
~~~

## Rubric Mapping

### Software Architecture

- API Gateway is the single public backend entry point.
- Frontend does not call internal services directly.
- gRPC is used for internal service-to-service communication.
- Auth Service owns its own database.

### Software Deployment

- Core services are containerized.
- Core services run as one Docker Compose deployment stack.
- Service-to-service communication uses Docker network names.
- Smoke test verifies the deployed stack.

### Software Quality

- Deployment has an automated smoke test.
- Environment variables are documented in `.env.example`.
- `.env` is ignored and not committed.
