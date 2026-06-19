-- Khởi tạo dọn dẹp cấu trúc cũ theo thứ tự ngược để tránh lỗi ràng buộc
DROP TABLE IF EXISTS ACTIVITY_ASSIGNMENT CASCADE;
DROP TABLE IF EXISTS MAINTENANCE_ACTIVITY CASCADE;
DROP TABLE IF EXISTS MAINTENANCE_JOB CASCADE;
DROP TABLE IF EXISTS PREDICTIVE_ALERT CASCADE;
DROP TABLE IF EXISTS MECHANIC CASCADE;
DROP TABLE IF EXISTS WORKSHOP CASCADE;
DROP TABLE IF EXISTS INCIDENT_REVIEW CASCADE;
DROP TABLE IF EXISTS SAFETY_EVENT CASCADE;
DROP TABLE IF EXISTS Driver_Certification CASCADE;
DROP TABLE IF EXISTS Driver CASCADE;
DROP TABLE IF EXISTS VEHICLE CASCADE;
DROP TABLE IF EXISTS Certification CASCADE;
DROP TABLE IF EXISTS DEPOT CASCADE;


--LEVEL 0 TABLES (Bảng độc lập hoàn toàn)


-- 1. Depot table
CREATE TABLE DEPOT (
    depot_id INT PRIMARY KEY,
    depot_name VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL
);

-- 2. Certification table
CREATE TABLE Certification (
    certification_id INT AUTO_INCREMENT PRIMARY KEY,
    certification_name VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);


--LEVEL 1 TABLES (Phụ thuộc trực tiếp vào DEPOT)


-- 3. Vehicle table
CREATE TABLE VEHICLE (
    vehicle_id INT PRIMARY KEY,
    registration_number VARCHAR(255) UNIQUE NOT NULL,
    vin VARCHAR(255) UNIQUE NOT NULL,
    category VARCHAR(255),
    manufacturer VARCHAR(255),
    model VARCHAR(255),
    manufacture_year INT,
    odometer INT,
    status VARCHAR(50),
    depot_id INT,
    FOREIGN KEY (depot_id) REFERENCES DEPOT(depot_id)
);

-- 4. Workshop table
CREATE TABLE WORKSHOP (
    workshop_id INT PRIMARY KEY,
    depot_id INT,
    workshop_name VARCHAR(100),
    FOREIGN KEY (depot_id) REFERENCES DEPOT(depot_id)
);

-- 5. Driver information table
CREATE TABLE Driver (
    driver_id INT AUTO_INCREMENT PRIMARY KEY,
    driver_code VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    contact_info VARCHAR(255),
    licence_type VARCHAR(50) NOT NULL,
    licence_expiry DATE NOT NULL,
    employment_status VARCHAR(50),
    emergency_contact VARCHAR(255),
    depot_id INT NOT NULL,
    CONSTRAINT fk_driver_depot FOREIGN KEY (depot_id) REFERENCES DEPOT(depot_id)
);


--LEVEL 2 TABLES (Phụ thuộc vào các thực thể Cấp 1)


-- 6. Driver certification table
CREATE TABLE Driver_Certification (
    driver_cert_id INT AUTO_INCREMENT PRIMARY KEY,
    driver_id INT NOT NULL,
    certification_id INT NOT NULL,
    issue_date DATE NOT NULL,
    expiry_date DATE,
    CONSTRAINT fk_drivercert_driver FOREIGN KEY (driver_id) REFERENCES Driver(driver_id),
    CONSTRAINT fk_drivercert_certification FOREIGN KEY (certification_id) REFERENCES Certification(certification_id),
    CONSTRAINT uk_driver_certification UNIQUE (driver_id, certification_id)
);

-- 7. Safety Event table
CREATE TABLE SAFETY_EVENT (
    event_id INT PRIMARY KEY,
    vehicle_id INT,
    driver_id INT,
    depot_id INT,
    event_timestamp DATETIME,
    event_type VARCHAR(100),
    severity VARCHAR(50),
    odometer INT,
    FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id),
    FOREIGN KEY (driver_id) REFERENCES Driver(driver_id),
    FOREIGN KEY (depot_id) REFERENCES DEPOT(depot_id)
);

-- 8. Mechanic table (Bổ sung để làm cha cho bảng con phía dưới)
CREATE TABLE MECHANIC (
    mechanic_id INT PRIMARY KEY,
    workshop_id INT,
    mechanic_code VARCHAR(50),
    full_name VARCHAR(100),
    specialty VARCHAR(100),
    employment_status VARCHAR(50),
    FOREIGN KEY (workshop_id) REFERENCES WORKSHOP(workshop_id)
);

-- 9. Predictive Alert table (Bổ sung để đáp ứng FK của MAINTENANCE_JOB)
CREATE TABLE PREDICTIVE_ALERT (
    alert_id INT PRIMARY KEY,
    vehicle_id INT,
    alert_type VARCHAR(100),
    generated_at DATETIME,
    status VARCHAR(50),
    FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id)
);


--LEVEL 3 & 4 TABLES (Bảng nghiệp vụ sâu/Lịch sử sửa chữa)

-- 10. Incident Review table
CREATE TABLE INCIDENT_REVIEW (
    review_id INT PRIMARY KEY,
    event_id INT,
    review_date DATE,
    reviewer VARCHAR(100),
    comments VARCHAR(255),
    recommendation VARCHAR(255),
    review_status VARCHAR(50),
    FOREIGN KEY (event_id) REFERENCES SAFETY_EVENT(event_id)
);

-- 11. Maintenance Job table
CREATE TABLE MAINTENANCE_JOB (
    job_id INT PRIMARY KEY,
    vehicle_id INT,
    workshop_id INT,
    alert_id INT,
    opened_date DATETIME,
    closed_date DATETIME,
    estimated_hours DECIMAL(10, 2),
    total_cost DECIMAL(15, 2),
    FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id),
    FOREIGN KEY (workshop_id) REFERENCES WORKSHOP(workshop_id),
    FOREIGN KEY (alert_id) REFERENCES PREDICTIVE_ALERT(alert_id)
);

-- 12. Maintenance Activity table
CREATE TABLE MAINTENANCE_ACTIVITY (
    activity_id INT PRIMARY KEY,
    job_id INT,
    activity_type VARCHAR(100),
    diagnostic_result VARCHAR(255),
    repeat_fault BOOLEAN,
    warranty_claim BOOLEAN,
    FOREIGN KEY (job_id) REFERENCES MAINTENANCE_JOB(job_id)
);

-- 13. Activity Assignment table
CREATE TABLE ACTIVITY_ASSIGNMENT (
    assignment_id INT PRIMARY KEY,
    activity_id INT,
    mechanic_id INT,
    labour_hours DECIMAL(10, 2),
    FOREIGN KEY (activity_id) REFERENCES MAINTENANCE_ACTIVITY(activity_id),
    FOREIGN KEY (mechanic_id) REFERENCES MECHANIC(mechanic_id)
);


-- Tối ưu hóa truy vấn lịch sử sự kiện an toàn dung lượng lớn
CREATE INDEX idx_safety_event_timestamp ON SAFETY_EVENT (event_timestamp DESC, vehicle_id);
-- Tối ưu hóa truy vấn tìm kiếm trạng thái các công việc bảo trì
CREATE INDEX idx_maintenance_job_dates ON MAINTENANCE_JOB (opened_date DESC, vehicle_id);