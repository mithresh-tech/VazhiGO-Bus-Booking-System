package com.tnbus.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

public class BusSearchCard {

    private int scheduleId;

    // STEP 20A - Bus Amenities
    private int busId;
    private BusAmenity amenity;

    private String busName;
    private String busNumber;
    private String busType;
    private String sourceCity;
    private String destinationCity;

    private LocalDate travelDate;
    private LocalTime departureTime;
    private LocalTime arrivalTime;

    private BigDecimal fare;

    private int totalSeats;
    private int availableSeats;

    // ==========================================
    // SCHEDULE ID
    // ==========================================

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    // ==========================================
    // BUS ID - NEW
    // ==========================================

    public int getBusId() {
        return busId;
    }

    public void setBusId(int busId) {
        this.busId = busId;
    }

    // ==========================================
    // BUS AMENITIES - NEW
    // ==========================================

    public BusAmenity getAmenity() {
        return amenity;
    }

    public void setAmenity(BusAmenity amenity) {
        this.amenity = amenity;
    }

    // ==========================================
    // BUS DETAILS
    // ==========================================

    public String getBusName() {
        return busName;
    }

    public void setBusName(String busName) {
        this.busName = busName;
    }

    public String getBusNumber() {
        return busNumber;
    }

    public void setBusNumber(String busNumber) {
        this.busNumber = busNumber;
    }

    public String getBusType() {
        return busType;
    }

    public void setBusType(String busType) {
        this.busType = busType;
    }

    // ==========================================
    // ROUTE DETAILS
    // ==========================================

    public String getSourceCity() {
        return sourceCity;
    }

    public void setSourceCity(String sourceCity) {
        this.sourceCity = sourceCity;
    }

    public String getDestinationCity() {
        return destinationCity;
    }

    public void setDestinationCity(String destinationCity) {
        this.destinationCity = destinationCity;
    }

    // ==========================================
    // JOURNEY DATE AND TIME
    // ==========================================

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

    // ==========================================
    // FARE
    // ==========================================

    public BigDecimal getFare() {
        return fare;
    }

    public void setFare(BigDecimal fare) {
        this.fare = fare;
    }

    // ==========================================
    // SEAT AVAILABILITY
    // ==========================================

    public int getTotalSeats() {
        return totalSeats;
    }

    public void setTotalSeats(int totalSeats) {
        this.totalSeats = totalSeats;
    }

    public int getAvailableSeats() {
        return availableSeats;
    }

    public void setAvailableSeats(int availableSeats) {
        this.availableSeats = availableSeats;
    }
}