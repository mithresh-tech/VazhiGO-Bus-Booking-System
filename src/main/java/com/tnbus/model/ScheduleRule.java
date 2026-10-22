package com.tnbus.model;

import java.time.LocalDate;
import java.time.LocalTime;

public class ScheduleRule {

    private int scheduleRuleId;

    private int busId;
    private int routeId;

    private LocalTime departureTime;
    private LocalTime arrivalTime;

    private java.math.BigDecimal fare;

    private String recurrenceType;

    private String daysOfWeek;

    private LocalDate validFrom;
    private LocalDate validUntil;

    private LocalDate specificDate;

    private String status;

    public ScheduleRule() {
    }

    public ScheduleRule(
            int scheduleRuleId,
            int busId,
            int routeId,
            LocalTime departureTime,
            LocalTime arrivalTime,
            java.math.BigDecimal fare,
            String recurrenceType,
            String daysOfWeek,
            LocalDate validFrom,
            LocalDate validUntil,
            LocalDate specificDate,
            String status) {

        this.scheduleRuleId = scheduleRuleId;
        this.busId = busId;
        this.routeId = routeId;
        this.departureTime = departureTime;
        this.arrivalTime = arrivalTime;
        this.fare = fare;
        this.recurrenceType = recurrenceType;
        this.daysOfWeek = daysOfWeek;
        this.validFrom = validFrom;
        this.validUntil = validUntil;
        this.specificDate = specificDate;
        this.status = status;
    }

    public int getScheduleRuleId() {
        return scheduleRuleId;
    }

    public void setScheduleRuleId(int scheduleRuleId) {
        this.scheduleRuleId = scheduleRuleId;
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

    public java.math.BigDecimal getFare() {
        return fare;
    }

    public void setFare(java.math.BigDecimal fare) {
        this.fare = fare;
    }

    public String getRecurrenceType() {
        return recurrenceType;
    }

    public void setRecurrenceType(String recurrenceType) {
        this.recurrenceType = recurrenceType;
    }

    public String getDaysOfWeek() {
        return daysOfWeek;
    }

    public void setDaysOfWeek(String daysOfWeek) {
        this.daysOfWeek = daysOfWeek;
    }

    public LocalDate getValidFrom() {
        return validFrom;
    }

    public void setValidFrom(LocalDate validFrom) {
        this.validFrom = validFrom;
    }

    public LocalDate getValidUntil() {
        return validUntil;
    }

    public void setValidUntil(LocalDate validUntil) {
        this.validUntil = validUntil;
    }

    public LocalDate getSpecificDate() {
        return specificDate;
    }

    public void setSpecificDate(LocalDate specificDate) {
        this.specificDate = specificDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "ScheduleRule{" +
                "scheduleRuleId=" + scheduleRuleId +
                ", busId=" + busId +
                ", routeId=" + routeId +
                ", departureTime=" + departureTime +
                ", arrivalTime=" + arrivalTime +
                ", fare=" + fare +
                ", recurrenceType='" + recurrenceType + '\'' +
                ", daysOfWeek='" + daysOfWeek + '\'' +
                ", validFrom=" + validFrom +
                ", validUntil=" + validUntil +
                ", specificDate=" + specificDate +
                ", status='" + status + '\'' +
                '}';
    }
}