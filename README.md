# BidMart Deployment
### ***By Neal Guarddin - Advance Programming A - 2406348282***

Repository ini berisi konfigurasi deployment untuk arsitektur microservice BidMart.

Tujuan utama repository ini adalah menyediakan satu tempat untuk menjalankan service-service utama BidMart secara terintegrasi menggunakan Docker Compose.

## Core Stack

Untuk tahap saat ini, stack utama yang dijalankan adalah:

- `frontend-bidmart`
- `bidmart-api-gateway`
- `bidmart-auth-service`
- `auth-db`

Service lain seperti `bidmart-catalog-service`, `bidmart-auction-wallet-service`, RabbitMQ, Prometheus, dan Grafana akan ditambahkan setelah core Auth flow stabil.

## Arsitektur

Komunikasi eksternal:

~~~text
User Browser -> frontend-bidmart -> bidmart-api-gateway
~~~

Komunikasi internal antar-service:

~~~text
bidmart-api-gateway -> bidmart-auth-service via gRPC
~~~

Komunikasi database:

~~~text
bidmart-auth-service -> auth-db
~~~

Dengan arsitektur ini, frontend tidak memanggil Auth Service secara langsung. Semua request dari frontend masuk melalui API Gateway.

## Cara Menjalankan Local Deployment

Pastikan Docker dan Docker Compose sudah terinstall.

Dari repository ini, jalankan:

~~~bash
cp .env.example .env
docker compose up -d --build
./scripts/smoke-docker-compose.sh
~~~

Jika ingin menjalankan ulang dari kondisi bersih:

~~~bash
docker compose down -v --remove-orphans
docker compose up -d --build
./scripts/smoke-docker-compose.sh
~~~

## URL Local

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

## Aturan Penting Docker Networking

Di dalam Docker Compose, antar-container tidak boleh menggunakan `localhost`.

Gunakan nama service Docker.

Benar:

~~~text
API Gateway -> http://bidmart-auth-service:8081
API Gateway -> bidmart-auth-service:9091
Auth Service -> jdbc:postgresql://auth-db:5432/auth_db
~~~

Salah:

~~~text
API Gateway -> http://localhost:8081
Auth Service -> jdbc:postgresql://localhost:5434/auth_db
~~~

Alasannya, `localhost` di dalam container berarti container itu sendiri, bukan host laptop dan bukan container lain.

## Smoke Test

Smoke test digunakan untuk memastikan stack Docker Compose berjalan dengan benar.

Jalankan:

~~~bash
./scripts/smoke-docker-compose.sh
~~~

Smoke test memvalidasi:

- API Gateway health endpoint
- Frontend dapat diakses
- Auth DB ping melalui Gateway
- Captcha issuance melalui Gateway
- Login admin melalui Gateway
- Protected endpoint melalui Gateway
- Komunikasi internal API Gateway ke Auth Service melalui gRPC

## Troubleshooting

### Container name conflict

Jika muncul error seperti:

~~~text
Conflict. The container name "/bidmart-auth-db" is already in use
~~~

hapus container lama:

~~~bash
docker compose down -v --remove-orphans
docker rm -f bidmart-auth-db 2>/dev/null || true
docker rm -f bidmart-db-1 2>/dev/null || true
docker compose up -d --build
~~~

### Melihat status container

~~~bash
docker compose ps
~~~

### Melihat logs Auth Service

~~~bash
docker compose logs --tail=200 bidmart-auth-service
~~~

### Melihat logs API Gateway

~~~bash
docker compose logs --tail=200 bidmart-api-gateway
~~~

### Melihat logs Frontend

~~~bash
docker compose logs --tail=200 frontend-bidmart
~~~

## File Environment

File `.env.example` berisi contoh environment variable yang dibutuhkan untuk local deployment.

File `.env` digunakan untuk konfigurasi lokal dan tidak boleh di-commit.

## Catatan Scope Saat Ini

Deployment ini fokus pada core Auth flow terlebih dahulu:

~~~text
Frontend -> API Gateway -> Auth Service -> Auth DB
                       |
                       +-> Auth Service via gRPC
~~~

Service Catalog, Auction-Wallet, RabbitMQ, Monitoring, dan Performance Testing akan ditambahkan pada phase berikutnya.
