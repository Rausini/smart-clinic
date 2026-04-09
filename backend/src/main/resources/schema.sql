-- Smart Clinic Management System — Database Schema
-- MySQL 8

CREATE DATABASE IF NOT EXISTS smart_clinic;
USE smart_clinic;

-- ============================================================
-- TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS admin (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100)  NOT NULL,
    email      VARCHAR(150)  NOT NULL UNIQUE,
    password   VARCHAR(255)  NOT NULL,
    created_at TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS doctor (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100)  NOT NULL,
    speciality VARCHAR(100)  NOT NULL,
    email      VARCHAR(150)  NOT NULL UNIQUE,
    password   VARCHAR(255)  NOT NULL,
    phone      VARCHAR(20),
    created_at TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS patient (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100)  NOT NULL,
    email         VARCHAR(150)  NOT NULL UNIQUE,
    password      VARCHAR(255)  NOT NULL,
    phone         VARCHAR(20),
    date_of_birth DATE,
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS appointment (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    doctor_id        BIGINT       NOT NULL,
    patient_id       BIGINT       NOT NULL,
    appointment_date DATE         NOT NULL,
    appointment_time TIME         NOT NULL,
    status           ENUM('SCHEDULED','COMPLETED','CANCELLED') DEFAULT 'SCHEDULED',
    notes            TEXT,
    created_at       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointment_doctor  FOREIGN KEY (doctor_id)  REFERENCES doctor(id),
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) REFERENCES patient(id)
);

CREATE TABLE IF NOT EXISTS prescription (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    appointment_id BIGINT       NOT NULL,
    doctor_id      BIGINT       NOT NULL,
    patient_id     BIGINT       NOT NULL,
    medication     VARCHAR(255) NOT NULL,
    dosage         VARCHAR(100),
    instructions   TEXT,
    created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prescription_appointment FOREIGN KEY (appointment_id) REFERENCES appointment(id),
    CONSTRAINT fk_prescription_doctor      FOREIGN KEY (doctor_id)      REFERENCES doctor(id),
    CONSTRAINT fk_prescription_patient     FOREIGN KEY (patient_id)     REFERENCES patient(id)
);

