-- =========================================================
-- ONLINE BUS TICKET BOOKING SYSTEM
-- Structured SQL script for MySQL 8.0+
-- Review notes:
-- 1. Run on a test database first; CREATE TABLE statements are not all idempotent.
-- 2. Sample users are inserted before booking-related records to satisfy foreign keys.
-- 3. CHECK constraints and recursive CTEs require a compatible MySQL version.
-- 4. Demo credentials below are placeholders; never use these passwords in production.
-- =========================================================

-- DATABASE CREATION

CREATE DATABASE IF NOT EXISTS bus_booking_db;

USE bus_booking_db;

SELECT DATABASE();
SHOW TABLES;



-- TABLE CREATION

-- 1. USER TABLE
CREATE TABLE users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ACTIVE'
);


-- 2. ADMIN TABLE
CREATE TABLE admin (
    admin_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    admin_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE'
);


-- 3. DISTRICT TABLE
CREATE TABLE district (
    district_id INT AUTO_INCREMENT PRIMARY KEY,
    district_name VARCHAR(100) NOT NULL UNIQUE,
    status VARCHAR(20) DEFAULT 'ACTIVE'
);


-- 4. CITY TABLE
CREATE TABLE city (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    district_id INT NOT NULL,
    city_name VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT fk_city_district
        FOREIGN KEY (district_id)
        REFERENCES district(district_id),

    CONSTRAINT uk_city_district_name
        UNIQUE (district_id, city_name)
);


-- 5. BUS TABLE
CREATE TABLE bus (
    bus_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_number VARCHAR(30) NOT NULL UNIQUE,
    bus_name VARCHAR(100) NOT NULL,
    bus_type VARCHAR(50) NOT NULL,
    total_seats INT NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT chk_bus_total_seats
        CHECK (total_seats > 0)
);


-- 6. ROUTE TABLE
CREATE TABLE route (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    source_city_id INT NOT NULL,
    destination_city_id INT NOT NULL,
    distance_km DECIMAL(8,2),
    status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT fk_route_source_city
        FOREIGN KEY (source_city_id)
        REFERENCES city(city_id),

    CONSTRAINT fk_route_destination_city
        FOREIGN KEY (destination_city_id)
        REFERENCES city(city_id),

    CONSTRAINT chk_route_different_cities
        CHECK (source_city_id <> destination_city_id),

    CONSTRAINT uk_route
        UNIQUE (source_city_id, destination_city_id)
);


-- 7. BUS SCHEDULE TABLE
CREATE TABLE bus_schedule (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_id INT NOT NULL,
    route_id INT NOT NULL,
    travel_date DATE NOT NULL,
    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    fare DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'SCHEDULED',

    CONSTRAINT fk_schedule_bus
        FOREIGN KEY (bus_id)
        REFERENCES bus(bus_id),

    CONSTRAINT fk_schedule_route
        FOREIGN KEY (route_id)
        REFERENCES route(route_id),

    CONSTRAINT chk_schedule_fare
        CHECK (fare >= 0),

    CONSTRAINT chk_schedule_time
        CHECK (arrival_time <> departure_time)
);


-- 8. SEAT TABLE
CREATE TABLE seat (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_type VARCHAR(30) DEFAULT 'REGULAR',
    status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT fk_seat_bus
        FOREIGN KEY (bus_id)
        REFERENCES bus(bus_id),

    CONSTRAINT uk_bus_seat
        UNIQUE (bus_id, seat_number)
);


-- 9. BOOKING TABLE 
CREATE TABLE booking (
    booking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    schedule_id INT NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    booking_status VARCHAR(20) DEFAULT 'PENDING',
    payment_status VARCHAR(20) DEFAULT 'PENDING',

    CONSTRAINT fk_booking_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_booking_schedule
        FOREIGN KEY (schedule_id)
        REFERENCES bus_schedule(schedule_id),

    CONSTRAINT chk_booking_amount
        CHECK (total_amount >= 0)
);


-- 10. BOOKING_PASSENGER TABLE
CREATE TABLE booking_passenger (
    passenger_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    seat_id INT NOT NULL,
    passenger_name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(20) NOT NULL,
    passenger_phone VARCHAR(15),

    CONSTRAINT fk_passenger_booking
        FOREIGN KEY (booking_id)
        REFERENCES booking(booking_id),

    CONSTRAINT fk_passenger_seat
        FOREIGN KEY (seat_id)
        REFERENCES seat(seat_id),

    CONSTRAINT chk_passenger_age
        CHECK (age > 0 AND age <= 120),

    CONSTRAINT uk_booking_seat
        UNIQUE (booking_id, seat_id)
);


-- 11. PAYMENT TABLE
CREATE TABLE payment (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    transaction_reference VARCHAR(100) UNIQUE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_status VARCHAR(20) DEFAULT 'PENDING',

    CONSTRAINT fk_payment_booking
        FOREIGN KEY (booking_id)
        REFERENCES booking(booking_id),

    CONSTRAINT uk_payment_booking
        UNIQUE (booking_id),

    CONSTRAINT chk_payment_amount
        CHECK (amount >= 0)
);


-- 12. CANCELLATION TABLE
CREATE TABLE cancellation (
    cancellation_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    cancellation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason VARCHAR(255),
    refund_amount DECIMAL(10,2) DEFAULT 0.00,
    cancellation_status VARCHAR(20) DEFAULT 'REQUESTED',

    CONSTRAINT fk_cancellation_booking
        FOREIGN KEY (booking_id)
        REFERENCES booking(booking_id),

    CONSTRAINT uk_cancellation_booking
        UNIQUE (booking_id),

    CONSTRAINT chk_refund_amount
        CHECK (refund_amount >= 0)
);


-- 13. BOOKING_HISTORY
CREATE TABLE booking_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    status VARCHAR(30) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remarks VARCHAR(255),

    CONSTRAINT fk_history_booking
        FOREIGN KEY (booking_id)
        REFERENCES booking(booking_id)
);



