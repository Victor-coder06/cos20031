==Dữ liệu giao dịch/sự kiện lớn==

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