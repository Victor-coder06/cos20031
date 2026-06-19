DROP TABLE IF EXISTS telematics_events CASCADE;
DROP TABLE IF EXISTS safety_events CASCADE;
DROP TABLE IF EXISTS maintenance_records CASCADE;
DROP TABLE IF EXISTS certifications CASCADE;
DROP TABLE IF EXISTS drivers CASCADE;
DROP TABLE IF EXISTS vehicles CASCADE;
DROP TABLE IF EXISTS depots CASCADE;


==Dá»¯ liá»‡u danh má»¥c/gá»‘c==
CREATE TABLE depots (
    depot_id SERIAL PRIMARY KEY,
    depot_name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    model VARCHAR(50) NOT NULL,
    manufacture_year INT CHECK (manufacture_year >= 1900),
    depot_id INT REFERENCES depots(depot_id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    hire_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Available'
);

CREATE TABLE certifications (
    cert_id SERIAL PRIMARY KEY,
    driver_id INT REFERENCES drivers(driver_id) ON DELETE CASCADE,
    cert_name VARCHAR(100) NOT NULL,
    issue_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    CHECK (expiry_date > issue_date)
);
==Dá»¯ liá»‡u giao dá»‹ch/sá»± kiá»‡n lá»›n==

CREATE TABLE maintenance_records (
    maintenance_id SERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    cost DECIMAL(12, 2) NOT NULL CHECK (cost >= 0),
    maintenance_date DATE NOT NULL,
    completion_date DATE,
    CHECK (completion_date >= maintenance_date)
);

CREATE TABLE safety_events (
    safety_event_id BIGSERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    driver_id INT REFERENCES drivers(driver_id) ON DELETE SET NULL,
    severity_level VARCHAR(20) NOT NULL, 
    event_type VARCHAR(50) NOT NULL,     
    event_timestamp TIMESTAMP NOT NULL,
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6)
);

CREATE TABLE telematics_events (
    telematics_id BIGSERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    speed NUMERIC(5,2) NOT NULL,
    fuel_level NUMERIC(5,2),
    odometer NUMERIC(10,2),
    event_timestamp TIMESTAMP NOT NULL
);
==tá»‘i Æ°u==


-- Tá»‘i Æ°u lá»c sá»± kiá»‡n an toĂ n theo thá»i gian thá»±c vĂ  phÆ°Æ¡ng tiá»‡n cá»¥ thá»ƒ
CREATE INDEX idx_safety_events_timestamp_vehicle 
ON safety_events (event_timestamp DESC, vehicle_id);

-- Tá»‘i Æ°u tĂ¬m kiáº¿m theo loáº¡i sá»± kiá»‡n Ä‘á»™t ngá»™t (Overspeeding, Harsh Braking...)
CREATE INDEX idx_safety_events_type_severity 
ON safety_events (event_type, severity_level);

-- Tá»‘i Æ°u dá»¯ liá»‡u hĂ nh trĂ¬nh viá»…n thĂ´ng táº£i trá»ng lá»›n (Telematics) Ä‘á»ƒ váº½ biá»ƒu Ä‘á»“
CREATE INDEX idx_telematics_vehicle_timestamp 
ON telematics_events (vehicle_id, event_timestamp DESC);