-- 14. SCHEDULE RULE TABLE
CREATE TABLE IF NOT EXISTS schedule_rule (
    schedule_rule_id INT AUTO_INCREMENT PRIMARY KEY,

    bus_id INT NOT NULL,
    route_id INT NOT NULL,

    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL,

    fare DECIMAL(10,2) NOT NULL,

    recurrence_type ENUM(
        'DAILY',
        'WEEKLY',
        'SPECIFIC_DATE'
    ) NOT NULL,

    days_of_week VARCHAR(50),

    valid_from DATE NOT NULL,
    valid_until DATE,

    specific_date DATE,

    status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT fk_rule_bus
        FOREIGN KEY (bus_id)
        REFERENCES bus(bus_id),

    CONSTRAINT fk_rule_route
        FOREIGN KEY (route_id)
        REFERENCES route(route_id),

    CONSTRAINT chk_rule_fare
        CHECK (fare >= 0),

    CONSTRAINT chk_rule_time
        CHECK (arrival_time <> departure_time),

    CONSTRAINT chk_rule_dates
        CHECK (
            valid_until IS NULL
            OR valid_until >= valid_from
        )
) ENGINE=InnoDB;



-- 15. EXCEPTION TABLE

CREATE TABLE IF NOT EXISTS schedule_exception (
    exception_id INT AUTO_INCREMENT PRIMARY KEY,

    schedule_rule_id INT NOT NULL,

    exception_date DATE NOT NULL,

    exception_type ENUM(
        'CANCEL',
        'ADD'
    ) NOT NULL,

    departure_time TIME,
    arrival_time TIME,
    fare DECIMAL(10,2),

    reason VARCHAR(255),

    status VARCHAR(20) DEFAULT 'ACTIVE',

    CONSTRAINT fk_exception_rule
        FOREIGN KEY (schedule_rule_id)
        REFERENCES schedule_rule(schedule_rule_id),

    CONSTRAINT chk_exception_fare
        CHECK (
            fare IS NULL OR fare >= 0
        )
) ENGINE=InnoDB;

-- 16. BUS AMENITIES TABLE
CREATE TABLE IF NOT EXISTS bus_amenity (
    bus_id INT PRIMARY KEY,
    wifi BOOLEAN NOT NULL DEFAULT FALSE,
    charging BOOLEAN NOT NULL DEFAULT FALSE,
    food BOOLEAN NOT NULL DEFAULT FALSE,
    restroom BOOLEAN NOT NULL DEFAULT FALSE,
    blanket BOOLEAN NOT NULL DEFAULT FALSE,
    water_bottle BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_bus_amenity_bus FOREIGN KEY (bus_id) REFERENCES bus(bus_id)
) ENGINE=InnoDB;

-- 17. EMERGENCY REQUEST TABLE
CREATE TABLE IF NOT EXISTS emergency_request (
    emergency_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    emergency_type VARCHAR(50) NOT NULL,
    description VARCHAR(500) NOT NULL,
    emergency_status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_emergency_booking FOREIGN KEY (booking_id) REFERENCES booking(booking_id),
    CONSTRAINT chk_emergency_status CHECK (emergency_status IN ('OPEN','IN_PROGRESS','RESOLVED')),
    INDEX idx_emergency_booking (booking_id),
    INDEX idx_emergency_status (emergency_status)
) ENGINE=InnoDB;


-- =========================================================
-- SAMPLE DATA INSERTION
-- =========================================================
-- =========================================================

-- DISTRICT RECORDS
INSERT INTO district (district_id, district_name) VALUES
(1, 'Ariyalur'),
(2, 'Chengalpattu'),
(3, 'Chennai'),
(4, 'Coimbatore'),
(5, 'Cuddalore'),
(6, 'Dharmapuri'),
(7, 'Dindigul'),
(8, 'Erode'),
(9, 'Kallakurichi'),
(10, 'Kancheepuram'),
(11, 'Karur'),
(12, 'Krishnagiri'),
(13, 'Madurai'),
(14, 'Mayiladuthurai'),
(15, 'Nagapattinam'),
(16, 'Kanyakumari'),
(17, 'Namakkal'),
(18, 'Perambalur'),
(19, 'Pudukottai'),
(20, 'Ramanathapuram'),
(21, 'Ranipet'),
(22, 'Salem'),
(23, 'Sivaganga'),
(24, 'Tenkasi'),
(25, 'Thanjavur'),
(26, 'Theni'),
(27, 'Thiruvallur'),
(28, 'Thiruvarur'),
(29, 'Thoothukudi'),
(30, 'Tiruchirappalli'),
(31, 'Tirunelveli'),
(32, 'Tirupathur'),
(33, 'Tiruppur'),
(34, 'Tiruvannamalai'),
(35, 'The Nilgiris'),
(36, 'Vellore'),
(37, 'Viluppuram'),
(38, 'Virudhunagar');

-- CITY RECORDS
INSERT INTO city (district_id, city_name) VALUES

-- 1. Ariyalur
(1, 'Ariyalur'),
(1, 'Jayankondam'),
(1, 'Udayarpalayam'),
(1, 'Varadarajanpettai'),

-- 2. Chengalpattu
(2, 'Chengalpattu'),
(2, 'Tambaram'),
(2, 'Maraimalai Nagar'),
(2, 'Madurantakam'),
(2, 'Mamallapuram'),
(2, 'Guduvanchery'),

-- 3. Chennai
(3, 'Chennai'),

-- 4. Coimbatore
(4, 'Coimbatore'),
(4, 'Pollachi'),
(4, 'Mettupalayam'),
(4, 'Valparai'),
(4, 'Sulur'),
(4, 'Annur'),

-- 5. Cuddalore
(5, 'Cuddalore'),
(5, 'Chidambaram'),
(5, 'Panruti'),
(5, 'Neyveli'),
(5, 'Vadalur'),
(5, 'Virudhachalam'),

-- 6. Dharmapuri
(6, 'Dharmapuri'),
(6, 'Harur'),
(6, 'Pennagaram'),
(6, 'Palacode'),

