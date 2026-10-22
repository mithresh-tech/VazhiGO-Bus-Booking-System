package com.tnbus.dao;

import com.tnbus.model.Bus;
import com.tnbus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BusDAO {

    // Existing functionality

    public boolean addBus(Bus bus) throws SQLException {

        String sql = """
                INSERT INTO bus
                (bus_number, bus_name, bus_type, total_seats, status)
                VALUES (?, ?, ?, ?, ?)
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, bus.getBusNumber());
            statement.setString(2, bus.getBusName());
            statement.setString(3, bus.getBusType());
            statement.setInt(4, bus.getTotalSeats());
            statement.setString(5, bus.getStatus());

            return statement.executeUpdate() > 0;
        }
    }

    public boolean updateBus(Bus bus) throws SQLException {

        String sql = """
                UPDATE bus
                SET bus_number = ?,
                    bus_name = ?,
                    bus_type = ?,
                    total_seats = ?,
                    status = ?
                WHERE bus_id = ?
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, bus.getBusNumber());
            statement.setString(2, bus.getBusName());
            statement.setString(3, bus.getBusType());
            statement.setInt(4, bus.getTotalSeats());
            statement.setString(5, bus.getStatus());
            statement.setInt(6, bus.getBusId());

            return statement.executeUpdate() > 0;
        }
    }

    // Retained for compatibility with existing application code.
    // The new admin management screen NEVER invokes this method.

    public boolean deleteBus(int busId) throws SQLException {

        String sql = "DELETE FROM bus WHERE bus_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, busId);

            return statement.executeUpdate() > 0;
        }
    }

    public Bus getBusById(int busId) throws SQLException {

        String sql = "SELECT * FROM bus WHERE bus_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, busId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {
                    return mapBus(resultSet);
                }
            }
        }

        return null;
    }

    public List<Bus> getAllBuses() throws SQLException {

        List<Bus> buses = new ArrayList<>();

        String sql = "SELECT * FROM bus ORDER BY bus_id";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                buses.add(mapBus(resultSet));
            }
        }

        return buses;
    }

    // STEP 25: ADMIN-SPECIFIC METHODS

    public boolean addAdminBus(Bus bus) throws SQLException {

        String sql = """
                INSERT INTO bus
                (bus_number, bus_name, bus_type, total_seats, status)
                VALUES (?, ?, ?, ?, 'INACTIVE')
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, bus.getBusNumber());
            statement.setString(2, bus.getBusName());
            statement.setString(3, bus.getBusType());
            statement.setInt(4, bus.getTotalSeats());

            return statement.executeUpdate() == 1;
        }
    }

    // Does not modify total_seats or status.

    public boolean updateAdminBusDetails(Bus bus)
            throws SQLException {

        String sql = """
                UPDATE bus
                SET bus_number = ?,
                    bus_name = ?,
                    bus_type = ?
                WHERE bus_id = ?
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, bus.getBusNumber());
            statement.setString(2, bus.getBusName());
            statement.setString(3, bus.getBusType());
            statement.setInt(4, bus.getBusId());

            return statement.executeUpdate() > 0;
        }
    }

    public boolean updateAdminBusStatus(
            int busId,
            String status) throws SQLException {

        String sql = """
                UPDATE bus
                SET status = ?
                WHERE bus_id = ?
                AND (
                    ? = 'ACTIVE'
                    OR NOT EXISTS (
                        SELECT 1
                        FROM bus_schedule
                        WHERE bus_schedule.bus_id = bus.bus_id
                          AND travel_date >= CURRENT_DATE()
                    )
                )
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, status);
            statement.setInt(2, busId);
            statement.setString(3, status);

            return statement.executeUpdate() > 0;
        }
    }

    public boolean hasCurrentOrFutureSchedules(int busId)
            throws SQLException {

        String sql = """
                SELECT 1
                FROM bus_schedule
                WHERE bus_id = ?
                  AND travel_date >= CURRENT_DATE()
                LIMIT 1
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, busId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    public int countSeats(int busId) throws SQLException {

        String sql = """
                SELECT COUNT(*)
                FROM seat
                WHERE bus_id = ?
                  AND status = 'ACTIVE'
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, busId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {
                    return resultSet.getInt(1);
                }
            }
        }

        return 0;
    }

    private Bus mapBus(ResultSet resultSet)
            throws SQLException {

        Bus bus = new Bus();

        bus.setBusId(resultSet.getInt("bus_id"));
        bus.setBusNumber(resultSet.getString("bus_number"));
        bus.setBusName(resultSet.getString("bus_name"));
        bus.setBusType(resultSet.getString("bus_type"));
        bus.setTotalSeats(resultSet.getInt("total_seats"));
        bus.setStatus(resultSet.getString("status"));

        return bus;
    }
}