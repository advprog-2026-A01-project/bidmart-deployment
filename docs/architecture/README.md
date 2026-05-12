## Container Diagram

## Anggota Kelompok

**BidMart A01 - Advance Programming A**

1. Neal Guarddin - 2406348282
2. Go Nadine Audelia - 2406348774
3. Renata Gracia - 2406399705
4. Sahila Khairatul Athia - 2406495716
> Bagian ini menjelaskan **container-level architecture** BidMart pada kondisi saat ini dan rancangan masa depan setelah risk storming.

Container diagram digunakan untuk menunjukkan:

- aplikasi/service utama yang membentuk sistem;
- hubungan komunikasi antar-container;
- batas tanggung jawab antar-service;
- perbedaan antara current architecture dan future architecture.

---

## Current Container Diagram

![Current Container Diagram](images/02-current-container.png)

### Deskripsi Singkat

Current container diagram menggambarkan **core deployment BidMart** yang saat ini menjadi fokus utama pada repository `bidmart-deployment`.

Pada tahap ini, sistem berfokus pada **core Auth flow** yang terdiri dari:

| Container | Tanggung Jawab |
|---|---|
| `frontend-bidmart` | Menyediakan user interface untuk pengguna |
| `bidmart-api-gateway` | Menjadi single public backend entry point |
| `bidmart-auth-service` | Menangani authentication, authorization, dan token/session logic |
| `auth-db` | Menyimpan data autentikasi |

### Alur Komunikasi

```text
User Browser
    -> frontend-bidmart
    -> bidmart-api-gateway
    -> bidmart-auth-service
    -> auth-db
```

### Penjelasan Alur

- **Frontend tidak memanggil Auth Service secara langsung.**
- Semua request dari frontend diarahkan terlebih dahulu ke `bidmart-api-gateway`.
- API Gateway kemudian meneruskan request autentikasi ke `bidmart-auth-service` melalui komunikasi internal.
- Auth Service mengakses `auth-db` untuk kebutuhan data autentikasi.
- Dengan struktur ini, API Gateway berperan sebagai **single public backend entry point**.

### Batasan Current Architecture

Current architecture masih terbatas pada core Auth flow.

Service berikut belum menjadi bagian utama dari deployment stabil saat ini:

- `bidmart-catalog-service`
- `bidmart-auction-wallet-service`
- RabbitMQ
- Prometheus
- Grafana

---

## Future Container Diagram

![Future Container Diagram](images/05-future-container.png)

### Deskripsi Singkat

Future container diagram menggambarkan pengembangan BidMart menuju **microservice architecture** yang lebih lengkap.

Pada rancangan ini, `bidmart-api-gateway` tetap menjadi **single public backend entry point**, tetapi gateway tidak hanya meneruskan request ke Auth Service. Gateway juga meneruskan request ke service lain sesuai domain fitur.

### Alur Komunikasi

```text
User Browser
    -> frontend-bidmart
    -> bidmart-api-gateway
        -> bidmart-auth-service -> auth-db
        -> bidmart-catalog-service -> catalog-db
        -> bidmart-auction-wallet-service -> auction-wallet-db
```

### Service pada Future Architecture

| Service | Database | Tanggung Jawab |
|---|---|---|
| `bidmart-auth-service` | `auth-db` | Authentication, authorization, token/session logic |
| `bidmart-catalog-service` | `catalog-db` | Catalog, product listing, dan listing data |
| `bidmart-auction-wallet-service` | `auction-wallet-db` | Auction, bidding, wallet, dan settlement flow |

### Tujuan Pemisahan Service

Pemisahan service pada future architecture bertujuan untuk:

- memperjelas ownership data;
- mengurangi coupling antar-domain;
- membuat setiap service lebih mudah dikembangkan secara mandiri;
- membuat testing lebih terisolasi;
- membuat deployment lebih fleksibel;
- mengurangi risiko perubahan pada satu fitur memengaruhi seluruh sistem.

### Pengembangan Lanjutan

Future architecture juga membuka ruang untuk penambahan komponen pendukung seperti:

| Komponen | Fungsi |
|---|---|
| RabbitMQ | Mendukung asynchronous communication antar-service |
| Prometheus | Mengumpulkan metrics dari service |
| Grafana | Menampilkan monitoring dashboard |
| CI/CD Pipeline | Membantu deployment dan quality checking secara otomatis |

---

## Container Diagram Summary

| Aspek | Current Container Architecture | Future Container Architecture |
|---|---|---|
| Fokus utama | Core Auth flow | Full microservice architecture |
| Entry point backend | API Gateway | API Gateway |
| Service utama | Auth Service | Auth Service, Catalog Service, Auction-Wallet Service |
| Database | `auth-db` | `auth-db`, `catalog-db`, `auction-wallet-db` |
| Komunikasi frontend | Frontend ke API Gateway | Frontend ke API Gateway |
| Komunikasi backend | Gateway ke Auth Service | Gateway ke service sesuai domain |
| Data ownership | Masih terbatas pada Auth domain | Dipisahkan berdasarkan domain service |
| Coupling | Lebih sederhana tetapi masih terbatas | Lebih rendah karena service dan database dipisah |
| Pengembangan berikutnya | Integrasi service tambahan | Event bus, monitoring, dan deployment yang lebih lengkap |

---

## Kesimpulan Container Diagram

Current container architecture menunjukkan bahwa BidMart sudah mulai dipisahkan dari monolith melalui core Auth flow:

```text
frontend-bidmart -> bidmart-api-gateway -> bidmart-auth-service -> auth-db
```

Future container architecture memperluas struktur tersebut menjadi microservice architecture yang lebih lengkap:

```text
frontend-bidmart -> bidmart-api-gateway -> Auth / Catalog / Auction-Wallet services
```

Dengan perubahan ini, BidMart memiliki struktur yang lebih modular, lebih mudah dikembangkan, dan lebih siap untuk integrasi service tambahan pada tahap berikutnya.