-- 7. Dindigul
(7, 'Dindigul'),
(7, 'Palani'),
(7, 'Kodaikanal'),
(7, 'Oddanchatram'),
(7, 'Vedasandur'),

-- 8. Erode
(8, 'Erode'),
(8, 'Bhavani'),
(8, 'Gobichettipalayam'),
(8, 'Sathyamangalam'),
(8, 'Perundurai'),

-- 9. Kallakurichi
(9, 'Kallakurichi'),
(9, 'Tirukoilur'),
(9, 'Ulundurpet'),
(9, 'Sankarapuram'),
(9, 'Chinnasalem'),

-- 10. Kancheepuram
(10, 'Kancheepuram'),
(10, 'Sriperumbudur'),
(10, 'Uthiramerur'),
(10, 'Walajabad'),
(10, 'Kundrathur'),

-- 11. Karur
(11, 'Karur'),
(11, 'Kulithalai'),
(11, 'Aravakurichi'),
(11, 'Pugalur'),
(11, 'Krishnarayapuram'),

-- 12. Krishnagiri
(12, 'Krishnagiri'),
(12, 'Hosur'),
(12, 'Bargur'),
(12, 'Denkanikottai'),
(12, 'Uthangarai'),

-- 13. Madurai
(13, 'Madurai'),
(13, 'Melur'),
(13, 'Tirumangalam'),
(13, 'Usilampatti'),

-- 14. Mayiladuthurai
(14, 'Mayiladuthurai'),
(14, 'Sirkazhi'),
(14, 'Kuthalam'),

-- 15. Nagapattinam
(15, 'Nagapattinam'),
(15, 'Vedaranyam'),
(15, 'Velankanni'),
(15, 'Kilvelur'),

-- 16. Kanyakumari
(16, 'Nagercoil'),
(16, 'Kanyakumari'),
(16, 'Colachel'),
(16, 'Padmanabhapuram'),
(16, 'Marthandam'),

-- 17. Namakkal
(17, 'Namakkal'),
(17, 'Rasipuram'),
(17, 'Tiruchengode'),
(17, 'Paramathi Velur'),
(17, 'Komarapalayam'),

-- 18. Perambalur
(18, 'Perambalur'),
(18, 'Kunnam'),
(18, 'Arumbavur'),

-- 19. Pudukottai
(19, 'Pudukottai'),
(19, 'Aranthangi'),
(19, 'Alangudi'),
(19, 'Keeranur'),
(19, 'Illuppur'),

-- 20. Ramanathapuram
(20, 'Ramanathapuram'),
(20, 'Rameswaram'),
(20, 'Paramakudi'),
(20, 'Keelakarai'),
(20, 'Kamuthi'),

-- 21. Ranipet
(21, 'Ranipet'),
(21, 'Arcot'),
(21, 'Arakkonam'),
(21, 'Walajapet'),
(21, 'Sholinghur'),

-- 22. Salem
(22, 'Salem'),
(22, 'Attur'),
(22, 'Mettur'),
(22, 'Edappadi'),
(22, 'Sankari'),
(22, 'Omalur'),

-- 23. Sivaganga
(23, 'Sivaganga'),
(23, 'Karaikudi'),
(23, 'Devakottai'),
(23, 'Manamadurai'),
(23, 'Ilayangudi'),

-- 24. Tenkasi
(24, 'Tenkasi'),
(24, 'Sankarankovil'),
(24, 'Shenkottai'),
(24, 'Kadayanallur'),
(24, 'Puliyankudi'),

-- 25. Thanjavur
(25, 'Thanjavur'),
(25, 'Kumbakonam'),
(25, 'Pattukkottai'),
(25, 'Papanasam'),
(25, 'Peravurani'),
(25, 'Orathanadu'),

-- 26. Theni
(26, 'Theni'),
(26, 'Periyakulam'),
(26, 'Bodinayakanur'),
(26, 'Cumbum'),
(26, 'Chinnamanur'),
(26, 'Uthamapalayam'),

-- 27. Thiruvallur
(27, 'Thiruvallur'),
(27, 'Avadi'),
(27, 'Poonamallee'),
(27, 'Tiruttani'),
(27, 'Ponneri'),
(27, 'Gummidipoondi'),

-- 28. Thiruvarur
(28, 'Thiruvarur'),
(28, 'Mannargudi'),
(28, 'Thiruthuraipoondi'),
(28, 'Needamangalam'),
(28, 'Nannilam'),

-- 29. Thoothukudi
(29, 'Thoothukudi'),
(29, 'Kovilpatti'),
(29, 'Tiruchendur'),
(29, 'Kayalpattinam'),
(29, 'Ettayapuram'),

-- 30. Tiruchirappalli
(30, 'Tiruchirappalli'),
(30, 'Srirangam'),
(30, 'Manapparai'),
(30, 'Musiri'),
(30, 'Thuraiyur'),
(30, 'Lalgudi'),

-- 31. Tirunelveli
(31, 'Tirunelveli'),
(31, 'Ambasamudram'),
(31, 'Nanguneri'),
(31, 'Kalakad'),
(31, 'Tisayanvilai'),

-- 32. Tirupathur
(32, 'Tirupathur'),
(32, 'Ambur'),
(32, 'Vaniyambadi'),
(32, 'Natrampalli'),

-- 33. Tiruppur
(33, 'Tiruppur'),
(33, 'Dharapuram'),
(33, 'Udumalpet'),
(33, 'Palladam'),
(33, 'Avinashi'),
(33, 'Kangeyam'),

-- 34. Tiruvannamalai
(34, 'Tiruvannamalai'),
(34, 'Arani'),
(34, 'Polur'),
(34, 'Chengam'),
(34, 'Vandavasi'),

-- 35. The Nilgiris
(35, 'Udhagamandalam'),
(35, 'Coonoor'),
(35, 'Kotagiri'),
(35, 'Gudalur'),

-- 36. Vellore
(36, 'Vellore'),
(36, 'Gudiyatham'),
(36, 'Katpadi'),

