package com.tnbus.service;

import com.tnbus.dao.ScheduleExceptionDAO;
import com.tnbus.model.ScheduleException;


import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

public class ScheduleExceptionService {

    private final ScheduleExceptionDAO scheduleExceptionDAO;

    public ScheduleExceptionService() {
        this.scheduleExceptionDAO =
                new ScheduleExceptionDAO();
    }

    public boolean addScheduleException(
            ScheduleException exception)
            throws SQLException {

        validateScheduleException(exception);

        if (exception.getStatus() == null
                || exception.getStatus().isBlank()) {

            exception.setStatus("ACTIVE");
        }

        return scheduleExceptionDAO
                .addScheduleException(exception);
    }

    public ScheduleException getScheduleExceptionById(
            int exceptionId)
            throws SQLException {

        if (exceptionId <= 0) {
            return null;
        }

        return scheduleExceptionDAO
                .getScheduleExceptionById(exceptionId);
    }

    public List<ScheduleException>
    getExceptionsByScheduleRule(
            int scheduleRuleId)
            throws SQLException {

        if (scheduleRuleId <= 0) {
            return List.of();
        }

        return scheduleExceptionDAO
                .getExceptionsByScheduleRule(
                        scheduleRuleId);
    }

    public List<ScheduleException>
    getExceptionsByDate(
            LocalDate exceptionDate)
            throws SQLException {

        if (exceptionDate == null) {
            return List.of();
        }

        return scheduleExceptionDAO
                .getExceptionsByDate(
                        Date.valueOf(exceptionDate));
    }

    private void validateScheduleException(
            ScheduleException exception) {

        if (exception == null) {
            throw new IllegalArgumentException(
                    "Schedule exception cannot be null.");
        }

        if (exception.getScheduleRuleId() <= 0) {
            throw new IllegalArgumentException(
                    "Invalid schedule rule ID.");
        }

        if (exception.getExceptionDate() == null) {
            throw new IllegalArgumentException(
                    "Exception date is required.");
        }

        if (exception.getExceptionType() == null
                || exception.getExceptionType().isBlank()) {

            throw new IllegalArgumentException(
                    "Exception type is required.");
        }

        String exceptionType =
                exception.getExceptionType()
                        .trim()
                        .toUpperCase();

        if (!exceptionType.equals("CANCEL")
                && !exceptionType.equals("ADD")) {

            throw new IllegalArgumentException(
                    "Invalid exception type. "
                    + "Use CANCEL or ADD.");
        }

        exception.setExceptionType(exceptionType);

        if (exceptionType.equals("ADD")) {

            if (exception.getDepartureTime() == null) {
                throw new IllegalArgumentException(
                        "Departure time is required "
                        + "for ADD exception.");
            }

            if (exception.getArrivalTime() == null) {
                throw new IllegalArgumentException(
                        "Arrival time is required "
                        + "for ADD exception.");
            }

            if (exception.getFare() == null
                    || exception.getFare().signum() < 0) {

                throw new IllegalArgumentException(
                        "Valid fare is required "
                        + "for ADD exception.");
            }
        }

        if (exception.getFare() != null
                && exception.getFare().signum() < 0) {

            throw new IllegalArgumentException(
                    "Fare cannot be negative.");
        }

        if (exception.getDepartureTime() != null
                && exception.getArrivalTime() != null
                && exception.getDepartureTime()
                        .equals(exception.getArrivalTime())) {

            throw new IllegalArgumentException(
                    "Departure and arrival time "
                    + "cannot be the same.");
        }
    }
}