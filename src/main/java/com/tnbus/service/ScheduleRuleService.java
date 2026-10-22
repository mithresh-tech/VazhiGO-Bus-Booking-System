package com.tnbus.service;

import com.tnbus.dao.ScheduleRuleDAO;
import com.tnbus.model.ScheduleRule;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

public class ScheduleRuleService {

    private final ScheduleRuleDAO scheduleRuleDAO;

    public ScheduleRuleService() {
        this.scheduleRuleDAO = new ScheduleRuleDAO();
    }

    public boolean addScheduleRule(ScheduleRule rule)
            throws SQLException {

        validateScheduleRule(rule);

        if (rule.getStatus() == null
                || rule.getStatus().isBlank()) {

            rule.setStatus("ACTIVE");
        }

        return scheduleRuleDAO.addScheduleRule(rule);
    }

    public ScheduleRule getScheduleRuleById(
            int scheduleRuleId)
            throws SQLException {

        if (scheduleRuleId <= 0) {
            return null;
        }

        return scheduleRuleDAO
                .getScheduleRuleById(scheduleRuleId);
    }

    public List<ScheduleRule> getAllScheduleRules()
            throws SQLException {

        return scheduleRuleDAO.getAllScheduleRules();
    }

    public List<ScheduleRule> getActiveScheduleRules()
            throws SQLException {

        return scheduleRuleDAO.getActiveScheduleRules();
    }

    public boolean updateScheduleRule(
            ScheduleRule rule)
            throws SQLException {

        validateScheduleRule(rule);

        if (rule.getScheduleRuleId() <= 0) {
            return false;
        }

        return scheduleRuleDAO.updateScheduleRule(rule);
    }

    private void validateScheduleRule(
            ScheduleRule rule) {

        if (rule == null) {
            throw new IllegalArgumentException(
                    "Schedule rule cannot be null.");
        }

        if (rule.getBusId() <= 0) {
            throw new IllegalArgumentException(
                    "Invalid bus ID.");
        }

        if (rule.getRouteId() <= 0) {
            throw new IllegalArgumentException(
                    "Invalid route ID.");
        }

        if (rule.getDepartureTime() == null) {
            throw new IllegalArgumentException(
                    "Departure time is required.");
        }

        if (rule.getArrivalTime() == null) {
            throw new IllegalArgumentException(
                    "Arrival time is required.");
        }

        if (rule.getDepartureTime()
                .equals(rule.getArrivalTime())) {

            throw new IllegalArgumentException(
                    "Departure and arrival time cannot be the same.");
        }

        BigDecimal fare = rule.getFare();

        if (fare == null || fare.signum() < 0) {
            throw new IllegalArgumentException(
                    "Fare cannot be null or negative.");
        }

        if (rule.getRecurrenceType() == null
                || rule.getRecurrenceType().isBlank()) {

            throw new IllegalArgumentException(
                    "Recurrence type is required.");
        }

        String recurrenceType =
                rule.getRecurrenceType()
                        .trim()
                        .toUpperCase();

        if (!recurrenceType.equals("DAILY")
                && !recurrenceType.equals("WEEKLY")
                && !recurrenceType.equals("SPECIFIC_DATE")) {

            throw new IllegalArgumentException(
                    "Invalid recurrence type. "
                    + "Use DAILY, WEEKLY or SPECIFIC_DATE.");
        }

        rule.setRecurrenceType(recurrenceType);

        if (rule.getValidFrom() == null) {
            throw new IllegalArgumentException(
                    "Valid-from date is required.");
        }

        LocalDate validUntil =
                rule.getValidUntil();

        if (validUntil != null
                && validUntil.isBefore(
                        rule.getValidFrom())) {

            throw new IllegalArgumentException(
                    "Valid-until date cannot be before valid-from date.");
        }

        if (recurrenceType.equals("DAILY")) {

            rule.setDaysOfWeek(null);
            rule.setSpecificDate(null);

        } else if (recurrenceType.equals("WEEKLY")) {

            if (rule.getDaysOfWeek() == null
                    || rule.getDaysOfWeek().isBlank()) {

                throw new IllegalArgumentException(
                        "Days of week are required for WEEKLY schedules.");
            }

            rule.setDaysOfWeek(
                    rule.getDaysOfWeek()
                            .trim()
                            .toUpperCase());

            rule.setSpecificDate(null);

        } else {

            if (rule.getSpecificDate() == null) {

                throw new IllegalArgumentException(
                        "Specific date is required "
                        + "for SPECIFIC_DATE schedules.");
            }

            rule.setDaysOfWeek(null);
        }
    }
}