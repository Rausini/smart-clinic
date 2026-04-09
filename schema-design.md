# Smart Clinic Management System — Database Schema Design

## Overview

The Smart Clinic Management System uses a **MySQL 8** relational database. The schema supports three user roles (Admin, Doctor, Patient) and manages appointments, prescriptions, and reporting via stored procedures.

---

## Entity Relationship Summary

```
Admin ─────────────── (manages) ──────────────► Doctor
Doctor ─────────────── (has many) ────────────► Appointment ◄──── (books) ─── Patient
Appointment ──────────── (generates) ─────────► Prescription
```

---

## Tables

### 1. `admin`

Stores administrator accounts.

| Column       | Type           | Constraints                  |
|-------------|----------------|------------------------------|
| id          | BIGINT         | PRIMARY KEY, AUTO_INCREMENT  |
| name        | VARCHAR(100)   | NOT NULL                     |
| email       | VARCHAR(150)   | NOT NULL, UNIQUE             |
| password    | VARCHAR(255)   | NOT NULL (BCrypt hash)       |
| created_at  | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP    |

---

### 2. `doctor`

Stores doctor profiles and credentials.

| Column       | Type           | Constraints                   |
|-------------|----------------|-------------------------------|
| id          | BIGINT         | PRIMARY KEY, AUTO_INCREMENT   |
| name        | VARCHAR(100)   | NOT NULL                      |
| speciality  | VARCHAR(100)   | NOT NULL                      |
| email       | VARCHAR(150)   | NOT NULL, UNIQUE              |
| password    | VARCHAR(255)   | NOT NULL (BCrypt hash)        |
| phone       | VARCHAR(20)    |                               |
| created_at  | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP     |

---

### 3. `patient`

Stores patient profiles and credentials.

| Column         | Type           | Constraints                   |
|---------------|----------------|-------------------------------|
| id            | BIGINT         | PRIMARY KEY, AUTO_INCREMENT   |
| name          | VARCHAR(100)   | NOT NULL                      |
| email         | VARCHAR(150)   | NOT NULL, UNIQUE              |
| password      | VARCHAR(255)   | NOT NULL (BCrypt hash)        |
| phone         | VARCHAR(20)    |                               |
| date_of_birth | DATE           |                               |
| created_at    | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP     |

---

### 4. `appointment`

Tracks all appointment bookings between doctors and patients.

| Column             | Type           | Constraints                               |
|-------------------|----------------|-------------------------------------------|
| id                | BIGINT         | PRIMARY KEY, AUTO_INCREMENT               |
| doctor_id         | BIGINT         | NOT NULL, FK → doctor(id)                 |
| patient_id        | BIGINT         | NOT NULL, FK → patient(id)                |
| appointment_date  | DATE           | NOT NULL                                  |
| appointment_time  | TIME           | NOT NULL                                  |
| status            | ENUM(...)      | 'SCHEDULED','COMPLETED','CANCELLED'       |
| notes             | TEXT           |                                           |
| created_at        | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP                 |

---

### 5. `prescription`

Prescriptions issued during an appointment.

| Column           | Type           | Constraints                               |
|-----------------|----------------|-------------------------------------------|
| id              | BIGINT         | PRIMARY KEY, AUTO_INCREMENT               |
| appointment_id  | BIGINT         | NOT NULL, FK → appointment(id)            |
| doctor_id       | BIGINT         | NOT NULL, FK → doctor(id)                 |
| patient_id      | BIGINT         | NOT NULL, FK → patient(id)                |
| medication      | VARCHAR(255)   | NOT NULL                                  |
| dosage          | VARCHAR(100)   |                                           |
| instructions    | TEXT           |                                           |
| created_at      | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP                 |

---

## Stored Procedures

### `GetDailyAppointmentReportByDoctor(IN p_doctor_id BIGINT, IN p_date DATE)`

Returns the count of appointments for a specific doctor on a specific date.

**Use case:** Daily schedule reporting for a doctor.

```sql
CALL GetDailyAppointmentReportByDoctor(1, '2026-04-08');
```

---

### `GetDoctorWithMostPatientsByMonth(IN p_year INT, IN p_month INT)`

Returns the doctor who had the most appointments in a given month and year.

**Use case:** Monthly performance reporting.

```sql
CALL GetDoctorWithMostPatientsByMonth(2026, 4);
```

---

### `GetDoctorWithMostPatientsByYear(IN p_year INT)`

Returns the doctor who had the most appointments in a given year.

**Use case:** Annual performance reporting.

```sql
CALL GetDoctorWithMostPatientsByYear(2026);
```

---

## Indexes

- `doctor(email)` — UNIQUE for login lookups
- `patient(email)` — UNIQUE for login lookups
- `appointment(doctor_id, appointment_date)` — for daily schedule queries
- `appointment(patient_id)` — for patient appointment history

---

## Notes

- All passwords are stored as BCrypt hashes (never plain text).
- The `status` field in `appointment` uses MySQL ENUM.
- Cascading deletes are not used; orphan records are retained for audit purposes.