-- 37. Viluppuram
(37, 'Viluppuram'),
(37, 'Tindivanam'),
(37, 'Gingee'),
(37, 'Marakkanam'),
(37, 'Vikravandi'),

-- 38. Virudhunagar
(38, 'Virudhunagar'),
(38, 'Sivakasi'),
(38, 'Rajapalayam'),
(38, 'Aruppukkottai'),
(38, 'Srivilliputhur'),
(38, 'Sattur');

-- ---------------------------------------------------------
-- BUS RECORDS
INSERT INTO bus
(bus_number, bus_name, bus_type, total_seats, status)
VALUES
('TN01AB1001','Chennai Express','AC Sleeper',36,'ACTIVE'),
('TN01AB1002','Chennai Super Fast','AC Seater',40,'ACTIVE'),
('TN01AB1003','Tamil Nadu Express','Non-AC Seater',50,'ACTIVE'),
('TN02CD2001','Coimbatore Express','AC Sleeper',36,'ACTIVE'),
('TN02CD2002','Kovai Super Fast','AC Seater',40,'ACTIVE'),
('TN02CD2003','Kovai Passenger','Non-AC Seater',50,'ACTIVE'),
('TN03EF3001','Madurai Express','AC Sleeper',36,'ACTIVE'),
('TN03EF3002','Madurai Super Fast','AC Seater',40,'ACTIVE'),
('TN03EF3003','Vaigai Bus','Non-AC Seater',50,'ACTIVE'),
('TN04GH4001','Trichy Express','AC Sleeper',36,'ACTIVE'),
('TN04GH4002','Rockfort Express','AC Seater',40,'ACTIVE'),
('TN04GH4003','Trichy Passenger','Non-AC Seater',50,'ACTIVE'),
('TN05IJ5001','Salem Express','AC Sleeper',36,'ACTIVE'),
('TN05IJ5002','Salem Super Fast','AC Seater',40,'ACTIVE'),
('TN05IJ5003','Salem Passenger','Non-AC Seater',50,'ACTIVE'),
('TN06KL6001','Nellai Express','AC Sleeper',36,'ACTIVE'),
('TN06KL6002','Nellai Super Fast','AC Seater',40,'ACTIVE'),
('TN06KL6003','Nellai Passenger','Non-AC Seater',50,'ACTIVE'),
('TN07MN7001','Erode Express','AC Sleeper',36,'ACTIVE'),
('TN07MN7002','Erode Super Fast','AC Seater',40,'ACTIVE'),
('TN07MN7003','Erode Passenger','Non-AC Seater',50,'ACTIVE'),
('TN08OP8001','Thanjavur Express','AC Sleeper',36,'ACTIVE'),
('TN08OP8002','Thanjavur Super Fast','AC Seater',40,'ACTIVE'),
('TN08OP8003','Delta Passenger','Non-AC Seater',50,'ACTIVE'),
('TN09QR9001','Chennai Salem Express','AC Sleeper',36,'ACTIVE'),
('TN09QR9002','Chennai Coimbatore Express','AC Seater',40,'ACTIVE'),
('TN09QR9003','Chennai Madurai Express','Non-AC Seater',50,'ACTIVE'),
('TN10ST1001','Kanyakumari Express','AC Sleeper',36,'ACTIVE'),
('TN10ST1002','Kanyakumari Super Fast','AC Seater',40,'ACTIVE'),
('TN10ST1003','Kanyakumari Passenger','Non-AC Seater',50,'ACTIVE');

-- ROUTE RECORDS
INSERT INTO route
(source_city_id, destination_city_id, distance_km, status)

SELECT
    s.city_id,
    d.city_id,
    x.distance_km,
    'ACTIVE'
