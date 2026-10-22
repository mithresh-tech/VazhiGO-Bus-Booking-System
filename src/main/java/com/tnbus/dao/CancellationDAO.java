package com.tnbus.dao;

import java.sql.*;
import java.math.BigDecimal;

import com.tnbus.model.Cancellation;
import com.tnbus.util.DBConnection;

public class CancellationDAO {

    public boolean addCancellation(Cancellation cancellation)
            throws SQLException {

        if (cancellation == null
                || cancellation.getBookingId() <= 0
                || cancellation.getReason() == null
                || cancellation.getReason().isBlank()
                || cancellation.getReason().trim().length() > 255) {

            return false;
        }

        try (Connection connection = DBConnection.getConnection()) {

            connection.setAutoCommit(false);

            try {

                long bookingId = cancellation.getBookingId();

                // ==========================================
                // LOCK AND VALIDATE BOOKING
                // ==========================================

                String checkBooking =
                        "SELECT booking_status, payment_status, total_amount "
                        + "FROM booking "
                        + "WHERE booking_id = ? FOR UPDATE";

                String bookingStatus;
                String paymentStatus;
                BigDecimal totalAmount;

                try (PreparedStatement statement =
                        connection.prepareStatement(checkBooking)) {

                    statement.setLong(1, bookingId);

                    try (ResultSet rs = statement.executeQuery()) {

                        if (!rs.next()) {

                            connection.rollback();
                            return false;
                        }

                        bookingStatus =
                                rs.getString("booking_status");

                        paymentStatus =
                                rs.getString("payment_status");

                        totalAmount =
                                rs.getBigDecimal("total_amount");
                    }
                }

                // ==========================================
                // VALIDATE ELIGIBLE BOOKING STATUS
                // ==========================================

                boolean confirmedAndPaid =
                        "CONFIRMED".equalsIgnoreCase(bookingStatus)
                        && "PAID".equalsIgnoreCase(paymentStatus);

                boolean pendingAndUnpaid =
                        "PENDING".equalsIgnoreCase(bookingStatus)
                        && "PENDING".equalsIgnoreCase(paymentStatus);

                if (!confirmedAndPaid && !pendingAndUnpaid) {

                    connection.rollback();
                    return false;
                }

                // ==========================================
                // PREVENT DUPLICATE CANCELLATION
                // ==========================================

                String checkCancellation =
                        "SELECT cancellation_id "
                        + "FROM cancellation "
                        + "WHERE booking_id = ?";

                try (PreparedStatement statement =
                        connection.prepareStatement(checkCancellation)) {

                    statement.setLong(1, bookingId);

                    try (ResultSet rs = statement.executeQuery()) {

                        if (rs.next()) {

                            connection.rollback();
                            return false;
                        }
                    }
                }

                // ==========================================
                // CALCULATE DEMO REFUND AMOUNT
                // ==========================================

                BigDecimal refundAmount = BigDecimal.ZERO;

                if (confirmedAndPaid) {

                    if (totalAmount == null
                            || totalAmount.signum() < 0) {

                        connection.rollback();
                        return false;
                    }

                    refundAmount = totalAmount;
                }

                // ==========================================
                // INSERT COMPLETED CANCELLATION
                // ==========================================

                String insertCancellation =
                        "INSERT INTO cancellation "
                        + "(booking_id, reason, refund_amount, "
                        + "cancellation_status) "
                        + "VALUES (?, ?, ?, ?)";

                try (PreparedStatement statement =
                        connection.prepareStatement(insertCancellation)) {

                    statement.setLong(1, bookingId);

                    statement.setString(
                            2,
                            cancellation.getReason().trim());

                    statement.setBigDecimal(3, refundAmount);

                    statement.setString(4, "COMPLETED");

                    if (statement.executeUpdate() != 1) {

                        connection.rollback();
                        return false;
                    }
                }

                // ==========================================
                // CANCEL BOOKING
                // ==========================================

                String updateBooking =
                        "UPDATE booking "
                        + "SET booking_status = 'CANCELLED' "
                        + "WHERE booking_id = ? "
                        + "AND booking_status = ? "
                        + "AND payment_status = ?";

                try (PreparedStatement statement =
                        connection.prepareStatement(updateBooking)) {

                    statement.setLong(1, bookingId);

                    statement.setString(2, bookingStatus);

                    statement.setString(3, paymentStatus);

                    if (statement.executeUpdate() != 1) {

                        connection.rollback();
                        return false;
                    }
                }

                // ==========================================
                // COMMIT TRANSACTION
                // ==========================================

                connection.commit();

                return true;

            } catch (SQLException | RuntimeException e) {

                try {

                    connection.rollback();

                } catch (SQLException rollbackException) {

                    e.addSuppressed(rollbackException);
                }

                throw e;

            } finally {

                connection.setAutoCommit(true);
            }
        }
    }

    // ==========================================
    // GET CANCELLATION BY BOOKING ID
    // ==========================================

    public Cancellation getCancellationByBookingId(long bookingId)
            throws SQLException {

        String sql =
                "SELECT * FROM cancellation WHERE booking_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setLong(1, bookingId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {

                    Cancellation cancellation = new Cancellation();

                    cancellation.setCancellationId(
                            resultSet.getLong("cancellation_id"));

                    cancellation.setBookingId(
                            resultSet.getLong("booking_id"));

                    Timestamp timestamp =
                            resultSet.getTimestamp("cancellation_date");

                    if (timestamp != null) {

                        cancellation.setCancellationDate(
                                timestamp.toLocalDateTime());
                    }

                    cancellation.setReason(
                            resultSet.getString("reason"));

                    cancellation.setRefundAmount(
                            resultSet.getBigDecimal("refund_amount"));

                    cancellation.setCancellationStatus(
                            resultSet.getString("cancellation_status"));

                    return cancellation;
                }
            }
        }

        return null;
    }
}