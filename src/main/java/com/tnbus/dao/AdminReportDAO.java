package com.tnbus.dao;

import com.tnbus.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.*;

public class AdminReportDAO {

    /*
     * Date filtering uses:
     * booking_date >= startDate
     * booking_date < endDate + 1 day
     *
     * Revenue definition:
     * CONFIRMED booking + PAID payment status.
     *
     * This is booking-value reporting, not actual bank settlement.
     * No passenger/payment joins are used for revenue aggregation,
     * preventing duplicate booking amounts.
     */

    public Map<String, Object> getSummary(
            LocalDate from, LocalDate to) throws SQLException {

        String sql = """
            SELECT
                COUNT(*) AS total_bookings,

                COALESCE(SUM(
                    CASE WHEN UPPER(booking_status) = 'CONFIRMED'
                    THEN 1 ELSE 0 END
                ), 0) AS confirmed_bookings,

                COALESCE(SUM(
                    CASE WHEN UPPER(booking_status) = 'CANCELLED'
                    THEN 1 ELSE 0 END
                ), 0) AS cancelled_bookings,

                COALESCE(SUM(
                    CASE WHEN UPPER(booking_status) = 'PENDING'
                    THEN 1 ELSE 0 END
                ), 0) AS pending_bookings,

                COALESCE(SUM(
                    CASE
                        WHEN UPPER(booking_status) = 'CONFIRMED'
                         AND UPPER(payment_status) = 'PAID'
                        THEN total_amount
                        ELSE 0
                    END
                ), 0) AS confirmed_paid_amount

            FROM booking
            WHERE booking_date >= ?
              AND booking_date < ?
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            setDates(ps, from, to);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : new LinkedHashMap<>();
            }
        }
    }

    public List<Map<String, Object>> getBookingStatusReport(
            LocalDate from, LocalDate to) throws SQLException {

        String sql = """
            SELECT
                COALESCE(booking_status, 'UNKNOWN') AS status,
                COUNT(*) AS total
            FROM booking
            WHERE booking_date >= ?
              AND booking_date < ?
            GROUP BY booking_status
            ORDER BY total DESC, status
            """;

        return executeReport(sql, from, to);
    }

    public List<Map<String, Object>> getPaymentStatusReport(
            LocalDate from, LocalDate to) throws SQLException {

        String sql = """
            SELECT
                COALESCE(payment_status, 'UNKNOWN') AS status,
                COUNT(*) AS total
            FROM booking
            WHERE booking_date >= ?
              AND booking_date < ?
            GROUP BY payment_status
            ORDER BY total DESC, status
            """;

        return executeReport(sql, from, to);
    }

    public List<Map<String, Object>> getRouteReport(
            LocalDate from, LocalDate to) throws SQLException {

        String sql = """
            SELECT
                r.route_id,
                sc.city_name AS source_city,
                dc.city_name AS destination_city,

                COUNT(bk.booking_id) AS total_bookings,

                COALESCE(SUM(
                    CASE
                        WHEN UPPER(bk.booking_status) = 'CONFIRMED'
                        THEN 1 ELSE 0
                    END
                ), 0) AS confirmed_bookings,

                COALESCE(SUM(
                    CASE
                        WHEN UPPER(bk.booking_status) = 'CANCELLED'
                        THEN 1 ELSE 0
                    END
                ), 0) AS cancelled_bookings,

                COALESCE(SUM(
                    CASE
                        WHEN UPPER(bk.booking_status) = 'CONFIRMED'
                         AND UPPER(bk.payment_status) = 'PAID'
                        THEN bk.total_amount
                        ELSE 0
                    END
                ), 0) AS confirmed_paid_amount

            FROM booking bk

            JOIN bus_schedule bs
                ON bk.schedule_id = bs.schedule_id

            JOIN route r
                ON bs.route_id = r.route_id

            JOIN city sc
                ON r.source_city_id = sc.city_id

            JOIN city dc
                ON r.destination_city_id = dc.city_id

            WHERE bk.booking_date >= ?
              AND bk.booking_date < ?

            GROUP BY
                r.route_id,
                sc.city_name,
                dc.city_name

            ORDER BY total_bookings DESC, r.route_id
            """;

        return executeReport(sql, from, to);
    }

    public List<Map<String, Object>> getDailyReport(
            LocalDate from, LocalDate to) throws SQLException {

        String sql = """
            SELECT
                DATE(booking_date) AS report_date,
                COUNT(*) AS total_bookings,

                COALESCE(SUM(
                    CASE
                        WHEN UPPER(booking_status) = 'CONFIRMED'
                         AND UPPER(payment_status) = 'PAID'
                        THEN total_amount
                        ELSE 0
                    END
                ), 0) AS confirmed_paid_amount

            FROM booking

            WHERE booking_date >= ?
              AND booking_date < ?

            GROUP BY DATE(booking_date)

            ORDER BY report_date DESC
            """;

        return executeReport(sql, from, to);
    }

    private List<Map<String, Object>> executeReport(
            String sql,
            LocalDate from,
            LocalDate to) throws SQLException {

        List<Map<String, Object>> results = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            setDates(ps, from, to);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    results.add(mapRow(rs));
                }
            }
        }

        return results;
    }

    private void setDates(
            PreparedStatement ps,
            LocalDate from,
            LocalDate to) throws SQLException {

        ps.setTimestamp(
            1,
            Timestamp.valueOf(from.atStartOfDay())
        );

        ps.setTimestamp(
            2,
            Timestamp.valueOf(to.plusDays(1).atStartOfDay())
        );
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