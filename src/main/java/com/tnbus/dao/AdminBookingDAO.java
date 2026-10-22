package com.tnbus.dao;

import com.tnbus.util.DBConnection;

import java.sql.*;
import java.util.*;

public class AdminBookingDAO {

    public List<Map<String, Object>> getAllBookings()
            throws SQLException {

        List<Map<String, Object>> bookings = new ArrayList<>();

        String sql = """
            SELECT
                bk.booking_id,
                bk.user_id,
                bk.schedule_id,
                bk.booking_date,
                bk.total_amount,
                bk.booking_status,
                bk.payment_status,
                u.full_name,
                u.email,
                u.phone,
                b.bus_number,
                b.bus_name,
                bs.travel_date,
                bs.departure_time,
                bs.arrival_time,
                sc.city_name AS source_city,
                dc.city_name AS destination_city,
                (SELECT COUNT(*)
                 FROM booking_passenger bp
                 WHERE bp.booking_id = bk.booking_id)
                 AS passenger_count
            FROM booking bk
            JOIN users u ON bk.user_id = u.user_id
            JOIN bus_schedule bs
                ON bk.schedule_id = bs.schedule_id
            JOIN bus b ON bs.bus_id = b.bus_id
            JOIN route r ON bs.route_id = r.route_id
            JOIN city sc ON r.source_city_id = sc.city_id
            JOIN city dc ON r.destination_city_id = dc.city_id
            ORDER BY bk.booking_date DESC, bk.booking_id DESC
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Map<String, Object> row = new LinkedHashMap<>();

                ResultSetMetaData meta = rs.getMetaData();

                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    row.put(
                        meta.getColumnLabel(i),
                        rs.getObject(i)
                    );
                }

                bookings.add(row);
            }
        }

        return bookings;
    }

    public Map<String, Object> getBookingDetails(long bookingId)
            throws SQLException {

        Map<String, Object> result = new HashMap<>();

        String paymentSql = """
            SELECT payment_id, booking_id, amount,
                   payment_method, transaction_reference,
                   payment_date, payment_status
            FROM payment
            WHERE booking_id = ?
            """;

        String passengerSql = """
            SELECT bp.passenger_id,
                   bp.passenger_name,
                   bp.age,
                   bp.gender,
                   bp.passenger_phone,
                   s.seat_number,
                   s.seat_type,
                   s.deck,
                   s.layout_type
            FROM booking_passenger bp
            JOIN seat s ON bp.seat_id = s.seat_id
            WHERE bp.booking_id = ?
            ORDER BY bp.passenger_id
            """;

        String cancellationSql = """
            SELECT cancellation_id, cancellation_date,
                   reason, refund_amount, cancellation_status
            FROM cancellation
            WHERE booking_id = ?
            """;

        try (Connection con = DBConnection.getConnection()) {

            result.put("payment", getSingleRow(
                    con, paymentSql, bookingId));

            result.put("cancellation", getSingleRow(
                    con, cancellationSql, bookingId));

            List<Map<String, Object>> passengers =
                    new ArrayList<>();

            try (PreparedStatement ps =
                         con.prepareStatement(passengerSql)) {

                ps.setLong(1, bookingId);

                try (ResultSet rs = ps.executeQuery()) {

                    while (rs.next()) {
                        passengers.add(mapRow(rs));
                    }
                }
            }

            result.put("passengers", passengers);
        }

        return result;
    }

    private Map<String, Object> getSingleRow(
            Connection con,
            String sql,
            long bookingId) throws SQLException {

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }

        return null;
    }

    private Map<String, Object> mapRow(ResultSet rs)
            throws SQLException {

        Map<String, Object> row = new LinkedHashMap<>();

        ResultSetMetaData meta = rs.getMetaData();

        for (int i = 1; i <= meta.getColumnCount(); i++) {

            row.put(
                meta.getColumnLabel(i),
                rs.getObject(i)
            );
        }

        return row;
    }
}