# Tutorial B: Visualizing and Architectural Risk - BidMart

Dokumentasi ini dibuat untuk memenuhi Tutorial B: **Visualizing and Architectural Risk** pada proyek BidMart A01. Repository `bidmart-deployment` digunakan sebagai pusat dokumentasi arsitektur karena repository ini berisi konfigurasi deployment dan integrasi service utama BidMart.

---

## Anggota Kelompok

**BidMart A01 - Advance Programming A**

| No. | Nama | NPM |
|---:|---|---|
| 1 | Neal Guarddin | 2406348282 |
| 2 | Go Nadine Audelia | 2406348774 |
| 3 | Renata Gracia | 2406399705 |
| 4 | Sahila Khairatul Athia | 2406495716 |

---

## Ringkasan Arsitektur

BidMart saat ini sudah memiliki core microservice deployment yang berfokus pada alur autentikasi:

```text
frontend-bidmart -> bidmart-api-gateway -> bidmart-auth-service -> auth-db
```

Arsitektur masa depan memperluas core stack tersebut dengan menambahkan service lain seperti Catalog Service, Auction-Wallet Service, database masing-masing service, asynchronous messaging, dan monitoring.

---

## Daftar Diagram

| Bagian | File |
|---|---|
| Current Context Diagram | `images/01-current-context.png` |
| Current Container Diagram | `images/02-current-container.png` |
| Current Deployment Diagram | `images/03-current-deployment.png` |
| Future Context Diagram | `images/04-future-context.png` |
| Future Container Diagram | `images/05-future-container.png` |
| Future Deployment Diagram | `images/06-future-deployment.png` |

---

# 1. Current Architecture

## 1.1 Current Context Diagram


![Current Context Diagram](images/01-current-context.png)

Current context diagram menjelaskan posisi BidMart sebagai sistem yang digunakan oleh pengguna. Diagram ini menampilkan hubungan antara user, browser, dan sistem BidMart pada kondisi saat ini.

---

## 1.2 Current Container Diagram

![Current Container Diagram](images/02-current-container.png)

Current container diagram menggambarkan **core deployment BidMart** yang saat ini menjadi fokus utama pada repository `bidmart-deployment`.

Pada tahap ini, sistem berfokus pada **core Auth flow** yang terdiri dari:

| Container | Tanggung Jawab |
|---|---|
| `frontend-bidmart` | Menyediakan user interface untuk pengguna |
| `bidmart-api-gateway` | Menjadi single public backend entry point |
| `bidmart-auth-service` | Menangani authentication, authorization, dan token/session logic |
| `auth-db` | Menyimpan data autentikasi |

### Alur Komunikasi Current Container

```text
User Browser
    -> frontend-bidmart
    -> bidmart-api-gateway
    -> bidmart-auth-service
    -> auth-db
```

### Penjelasan Current Container

- Frontend tidak memanggil Auth Service secara langsung.
- Semua request dari frontend diarahkan terlebih dahulu ke `bidmart-api-gateway`.
- API Gateway kemudian meneruskan request autentikasi ke `bidmart-auth-service` melalui komunikasi internal.
- Auth Service mengakses `auth-db` untuk kebutuhan data autentikasi.
- Dengan struktur ini, API Gateway berperan sebagai **single public backend entry point**.

### Batasan Current Architecture

Current architecture masih terbatas pada core Auth flow. Service berikut belum menjadi bagian utama dari deployment stabil saat ini:

- `bidmart-catalog-service`
- `bidmart-auction-wallet-service`
- RabbitMQ
- Prometheus
- Grafana

---

## 1.3 Current Deployment Diagram

> TODO: Bagian ini diisi oleh anggota yang mengerjakan deployment diagram.

![Current Deployment Diagram](images/03-current-deployment.png)

Current deployment diagram menjelaskan bagaimana komponen current architecture dijalankan pada environment deployment saat ini, terutama melalui Docker Compose di repository `bidmart-deployment`.

---

# 2. Future Architecture After Risk Storming

## 2.1 Future Context Diagram


![Future Context Diagram](images/04-future-context.png)

Future context diagram menjelaskan posisi BidMart sebagai sistem microservice-based yang lebih lengkap setelah dilakukan risk storming.

---

## 2.2 Future Container Diagram

![Future Container Diagram](images/05-future-container.png)

Future container diagram menggambarkan pengembangan BidMart menuju **microservice architecture** yang lebih lengkap.

Pada rancangan ini, `bidmart-api-gateway` tetap menjadi **single public backend entry point**, tetapi gateway tidak hanya meneruskan request ke Auth Service. Gateway juga meneruskan request ke service lain sesuai domain fitur.

