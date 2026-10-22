package com.tnbus.model;

import java.time.LocalDateTime;

public class BookingHistory {

    private long historyId;
    private long bookingId;
    private String status;
    private LocalDateTime changedAt;
    private String remarks;

    public BookingHistory() {
    }

    public BookingHistory(long historyId, long bookingId,
                          String status, LocalDateTime changedAt,
                          String remarks) {
        this.historyId = historyId;
        this.bookingId = bookingId;
        this.status = status;
        this.changedAt = changedAt;
        this.remarks = remarks;
    }

    public long getHistoryId() {
        return historyId;
    }

    public void setHistoryId(long historyId) {
        this.historyId = historyId;
    }

    public long getBookingId() {
        return bookingId;
    }

    public void setBookingId(long bookingId) {
        this.bookingId = bookingId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(LocalDateTime changedAt) {
        this.changedAt = changedAt;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }
}