FROM
(
    SELECT 'Chennai' source_name, 'Coimbatore' destination_name, 510.00 distance_km
    UNION ALL SELECT 'Chennai','Madurai',460.00
    UNION ALL SELECT 'Chennai','Salem',340.00
    UNION ALL SELECT 'Chennai','Tiruchirappalli',320.00
    UNION ALL SELECT 'Chennai','Tirunelveli',625.00
    UNION ALL SELECT 'Chennai','Thoothukudi',600.00
    UNION ALL SELECT 'Chennai','Erode',400.00
    UNION ALL SELECT 'Chennai','Thanjavur',350.00
    UNION ALL SELECT 'Chennai','Vellore',145.00
    UNION ALL SELECT 'Chennai','Tiruppur',475.00

    UNION ALL SELECT 'Coimbatore','Chennai',510.00
    UNION ALL SELECT 'Coimbatore','Madurai',215.00
    UNION ALL SELECT 'Coimbatore','Salem',160.00
    UNION ALL SELECT 'Coimbatore','Erode',100.00
    UNION ALL SELECT 'Coimbatore','Tiruchirappalli',215.00
    UNION ALL SELECT 'Coimbatore','Thanjavur',280.00
    UNION ALL SELECT 'Coimbatore','Tiruppur',55.00

    UNION ALL SELECT 'Madurai','Chennai',460.00
    UNION ALL SELECT 'Madurai','Coimbatore',215.00
    UNION ALL SELECT 'Madurai','Tiruchirappalli',145.00
    UNION ALL SELECT 'Madurai','Tirunelveli',160.00
    UNION ALL SELECT 'Madurai','Thoothukudi',135.00
    UNION ALL SELECT 'Madurai','Thanjavur',170.00
    UNION ALL SELECT 'Madurai','Dindigul',65.00
    UNION ALL SELECT 'Madurai','Ramanathapuram',120.00

    UNION ALL SELECT 'Salem','Chennai',340.00
    UNION ALL SELECT 'Salem','Coimbatore',160.00
    UNION ALL SELECT 'Salem','Madurai',235.00
    UNION ALL SELECT 'Salem','Erode',65.00
    UNION ALL SELECT 'Salem','Tiruchirappalli',175.00
    UNION ALL SELECT 'Salem','Vellore',180.00

    UNION ALL SELECT 'Tiruchirappalli','Chennai',320.00
    UNION ALL SELECT 'Tiruchirappalli','Madurai',145.00
    UNION ALL SELECT 'Tiruchirappalli','Coimbatore',215.00
    UNION ALL SELECT 'Tiruchirappalli','Salem',175.00
    UNION ALL SELECT 'Tiruchirappalli','Thanjavur',60.00
    UNION ALL SELECT 'Tiruchirappalli','Tirunelveli',300.00

    UNION ALL SELECT 'Tirunelveli','Chennai',625.00
    UNION ALL SELECT 'Tirunelveli','Madurai',160.00
    UNION ALL SELECT 'Tirunelveli','Thoothukudi',60.00
    UNION ALL SELECT 'Tirunelveli','Nagercoil',80.00

    UNION ALL SELECT 'Thoothukudi','Madurai',135.00
    UNION ALL SELECT 'Thoothukudi','Tirunelveli',60.00
    UNION ALL SELECT 'Thoothukudi','Chennai',600.00

    UNION ALL SELECT 'Erode','Chennai',400.00
    UNION ALL SELECT 'Erode','Coimbatore',100.00
    UNION ALL SELECT 'Erode','Salem',65.00
    UNION ALL SELECT 'Erode','Tiruppur',55.00

    UNION ALL SELECT 'Thanjavur','Chennai',350.00
    UNION ALL SELECT 'Thanjavur','Madurai',170.00
    UNION ALL SELECT 'Thanjavur','Tiruchirappalli',60.00
    UNION ALL SELECT 'Thanjavur','Kumbakonam',40.00

    UNION ALL SELECT 'Vellore','Chennai',145.00
    UNION ALL SELECT 'Vellore','Salem',180.00
    UNION ALL SELECT 'Vellore','Tiruvannamalai',85.00

    UNION ALL SELECT 'Tiruppur','Coimbatore',55.00
    UNION ALL SELECT 'Tiruppur','Erode',55.00
    UNION ALL SELECT 'Tiruppur','Chennai',475.00

    UNION ALL SELECT 'Dindigul','Madurai',65.00
    UNION ALL SELECT 'Dindigul','Coimbatore',160.00
    UNION ALL SELECT 'Dindigul','Tiruchirappalli',100.00

    UNION ALL SELECT 'Nagercoil','Tirunelveli',80.00
    UNION ALL SELECT 'Nagercoil','Madurai',245.00
    UNION ALL SELECT 'Nagercoil','Chennai',700.00

    UNION ALL SELECT 'Kumbakonam','Thanjavur',40.00
    UNION ALL SELECT 'Kumbakonam','Chennai',300.00
    UNION ALL SELECT 'Kumbakonam','Madurai',230.00

    UNION ALL SELECT 'Ramanathapuram','Madurai',120.00
    UNION ALL SELECT 'Ramanathapuram','Rameswaram',55.00

    UNION ALL SELECT 'Tiruvannamalai','Vellore',85.00
    UNION ALL SELECT 'Tiruvannamalai','Chennai',195.00

    UNION ALL SELECT 'Kancheepuram','Chennai',70.00
) x
JOIN city s
    ON s.city_name = x.source_name
JOIN city d
    ON d.city_name = x.destination_name;

-- ADMIN RECORDS
INSERT INTO admin
(admin_name, email, password, status)
VALUES
('System Admin','admin@tnbus.com','Admin@123','ACTIVE'),
('Bus Manager','manager@tnbus.com','Manager@123','ACTIVE');

-- USER SAMPLE RECORDS (insert before bookings)
-- INSERT USER RECORD
INSERT INTO users
(
    full_name,
    email,
    phone,
    password,
    status
)
VALUES
('Arun Kumar', 'arun@gmail.com', '9000000001', 'Arun@123', 'ACTIVE'),
('Priya S', 'priya@gmail.com', '9000000002', 'Priya@123', 'ACTIVE'),
('Karthik R', 'karthik@gmail.com', '9000000003', 'Karthik@123', 'ACTIVE'),
('Divya M', 'divya@gmail.com', '9000000004', 'Divya@123', 'ACTIVE'),
('Suresh Kumar', 'suresh@gmail.com', '9000000005', 'Suresh@123', 'ACTIVE');

INSERT INTO bus_schedule
(
    bus_id,
    route_id,
    travel_date,
    departure_time,
    arrival_time,
    fare,
    status
)
SELECT
    b.bus_id,
    r.route_id,
    x.travel_date,
    x.departure_time,
    x.arrival_time,
    x.fare,
    'SCHEDULED'
