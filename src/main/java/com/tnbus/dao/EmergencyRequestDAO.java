package com.tnbus.dao;

import com.tnbus.model.EmergencyRequest;
import com.tnbus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmergencyRequestDAO {

    // CREATE EMERGENCY REQUEST

    public long createEmergencyRequest(
            EmergencyRequest emergency)
            throws SQLException {

        String sql =
                "INSERT INTO emergency_request "
                + "(booking_id, emergency_type, description, emergency_status) "
                + "VALUES (?, ?, ?, 'OPEN')";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(
                             sql, Statement.RETURN_GENERATED_KEYS)) {

            statement.setLong(1, emergency.getBookingId());
            statement.setString(2, emergency.getEmergencyType());
            statement.setString(3, emergency.getDescription());

            if (statement.executeUpdate() != 1) {
                throw new SQLException(
                        "Unable to create emergency request.");
            }

            try (ResultSet resultSet =
                         statement.getGeneratedKeys()) {

                if (resultSet.next()) {
                    return resultSet.getLong(1);
                }
            }
        }

        throw new SQLException(
                "Emergency reference number was not generated.");
    }

    // GET REQUESTS FOR A BOOKING

    public List<EmergencyRequest> getRequestsByBookingId(
            long bookingId) throws SQLException {

        List<EmergencyRequest> requests = new ArrayList<>();

        String sql =
                "SELECT * FROM emergency_request "
                + "WHERE booking_id = ? "
                + "ORDER BY created_at DESC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setLong(1, bookingId);

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {
                    requests.add(mapEmergency(rs));
                }
            }
        }

        return requests;
    }

    // GET ALL REQUESTS - FOR FUTURE ADMIN DASHBOARD

    public List<EmergencyRequest> getAllEmergencyRequests()
            throws SQLException {

        List<EmergencyRequest> requests = new ArrayList<>();

        String sql =
                "SELECT * FROM emergency_request "
                + "ORDER BY created_at DESC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {

            while (rs.next()) {
                requests.add(mapEmergency(rs));
            }
        }

        return requests;
    }

    // UPDATE REQUEST STATUS - FOR FUTURE ADMIN DASHBOARD

    public boolean updateEmergencyStatus(
            long emergencyId,
            String status) throws SQLException {

        if (!"OPEN".equals(status)
                && !"IN_PROGRESS".equals(status)
                && !"RESOLVED".equals(status)) {

            throw new IllegalArgumentException(
                    "Invalid emergency status.");
        }

        String sql =
                "UPDATE emergency_request "
                + "SET emergency_status = ? "
                + "WHERE emergency_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, status);
            statement.setLong(2, emergencyId);

            return statement.executeUpdate() > 0;
        }
    }

    private EmergencyRequest mapEmergency(ResultSet rs)
            throws SQLException {

        EmergencyRequest emergency = new EmergencyRequest();

        emergency.setEmergencyId(
                rs.getLong("emergency_id"));

        emergency.setBookingId(
                rs.getLong("booking_id"));

        emergency.setEmergencyType(
                rs.getString("emergency_type"));

        emergency.setDescription(
                rs.getString("description"));

        emergency.setEmergencyStatus(
                rs.getString("emergency_status"));

        Timestamp created = rs.getTimestamp("created_at");
        Timestamp updated = rs.getTimestamp("updated_at");

        if (created != null) {
            emergency.setCreatedAt(created.toLocalDateTime());
        }

        if (updated != null) {
            emergency.setUpdatedAt(updated.toLocalDateTime());
        }

        return emergency;
    }
}