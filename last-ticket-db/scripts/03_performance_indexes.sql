==tối ưu==


-- Tối ưu lọc sự kiện an toàn theo thời gian thực và phương tiện cụ thể
CREATE INDEX idx_safety_events_timestamp_vehicle 
ON safety_events (event_timestamp DESC, vehicle_id);

-- Tối ưu tìm kiếm theo loại sự kiện đột ngột (Overspeeding, Harsh Braking...)
CREATE INDEX idx_safety_events_type_severity 
ON safety_events (event_type, severity_level);

-- Tối ưu dữ liệu hành trình viễn thông tải trọng lớn (Telematics) để vẽ biểu đồ
CREATE INDEX idx_telematics_vehicle_timestamp 
ON telematics_events (vehicle_id, event_timestamp DESC);