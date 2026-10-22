package com.tnbus.service;

import com.tnbus.dao.PaymentDAO;
import com.tnbus.model.Payment;

import java.sql.SQLException;
import java.util.Set;
import java.util.UUID;

public class PaymentService {

    private final PaymentDAO paymentDAO;

    private static final Set<String> PAYMENT_METHODS =
            Set.of("UPI", "CARD", "NET_BANKING");

    public PaymentService() {
        this.paymentDAO = new PaymentDAO();
    }

    public boolean addPayment(Payment payment)
            throws SQLException {

        if (payment == null) {
            return false;
        }

        if (payment.getBookingId() <= 0) {
            return false;
        }

        if (payment.getAmount() == null
                || payment.getAmount().signum() < 0) {
            return false;
        }

        if (payment.getPaymentMethod() == null
                || payment.getPaymentMethod().isBlank()) {
            return false;
        }

        if (payment.getPaymentStatus() == null
                || payment.getPaymentStatus().isBlank()) {

            payment.setPaymentStatus("PENDING");
        }

        return paymentDAO.addPayment(payment);
    }

    public Payment getPaymentByBookingId(long bookingId)
            throws SQLException {

        if (bookingId <= 0) {
            return null;
        }

        return paymentDAO.getPaymentByBookingId(bookingId);
    }

    public boolean updatePaymentStatus(
            long paymentId,
            String paymentStatus)
            throws SQLException {

        if (paymentId <= 0
                || paymentStatus == null
                || paymentStatus.isBlank()) {
            return false;
        }

        return paymentDAO.updatePaymentStatus(
                paymentId, paymentStatus);
    }

    public boolean processPayment(
            long bookingId,
            long userId,
            String paymentMethod)
            throws SQLException {

        if (bookingId <= 0 || userId <= 0) {
            return false;
        }

        if (paymentMethod == null
                || !PAYMENT_METHODS.contains(paymentMethod)) {
            return false;
        }

        // Unique reference for academic/demo transactions.

        String transactionReference =
                "DEMO-" + UUID.randomUUID().toString();

        return paymentDAO.processPayment(
                bookingId,
                userId,
                paymentMethod,
                transactionReference);
    }
}