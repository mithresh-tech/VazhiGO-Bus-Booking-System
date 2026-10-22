package com.tnbus.dao;

import com.tnbus.model.ScheduleException;
import com.tnbus.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

public class ScheduleExceptionDAO {

    public boolean addScheduleException(
            ScheduleException exception)
            throws SQLException {

        String sql =
                "INSERT INTO schedule_exception "
                + "(schedule_rule_id, exception_date, "
                + "exception_type, departure_time, arrival_time, "
                + "fare, reason, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection =
                     DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(
                    1,
                    exception.getScheduleRuleId());

            statement.setDate(
                    2,
                    Date.valueOf(
                            exception.getExceptionDate()));

            statement.setString(
                    3,
                    exception.getExceptionType());

            if (exception.getDepartureTime() != null) {
                statement.setTime(
                        4,
                        Time.valueOf(
                                exception.getDepartureTime()));
            } else {
                statement.setNull(
                        4,
                        java.sql.Types.TIME);
            }

            if (exception.getArrivalTime() != null) {
                statement.setTime(
                        5,
                        Time.valueOf(
                                exception.getArrivalTime()));
            } else {
                statement.setNull(
                        5,
                        java.sql.Types.TIME);
            }

            if (exception.getFare() != null) {
                statement.setBigDecimal(
                        6,
                        exception.getFare());
            } else {
                statement.setNull(
                        6,
                        java.sql.Types.DECIMAL);
            }

            statement.setString(
                    7,
                    exception.getReason());

            statement.setString(
                    8,
                    exception.getStatus());

            return statement.executeUpdate() > 0;
        }
    }

    public ScheduleException getScheduleExceptionById(
            int exceptionId) throws SQLException {

        String sql =
                "SELECT * FROM schedule_exception "
                + "WHERE exception_id = ?";

        try (Connection connection =
                     DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, exceptionId);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                if (resultSet.next()) {
                    return mapScheduleException(
                            resultSet);
                }
            }
        }

        return null;
    }

    public List<ScheduleException>
    getExceptionsByScheduleRule(
            int scheduleRuleId) throws SQLException {

        List<ScheduleException> exceptions =
                new ArrayList<>();

        String sql =
                "SELECT * FROM schedule_exception "
                + "WHERE schedule_rule_id = ? "
                + "ORDER BY exception_date";

        try (Connection connection =
                     DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, scheduleRuleId);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                while (resultSet.next()) {
                    exceptions.add(
                            mapScheduleException(
                                    resultSet));
                }
            }
        }

        return exceptions;
    }

    public List<ScheduleException>
    getExceptionsByDate(
            java.sql.Date exceptionDate)
            throws SQLException {

        List<ScheduleException> exceptions =
                new ArrayList<>();

        String sql =
                "SELECT * FROM schedule_exception "
                + "WHERE exception_date = ? "
                + "AND status = 'ACTIVE' "
                + "ORDER BY exception_id";

        try (Connection connection =
                     DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setDate(1, exceptionDate);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                while (resultSet.next()) {
                    exceptions.add(
                            mapScheduleException(
                                    resultSet));
                }
            }
        }

        return exceptions;
    }

    private ScheduleException mapScheduleException(
            ResultSet resultSet) throws SQLException {

        ScheduleException exception =
                new ScheduleException();

        exception.setExceptionId(
                resultSet.getInt("exception_id"));

        exception.setScheduleRuleId(
                resultSet.getInt("schedule_rule_id"));

        exception.setExceptionDate(
                resultSet.getDate("exception_date")
                        .toLocalDate());

        exception.setExceptionType(
                resultSet.getString("exception_type"));

        Time departureTime =
                resultSet.getTime("departure_time");

        if (departureTime != null) {
            exception.setDepartureTime(
                    departureTime.toLocalTime());
        }

        Time arrivalTime =
                resultSet.getTime("arrival_time");

        if (arrivalTime != null) {
            exception.setArrivalTime(
                    arrivalTime.toLocalTime());
        }

        exception.setFare(
                resultSet.getBigDecimal("fare"));

        exception.setReason(
                resultSet.getString("reason"));

        exception.setStatus(
                resultSet.getString("status"));

        return exception;
    }
}