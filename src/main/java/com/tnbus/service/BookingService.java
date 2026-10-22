package com.tnbus.service;

import com.tnbus.dao.BookingDAO;
import com.tnbus.exception.BookingException;
import com.tnbus.model.Booking;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

public class BookingService {

    private final BookingDAO bookingDAO;

    public BookingService() {
        this.bookingDAO = new BookingDAO();
    }

    public long createBooking(Booking booking)
            throws SQLException, BookingException {

        if (booking == null) {
            throw new BookingException(
                    "Booking details cannot be null.");
        }

        if (booking.getUserId() <= 0) {
            throw new BookingException(
                    "Invalid user ID.");
        }

        if (booking.getScheduleId() <= 0) {
            throw new BookingException(
                    "Invalid schedule ID.");
        }

        BigDecimal amount = booking.getTotalAmount();

        if (amount == null || amount.signum() < 0) {
            throw new BookingException(
                    "Invalid booking amount.");
        }

        if (booking.getBookingStatus() == null
                || booking.getBookingStatus().isBlank()) {
            booking.setBookingStatus("PENDING");
        }

        if (booking.getPaymentStatus() == null
                || booking.getPaymentStatus().isBlank()) {
            booking.setPaymentStatus("PENDING");
        }

        long bookingId = bookingDAO.createBooking(booking);

        if (bookingId <= 0) {
            throw new BookingException(
                    "Booking could not be created.");
        }

        return bookingId;
    }

    public Booking getBookingById(long bookingId)
            throws SQLException, BookingException {

        if (bookingId <= 0) {
            throw new BookingException(
                    "Invalid booking ID.");
        }

        Booking booking =
                bookingDAO.getBookingById(bookingId);

        if (booking == null) {
            throw new BookingException(
                    "Booking not found.");
        }

        return booking;
    }

    public List<Booking> getBookingsByUser(long userId)
            throws SQLException {

        if (userId <= 0) {
            return List.of();
        }

        return bookingDAO.getBookingsByUser(userId);
    }

    public List<Booking> getAllBookings()
            throws SQLException {

        return bookingDAO.getAllBookings();
    }

    public boolean updateBookingStatus(
            long bookingId,
            String bookingStatus,
            String paymentStatus)
            throws SQLException, BookingException {

        if (bookingId <= 0) {
            throw new BookingException(
                    "Invalid booking ID.");
        }

        if (bookingStatus == null
                || bookingStatus.isBlank()) {
            throw new BookingException(
                    "Booking status is required.");
        }

        if (paymentStatus == null
                || paymentStatus.isBlank()) {
            throw new BookingException(
                    "Payment status is required.");
        }

        return bookingDAO.updateBookingStatus(
                bookingId,
                bookingStatus,
                paymentStatus);
    }
}