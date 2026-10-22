package com.tnbus.model;

public class Seat {

    private int seatId;
    private int busId;

    private String seatNumber;
    private String seatType;
    private String status;

    // New physical layout fields
    private String deck;
    private String layoutType;
    private String seatSide;
    private Integer rowNumber;
    private Integer columnNumber;
    private String berthGroup;

    // ==========================================
    // DEFAULT CONSTRUCTOR
    // ==========================================

    public Seat() {
    }

    // ==========================================
    // EXISTING CONSTRUCTOR — PRESERVED
    // ==========================================

    public Seat(
            int seatId,
            int busId,
            String seatNumber,
            String seatType,
            String status) {

        this.seatId = seatId;
        this.busId = busId;
        this.seatNumber = seatNumber;
        this.seatType = seatType;
        this.status = status;
    }

    // ==========================================
    // GETTERS AND SETTERS
    // ==========================================

    public int getSeatId() {
        return seatId;
    }

    public void setSeatId(int seatId) {
        this.seatId = seatId;
    }

    public int getBusId() {
        return busId;
    }

    public void setBusId(int busId) {
        this.busId = busId;
    }

    public String getSeatNumber() {
        return seatNumber;
    }

    public void setSeatNumber(String seatNumber) {
        this.seatNumber = seatNumber;
    }

    public String getSeatType() {
        return seatType;
    }

    public void setSeatType(String seatType) {
        this.seatType = seatType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    // ==========================================
    // NEW LAYOUT GETTERS AND SETTERS
    // ==========================================

    public String getDeck() {
        return deck;
    }

    public void setDeck(String deck) {
        this.deck = deck;
    }

    public String getLayoutType() {
        return layoutType;
    }

    public void setLayoutType(String layoutType) {
        this.layoutType = layoutType;
    }

    public String getSeatSide() {
        return seatSide;
    }

    public void setSeatSide(String seatSide) {
        this.seatSide = seatSide;
    }

    public Integer getRowNumber() {
        return rowNumber;
    }

    public void setRowNumber(Integer rowNumber) {
        this.rowNumber = rowNumber;
    }

    public Integer getColumnNumber() {
        return columnNumber;
    }

    public void setColumnNumber(Integer columnNumber) {
        this.columnNumber = columnNumber;
    }

    public String getBerthGroup() {
        return berthGroup;
    }

    public void setBerthGroup(String berthGroup) {
        this.berthGroup = berthGroup;
    }
}