FROM
(
    SELECT 'TN01AB1001' bus_number, 'Chennai' source_name, 'Coimbatore' destination_name,
           '2026-10-05' travel_date, '05:30:00' departure_time, '14:30:00' arrival_time, 650.00 fare
    UNION ALL
    SELECT 'TN01AB1002', 'Chennai', 'Madurai',
           '2026-10-05', '06:00:00', '14:00:00', 600.00
    UNION ALL
    SELECT 'TN01AB1003', 'Chennai', 'Salem',
           '2026-10-05', '07:00:00', '13:00:00', 450.00

    UNION ALL
    SELECT 'TN02CD2001', 'Coimbatore', 'Chennai',
           '2026-10-05', '05:30:00', '14:30:00', 650.00
    UNION ALL
    SELECT 'TN02CD2002', 'Coimbatore', 'Madurai',
           '2026-10-06', '07:00:00', '12:30:00', 450.00
    UNION ALL
    SELECT 'TN02CD2003', 'Coimbatore', 'Salem',
           '2026-10-06', '08:00:00', '12:00:00', 350.00

    UNION ALL
    SELECT 'TN03EF3001', 'Madurai', 'Chennai',
           '2026-10-06', '06:00:00', '14:00:00', 600.00
    UNION ALL
    SELECT 'TN03EF3002', 'Madurai', 'Tirunelveli',
           '2026-10-06', '07:00:00', '10:30:00', 300.00
    UNION ALL
    SELECT 'TN03EF3003', 'Madurai', 'Coimbatore',
           '2026-10-07', '08:00:00', '13:00:00', 450.00

    UNION ALL
    SELECT 'TN04GH4001', 'Tiruchirappalli', 'Chennai',
           '2026-10-07', '06:00:00', '12:00:00', 500.00
    UNION ALL
    SELECT 'TN04GH4002', 'Tiruchirappalli', 'Madurai',
           '2026-10-07', '08:00:00', '11:00:00', 250.00
    UNION ALL
    SELECT 'TN04GH4003', 'Tiruchirappalli', 'Thanjavur',
           '2026-10-07', '09:00:00', '10:30:00', 180.00

    UNION ALL
    SELECT 'TN05IJ5001', 'Salem', 'Chennai',
           '2026-10-08', '06:00:00', '12:00:00', 450.00
    UNION ALL
    SELECT 'TN05IJ5002', 'Salem', 'Coimbatore',
           '2026-10-08', '07:00:00', '11:00:00', 350.00
    UNION ALL
    SELECT 'TN05IJ5003', 'Salem', 'Erode',
           '2026-10-08', '08:00:00', '10:30:00', 200.00

    UNION ALL
    SELECT 'TN06KL6001', 'Tirunelveli', 'Chennai',
           '2026-10-08', '05:30:00', '16:00:00', 800.00
    UNION ALL
    SELECT 'TN06KL6002', 'Tirunelveli', 'Thoothukudi',
           '2026-10-09', '08:00:00', '10:00:00', 200.00
    UNION ALL
    SELECT 'TN06KL6003', 'Tirunelveli', 'Nagercoil',
           '2026-10-09', '09:00:00', '11:00:00', 220.00

    UNION ALL
    SELECT 'TN07MN7001', 'Erode', 'Chennai',
           '2026-10-09', '06:00:00', '13:00:00', 550.00
    UNION ALL
    SELECT 'TN07MN7002', 'Erode', 'Coimbatore',
           '2026-10-09', '08:00:00', '10:00:00', 200.00
    UNION ALL
    SELECT 'TN07MN7003', 'Erode', 'Salem',
           '2026-10-10', '10:00:00', '12:00:00', 180.00

    UNION ALL
    SELECT 'TN08OP8001', 'Thanjavur', 'Chennai',
           '2026-10-10', '05:30:00', '12:30:00', 500.00
    UNION ALL
    SELECT 'TN08OP8002', 'Thanjavur', 'Madurai',
           '2026-10-10', '07:00:00', '11:00:00', 300.00
    UNION ALL
    SELECT 'TN08OP8003', 'Thanjavur', 'Kumbakonam',
           '2026-10-10', '09:00:00', '10:30:00', 150.00

    UNION ALL
    SELECT 'TN09QR9001', 'Salem', 'Chennai',
           '2026-10-11', '14:00:00', '20:00:00', 450.00
    UNION ALL
    SELECT 'TN09QR9002', 'Coimbatore', 'Chennai',
           '2026-10-11', '15:00:00', '23:30:00', 650.00
    UNION ALL
    SELECT 'TN09QR9003', 'Madurai', 'Chennai',
           '2026-10-11', '15:00:00', '23:00:00', 600.00

    UNION ALL
    SELECT 'TN10ST1001', 'Nagercoil', 'Chennai',
           '2026-10-12', '06:00:00', '17:00:00', 850.00
    UNION ALL
    SELECT 'TN10ST1002', 'Nagercoil', 'Madurai',
           '2026-10-12', '07:00:00', '12:00:00', 450.00
    UNION ALL
    SELECT 'TN10ST1003', 'Nagercoil', 'Tirunelveli',
           '2026-10-12', '09:00:00', '11:00:00', 220.00
) x
JOIN bus b
    ON b.bus_number = x.bus_number
JOIN city src
    ON src.city_name = x.source_name
JOIN city dest
    ON dest.city_name = x.destination_name
JOIN route r
    ON r.source_city_id = src.city_id
   AND r.destination_city_id = dest.city_id;

-- BUS SEATS RECORDS
INSERT INTO seat
(
    bus_id,
    seat_number,
    seat_type,
    status
)
WITH RECURSIVE seat_numbers AS
(
    SELECT 1 AS seat_no

    UNION ALL

    SELECT seat_no + 1
    FROM seat_numbers
    WHERE seat_no < 50
)
SELECT
    b.bus_id,
    CONCAT('S', LPAD(s.seat_no, 2, '0')) AS seat_number,

    CASE
        WHEN b.bus_type = 'AC Sleeper'
            THEN 'SLEEPER'
        ELSE 'REGULAR'
    END AS seat_type,

    'ACTIVE' AS status

FROM bus b
CROSS JOIN seat_numbers s
WHERE s.seat_no <= b.total_seats;

-- SAMPLE BOOKINGS RECORD
INSERT INTO booking
(
    user_id,
    schedule_id,
    total_amount,
    booking_status,
    payment_status
)
SELECT
    u.user_id,
    bs.schedule_id,
    bs.fare,
    x.booking_status,
    x.payment_status
FROM
(
    SELECT
        'arun@gmail.com' AS email,
        'TN01AB1001' AS bus_number,
        '2026-10-05' AS travel_date,
        'CONFIRMED' AS booking_status,
        'PAID' AS payment_status

    UNION ALL

    SELECT
        'priya@gmail.com',
        'TN02CD2001',
        '2026-10-05',
        'CONFIRMED',
        'PAID'

    UNION ALL

    SELECT
        'karthik@gmail.com',
        'TN03EF3001',
        '2026-10-06',
        'CONFIRMED',
        'PAID'

    UNION ALL

    SELECT
        'divya@gmail.com',
        'TN04GH4001',
        '2026-10-07',
        'CONFIRMED',
        'PAID'

    UNION ALL

    SELECT
        'suresh@gmail.com',
        'TN10ST1001',
        '2026-10-12',
        'CANCELLED',
        'REFUNDED'
) x
JOIN users u
    ON u.email = x.email
JOIN bus b
    ON b.bus_number = x.bus_number
