# Online Bus Ticket Booking System (SQL)

A MySQL database project for an online bus ticket booking system. The SQL script creates the database schema, inserts demonstration data, and includes example queries for common booking and administration tasks.

## Project Overview

The database supports:
- User and administrator records
- Districts, cities, routes, buses, and bus schedules
- Bus seats and passenger details
- Bookings and payment records
- Booking history, cancellations, and refunds
- Recurring schedule rules and schedule exceptions
- Bus amenities
- Emergency requests linked to bookings

## Technology

- **Database:** MySQL 8.0+
- **Storage engine:** InnoDB (used explicitly by selected tables)
- **SQL features:** Foreign keys, `CHECK` constraints, recursive CTEs, `ENUM`, and indexes

## Database

The script creates and selects:

```sql
CREATE DATABASE IF NOT EXISTS bus_booking_db;
USE bus_booking_db;
```

## Database Tables

| Table | Purpose |
|---|---|
| `users` | Stores customer account details |
| `admin` | Stores administrator accounts |
| `district` | Stores district names |
| `city` | Stores cities and their districts |
| `bus` | Stores bus details and seat capacity |
| `route` | Defines source and destination cities |
| `bus_schedule` | Stores dated trips, timings, fares, and status |
| `seat` | Stores seats associated with each bus |
| `booking` | Stores customer bookings and booking/payment statuses |
| `booking_passenger` | Stores passenger and assigned-seat details for bookings |
| `payment` | Stores payment amount, method, transaction reference, and status |
| `cancellation` | Stores cancellation and refund information |
| `booking_history` | Records booking status history and remarks |
| `schedule_rule` | Defines daily, weekly, or specific-date schedule rules |
| `schedule_exception` | Records schedule additions or cancellations |
| `bus_amenity` | Stores amenity flags such as Wi-Fi, charging, and food |
| `emergency_request` | Stores emergency requests associated with bookings |

## Setup and Execution

1. Install and start **MySQL 8.0 or a compatible version**.
2. Open MySQL Workbench or another MySQL client.
3. Open `Bus_Booking_Queries.sql`.
4. Review the script before running it.
5. Execute the script from the beginning to create the database, tables, sample records, and example queries.
6. Check the results using the verification queries at the end of the script.

### Command-line option

From a terminal with the MySQL client installed, run:

```bash
mysql -u YOUR_USERNAME -p < Bus_Booking_Queries.sql
```

Enter your MySQL password when prompted.

## Included Sample Data

The script includes demonstration records for:
- Tamil Nadu districts and cities
- Buses and routes
- Sample users and administrators
- Bus schedules, seats, bookings, passengers, and payments
- A cancellation/refund example
- Schedule rules, exceptions, and bus amenities

The sample schedules use dates in **October and November 2026**. Update these dates if you want to test different travel dates.

## Example Queries

### 1. List active buses

```sql
SELECT bus_id, bus_number, bus_name, bus_type, total_seats
FROM bus
WHERE status = 'ACTIVE'
ORDER BY bus_name;
```

### 2. Search scheduled trips

Change the source city, destination city, and date as needed.

```sql
SELECT bs.schedule_id, b.bus_number, b.bus_name,
       src.city_name AS source_city,
       dest.city_name AS destination_city,
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
```

### 3. View seats for a bus

```sql
SELECT seat_id, seat_number, seat_type, status
FROM seat
WHERE bus_id = 1
ORDER BY seat_number;
```

### 4. View bookings for a user

Replace the sample email with the relevant user's email.

```sql
SELECT bk.booking_id, bk.booking_date, bk.total_amount,
       bk.booking_status, bk.payment_status, bs.travel_date,
       bs.departure_time, b.bus_name,
       src.city_name AS source_city,
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
```

The SQL file also includes queries for passenger and seat details, payment status, cancellation/refund status, schedule rules and exceptions, amenities, emergency requests, and table row counts.

## Important Notes

- **Use a test database first.** Several `CREATE TABLE` statements are not idempotent, so rerunning the entire script can fail when tables already exist.
- **Demo credentials are placeholders.** The script contains sample account passwords. Do not use these credentials in production or publish them in a public repository.
- **Password handling:** The sample schema uses a `password` column. A real application should store securely generated password hashes, not plaintext passwords.
- **Booking integrity:** The schema's unique constraint on `(booking_id, seat_id)` prevents duplicate seat entries within one booking, but by itself does not prevent the same seat from being assigned to different bookings for overlapping trips. Production booking logic should enforce trip-specific seat availability safely.
- **Schedule validation:** The script uses foreign keys and checks, but application logic should also validate operational details such as travel duration, overnight trips, and seat availability.
- **Sample data assumptions:** Some schedule-rule inserts use numeric bus and route IDs. Confirm that the referenced IDs match the inserted data before relying on those records.
- **MySQL compatibility:** Use a MySQL version that supports the script's `CHECK` constraints and recursive CTE syntax.

## Suggested Project Structure

```text
project/
├── Bus_Booking_Queries.sql
└── README.md
```

## Purpose

This project can be used for learning and demonstrating relational database design, SQL joins, constraints, sample-data insertion, and queries for a bus booking workflow.
