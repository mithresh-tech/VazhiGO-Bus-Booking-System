package com.tnbus.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

public class BusSchedule {

    // ==========================================
    // EXISTING FIELDS
    // ==========================================

    private int scheduleId;
    private int busId;
    private int routeId;

    private LocalDate travelDate;
    private LocalTime departureTime;
    private LocalTime arrivalTime;

    private BigDecimal fare;

    // Existing sleeper deck pricing
    private BigDecimal upperDeckFare;
    private BigDecimal lowerDeckFare;

    private String status;

    // ==========================================
    // NEW CATEGORY-WISE PRICING
    // ==========================================

    private BigDecimal doubleUpperFare;
    private BigDecimal doubleLowerFare;

    private BigDecimal singleUpperFare;
    private BigDecimal singleLowerFare;

    private BigDecimal seaterFare;

    // ==========================================
    // DEFAULT CONSTRUCTOR
    // ==========================================

    public BusSchedule() {
    }

    // ==========================================
    // EXISTING GETTERS AND SETTERS
    // ==========================================

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public int getBusId() {
        return busId;
    }

    public void setBusId(int busId) {
        this.busId = busId;
    }

    public int getRouteId() {
        return routeId;
    }

    public void setRouteId(int routeId) {
        this.routeId = routeId;
    }

    public LocalDate getTravelDate() {
        return travelDate;
    }

    public void setTravelDate(LocalDate travelDate) {
        this.travelDate = travelDate;
    }

    public LocalTime getDepartureTime() {
        return departureTime;
    }

    public void setDepartureTime(LocalTime departureTime) {
        this.departureTime = departureTime;
    }

    public LocalTime getArrivalTime() {
        return arrivalTime;
    }

    public void setArrivalTime(LocalTime arrivalTime) {
        this.arrivalTime = arrivalTime;
    }

    public BigDecimal getFare() {
        return fare;
    }

    public void setFare(BigDecimal fare) {
        this.fare = fare;
    }

    public BigDecimal getUpperDeckFare() {
        return upperDeckFare;
    }

    public void setUpperDeckFare(BigDecimal upperDeckFare) {
        this.upperDeckFare = upperDeckFare;
    }

    public BigDecimal getLowerDeckFare() {
        return lowerDeckFare;
    }

    public void setLowerDeckFare(BigDecimal lowerDeckFare) {
        this.lowerDeckFare = lowerDeckFare;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    // ==========================================
    // NEW CATEGORY FARE GETTERS AND SETTERS
    // ==========================================

    public BigDecimal getDoubleUpperFare() {
        return doubleUpperFare;
    }

    public void setDoubleUpperFare(BigDecimal doubleUpperFare) {
        this.doubleUpperFare = doubleUpperFare;
    }

    public BigDecimal getDoubleLowerFare() {
        return doubleLowerFare;
    }

    public void setDoubleLowerFare(BigDecimal doubleLowerFare) {
        this.doubleLowerFare = doubleLowerFare;
    }

    public BigDecimal getSingleUpperFare() {
        return singleUpperFare;
    }

    public void setSingleUpperFare(BigDecimal singleUpperFare) {
        this.singleUpperFare = singleUpperFare;
    }

    public BigDecimal getSingleLowerFare() {
        return singleLowerFare;
    }

    public void setSingleLowerFare(BigDecimal singleLowerFare) {
        this.singleLowerFare = singleLowerFare;
    }

    public BigDecimal getSeaterFare() {
        return seaterFare;
    }

    public void setSeaterFare(BigDecimal seaterFare) {
        this.seaterFare = seaterFare;
    }
}