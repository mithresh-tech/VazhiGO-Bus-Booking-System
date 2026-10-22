package com.tnbus.dao;

import com.tnbus.model.BookingPassenger;
import com.tnbus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingPassengerDAO {

    public boolean addPassenger(BookingPassenger passenger)
            throws SQLException {

        String sql = "INSERT INTO booking_passenger "
                + "(booking_id, seat_id, passenger_name, age, gender, passenger_phone) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, passenger.getBookingId());
            statement.setInt(2, passenger.getSeatId());
            statement.setString(3, passenger.getPassengerName());
            statement.setInt(4, passenger.getAge());
            statement.setString(5, passenger.getGender());
            statement.setString(6, passenger.getPassengerPhone());

            return statement.executeUpdate() > 0;
        }
    }

    public List<BookingPassenger> getPassengersByBooking(
            long bookingId) throws SQLException {

        List<BookingPassenger> passengers = new ArrayList<>();

        String sql = "SELECT * FROM booking_passenger "
                + "WHERE booking_id = ? ORDER BY passenger_id";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, bookingId);

            try (ResultSet resultSet = statement.executeQuery()) {

                while (resultSet.next()) {

                    BookingPassenger passenger = new BookingPassenger();

                    passenger.setPassengerId(
                            resultSet.getLong("passenger_id"));
                    passenger.setBookingId(
                            resultSet.getLong("booking_id"));
                    passenger.setSeatId(
                            resultSet.getInt("seat_id"));
                    passenger.setPassengerName(
                            resultSet.getString("passenger_name"));
                    passenger.setAge(
                            resultSet.getInt("age"));
                    passenger.setGender(
                            resultSet.getString("gender"));
                    passenger.setPassengerPhone(
                            resultSet.getString("passenger_phone"));

                    passengers.add(passenger);
                }
            }
        }

        return passengers;
    }
}