JOIN bus_schedule bs
    ON bs.bus_id = b.bus_id
   AND bs.travel_date = x.travel_date;

-- ADD PASSENGERS AND SEATS RECORD
INSERT INTO booking_passenger
(
    booking_id,
    seat_id,
    passenger_name,
    age,
    gender,
    passenger_phone
)
SELECT
    bkg.booking_id,
    s.seat_id,
    x.passenger_name,
    x.age,
    x.gender,
    x.passenger_phone
FROM
(
    SELECT
        'arun@gmail.com' AS email,
        'TN01AB1001' AS bus_number,
        'S01' AS seat_number,
        'Arun Kumar' AS passenger_name,
        25 AS age,
        'MALE' AS gender,
        '9000000001' AS passenger_phone

    UNION ALL

    SELECT
        'priya@gmail.com',
        'TN02CD2001',
        'S02',
        'Priya S',
        24,
        'FEMALE',
        '9000000002'

    UNION ALL

    SELECT
        'karthik@gmail.com',
        'TN03EF3001',
        'S03',
        'Karthik R',
        28,
        'MALE',
        '9000000003'

    UNION ALL

    SELECT
        'divya@gmail.com',
        'TN04GH4001',
        'S04',
        'Divya M',
        26,
        'FEMALE',
        '9000000004'

    UNION ALL

    SELECT
        'suresh@gmail.com',
        'TN10ST1001',
        'S05',
        'Suresh Kumar',
        32,
        'MALE',
        '9000000005'
) x
JOIN users u
    ON u.email = x.email
JOIN bus b
    ON b.bus_number = x.bus_number
JOIN bus_schedule bs
    ON bs.bus_id = b.bus_id
JOIN booking bkg
    ON bkg.user_id = u.user_id
   AND bkg.schedule_id = bs.schedule_id
JOIN seat s
    ON s.bus_id = b.bus_id
   AND s.seat_number = x.seat_number;

-- ADD PAYMENTS RECORD
INSERT INTO payment
(
    booking_id,
    amount,
    payment_method,
    transaction_reference,
    payment_status
)
SELECT
    b.booking_id,
    b.total_amount,
    x.payment_method,
    x.transaction_reference,
    x.payment_status
FROM booking b
JOIN users u
    ON u.user_id = b.user_id
JOIN bus_schedule bs
    ON bs.schedule_id = b.schedule_id
JOIN bus bus_info
    ON bus_info.bus_id = bs.bus_id
JOIN
(
    SELECT
        'arun@gmail.com' email,
        'TN01AB1001' bus_number,
        'CARD' payment_method,
        'TXN10001' transaction_reference,
        'PAID' payment_status

    UNION ALL

    SELECT
        'priya@gmail.com',
        'TN02CD2001',
        'UPI',
        'TXN10002',
        'PAID'

    UNION ALL

    SELECT
        'karthik@gmail.com',
        'TN03EF3001',
        'NET_BANKING',
        'TXN10003',
        'PAID'

    UNION ALL

    SELECT
        'divya@gmail.com',
        'TN04GH4001',
        'UPI',
        'TXN10004',
        'PAID'

    UNION ALL

    SELECT
        'suresh@gmail.com',
        'TN10ST1001',
        'UPI',
        'TXN10005',
        'REFUNDED'
) x
    ON x.email = u.email
   AND x.bus_number = bus_info.bus_number;

-- BOOKING HISTORY RECORD 
   INSERT INTO booking_history
(
    booking_id,
    status,
    remarks
)
SELECT
    b.booking_id,
    b.booking_status,
    CASE
        WHEN b.booking_status = 'CANCELLED'
            THEN 'Booking cancelled and refund initiated'
        ELSE 'Booking confirmed successfully'
    END
FROM booking b;

-- CANCELLATION RECORD
INSERT INTO cancellation
(
    booking_id,
    reason,
    refund_amount,
    cancellation_status
)
SELECT
    b.booking_id,
    'Customer requested cancellation',
    b.total_amount,
    'COMPLETED'
FROM booking b
JOIN users u
    ON u.user_id = b.user_id
WHERE u.email = 'suresh@gmail.com';

-- SCHEDULE RULE RECORD (DAILY RULE)
INSERT INTO schedule_rule
(
    bus_id,
    route_id,
    departure_time,
    arrival_time,
    fare,
    recurrence_type,
    days_of_week,
    valid_from,
    valid_until,
    specific_date,
    status
)
VALUES
(
    1,
    21,
    '05:30:00',
    '14:30:00',
    650.00,
    'DAILY',
    NULL,
    '2026-10-05',
    '2026-10-15',
    NULL,
    'ACTIVE'
);

-- SCHEDULE RULE RECORD (WEEKLY RULE)
INSERT INTO schedule_rule
(
    bus_id,
    route_id,
    departure_time,
    arrival_time,
    fare,
    recurrence_type,
    days_of_week,
    valid_from,
    valid_until,
    specific_date,
    status
)
VALUES
(
    2,
    37,
    '06:00:00',
    '14:00:00',
    600.00,
    'WEEKLY',
    'MON,WED,FRI',
    '2026-10-16',
    '2026-10-25',
    NULL,
    'ACTIVE'
);

-- SPECIFIC DATE RULE RECORD 
INSERT INTO schedule_rule
(
    bus_id,
    route_id,
    departure_time,
    arrival_time,
    fare,
    recurrence_type,
    days_of_week,
    valid_from,
    valid_until,
    specific_date,
    status
)
VALUES
(
    3,
    45,
    '07:00:00',
    '13:00:00',
    450.00,
    'SPECIFIC_DATE',
    NULL,
    '2026-10-27',
    '2026-10-27',
    '2026-10-27',
    'ACTIVE'
);

-- CANCEL EXCEPTION RECORD
INSERT INTO schedule_exception
(
    schedule_rule_id,
    exception_date,
    exception_type,
    departure_time,
    arrival_time,
    fare,
    reason,
    status
)
VALUES
(
    1,
    '2026-10-13',
    'CANCEL',
    NULL,
    NULL,
    NULL,
    'Bus service cancelled for maintenance',
    'ACTIVE'
);

