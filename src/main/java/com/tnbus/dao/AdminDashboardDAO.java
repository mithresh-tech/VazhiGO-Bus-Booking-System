package com.tnbus.dao;

import com.tnbus.util.DBConnection;

import java.sql.*;
import java.util.*;

public class AdminDashboardDAO {

    public Map<String, Object> getDashboardSummary()
            throws SQLException {

        Map<String, Object> summary = new LinkedHashMap<>();

        String sql = """
            SELECT
                (SELECT COUNT(*) FROM users) AS total_users,

                (SELECT COUNT(*) FROM bus) AS total_buses,

                (SELECT COUNT(*) FROM route) AS total_routes,

                (SELECT COUNT(*) FROM bus_schedule)
                    AS total_schedules,

                (SELECT COUNT(*) FROM booking)
                    AS total_bookings,

                (SELECT COUNT(*) FROM booking
                 WHERE UPPER(booking_status) = 'CONFIRMED')
                    AS confirmed_bookings,

                (SELECT COUNT(*) FROM booking
                 WHERE UPPER(booking_status) = 'PENDING')
                    AS pending_bookings,

                (SELECT COUNT(*) FROM booking
                 WHERE UPPER(booking_status) = 'CANCELLED')
                    AS cancelled_bookings,

                (SELECT COALESCE(SUM(total_amount), 0)
                 FROM booking
                 WHERE UPPER(booking_status) = 'CONFIRMED'
                   AND UPPER(payment_status) = 'PAID')
                    AS confirmed_paid_amount,

                (SELECT COUNT(*) FROM booking
                 WHERE booking_date >= CURRENT_DATE()
                   AND booking_date < CURRENT_DATE()
                       + INTERVAL 1 DAY)
                    AS today_bookings
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {

                ResultSetMetaData meta = rs.getMetaData();

                for (int i = 1; i <= meta.getColumnCount(); i++) {

                    summary.put(
                        meta.getColumnLabel(i),
                        rs.getObject(i)
                    );
                }
            }
        }

        return summary;
    }

    public List<Map<String, Object>> getRecentBookings()
            throws SQLException {

        List<Map<String, Object>> results = new ArrayList<>();

        String sql = """
            SELECT
                booking_id,
                user_id,
                schedule_id,
                booking_date,
                total_amount,
                booking_status,
                payment_status
            FROM booking
            ORDER BY booking_date DESC, booking_id DESC
            LIMIT 10
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Map<String, Object> row = new LinkedHashMap<>();

                row.put("booking_id", rs.getLong("booking_id"));
                row.put("user_id", rs.getLong("user_id"));
                row.put("schedule_id", rs.getInt("schedule_id"));

                row.put(
                    "booking_date",
                    rs.getTimestamp("booking_date")
                );

                row.put(
                    "total_amount",
                    rs.getBigDecimal("total_amount")
                );

                row.put(
                    "booking_status",
                    rs.getString("booking_status")
                );

                row.put(
                    "payment_status",
                    rs.getString("payment_status")
                );

                results.add(row);
            }
        }

        return results;
    }

    public List<Map<String, Object>> getTopRoutes()
            throws SQLException {

        List<Map<String, Object>> results = new ArrayList<>();

        String sql = """
            SELECT
                r.route_id,
                sc.city_name AS source_city,
                dc.city_name AS destination_city,

                COUNT(bk.booking_id) AS total_bookings,

                COALESCE(SUM(
                    CASE
                        WHEN UPPER(bk.booking_status) = 'CONFIRMED'
                         AND UPPER(bk.payment_status) = 'PAID'
                        THEN bk.total_amount
                        ELSE 0
                    END
                ), 0) AS confirmed_paid_amount

            FROM route r

            JOIN city sc
                ON r.source_city_id = sc.city_id

            JOIN city dc
                ON r.destination_city_id = dc.city_id

            JOIN bus_schedule bs
                ON r.route_id = bs.route_id

            JOIN booking bk
                ON bs.schedule_id = bk.schedule_id

            GROUP BY
                r.route_id,
                sc.city_name,
                dc.city_name

            ORDER BY
                total_bookings DESC,
                r.route_id ASC

            LIMIT 5
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Map<String, Object> row = new LinkedHashMap<>();

                row.put("route_id", rs.getInt("route_id"));

                row.put(
                    "source_city",
                    rs.getString("source_city")
                );

                row.put(
                    "destination_city",
                    rs.getString("destination_city")
                );

                row.put(
                    "total_bookings",
                    rs.getLong("total_bookings")
                );

                row.put(
                    "confirmed_paid_amount",
                    rs.getBigDecimal("confirmed_paid_amount")
                );

                results.add(row);
            }
        }

        return results;
    }
}