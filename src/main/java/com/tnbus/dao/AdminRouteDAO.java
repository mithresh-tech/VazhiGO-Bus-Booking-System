package com.tnbus.dao;

import com.tnbus.util.DBConnection;

import java.sql.*;
import java.util.*;

public class AdminRouteDAO {

    private static final String BASE_QUERY = """
        SELECT
            r.route_id,
            r.source_city_id,
            r.destination_city_id,
            sc.city_name AS source_city,
            dc.city_name AS destination_city,
            r.distance_km,
            r.status,
            (
                SELECT COUNT(*)
                FROM bus_schedule bs
                WHERE bs.route_id = r.route_id
            ) AS schedule_count
        FROM route r
        JOIN city sc ON r.source_city_id = sc.city_id
        JOIN city dc ON r.destination_city_id = dc.city_id
        """;

    public List<Map<String, Object>> getRoutes(
            String routeId,
            String source,
            String destination,
            String status) throws SQLException {

        List<Map<String, Object>> routes = new ArrayList<>();
        List<Object> parameters = new ArrayList<>();

        StringBuilder sql = new StringBuilder(BASE_QUERY);

        sql.append(" WHERE 1=1 ");

        if (routeId != null && !routeId.isBlank()) {
            sql.append(" AND r.route_id = ? ");
            parameters.add(Integer.parseInt(routeId));
        }

        if (source != null && !source.isBlank()) {
            sql.append(" AND LOWER(sc.city_name) LIKE ? ");
            parameters.add("%" + source.toLowerCase() + "%");
        }

        if (destination != null && !destination.isBlank()) {
            sql.append(" AND LOWER(dc.city_name) LIKE ? ");
            parameters.add("%" + destination.toLowerCase() + "%");
        }

        if (status != null && !status.isBlank()) {
            sql.append(" AND UPPER(r.status) = ? ");
            parameters.add(status.toUpperCase());
        }

        sql.append(" ORDER BY r.route_id DESC ");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps =
                     con.prepareStatement(sql.toString())) {

            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    routes.add(mapRow(rs));
                }
            }
        }

        return routes;
    }

    public Map<String, Object> getRouteById(int routeId)
            throws SQLException {

        String sql = BASE_QUERY + " WHERE r.route_id = ? ";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, routeId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public List<String> getStatuses() throws SQLException {

        List<String> statuses = new ArrayList<>();

        String sql = """
            SELECT DISTINCT status
            FROM route
            WHERE status IS NOT NULL
            AND TRIM(status) <> ''
            ORDER BY status
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                statuses.add(rs.getString(1));
            }
        }

        return statuses;
    }

    public long getTotalRoutes() throws SQLException {

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps =
                     con.prepareStatement("SELECT COUNT(*) FROM route");
             ResultSet rs = ps.executeQuery()) {

            return rs.next() ? rs.getLong(1) : 0;
        }
    }

    private Map<String, Object> mapRow(ResultSet rs)
            throws SQLException {

        Map<String, Object> row = new LinkedHashMap<>();
        ResultSetMetaData meta = rs.getMetaData();

        for (int i = 1; i <= meta.getColumnCount(); i++) {
            row.put(meta.getColumnLabel(i), rs.getObject(i));
        }

        return row;
    }
}