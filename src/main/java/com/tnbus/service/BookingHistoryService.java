package com.tnbus.service;

import com.tnbus.dao.BookingHistoryDAO;
import com.tnbus.model.BookingHistory;

import java.sql.SQLException;
import java.util.List;

public class BookingHistoryService {

    private final BookingHistoryDAO bookingHistoryDAO;

    public BookingHistoryService() {
        this.bookingHistoryDAO =
                new BookingHistoryDAO();
    }

    public boolean addHistory(
            BookingHistory history)
            throws SQLException {

        if (history == null) {
            return false;
        }

        if (history.getBookingId() <= 0) {
            return false;
        }

        if (history.getStatus() == null
                || history.getStatus().isBlank()) {
            return false;
        }

        return bookingHistoryDAO.addHistory(history);
    }

    public List<BookingHistory> getHistoryByBooking(
            long bookingId)
            throws SQLException {

        if (bookingId <= 0) {
            return List.of();
        }

        return bookingHistoryDAO
                .getHistoryByBooking(bookingId);
    }
}