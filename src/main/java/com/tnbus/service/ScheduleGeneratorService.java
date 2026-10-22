package com.tnbus.service;

import com.tnbus.model.BusSchedule;
import com.tnbus.model.ScheduleException;
import com.tnbus.model.ScheduleRule;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class ScheduleGeneratorService {

    private final ScheduleRuleService scheduleRuleService;
    private final ScheduleExceptionService scheduleExceptionService;
    private final BusScheduleService busScheduleService;

    public ScheduleGeneratorService() {

        this.scheduleRuleService =
                new ScheduleRuleService();

        this.scheduleExceptionService =
                new ScheduleExceptionService();

        this.busScheduleService =
                new BusScheduleService();
    }

    /**
     * Generates actual bus schedules between the given dates.
     *
     * Existing bus_schedule records are not deleted.
     * Duplicate schedules are skipped.
     */
    public int generateSchedules(
            LocalDate startDate,
            LocalDate endDate)
            throws SQLException {

        if (startDate == null || endDate == null) {
            throw new IllegalArgumentException(
                    "Start date and end date are required.");
        }

        if (endDate.isBefore(startDate)) {
            throw new IllegalArgumentException(
                    "End date cannot be before start date.");
        }

        List<ScheduleRule> rules =
                scheduleRuleService.getActiveScheduleRules();

        List<BusSchedule> existingSchedules =
                busScheduleService.getAllSchedules();

        Set<String> existingKeys =
                buildExistingScheduleKeys(existingSchedules);

        int generatedCount = 0;

        LocalDate currentDate = startDate;

        while (!currentDate.isAfter(endDate)) {

            List<ScheduleException> exceptions =
                    scheduleExceptionService
                            .getExceptionsByDate(currentDate);

            for (ScheduleRule rule : rules) {

                if (!isRuleActiveForDate(
                        rule,
                        currentDate)) {

                    continue;
                }

                if (!matchesRuleForDate(
                        rule,
                        currentDate)) {

                    continue;
                }

                if (isCancelled(
                        rule,
                        currentDate,
                        exceptions)) {

                    continue;
                }

                String key =
                        buildScheduleKey(
                                rule.getBusId(),
                                rule.getRouteId(),
                                currentDate,
                                rule.getDepartureTime());

                if (existingKeys.contains(key)) {
                    continue;
                }

                BusSchedule schedule =
                        createScheduleFromRule(
                                rule,
                                currentDate);

                if (busScheduleService
                        .addSchedule(schedule)) {

                    existingKeys.add(key);
                    generatedCount++;
                }
            }

            /*
             * Process ADD exceptions.
             */
            for (ScheduleException exception :
                    exceptions) {

                if (!"ADD".equalsIgnoreCase(
                        exception.getExceptionType())) {

                    continue;
                }

                ScheduleRule rule =
                        scheduleRuleService
                                .getScheduleRuleById(
                                        exception
                                                .getScheduleRuleId());

                if (rule == null) {
                    continue;
                }

                if (!"ACTIVE".equalsIgnoreCase(
                        rule.getStatus())) {

                    continue;
                }

                if (!isRuleDateInValidRange(
                        rule,
                        currentDate)) {

                    continue;
                }

                if (exception.getDepartureTime() == null
                        || exception.getArrivalTime() == null
                        || exception.getFare() == null) {

                    continue;
                }

                String key =
                        buildScheduleKey(
                                rule.getBusId(),
                                rule.getRouteId(),
                                currentDate,
                                exception
                                        .getDepartureTime());

                if (existingKeys.contains(key)) {
                    continue;
                }

                BusSchedule schedule =
                        createSchedule(
                                rule.getBusId(),
                                rule.getRouteId(),
                                currentDate,
                                exception.getDepartureTime(),
                                exception.getArrivalTime(),
                                exception.getFare());

                if (busScheduleService
                        .addSchedule(schedule)) {

                    existingKeys.add(key);
                    generatedCount++;
                }
            }

            currentDate =
                    currentDate.plusDays(1);
        }

        return generatedCount;
    }

    /**
     * Checks whether the rule is valid on the given date.
     */
    private boolean isRuleActiveForDate(
            ScheduleRule rule,
            LocalDate date) {

        if (rule == null || date == null) {
            return false;
        }

        if (!"ACTIVE".equalsIgnoreCase(
                rule.getStatus())) {

            return false;
        }

        return isRuleDateInValidRange(
                rule,
                date);
    }

    /**
     * Checks valid_from and valid_until.
     */
    private boolean isRuleDateInValidRange(
            ScheduleRule rule,
            LocalDate date) {

        if (rule.getValidFrom() == null) {
            return false;
        }

        if (date.isBefore(
                rule.getValidFrom())) {

            return false;
        }

        if (rule.getValidUntil() != null
                && date.isAfter(
                        rule.getValidUntil())) {

            return false;
        }

        return true;
    }

    /**
     * Checks whether a rule should generate a
     * schedule on a particular date.
     */
    private boolean matchesRuleForDate(
            ScheduleRule rule,
            LocalDate date) {

        String recurrenceType =
                rule.getRecurrenceType();

        if (recurrenceType == null) {
            return false;
        }

        recurrenceType =
                recurrenceType.trim()
                        .toUpperCase();

        if ("DAILY".equals(recurrenceType)) {

            return true;
        }

        if ("WEEKLY".equals(recurrenceType)) {

            return matchesWeeklyRule(
                    rule.getDaysOfWeek(),
                    date.getDayOfWeek());
        }

        if ("SPECIFIC_DATE".equals(
                recurrenceType)) {

            return date.equals(
                    rule.getSpecificDate());
        }

        return false;
    }

    /**
     * Checks WEEKLY days such as:
     * MON,WED,FRI
     */
    private boolean matchesWeeklyRule(
            String daysOfWeek,
            DayOfWeek dayOfWeek) {

        if (daysOfWeek == null
                || daysOfWeek.isBlank()
                || dayOfWeek == null) {

            return false;
        }

        String[] days =
                daysOfWeek
                        .toUpperCase()
                        .split(",");

        String currentDay =
                convertDayOfWeek(dayOfWeek);

        for (String day : days) {

            if (day.trim().equals(currentDay)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Converts Java DayOfWeek to:
     * MON, TUE, WED, THU, FRI, SAT, SUN
     */
    private String convertDayOfWeek(
            DayOfWeek dayOfWeek) {

        switch (dayOfWeek) {

            case MONDAY:
                return "MON";

            case TUESDAY:
                return "TUE";

            case WEDNESDAY:
                return "WED";

            case THURSDAY:
                return "THU";

            case FRIDAY:
                return "FRI";

            case SATURDAY:
                return "SAT";

            case SUNDAY:
                return "SUN";

            default:
                return "";
        }
    }

    /**
     * Checks whether a CANCEL exception exists
     * for the particular rule and date.
     */
    private boolean isCancelled(
            ScheduleRule rule,
            LocalDate date,
            List<ScheduleException> exceptions) {

        if (exceptions == null
                || exceptions.isEmpty()) {

            return false;
        }

        for (ScheduleException exception :
                exceptions) {

            if (!"CANCEL".equalsIgnoreCase(
                    exception.getExceptionType())) {

                continue;
            }

            if (exception.getScheduleRuleId()
                    != rule.getScheduleRuleId()) {

                continue;
            }

            if (!date.equals(
                    exception.getExceptionDate())) {

                continue;
            }

            return true;
        }

        return false;
    }

    /**
     * Creates BusSchedule from a ScheduleRule.
     */
    private BusSchedule createScheduleFromRule(
            ScheduleRule rule,
            LocalDate date) {

        return createSchedule(
                rule.getBusId(),
                rule.getRouteId(),
                date,
                rule.getDepartureTime(),
                rule.getArrivalTime(),
                rule.getFare());
    }

    /**
     * Creates an actual BusSchedule object.
     */
    private BusSchedule createSchedule(
            int busId,
            int routeId,
            LocalDate travelDate,
            LocalTime departureTime,
            LocalTime arrivalTime,
            BigDecimal fare) {

        BusSchedule schedule =
                new BusSchedule();

        schedule.setBusId(busId);
        schedule.setRouteId(routeId);
        schedule.setTravelDate(travelDate);
        schedule.setDepartureTime(departureTime);
        schedule.setArrivalTime(arrivalTime);
        schedule.setFare(fare);
        schedule.setStatus("SCHEDULED");

        return schedule;
    }

    /**
     * Builds a unique key for duplicate detection.
     */
    private String buildScheduleKey(
            int busId,
            int routeId,
            LocalDate travelDate,
            LocalTime departureTime) {

        return busId
                + "|"
                + routeId
                + "|"
                + travelDate
                + "|"
                + departureTime;
    }

    /**
     * Loads existing schedules into a Set so that
     * duplicate schedules are not inserted.
     */
    private Set<String> buildExistingScheduleKeys(
            List<BusSchedule> schedules) {

        Set<String> keys =
                new HashSet<>();

        if (schedules == null) {
            return keys;
        }

        for (BusSchedule schedule :
                schedules) {

            if (schedule == null) {
                continue;
            }

            String key =
                    buildScheduleKey(
                            schedule.getBusId(),
                            schedule.getRouteId(),
                            schedule.getTravelDate(),
                            schedule.getDepartureTime());

            keys.add(key);
        }

        return keys;
    }
}