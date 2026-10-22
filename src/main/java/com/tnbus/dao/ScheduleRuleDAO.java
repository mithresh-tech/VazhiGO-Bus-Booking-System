package com.tnbus.dao;

import com.tnbus.model.ScheduleRule;
import com.tnbus.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

public class ScheduleRuleDAO {

    public boolean addScheduleRule(ScheduleRule rule)
            throws SQLException {

        String sql = "INSERT INTO schedule_rule "
                + "(bus_id, route_id, departure_time, arrival_time, "
                + "fare, recurrence_type, days_of_week, valid_from, "
                + "valid_until, specific_date, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, rule.getBusId());
            statement.setInt(2, rule.getRouteId());

            statement.setTime(
                    3,
                    Time.valueOf(rule.getDepartureTime()));

            statement.setTime(
                    4,
                    Time.valueOf(rule.getArrivalTime()));

            statement.setBigDecimal(
                    5,
                    rule.getFare());

            statement.setString(
                    6,
                    rule.getRecurrenceType());

            statement.setString(
                    7,
                    rule.getDaysOfWeek());

            statement.setDate(
                    8,
                    Date.valueOf(rule.getValidFrom()));

            if (rule.getValidUntil() != null) {
                statement.setDate(
                        9,
                        Date.valueOf(rule.getValidUntil()));
            } else {
                statement.setNull(
                        9,
                        java.sql.Types.DATE);
            }

            if (rule.getSpecificDate() != null) {
                statement.setDate(
                        10,
                        Date.valueOf(rule.getSpecificDate()));
            } else {
                statement.setNull(
                        10,
                        java.sql.Types.DATE);
            }

            statement.setString(
                    11,
                    rule.getStatus());

            return statement.executeUpdate() > 0;
        }
    }

    public ScheduleRule getScheduleRuleById(
            int scheduleRuleId) throws SQLException {

        String sql =
                "SELECT * FROM schedule_rule "
                + "WHERE schedule_rule_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, scheduleRuleId);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                if (resultSet.next()) {
                    return mapScheduleRule(resultSet);
                }
            }
        }

        return null;
    }

    public List<ScheduleRule> getAllScheduleRules()
            throws SQLException {

        List<ScheduleRule> rules = new ArrayList<>();

        String sql =
                "SELECT * FROM schedule_rule "
                + "ORDER BY schedule_rule_id";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet resultSet =
                     statement.executeQuery()) {

            while (resultSet.next()) {
                rules.add(mapScheduleRule(resultSet));
            }
        }

        return rules;
    }

    public List<ScheduleRule> getActiveScheduleRules()
            throws SQLException {

        List<ScheduleRule> rules = new ArrayList<>();

        String sql =
                "SELECT * FROM schedule_rule "
                + "WHERE status = 'ACTIVE' "
                + "ORDER BY schedule_rule_id";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet resultSet =
                     statement.executeQuery()) {

            while (resultSet.next()) {
                rules.add(mapScheduleRule(resultSet));
            }
        }

        return rules;
    }

    public boolean updateScheduleRule(
            ScheduleRule rule) throws SQLException {

        String sql =
                "UPDATE schedule_rule SET "
                + "bus_id = ?, "
                + "route_id = ?, "
                + "departure_time = ?, "
                + "arrival_time = ?, "
                + "fare = ?, "
                + "recurrence_type = ?, "
                + "days_of_week = ?, "
                + "valid_from = ?, "
                + "valid_until = ?, "
                + "specific_date = ?, "
                + "status = ? "
                + "WHERE schedule_rule_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, rule.getBusId());
            statement.setInt(2, rule.getRouteId());

            statement.setTime(
                    3,
                    Time.valueOf(rule.getDepartureTime()));

            statement.setTime(
                    4,
                    Time.valueOf(rule.getArrivalTime()));

            statement.setBigDecimal(
                    5,
                    rule.getFare());

            statement.setString(
                    6,
                    rule.getRecurrenceType());

            statement.setString(
                    7,
                    rule.getDaysOfWeek());

            statement.setDate(
                    8,
                    Date.valueOf(rule.getValidFrom()));

            if (rule.getValidUntil() != null) {
                statement.setDate(
                        9,
                        Date.valueOf(rule.getValidUntil()));
            } else {
                statement.setNull(
                        9,
                        java.sql.Types.DATE);
            }

            if (rule.getSpecificDate() != null) {
                statement.setDate(
                        10,
                        Date.valueOf(rule.getSpecificDate()));
            } else {
                statement.setNull(
                        10,
                        java.sql.Types.DATE);
            }

            statement.setString(
                    11,
                    rule.getStatus());

            statement.setInt(
                    12,
                    rule.getScheduleRuleId());

            return statement.executeUpdate() > 0;
        }
    }

    private ScheduleRule mapScheduleRule(
            ResultSet resultSet) throws SQLException {

        ScheduleRule rule = new ScheduleRule();

        rule.setScheduleRuleId(
                resultSet.getInt("schedule_rule_id"));

        rule.setBusId(
                resultSet.getInt("bus_id"));

        rule.setRouteId(
                resultSet.getInt("route_id"));

        rule.setDepartureTime(
                resultSet.getTime("departure_time")
                        .toLocalTime());

        rule.setArrivalTime(
                resultSet.getTime("arrival_time")
                        .toLocalTime());

        rule.setFare(
                resultSet.getBigDecimal("fare"));

        rule.setRecurrenceType(
                resultSet.getString("recurrence_type"));

        rule.setDaysOfWeek(
                resultSet.getString("days_of_week"));

        rule.setValidFrom(
                resultSet.getDate("valid_from")
                        .toLocalDate());

        Date validUntil =
                resultSet.getDate("valid_until");

        if (validUntil != null) {
            rule.setValidUntil(
                    validUntil.toLocalDate());
        }

        Date specificDate =
                resultSet.getDate("specific_date");

        if (specificDate != null) {
            rule.setSpecificDate(
                    specificDate.toLocalDate());
        }

        rule.setStatus(
                resultSet.getString("status"));

        return rule;
    }
}