-- NEW DAILY SCHEDULE RULE_ID
INSERT INTO schedule_rule
(
    bus_id,
    route_id,
    departure_time,
    arrival_time,
    fare,
    recurrence_type,
    days_of_week,
    valid_from,
    valid_until,
    specific_date,
    status
)
VALUES
(
    4,
    14,
    '05:30:00',
    '14:30:00',
    650.00,
    'DAILY',
    NULL,
    '2026-10-28',
    '2026-11-02',
    NULL,
    'ACTIVE'
);

-- ADD CANCEL EXCEPTION RECORD
INSERT INTO schedule_exception
(
    schedule_rule_id,
    exception_date,
    exception_type,
    departure_time,
    arrival_time,
    fare,
    reason,
    status
)
VALUES
(
    4,
    '2026-10-30',
    'CANCEL',
    NULL,
    NULL,
    NULL,
    'Bus service cancelled for maintenance',
    'ACTIVE'
);

-- OPTIONAL SAMPLE DATA: BUS AMENITIES
INSERT IGNORE INTO bus_amenity (bus_id, wifi, charging, food, restroom, blanket, water_bottle)
SELECT bus_id, CASE WHEN bus_type IN ('AC Sleeper', 'AC Seater') THEN TRUE ELSE FALSE END, TRUE, CASE WHEN bus_type = 'AC Sleeper' THEN TRUE ELSE FALSE END, FALSE, CASE WHEN bus_type = 'AC Sleeper' THEN TRUE ELSE FALSE END, TRUE
FROM bus WHERE status = 'ACTIVE';

-- =========================================================
-- ESSENTIAL PROJECT QUERIES
-- Run these after the tables and sample data have been created.
-- =========================================================

-- 1. View active buses
SELECT bus_id, bus_number, bus_name, bus_type, total_seats
FROM bus
WHERE status = 'ACTIVE'
ORDER BY bus_name;

-- 2. Search available scheduled trips by source, destination, and date
-- Replace the city names and date with the user's search values.
SELECT bs.schedule_id, b.bus_number, b.bus_name,
       src.city_name AS source_city, dest.city_name AS destination_city,
       bs.travel_date, bs.departure_time, bs.arrival_time, bs.fare
FROM bus_schedule bs
JOIN bus b ON b.bus_id = bs.bus_id
JOIN route r ON r.route_id = bs.route_id
JOIN city src ON src.city_id = r.source_city_id
JOIN city dest ON dest.city_id = r.destination_city_id
WHERE src.city_name = 'Chennai'
  AND dest.city_name = 'Coimbatore'
  AND bs.travel_date = '2026-10-28'
  AND bs.status = 'SCHEDULED'
ORDER BY bs.departure_time;

-- 3. View seat status for a selected bus
SELECT seat_id, seat_number, seat_type, status
FROM seat
WHERE bus_id = 1
ORDER BY seat_number;

-- 4. View a user's bookings (replace email with the logged-in user's email)
SELECT bk.booking_id, bk.booking_date, bk.total_amount,
       bk.booking_status, bk.payment_status, bs.travel_date,
       bs.departure_time, b.bus_name, src.city_name AS source_city,
       dest.city_name AS destination_city
FROM booking bk
JOIN users u ON u.user_id = bk.user_id
JOIN bus_schedule bs ON bs.schedule_id = bk.schedule_id
JOIN bus b ON b.bus_id = bs.bus_id
JOIN route r ON r.route_id = bs.route_id
JOIN city src ON src.city_id = r.source_city_id
JOIN city dest ON dest.city_id = r.destination_city_id
WHERE u.email = 'arun@gmail.com'
ORDER BY bk.booking_date DESC;

-- 5. View passenger and seat details for one booking
SELECT bp.passenger_name, bp.age, bp.gender, s.seat_number
FROM booking_passenger bp
JOIN seat s ON s.seat_id = bp.seat_id
WHERE bp.booking_id = 1
ORDER BY bp.passenger_id;

-- 6. View payment status for one booking
SELECT p.payment_id, p.booking_id, p.amount, p.payment_method,
       p.transaction_reference, p.payment_status, p.payment_date
FROM payment p
WHERE p.booking_id = 1;

-- 7. View cancellation/refund status for one booking
SELECT c.cancellation_id, c.booking_id, c.reason, c.refund_amount,
       c.cancellation_status, c.cancellation_date
FROM cancellation c
WHERE c.booking_id = 1;

-- 8. View recurring schedule rules and exceptions
SELECT schedule_rule_id, bus_id, route_id, recurrence_type,
       departure_time, arrival_time, fare, valid_from, valid_until, status
FROM schedule_rule
ORDER BY schedule_rule_id;

SELECT exception_id, schedule_rule_id, exception_date, exception_type, reason, status
FROM schedule_exception
ORDER BY exception_date;

-- 9. View bus amenities
SELECT b.bus_number, b.bus_name, a.wifi, a.charging, a.food,
       a.restroom, a.blanket, a.water_bottle
FROM bus_amenity a
JOIN bus b ON b.bus_id = a.bus_id
ORDER BY b.bus_name;

-- 10. View emergency requests (staff/admin use)
SELECT emergency_id, booking_id, emergency_type, description,
       emergency_status, created_at
FROM emergency_request
ORDER BY created_at DESC;

-- 11. Basic row counts for final verification
SELECT 'users' AS table_name, COUNT(*) AS total FROM users
UNION ALL SELECT 'buses', COUNT(*) FROM bus
UNION ALL SELECT 'routes', COUNT(*) FROM route
UNION ALL SELECT 'schedules', COUNT(*) FROM bus_schedule
UNION ALL SELECT 'seats', COUNT(*) FROM seat
UNION ALL SELECT 'bookings', COUNT(*) FROM booking
UNION ALL SELECT 'passengers', COUNT(*) FROM booking_passenger
UNION ALL SELECT 'payments', COUNT(*) FROM payment;
