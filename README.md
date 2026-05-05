# BidMart Deployment

This repository contains deployment configuration for the BidMart microservice architecture.

## Core Stack

The current core Docker Compose stack runs:

- `frontend-bidmart`
- `bidmart-api-gateway`
- `bidmart-auth-service`
- `auth-db`

## Architecture

External/public communication:

~~~text
User Browser -> frontend-bidmart -> bidmart-api-gateway
~~~

Internal service-to-service communication:

~~~text
bidmart-api-gateway -> bidmart-auth-service via gRPC
~~~

Database communication:

~~~text
bidmart-auth-service -> auth-db
~~~

## Run Locally

~~~bash
cp .env.example .env
docker compose up -d --build
./scripts/smoke-docker-compose.sh
~~~

## URLs

~~~text
Frontend:     http://localhost:5173
API Gateway:  http://localhost:8080
Auth Service: http://localhost:8081
Auth gRPC:    localhost:9091
Auth DB:      localhost:5434/auth_db
~~~

## Default Local Admin

~~~text
username: admin
password: admin12345
~~~

## Important Docker Networking Rule

Inside Docker Compose, services must communicate using Docker service names, not `localhost`.

Correct:

~~~text
API Gateway -> http://bidmart-auth-service:8081
API Gateway -> bidmart-auth-service:9091
Auth Service -> jdbc:postgresql://auth-db:5432/auth_db
~~~

Wrong:

~~~text
API Gateway -> http://localhost:8081
Auth Service -> jdbc:postgresql://localhost:5434/auth_db
~~~

## Smoke Test Coverage

The smoke test validates:

- API Gateway health endpoint
- Frontend availability
- Auth DB ping through Gateway
- Captcha issuance through Gateway
- Login through Gateway
- Protected endpoint through Gateway
- API Gateway to Auth Service gRPC status

Run:

~~~bash
./scripts/smoke-docker-compose.sh
~~~

## Current Scope

This deployment stack intentionally starts with the core Auth flow first.

Catalog Service, Auction-Wallet Service, RabbitMQ, Prometheus, and Grafana can be added after the core stack is stable.
