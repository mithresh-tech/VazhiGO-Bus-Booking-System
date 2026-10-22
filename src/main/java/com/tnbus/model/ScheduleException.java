package com.tnbus.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

public class ScheduleException {

    private int exceptionId;

    private int scheduleRuleId;

    private LocalDate exceptionDate;

    private String exceptionType;

    private LocalTime departureTime;
    private LocalTime arrivalTime;

    private BigDecimal fare;

    private String reason;

    private String status;

    public ScheduleException() {
    }

    public ScheduleException(
            int exceptionId,
            int scheduleRuleId,
            LocalDate exceptionDate,
            String exceptionType,
            LocalTime departureTime,
            LocalTime arrivalTime,
            BigDecimal fare,
            String reason,
            String status) {

        this.exceptionId = exceptionId;
        this.scheduleRuleId = scheduleRuleId;
        this.exceptionDate = exceptionDate;
        this.exceptionType = exceptionType;
        this.departureTime = departureTime;
        this.arrivalTime = arrivalTime;
        this.fare = fare;
        this.reason = reason;
        this.status = status;
    }

    public int getExceptionId() {
        return exceptionId;
    }

    public void setExceptionId(int exceptionId) {
        this.exceptionId = exceptionId;
    }

    public int getScheduleRuleId() {
        return scheduleRuleId;
    }

    public void setScheduleRuleId(int scheduleRuleId) {
        this.scheduleRuleId = scheduleRuleId;
    }

    public LocalDate getExceptionDate() {
        return exceptionDate;
    }

    public void setExceptionDate(LocalDate exceptionDate) {
        this.exceptionDate = exceptionDate;
    }

    public String getExceptionType() {
        return exceptionType;
    }

    public void setExceptionType(String exceptionType) {
        this.exceptionType = exceptionType;
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

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "ScheduleException{" +
                "exceptionId=" + exceptionId +
                ", scheduleRuleId=" + scheduleRuleId +
                ", exceptionDate=" + exceptionDate +
                ", exceptionType='" + exceptionType + '\'' +
                ", departureTime=" + departureTime +
                ", arrivalTime=" + arrivalTime +
                ", fare=" + fare +
                ", reason='" + reason + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}