package com.tnbus.dao;

import com.tnbus.model.BusSearchCard;
import com.tnbus.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.time.LocalDate;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class BusSearchCardDAO {

    // =====================================================
    // METHOD 1: SEARCH BUSES FOR A SPECIFIC DATE
    // =====================================================

    public List<BusSearchCard> searchBusCards(
            int sourceCityId,
            int destinationCityId,
            LocalDate travelDate) throws SQLException {

        List<BusSearchCard> cards = new ArrayList<>();

        String sql = """
            SELECT
                bs.schedule_id,
                bus.bus_id,
                bs.travel_date,
                bs.departure_time,
                bs.arrival_time,
                bs.fare,

                bus.bus_name,
                bus.bus_number,
                bus.bus_type,

                src.city_name AS source_city,
                dest.city_name AS destination_city,

                (
                    SELECT COUNT(*)
                    FROM seat s
                    WHERE s.bus_id = bus.bus_id
                      AND s.status = 'ACTIVE'
                ) AS total_seats,

                (
                    SELECT COUNT(*)
                    FROM seat s
                    WHERE s.bus_id = bus.bus_id
                      AND s.status = 'ACTIVE'

                      AND NOT EXISTS (
                          SELECT 1
                          FROM booking_passenger bp

                          JOIN booking b
                            ON bp.booking_id = b.booking_id

                          WHERE bp.seat_id = s.seat_id
                            AND b.schedule_id = bs.schedule_id
                            AND b.booking_status <> 'CANCELLED'
                      )
                ) AS available_seats

            FROM bus_schedule bs

            JOIN bus
              ON bs.bus_id = bus.bus_id

            JOIN route r
              ON bs.route_id = r.route_id

            JOIN city src
              ON r.source_city_id = src.city_id

            JOIN city dest
              ON r.destination_city_id = dest.city_id

            WHERE r.source_city_id = ?
              AND r.destination_city_id = ?
              AND bs.travel_date = ?
              AND bs.status = 'SCHEDULED'
              AND bus.status = 'ACTIVE'

            ORDER BY bs.departure_time, bs.schedule_id
            """;

        try (Connection connection = DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, sourceCityId);
            statement.setInt(2, destinationCityId);

            statement.setDate(
                    3,
                    Date.valueOf(travelDate));

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {

                    BusSearchCard card = new BusSearchCard();
                    
                    card.setBusId(rs.getInt("bus_id"));

                    card.setScheduleId(
                            rs.getInt("schedule_id"));

                    card.setBusName(
                            rs.getString("bus_name"));

                    card.setBusNumber(
                            rs.getString("bus_number"));

                    card.setBusType(
                            rs.getString("bus_type"));

                    card.setSourceCity(
                            rs.getString("source_city"));

                    card.setDestinationCity(
                            rs.getString("destination_city"));

                    card.setTravelDate(
                            rs.getDate("travel_date").toLocalDate());

                    card.setDepartureTime(
                            rs.getTime("departure_time").toLocalTime());

                    card.setArrivalTime(
                            rs.getTime("arrival_time").toLocalTime());

                    card.setFare(
                            rs.getBigDecimal("fare"));

                    card.setTotalSeats(
                            rs.getInt("total_seats"));

                    card.setAvailableSeats(
                            rs.getInt("available_seats"));

                    cards.add(card);
                }
            }
        }

        return cards;
    }

    // =====================================================
    // METHOD 2: DATE-WISE AVAILABLE BUS COUNT
    // =====================================================

    public Map<LocalDate, Integer> getDateWiseAvailability(
            int sourceCityId,
            int destinationCityId,
            LocalDate startDate,
            int numberOfDays) throws SQLException {

        if (startDate == null
                || numberOfDays < 1
                || numberOfDays > 31) {

            throw new IllegalArgumentException(
                    "Invalid date availability range.");
        }

        Map<LocalDate, Integer> availability =
                new LinkedHashMap<>();

        LocalDate endDate =
                startDate.plusDays(numberOfDays - 1L);

        // Initialise every date, including dates with zero buses.

        for (int i = 0; i < numberOfDays; i++) {

            availability.put(
                    startDate.plusDays(i),
                    0);
        }

        String sql = """
            SELECT
                bs.travel_date,
                COUNT(*) AS available_bus_count

            FROM bus_schedule bs

            JOIN bus
              ON bs.bus_id = bus.bus_id

            JOIN route r
              ON bs.route_id = r.route_id

            WHERE r.source_city_id = ?
              AND r.destination_city_id = ?

              AND bs.travel_date BETWEEN ? AND ?

              AND bs.status = 'SCHEDULED'
              AND bus.status = 'ACTIVE'

              AND EXISTS (

                  SELECT 1
                  FROM seat s

                  WHERE s.bus_id = bus.bus_id
                    AND s.status = 'ACTIVE'

                    AND NOT EXISTS (

                        SELECT 1
                        FROM booking_passenger bp

                        JOIN booking b
                          ON bp.booking_id = b.booking_id

                        WHERE bp.seat_id = s.seat_id
                          AND b.schedule_id = bs.schedule_id
                          AND b.booking_status <> 'CANCELLED'
                    )
              )

            GROUP BY bs.travel_date

            ORDER BY bs.travel_date
            """;

        try (Connection connection = DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, sourceCityId);

            statement.setInt(2, destinationCityId);

            statement.setDate(
                    3,
                    Date.valueOf(startDate));

            statement.setDate(
                    4,
                    Date.valueOf(endDate));

            try (ResultSet rs = statement.executeQuery()) {

                while (rs.next()) {

                    LocalDate date =
                            rs.getDate("travel_date").toLocalDate();

                    int count =
                            rs.getInt("available_bus_count");

                    availability.put(date, count);
                }
            }
        }

        return availability;
    }
}