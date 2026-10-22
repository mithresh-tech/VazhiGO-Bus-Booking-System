package com.tnbus.service;

import java.sql.SQLException;
import java.util.List;

import com.tnbus.dao.BookingPassengerDAO;
import com.tnbus.exception.BookingException;
import com.tnbus.model.BookingPassenger;
import com.tnbus.util.ValidationUtil;

public class BookingPassengerService {

    private final BookingPassengerDAO bookingPassengerDAO;

    public BookingPassengerService() {
        this.bookingPassengerDAO = new BookingPassengerDAO();
    }

    public boolean addPassenger(BookingPassenger passenger)
            throws SQLException, BookingException {

        if (passenger == null) {
            throw new BookingException(
                    "Passenger details cannot be null.");
        }

        if (passenger.getBookingId() <= 0) {
            throw new BookingException(
                    "Invalid booking ID.");
        }

        if (passenger.getSeatId() <= 0) {
            throw new BookingException(
                    "Invalid seat ID.");
        }

        if (!ValidationUtil.isValidName(
                passenger.getPassengerName())) {

            throw new BookingException(
                    "Invalid passenger name.");
        }

        if (!ValidationUtil.isValidAge(
                passenger.getAge())) {

            throw new BookingException(
                    "Invalid passenger age.");
        }

        if (!ValidationUtil.isNotEmpty(
                passenger.getGender())) {

            throw new BookingException(
                    "Passenger gender is required.");
        }

        return bookingPassengerDAO.addPassenger(passenger);
    }

    public List<BookingPassenger> getPassengersByBooking(
            long bookingId) throws SQLException {

        if (bookingId <= 0) {
            return List.of();
        }

        return bookingPassengerDAO
                .getPassengersByBooking(bookingId);
    }
}