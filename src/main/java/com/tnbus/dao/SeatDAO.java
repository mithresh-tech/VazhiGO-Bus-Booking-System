package com.tnbus.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.tnbus.model.Seat;
import com.tnbus.util.DBConnection;

public class SeatDAO {

    // ==========================================
    // MAP DATABASE RESULT TO SEAT MODEL
    // ==========================================

    private Seat mapSeat(ResultSet rs) throws SQLException {

        Seat seat = new Seat();

        seat.setSeatId(rs.getInt("seat_id"));
        seat.setBusId(rs.getInt("bus_id"));
        seat.setSeatNumber(rs.getString("seat_number"));
        seat.setSeatType(rs.getString("seat_type"));
        seat.setStatus(rs.getString("status"));

        // New layout metadata
        seat.setDeck(rs.getString("deck"));
        seat.setLayoutType(rs.getString("layout_type"));
        seat.setSeatSide(rs.getString("seat_side"));

        int rowNumber = rs.getInt("row_number");
        seat.setRowNumber(
                rs.wasNull() ? null : rowNumber
        );

        int columnNumber = rs.getInt("column_number");
        seat.setColumnNumber(
                rs.wasNull() ? null : columnNumber
        );

        seat.setBerthGroup(rs.getString("berth_group"));

        return seat;
    }

    // ==========================================
    // GET ALL ACTIVE SEATS FOR A BUS
    // ==========================================

    public List<Seat> getSeatsByBus(int busId)
            throws SQLException {

        List<Seat> seats = new ArrayList<>();

        String sql =
                "SELECT * FROM seat "
                + "WHERE bus_id = ? "
                + "AND status = 'ACTIVE' "
                + "ORDER BY seat_id";

        try (Connection connection =
                     DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, busId);

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {
                    seats.add(mapSeat(rs));
                }
            }
        }

        return seats;
    }

    // ==========================================
    // GET SEAT BY ID
    // ==========================================

    public Seat getSeatById(int seatId)
            throws SQLException {

        String sql =
                "SELECT * FROM seat WHERE seat_id = ?";

        try (Connection connection =
                     DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, seatId);

            try (ResultSet rs = statement.executeQuery()) {

                if (rs.next()) {
                    return mapSeat(rs);
                }
            }
        }

        return null;
    }

    // ==========================================
    // GET BOOKED SEAT IDS FOR A SCHEDULE
    // ==========================================

    public List<Integer> getBookedSeatIdsBySchedule(
            int scheduleId) throws SQLException {

        List<Integer> bookedSeatIds = new ArrayList<>();

        String sql =
                "SELECT DISTINCT bp.seat_id "
                + "FROM booking_passenger bp "
                + "JOIN booking b "
                + "ON bp.booking_id = b.booking_id "
                + "WHERE b.schedule_id = ? "
                + "AND b.booking_status <> 'CANCELLED'";

        try (Connection connection =
                     DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, scheduleId);

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {
                    bookedSeatIds.add(rs.getInt("seat_id"));
                }
            }
        }

        return bookedSeatIds;
    }

    // ==========================================
    // GET BOOKED SEAT GENDERS
    // ==========================================

    public Map<Integer, String> getBookedSeatGendersBySchedule(
            int scheduleId) throws SQLException {

        Map<Integer, String> bookedSeatGenders =
                new HashMap<>();

        String sql =
                "SELECT bp.seat_id, bp.gender "
                + "FROM booking_passenger bp "
                + "JOIN booking b "
                + "ON bp.booking_id = b.booking_id "
                + "WHERE b.schedule_id = ? "
                + "AND b.booking_status <> 'CANCELLED'";

        try (Connection connection =
                     DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, scheduleId);

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {

                    bookedSeatGenders.put(
                            rs.getInt("seat_id"),
                            rs.getString("gender")
                    );
                }
            }
        }

        return bookedSeatGenders;
    }
}