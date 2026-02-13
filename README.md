# Zynetic_assignment

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

## System Flow

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

---

# 🧊 Data Strategy (Hot & Cold Architecture)

To handle write-heavy and read-heavy workloads:

## 1️⃣ Cold Storage (Append Only)

Stores every heartbeat for auditing & analytics.

Tables:
- meter_telemetry
- vehicle_telemetry

Design:
- BIGSERIAL Primary Key
- Indexed by (device_id, timestamp)
- Optimized for time-based queries

Purpose:
- Build historical insights
- Calculate efficiency
- Support long-term reporting

---

## 🔥 2️⃣ Hot Storage (Live Status)

Stores only latest state per device.

Tables:
- live_meter_status
- live_vehicle_status

Design:
- Primary Key = device_id
- Uses UPSERT
- No historical scanning required

Purpose:
- Fast dashboard queries
- Instant SoC lookup
- Active charging status

---

# 🧠 Ingestion Strategy

Instead of writing heavy SQL inside controllers, business logic is moved into PostgreSQL functions.

Functions Created:

- ingest_meter_data(...)
- ingest_vehicle_data(...)
- get_vehicle_performance(...)

Benefits:
- Atomic operations
- Reduced DB round trips
- Clean controllers
- Better scalability

---

# 🔄 Insert vs Upsert Strategy

Historical Path:
- INSERT only
- No updates
- Append-only audit trail

Live Path:
- INSERT ... ON CONFLICT DO UPDATE
- Keeps only latest device state
- Avoids scanning millions of rows

---

# 📊 Analytics Endpoint

GET /v1/analytics/performance/:vehicleId

Returns:

- Total AC energy consumed (last 24h)
- Total DC energy delivered (last 24h)
- Efficiency Ratio (DC / AC)
- Average Battery Temperature

Optimization:
- Indexed timestamp filtering
- No full table scan
- Uses aggregated queries

---

# 🛡 Middleware Layer

Implemented:

- Request validation (Joi)
- Async handler wrapper
- Global error handling

Benefits:
- Clean error management
- Prevents invalid telemetry
- Production-ready structure

---

# 📂 Project Structure

