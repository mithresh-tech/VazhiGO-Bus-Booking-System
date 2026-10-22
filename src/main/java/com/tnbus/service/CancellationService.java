package com.tnbus.service;

import java.sql.SQLException;

import com.tnbus.dao.CancellationDAO;
import com.tnbus.model.Cancellation;

public class CancellationService {

    private final CancellationDAO cancellationDAO;

    public CancellationService() {

        this.cancellationDAO = new CancellationDAO();
    }

    public boolean addCancellation(Cancellation cancellation)
            throws SQLException {

        if (cancellation == null) {
            return false;
        }

        if (cancellation.getBookingId() <= 0) {
            return false;
        }

        if (cancellation.getReason() == null
                || cancellation.getReason().isBlank()) {
            return false;
        }

        String reason = cancellation.getReason().trim();

        if (reason.length() > 255) {
            return false;
        }

        cancellation.setReason(reason);

        // Immediate cancellation workflow.
        // The DAO validates eligibility and atomically
        // stores COMPLETED and updates the booking to CANCELLED.

        cancellation.setCancellationStatus("COMPLETED");

        return cancellationDAO.addCancellation(cancellation);
    }

    public Cancellation getCancellationByBookingId(long bookingId)
            throws SQLException {

        if (bookingId <= 0) {
            return null;
        }

        return cancellationDAO.getCancellationByBookingId(bookingId);
    }
}