### Alur Komunikasi Future Container


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

Pemisahan service pada future architecture bertujuan untuk membuat BidMart lebih modular, scalable, dan maintainable. Pada arsitektur yang terlalu terpusat, pertambahan jumlah pengguna dan fitur dapat membuat sistem sulit dikembangkan karena semua bagian saling bergantung. Jika traffic meningkat, sistem juga menjadi sulit di-scale secara spesifik karena seluruh backend harus diperlakukan sebagai satu kesatuan.

Dengan memisahkan service berdasarkan domain, BidMart dapat memperoleh beberapa manfaat berikut:

- memperjelas ownership data pada setiap domain service;
- mengurangi coupling antar-domain seperti Auth, Catalog, dan Auction-Wallet;
- membuat setiap service lebih mudah dikembangkan secara mandiri;
- membuat testing lebih terisolasi;
- membuat deployment lebih fleksibel;
- memungkinkan service tertentu di-scale secara terpisah sesuai beban;
- mengurangi risiko bottleneck ketika jumlah pengguna bertambah;
- meningkatkan maintainability karena struktur sistem lebih modular;
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

## 2.3 Future Deployment Diagram

> TODO: Bagian ini diisi oleh anggota yang mengerjakan future deployment diagram.

![Future Deployment Diagram](images/06-future-deployment.png)

Future deployment diagram menjelaskan bagaimana service-service BidMart dapat dijalankan pada environment deployment yang lebih lengkap setelah Catalog Service, Auction-Wallet Service, messaging, dan monitoring ditambahkan.

---

# 3. Risk Storming Explanation

> TODO: Bagian ini diisi oleh anggota yang mengerjakan risk storming explanation.

Bagian ini akan menjelaskan hasil risk storming terhadap current architecture BidMart dan bagaimana hasil tersebut memengaruhi rancangan future architecture.

Risk storming explanation akan mencakup:

- risiko utama pada current architecture;
- dampak dari setiap risiko terhadap sistem;
- alasan perubahan menuju future architecture;
- hubungan antara risiko yang ditemukan dan modifikasi arsitektur yang diusulkan.

## Hasil Risk Storming

> TODO: Tambahkan tabel hasil risk storming.

| Risiko pada Current Architecture | Dampak | Modifikasi pada Future Architecture |
|---|---|---|
| TODO | TODO | TODO |

# 4. Individual Work

> TODO: Bagian ini diisi oleh masing-masing anggota sesuai kontribusi individual.

Bagian individual menjelaskan component diagram dan code diagram dari kontribusi masing-masing anggota. Setiap anggota dapat menambahkan subsection masing-masing dengan format berikut.

---

## 4.1 Neal Guarddin

### Fokus Kontribusi

| Area | Repository | Kontribusi |
|---|---|---|
| Frontend | `frontend-bidmart` | Alur autentikasi dari UI menuju API Gateway |
| API Gateway | `bidmart-api-gateway` | Public entry point, routing, dan komunikasi internal ke Auth Service |
| Auth Service | `bidmart-auth-service` | Login, token/session handling, gRPC endpoint, dan akses ke Auth DB |
| Deployment | `bidmart-deployment` | Docker Compose, environment configuration, smoke test, dan dokumentasi arsitektur |

### Individual Component Diagram

> TODO: Tambahkan gambar individual component diagram Neal.

![Neal Individual Component Diagram](images/07-neal-component-diagram.png)

### Code Diagram

> TODO: Tambahkan code diagram Neal.

![Neal Code Diagram](images/08-neal-code-diagram.png)

---

## 4.2 Go Nadine Audelia

> TODO: Tambahkan individual component diagram dan code diagram.

---

## 4.3 Renata Gracia

> TODO: Tambahkan individual component diagram dan code diagram.

---

## 4.4 Sahila Khairatul Athia

> TODO: Tambahkan individual component diagram dan code diagram.

---

# 5. Container Diagram Summary

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

# 6. Kesimpulan

Current architecture menunjukkan bahwa BidMart sudah mulai dipisahkan dari monolith melalui core Auth flow:

```text
frontend-bidmart -> bidmart-api-gateway -> bidmart-auth-service -> auth-db
```

Future architecture memperluas struktur tersebut menjadi microservice architecture yang lebih lengkap:

```text
frontend-bidmart -> bidmart-api-gateway -> Auth / Catalog / Auction-Wallet services
```

Dengan perubahan ini, BidMart memiliki struktur yang lebih modular, lebih mudah dikembangkan, dan lebih siap untuk integrasi service tambahan pada tahap berikutnya.