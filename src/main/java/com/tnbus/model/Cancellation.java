package com.tnbus.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Cancellation {

    private long cancellationId;
    private long bookingId;
    private LocalDateTime cancellationDate;
    private String reason;
    private BigDecimal refundAmount;
    private String cancellationStatus;

    public Cancellation() {
    }

    public Cancellation(long cancellationId, long bookingId,
                        LocalDateTime cancellationDate, String reason,
                        BigDecimal refundAmount,
                        String cancellationStatus) {
        this.cancellationId = cancellationId;
        this.bookingId = bookingId;
        this.cancellationDate = cancellationDate;
        this.reason = reason;
        this.refundAmount = refundAmount;
        this.cancellationStatus = cancellationStatus;
    }

    public long getCancellationId() {
        return cancellationId;
    }

    public void setCancellationId(long cancellationId) {
        this.cancellationId = cancellationId;
    }

    public long getBookingId() {
        return bookingId;
    }

    public void setBookingId(long bookingId) {
        this.bookingId = bookingId;
    }

    public LocalDateTime getCancellationDate() {
        return cancellationDate;
    }

    public void setCancellationDate(LocalDateTime cancellationDate) {
        this.cancellationDate = cancellationDate;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public BigDecimal getRefundAmount() {
        return refundAmount;
    }

    public void setRefundAmount(BigDecimal refundAmount) {
        this.refundAmount = refundAmount;
    }

    public String getCancellationStatus() {
        return cancellationStatus;
    }

    public void setCancellationStatus(String cancellationStatus) {
        this.cancellationStatus = cancellationStatus;
    }
}