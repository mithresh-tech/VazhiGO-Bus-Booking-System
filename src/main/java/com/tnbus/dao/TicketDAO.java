package com.tnbus.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.tnbus.model.TicketDetails;
import com.tnbus.model.TicketDetails.TicketPassenger;
import com.tnbus.util.DBConnection;

public class TicketDAO {

    public TicketDetails getTicketDetails(
            long bookingId,
            long userId) throws SQLException {

        String ticketSql =
                "SELECT b.booking_id, b.total_amount, "
                + "b.booking_status, b.payment_status, "
                + "bus.bus_number, bus.bus_name, bus.bus_type, "
                + "sc.travel_date, sc.departure_time, sc.arrival_time, "
                + "src.city_name AS source_city, "
                + "dest.city_name AS destination_city "
                + "FROM booking b "
                + "JOIN bus_schedule sc "
                + "ON b.schedule_id = sc.schedule_id "
                + "JOIN bus ON sc.bus_id = bus.bus_id "
                + "JOIN route r ON sc.route_id = r.route_id "
                + "JOIN city src ON r.source_city_id = src.city_id "
                + "JOIN city dest ON r.destination_city_id = dest.city_id "
                + "WHERE b.booking_id = ? "
                + "AND b.user_id = ? "
                + "AND b.booking_status = 'CONFIRMED' "
                + "AND b.payment_status = 'PAID'";

        String passengerSql =
                "SELECT bp.passenger_name, bp.age, bp.gender, "
                + "s.seat_number "
                + "FROM booking_passenger bp "
                + "JOIN seat s ON bp.seat_id = s.seat_id "
                + "WHERE bp.booking_id = ? "
                + "ORDER BY bp.passenger_id";

        try (Connection connection = DBConnection.getConnection()) {

            TicketDetails ticket = null;

            // Retrieve booking, bus and journey details

            try (PreparedStatement statement =
                    connection.prepareStatement(ticketSql)) {

                statement.setLong(1, bookingId);
                statement.setLong(2, userId);

                try (ResultSet rs = statement.executeQuery()) {

                    if (rs.next()) {

                        ticket = new TicketDetails();

                        ticket.setBookingId(
                                rs.getLong("booking_id"));

                        ticket.setTotalAmount(
                                rs.getBigDecimal("total_amount"));

                        ticket.setBookingStatus(
                                rs.getString("booking_status"));

                        ticket.setPaymentStatus(
                                rs.getString("payment_status"));

                        ticket.setBusNumber(
                                rs.getString("bus_number"));

                        ticket.setBusName(
                                rs.getString("bus_name"));

                        ticket.setBusType(
                                rs.getString("bus_type"));

                        ticket.setSourceCity(
                                rs.getString("source_city"));

                        ticket.setDestinationCity(
                                rs.getString("destination_city"));

                        Date travelDate =
                                rs.getDate("travel_date");

                        if (travelDate != null) {
                            ticket.setTravelDate(
                                    travelDate.toLocalDate());
                        }

                        Time departureTime =
                                rs.getTime("departure_time");

                        if (departureTime != null) {
                            ticket.setDepartureTime(
                                    departureTime.toLocalTime());
                        }

                        Time arrivalTime =
                                rs.getTime("arrival_time");

                        if (arrivalTime != null) {
                            ticket.setArrivalTime(
                                    arrivalTime.toLocalTime());
                        }
                    }
                }
            }

            if (ticket == null) {
                return null;
            }

            // Retrieve passenger details and actual seat numbers

            List<TicketPassenger> passengers = new ArrayList<>();

            try (PreparedStatement statement =
                    connection.prepareStatement(passengerSql)) {

                statement.setLong(1, bookingId);

                try (ResultSet rs = statement.executeQuery()) {

                    while (rs.next()) {

                        TicketPassenger passenger =
                                new TicketPassenger();

                        passenger.setPassengerName(
                                rs.getString("passenger_name"));

                        passenger.setAge(
                                rs.getInt("age"));

                        passenger.setGender(
                                rs.getString("gender"));

                        passenger.setSeatNumber(
                                rs.getString("seat_number"));

                        passengers.add(passenger);
                    }
                }
            }

            ticket.setPassengers(passengers);

            return ticket;
        }
    }
}