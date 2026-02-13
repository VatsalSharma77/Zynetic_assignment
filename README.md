# 🚀 High-Scale Energy Ingestion Engine

Backend service built using Node.js + PostgreSQL to ingest high-frequency telemetry from Smart Meters and EV Vehicles.

---

## 📌 Project Overview

This system simulates a high-scale ingestion engine handling:

- 10,000+ Smart Meters  
- 10,000+ EV Vehicles  
- 1 heartbeat per minute per device  
- ~14.4 Million records per day  

The service ingests telemetry, stores historical data efficiently, maintains live device state, and provides analytical insights on energy efficiency.

---

# 🏗️ Architecture Overview

## 🔄 System Flow

```
Device (Meter / EV)
        ↓
POST /v1/ingest
        ↓
Validation Middleware
        ↓
Controller
        ↓
PostgreSQL Function
        ↓
Historical Table (INSERT)
        ↓
Live Table (UPSERT)
        ↓
Analytics Endpoint (Aggregated Query)
```

---

# 🧊 Data Strategy (Hot & Cold Architecture)

To handle both write-heavy and read-heavy workloads efficiently, the system follows a **Hot & Cold data separation strategy**.

---

## 1️⃣ Cold Storage (Append-Only Historical Data)

Stores every heartbeat for auditing and analytics.

### Tables:
- `meter_telemetry`
- `vehicle_telemetry`

### Design Decisions:
- `BIGSERIAL` Primary Key
- Indexed on `(device_id, timestamp)`
- Optimized for time-based filtering

### Purpose:
- Long-term analytics
- Efficiency calculations
- Audit trail
- Historical reporting

This design ensures high write throughput without update contention.

---

## 🔥 2️⃣ Hot Storage (Live Device State)

Stores only the latest state of each device.

### Tables:
- `live_meter_status`
- `live_vehicle_status`

### Design Decisions:
- Primary Key = `device_id`
- Uses `INSERT ... ON CONFLICT DO UPDATE` (UPSERT)
- Constant table size (10k rows max)

### Purpose:
- Real-time dashboards
- Instant SoC lookup
- Active charging status
- Low-latency queries

This prevents scanning millions of rows for real-time data.

---

# 🧠 Ingestion Strategy

Instead of embedding heavy SQL logic inside controllers, all business logic is moved into PostgreSQL functions.

### Functions Implemented:

- `ingest_meter_data(...)`
- `ingest_vehicle_data(...)`
- `get_vehicle_performance(...)`

### Benefits:

- Atomic DB operations
- Reduced network round-trips
- Cleaner controller logic
- Better scalability
- Centralized ingestion logic

---

# 🔄 Insert vs Upsert Strategy

### Historical Path
- INSERT only
- Append-only
- Immutable audit log

### Live Path
- UPSERT (`ON CONFLICT DO UPDATE`)
- Maintains only latest state
- Avoids large table scans

This hybrid model ensures both durability and performance.

---

# 📊 Analytics Endpoint

### Endpoint:
```
GET /v1/analytics/performance/:vehicleId
```

### Returns (Last 24 Hours):

- Total AC energy consumed  
- Total DC energy delivered  
- Efficiency Ratio (DC / AC)  
- Average Battery Temperature  

### Optimization Techniques:

- Indexed timestamp filtering
- Aggregated queries
- No full-table scan
- Query logic inside PostgreSQL function

---

# 🛡 Middleware Layer

Implemented middleware:

- Request validation (Joi)
- Async handler wrapper
- Global error handler

### Benefits:

- Prevents invalid telemetry ingestion
- Clean error responses
- Production-ready structure

---

# 🐳 Dockerized Deployment

This project is fully containerized using Docker and Docker Compose.

It spins up:

- Node.js Backend Service
- PostgreSQL 15 Database
- Auto-initialized schema & functions

---

## 📦 Services

| Service | Description |
|----------|-------------|
| `app` | Node.js ingestion API |
| `db` | PostgreSQL database |

---

## ▶️ How to Run the Project

### 1️⃣ Prerequisites

- Install Docker Desktop
- Ensure Docker Engine is running

Verify:

```bash
docker --version
docker compose version
```

---

### 2️⃣ Start the System

From project root:

```bash
docker compose up --build
```

This will:

- Pull PostgreSQL image
- Build backend image
- Initialize database using `/db/init.sql`
- Start API server on port 5000

---

### 3️⃣ Access API

```
http://localhost:5000
```

Example:

```
GET http://localhost:5000/v1/analytics/performance/{vehicleId}
```

---

### 4️⃣ Stop Containers

```bash
docker compose down
```

Fresh reset (remove volumes):

```bash
docker compose down -v
```

---

# 🗄 Database Initialization

All tables and functions are automatically created using:

```
/db/init.sql
```

Includes:

- Telemetry tables
- Live status tables
- Ingestion functions
- Analytics function

No manual database setup required.

---

# ⚙️ Environment Variables (Docker)

Configured in `docker-compose.yml`:

```yaml
environment:
  DB_HOST: db
  DB_USER: postgres
  DB_PASSWORD: postgres
  DB_NAME: energy_ingestion_db
  DB_PORT: 5432
```

Inside Docker, `DB_HOST` must be `db` (service name).

---

# 📈 Handling 14.4 Million Records Per Day

### 1️⃣ Append-Only Cold Tables
Optimized for high write throughput.

### 2️⃣ Fixed-Size Live Tables
Constant size → no performance degradation.

### 3️⃣ PostgreSQL Stored Procedures
Reduces API-to-DB overhead.

### 4️⃣ Indexed Timestamp Filtering
Efficient 24-hour window queries.

### 5️⃣ Stateless API
Can scale horizontally with multiple instances.

This architecture ensures:

- High ingestion rate
- Low read latency
- Scalable design
- Clean separation of concerns

---

# 🏁 Production-Ready Design Decisions

- Stateless backend
- Database-driven ingestion logic
- Atomic UPSERT operations
- Clear middleware pipeline
- Dockerized reproducible setup
- Scalable write architecture

---

# ✅ Submission Checklist

- ✔ GitHub Repository  
- ✔ docker-compose.yml  
- ✔ Database initialization script  
- ✔ Architectural explanation  
- ✔ Scaling strategy explanation  

---

