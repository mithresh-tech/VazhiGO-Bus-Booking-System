package com.tnbus.dao;

import com.tnbus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class AdminUserDAO {

    public List<Map<String, Object>> getUsers(
            String userId,
            String keyword,
            String status) throws SQLException {

        List<Map<String, Object>> users = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT
                u.user_id,
                u.full_name,
                u.email,
                u.phone,
                u.created_at,
                u.status,
                (
                    SELECT COUNT(*)
                    FROM booking b
                    WHERE b.user_id = u.user_id
                ) AS booking_count
            FROM users u
            WHERE 1 = 1
            """);

        List<Object> parameters = new ArrayList<>();

        if (userId != null && !userId.isBlank()) {
            sql.append(" AND u.user_id = ? ");
            parameters.add(Long.parseLong(userId));
        }

        if (keyword != null && !keyword.isBlank()) {
            sql.append("""
                AND (
                    LOWER(u.full_name) LIKE ?
                    OR LOWER(u.email) LIKE ?
                    OR u.phone LIKE ?
                )
                """);

            String search = "%" + keyword.toLowerCase() + "%";

            parameters.add(search);
            parameters.add(search);
            parameters.add("%" + keyword + "%");
        }

        if (status != null && !status.isBlank()) {
            sql.append(" AND UPPER(u.status) = ? ");
            parameters.add(status.toUpperCase());
        }

        sql.append(" ORDER BY u.user_id DESC ");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps =
                     con.prepareStatement(sql.toString())) {

            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    users.add(mapRow(rs));
                }
            }
        }

        return users;
    }

    public Map<String, Object> getUserById(long userId)
            throws SQLException {

        String sql = """
            SELECT
                u.user_id,
                u.full_name,
                u.email,
                u.phone,
                u.created_at,
                u.status,
                (
                    SELECT COUNT(*)
                    FROM booking b
                    WHERE b.user_id = u.user_id
                ) AS booking_count,
                (
                    SELECT COALESCE(SUM(b.total_amount), 0)
                    FROM booking b
                    WHERE b.user_id = u.user_id
                    AND UPPER(b.booking_status) = 'CONFIRMED'
                    AND UPPER(b.payment_status) = 'PAID'
                ) AS confirmed_booking_amount
            FROM users u
            WHERE u.user_id = ?
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }

        return null;
    }

    public List<String> getAvailableStatuses()
            throws SQLException {

        List<String> statuses = new ArrayList<>();

        String sql = """
            SELECT DISTINCT status
            FROM users
            WHERE status IS NOT NULL
            AND TRIM(status) <> ''
            ORDER BY status
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                statuses.add(rs.getString("status"));
            }
        }

        return statuses;
    }

    public long getTotalUsers() throws SQLException {

        String sql = "SELECT COUNT(*) FROM users";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            return rs.next() ? rs.getLong(1) : 0;
        }
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