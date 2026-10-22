package com.tnbus.dao;

import com.tnbus.model.Payment;
import com.tnbus.util.DBConnection;

import java.sql.*;
import java.math.BigDecimal;

public class PaymentDAO {

    public boolean addPayment(Payment payment)
            throws SQLException {

        String sql = "INSERT INTO payment "
                + "(booking_id, amount, payment_method, "
                + "transaction_reference, payment_status) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setLong(1, payment.getBookingId());
            statement.setBigDecimal(2, payment.getAmount());
            statement.setString(3, payment.getPaymentMethod());
            statement.setString(4, payment.getTransactionReference());
            statement.setString(5, payment.getPaymentStatus());

            return statement.executeUpdate() == 1;
        }
    }

    public Payment getPaymentByBookingId(long bookingId)
            throws SQLException {

        String sql = "SELECT * FROM payment WHERE booking_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setLong(1, bookingId);

            try (ResultSet rs = statement.executeQuery()) {

                if (rs.next()) {

                    Payment payment = new Payment();

                    payment.setPaymentId(rs.getLong("payment_id"));
                    payment.setBookingId(rs.getLong("booking_id"));
                    payment.setAmount(rs.getBigDecimal("amount"));

                    payment.setPaymentMethod(
                            rs.getString("payment_method"));

                    payment.setTransactionReference(
                            rs.getString("transaction_reference"));

                    Timestamp timestamp =
                            rs.getTimestamp("payment_date");

                    if (timestamp != null) {
                        payment.setPaymentDate(
                                timestamp.toLocalDateTime());
                    }

                    payment.setPaymentStatus(
                            rs.getString("payment_status"));

                    return payment;
                }
            }
        }

        return null;
    }

    public boolean updatePaymentStatus(
            long paymentId,
            String paymentStatus) throws SQLException {

        String sql = "UPDATE payment SET payment_status = ? "
                + "WHERE payment_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, paymentStatus);
            statement.setLong(2, paymentId);

            return statement.executeUpdate() == 1;
        }
    }

    // Process simulated payment and update booking atomically.

    public boolean processPayment(
            long bookingId,
            long userId,
            String paymentMethod,
            String transactionReference)
            throws SQLException {

        try (Connection connection = DBConnection.getConnection()) {

            connection.setAutoCommit(false);

            try {

                String checkBooking =
                        "SELECT user_id, total_amount, booking_status, "
                        + "payment_status FROM booking "
                        + "WHERE booking_id = ? FOR UPDATE";

                BigDecimal amount;

                try (PreparedStatement statement =
                        connection.prepareStatement(checkBooking)) {

                    statement.setLong(1, bookingId);

                    try (ResultSet rs = statement.executeQuery()) {

                        if (!rs.next()) {
                            connection.rollback();
                            return false;
                        }

                        if (rs.getLong("user_id") != userId) {
                            connection.rollback();
                            return false;
                        }

                        String bookingStatus =
                                rs.getString("booking_status");

                        String paymentStatus =
                                rs.getString("payment_status");

                        if (!"PENDING".equalsIgnoreCase(bookingStatus)
                                || !"PENDING".equalsIgnoreCase(paymentStatus)) {

                            connection.rollback();
                            return false;
                        }

                        amount = rs.getBigDecimal("total_amount");

                        if (amount == null || amount.signum() <= 0) {
                            connection.rollback();
                            return false;
                        }
                    }
                }

                // Prevent duplicate payment records.

                String checkPayment =
                        "SELECT payment_id FROM payment "
                        + "WHERE booking_id = ?";

                try (PreparedStatement statement =
                        connection.prepareStatement(checkPayment)) {

                    statement.setLong(1, bookingId);

                    try (ResultSet rs = statement.executeQuery()) {

                        if (rs.next()) {
                            connection.rollback();
                            return false;
                        }
                    }
                }

                // Insert successful simulated payment.

                String insertPayment =
                        "INSERT INTO payment "
                        + "(booking_id, amount, payment_method, "
                        + "transaction_reference, payment_status) "
                        + "VALUES (?, ?, ?, ?, ?)";

                try (PreparedStatement statement =
                        connection.prepareStatement(insertPayment)) {

                    statement.setLong(1, bookingId);
                    statement.setBigDecimal(2, amount);
                    statement.setString(3, paymentMethod);
                    statement.setString(4, transactionReference);
                    statement.setString(5, "SUCCESS");

                    if (statement.executeUpdate() != 1) {
                        connection.rollback();
                        return false;
                    }
                }

                // Update booking only after payment insertion.

                String updateBooking =
                        "UPDATE booking SET booking_status = 'CONFIRMED', "
                        + "payment_status = 'PAID' "
                        + "WHERE booking_id = ? "
                        + "AND booking_status = 'PENDING' "
                        + "AND payment_status = 'PENDING'";

                try (PreparedStatement statement =
                        connection.prepareStatement(updateBooking)) {

                    statement.setLong(1, bookingId);

                    if (statement.executeUpdate() != 1) {
                        connection.rollback();
                        return false;
                    }
                }

                connection.commit();

                return true;

            } catch (SQLException | RuntimeException e) {

                connection.rollback();
                throw e;

            } finally {

                connection.setAutoCommit(true);
            }
        }
    }
}