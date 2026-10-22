package com.tnbus.dao;

import com.tnbus.model.BookingHistory;
import com.tnbus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingHistoryDAO {

    public boolean addHistory(BookingHistory history)
            throws SQLException {

        String sql = "INSERT INTO booking_history "
                + "(booking_id, status, remarks) "
                + "VALUES (?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, history.getBookingId());
            statement.setString(2, history.getStatus());
            statement.setString(3, history.getRemarks());

            return statement.executeUpdate() > 0;
        }
    }

    public List<BookingHistory> getHistoryByBooking(
            long bookingId) throws SQLException {

        List<BookingHistory> historyList = new ArrayList<>();

        String sql = "SELECT * FROM booking_history "
                + "WHERE booking_id = ? ORDER BY changed_at";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, bookingId);

            try (ResultSet resultSet = statement.executeQuery()) {

                while (resultSet.next()) {

                    BookingHistory history = new BookingHistory();

                    history.setHistoryId(
                            resultSet.getLong("history_id"));
                    history.setBookingId(
                            resultSet.getLong("booking_id"));
                    history.setStatus(
                            resultSet.getString("status"));

                    Timestamp timestamp =
                            resultSet.getTimestamp("changed_at");

                    if (timestamp != null) {
                        history.setChangedAt(
                                timestamp.toLocalDateTime());
                    }

                    history.setRemarks(
                            resultSet.getString("remarks"));

                    historyList.add(history);
                }
            }
        }

        return historyList;
    }
}