CREATE TABLE IF NOT EXISTS doctor_available_times (
    doctor_id  BIGINT      NOT NULL,
    time_slot  VARCHAR(10) NOT NULL,
    CONSTRAINT fk_avail_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(id)
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_appointment_doctor_date ON appointment(doctor_id, appointment_date);
CREATE INDEX idx_appointment_patient      ON appointment(patient_id);

-- ============================================================
-- SEED DATA
-- ============================================================

-- Default admin (password: admin123)
INSERT IGNORE INTO admin (name, email, password)
VALUES ('System Admin', 'admin@smartclinic.com',
        '$2b$10$c.3UE6w0yWRQZunGvYRNwe.f.HWjicRpnwOtkfBl4ARTTneQgGBnC');

-- Sample doctors
INSERT IGNORE INTO doctor (name, speciality, email, password, phone) VALUES
('Dr. Ana Costa',     'Cardiology',     'ana.costa@smartclinic.com',    '$2b$10$c.3UE6w0yWRQZunGvYRNwe.f.HWjicRpnwOtkfBl4ARTTneQgGBnC', '11 9 9001-0001'),
('Dr. Bruno Lima',    'Neurology',      'bruno.lima@smartclinic.com',   '$2b$10$c.3UE6w0yWRQZunGvYRNwe.f.HWjicRpnwOtkfBl4ARTTneQgGBnC', '11 9 9001-0002'),
('Dr. Clara Santos',  'Pediatrics',     'clara.santos@smartclinic.com', '$2b$10$c.3UE6w0yWRQZunGvYRNwe.f.HWjicRpnwOtkfBl4ARTTneQgGBnC', '11 9 9001-0003'),
('Dr. Diego Rocha',   'Orthopedics',    'diego.rocha@smartclinic.com',  '$2b$10$c.3UE6w0yWRQZunGvYRNwe.f.HWjicRpnwOtkfBl4ARTTneQgGBnC', '11 9 9001-0004'),
('Dr. Elena Ferreira','Dermatology',    'elena.f@smartclinic.com',      '$2b$10$c.3UE6w0yWRQZunGvYRNwe.f.HWjicRpnwOtkfBl4ARTTneQgGBnC', '11 9 9001-0005');

-- Doctor available time slots
INSERT IGNORE INTO doctor_available_times (doctor_id, time_slot)
SELECT d.id, t.time_slot
FROM doctor d
JOIN (
    SELECT '09:00' AS time_slot UNION ALL
    SELECT '10:00' UNION ALL
    SELECT '11:00' UNION ALL
    SELECT '14:00' UNION ALL
    SELECT '15:00' UNION ALL
    SELECT '16:00'
) t;

-- Sample patients (password: patient123)
INSERT IGNORE INTO patient (name, email, password, phone, date_of_birth) VALUES
('João Silva',    'joao.silva@email.com',    '$2b$10$c.3UE6w0yWRQZunGvYRNwe.f.HWjicRpnwOtkfBl4ARTTneQgGBnC', '11 9 8001-0001', '1985-03-15'),
('Maria Oliveira','maria.oliveira@email.com','$2b$10$c.3UE6w0yWRQZunGvYRNwe.f.HWjicRpnwOtkfBl4ARTTneQgGBnC', '11 9 8001-0002', '1990-07-22'),
('Carlos Mendes', 'carlos.mendes@email.com', '$2b$10$c.3UE6w0yWRQZunGvYRNwe.f.HWjicRpnwOtkfBl4ARTTneQgGBnC', '11 9 8001-0003', '1978-11-05'),
('Fernanda Reis', 'fernanda.reis@email.com', '$2b$10$c.3UE6w0yWRQZunGvYRNwe.f.HWjicRpnwOtkfBl4ARTTneQgGBnC', '11 9 8001-0004', '1995-01-30'),
('Lucas Barbosa', 'lucas.barbosa@email.com', '$2b$10$c.3UE6w0yWRQZunGvYRNwe.f.HWjicRpnwOtkfBl4ARTTneQgGBnC', '11 9 8001-0005', '2000-06-18');

-- Sample appointments
INSERT IGNORE INTO appointment (doctor_id, patient_id, appointment_date, appointment_time, status, notes) VALUES
(1, 1, '2026-04-01', '09:00:00', 'COMPLETED', 'Routine checkup'),
(1, 2, '2026-04-01', '10:00:00', 'COMPLETED', 'Follow-up'),
(1, 3, '2026-04-02', '09:00:00', 'COMPLETED', 'Chest pain evaluation'),
(2, 1, '2026-04-03', '14:00:00', 'COMPLETED', 'Headache investigation'),
(2, 4, '2026-04-03', '15:00:00', 'COMPLETED', 'Migraine follow-up'),
(3, 5, '2026-04-04', '08:30:00', 'COMPLETED', 'Child wellness visit'),
(1, 4, '2026-04-08', '11:00:00', 'SCHEDULED', 'ECG results review'),
(2, 2, '2026-04-09', '13:00:00', 'SCHEDULED', 'MRI follow-up'),
(4, 3, '2026-04-10', '10:30:00', 'SCHEDULED', 'Knee pain'),
(5, 1, '2026-04-11', '09:00:00', 'SCHEDULED', 'Skin rash evaluation');

-- Sample prescriptions
INSERT IGNORE INTO prescription (appointment_id, doctor_id, patient_id, medication, dosage, instructions) VALUES
(1, 1, 1, 'Aspirin',      '100mg', 'Once daily with food'),
(2, 1, 2, 'Atorvastatin', '20mg',  'Once daily at night'),
(3, 1, 3, 'Bisoprolol',   '5mg',   'Once daily in the morning'),
(4, 2, 1, 'Ibuprofen',    '400mg', 'Every 8 hours as needed'),
(5, 2, 4, 'Sumatriptan',  '50mg',  'At onset of migraine');

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

DROP PROCEDURE IF EXISTS GetDailyAppointmentReportByDoctor;
DELIMITER //
CREATE PROCEDURE GetDailyAppointmentReportByDoctor(
    IN p_doctor_id BIGINT,
    IN p_date      DATE
)
BEGIN
    SELECT
        d.id             AS doctor_id,
        d.name           AS doctor_name,
        d.speciality     AS speciality,
        p_date           AS report_date,
        COUNT(a.id)      AS total_appointments,
        SUM(CASE WHEN a.status = 'COMPLETED'  THEN 1 ELSE 0 END) AS completed,
        SUM(CASE WHEN a.status = 'SCHEDULED'  THEN 1 ELSE 0 END) AS scheduled,
        SUM(CASE WHEN a.status = 'CANCELLED'  THEN 1 ELSE 0 END) AS cancelled
    FROM doctor d
    LEFT JOIN appointment a
        ON a.doctor_id = d.id
        AND a.appointment_date = p_date
    WHERE d.id = p_doctor_id
    GROUP BY d.id, d.name, d.speciality;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS GetDoctorWithMostPatientsByMonth;
DELIMITER //
CREATE PROCEDURE GetDoctorWithMostPatientsByMonth(
    IN p_year  INT,
    IN p_month INT
)
BEGIN
    SELECT
        d.id                        AS doctor_id,
        d.name                      AS doctor_name,
        d.speciality                AS speciality,
        COUNT(DISTINCT a.patient_id) AS unique_patients,
        COUNT(a.id)                 AS total_appointments
    FROM doctor d
    JOIN appointment a ON a.doctor_id = d.id
    WHERE YEAR(a.appointment_date)  = p_year
      AND MONTH(a.appointment_date) = p_month
    GROUP BY d.id, d.name, d.speciality
    ORDER BY unique_patients DESC
    LIMIT 1;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS GetDoctorWithMostPatientsByYear;
DELIMITER //
CREATE PROCEDURE GetDoctorWithMostPatientsByYear(
    IN p_year INT
)
BEGIN
    SELECT
        d.id                        AS doctor_id,
        d.name                      AS doctor_name,
        d.speciality                AS speciality,
        COUNT(DISTINCT a.patient_id) AS unique_patients,
        COUNT(a.id)                 AS total_appointments
    FROM doctor d
    JOIN appointment a ON a.doctor_id = d.id
    WHERE YEAR(a.appointment_date) = p_year
    GROUP BY d.id, d.name, d.speciality
    ORDER BY unique_patients DESC
    LIMIT 1;
END //
DELIMITER ;
