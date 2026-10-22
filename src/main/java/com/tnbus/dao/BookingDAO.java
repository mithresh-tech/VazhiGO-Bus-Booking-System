package com.tnbus.dao;

import com.tnbus.model.Booking;
import com.tnbus.model.BookingPassenger;
import com.tnbus.util.DBConnection;

import java.math.BigDecimal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

public class BookingDAO {

    // =====================================================
    // INTERNAL SEAT INFORMATION
    // =====================================================

    private static class SeatInfo {

        int seatId;
        int busId;

        String seatNumber;
        String status;

        String deck;
        String layoutType;

        SeatInfo(
                int seatId,
                int busId,
                String seatNumber,
                String status,
                String deck,
                String layoutType) {

            this.seatId = seatId;
            this.busId = busId;
            this.seatNumber = seatNumber;
            this.status = status;
            this.deck = deck;
            this.layoutType = layoutType;
        }
    }

    // =====================================================
    // VALIDATE CONFIGURED FARE
    // =====================================================

    private void validateFare(
            BigDecimal fare,
            String category) throws SQLException {

        if (fare == null || fare.signum() < 0) {

            throw new SQLException(
                    category + " fare has not been configured.");
        }
    }

    // =====================================================
    // CALCULATE CATEGORY-WISE SEAT FARE
    // =====================================================

    private BigDecimal determineSeatFare(
            SeatInfo seat,
            boolean isSleeper,
            BigDecimal seaterFare,
            BigDecimal doubleUpperFare,
            BigDecimal doubleLowerFare,
            BigDecimal singleUpperFare,
            BigDecimal singleLowerFare)
            throws SQLException {

        if (!isSleeper) {

            validateFare(seaterFare, "Seater");

            return seaterFare;
        }

        if (seat.deck == null || seat.layoutType == null) {

            throw new SQLException(
                    "Sleeper seat layout is incomplete for seat "
                    + seat.seatNumber + ".");
        }

        String deck =
                seat.deck.trim().toUpperCase(Locale.ROOT);

        String layoutType =
                seat.layoutType.trim().toUpperCase(Locale.ROOT);

        BigDecimal individualFare;

        switch (layoutType) {

            case "DOUBLE_SLEEPER":

                if ("UPPER".equals(deck)) {

                    individualFare = doubleUpperFare;

                } else if ("LOWER".equals(deck)) {

                    individualFare = doubleLowerFare;

                } else {

                    throw new SQLException(
                            "Invalid sleeper deck for seat "
                            + seat.seatNumber + ".");
                }

                break;

            case "SINGLE_SLEEPER":

                if ("UPPER".equals(deck)) {

                    individualFare = singleUpperFare;

                } else if ("LOWER".equals(deck)) {

                    individualFare = singleLowerFare;

                } else {

                    throw new SQLException(
                            "Invalid sleeper deck for seat "
                            + seat.seatNumber + ".");
                }

                break;

            default:

                throw new SQLException(
                        "Unknown sleeper layout type for seat "
                        + seat.seatNumber + ".");
        }

        validateFare(
                individualFare,
                layoutType + " " + deck);

        return individualFare;
    }

    // =====================================================
    // EXISTING LEGACY METHOD - PRESERVED
    // =====================================================

    public long createBooking(Booking booking)
            throws SQLException {

        String sql =
                "INSERT INTO booking "
                + "(user_id, schedule_id, total_amount, "
                + "booking_status, payment_status) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (Connection connection =
                     DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(
                             sql,
                             Statement.RETURN_GENERATED_KEYS)) {

            statement.setLong(
                    1, booking.getUserId());

            statement.setInt(
                    2, booking.getScheduleId());

            statement.setBigDecimal(
                    3, booking.getTotalAmount());

            statement.setString(
                    4, booking.getBookingStatus());

            statement.setString(
                    5, booking.getPaymentStatus());

            statement.executeUpdate();

            try (ResultSet resultSet =
                         statement.getGeneratedKeys()) {

                if (resultSet.next()) {

                    return resultSet.getLong(1);
                }
            }
        }

        return 0;
    }

    // =====================================================
    // ATOMIC BOOKING WITH VERIFIED CATEGORY-WISE FARES
    // =====================================================

    public long createBookingWithPassengers(
            Booking booking,
            List<BookingPassenger> passengers)
            throws SQLException {

        if (booking == null
                || passengers == null
                || passengers.isEmpty()) {

            throw new SQLException(
                    "Booking and passenger details are required.");
        }

        String lockScheduleSql =
                "SELECT bs.bus_id, "
                + "bs.double_upper_fare, "
                + "bs.double_lower_fare, "
                + "bs.single_upper_fare, "
                + "bs.single_lower_fare, "
                + "bs.seater_fare, "
                + "b.bus_type "
                + "FROM bus_schedule bs "
                + "JOIN bus b ON bs.bus_id = b.bus_id "
                + "WHERE bs.schedule_id = ? "
                + "FOR UPDATE";

        String allSeatsSql =
                "SELECT seat_id, bus_id, seat_number, status, "
                + "deck, layout_type "
                + "FROM seat "
                + "WHERE bus_id = ?";

        String bookedSeatSql =
                "SELECT COUNT(*) "
                + "FROM booking_passenger bp "
                + "JOIN booking b "
                + "ON bp.booking_id = b.booking_id "
                + "WHERE b.schedule_id = ? "
                + "AND bp.seat_id = ? "
                + "AND b.booking_status <> 'CANCELLED'";

        String insertBookingSql =
                "INSERT INTO booking "
                + "(user_id, schedule_id, total_amount, "
                + "booking_status, payment_status) "
                + "VALUES (?, ?, ?, ?, ?)";

        String insertPassengerSql =
                "INSERT INTO booking_passenger "
                + "(booking_id, seat_id, passenger_name, "
                + "age, gender, passenger_phone) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection connection =
                     DBConnection.getConnection()) {

            connection.setAutoCommit(false);

            try {

                // ======================================
                // 1. LOCK SCHEDULE AND READ ACTUAL FARES
                // ======================================

                int scheduleBusId;
                String busType;

                BigDecimal seaterFare;
                BigDecimal doubleUpperFare;
                BigDecimal doubleLowerFare;
                BigDecimal singleUpperFare;
                BigDecimal singleLowerFare;

                try (PreparedStatement statement =
                             connection.prepareStatement(
                                     lockScheduleSql)) {

                    statement.setInt(
                            1, booking.getScheduleId());

                    try (ResultSet resultSet =
                                 statement.executeQuery()) {

                        if (!resultSet.next()) {

                            throw new SQLException(
                                    "Selected bus schedule was not found.");
                        }

                        scheduleBusId =
                                resultSet.getInt("bus_id");

                        busType =
                                resultSet.getString("bus_type");

                        seaterFare =
                                resultSet.getBigDecimal(
                                        "seater_fare");

                        doubleUpperFare =
                                resultSet.getBigDecimal(
                                        "double_upper_fare");

                        doubleLowerFare =
                                resultSet.getBigDecimal(
                                        "double_lower_fare");

                        singleUpperFare =
                                resultSet.getBigDecimal(
                                        "single_upper_fare");

                        singleLowerFare =
                                resultSet.getBigDecimal(
                                        "single_lower_fare");
                    }
                }

                boolean isSleeper =
                        busType != null
                        && busType.toUpperCase(Locale.ROOT)
                                .contains("SLEEPER");

                // ======================================
                // 2. VALIDATE CONFIGURED FARES
                // ======================================

                if (isSleeper) {

                    validateFare(
                            doubleUpperFare, "Double Upper");

                    validateFare(
                            doubleLowerFare, "Double Lower");

                    validateFare(
                            singleUpperFare, "Single Upper");

                    validateFare(
                            singleLowerFare, "Single Lower");

                } else {

                    validateFare(seaterFare, "Seater");
                }

                // ======================================
                // 3. RETRIEVE COMPLETE BUS SEAT LAYOUT
                // ======================================

                Map<Integer, SeatInfo> allSeats =
                        new HashMap<>();

                try (PreparedStatement statement =
                             connection.prepareStatement(
                                     allSeatsSql)) {

                    statement.setInt(1, scheduleBusId);

                    try (ResultSet resultSet =
                                 statement.executeQuery()) {

                        while (resultSet.next()) {

                            SeatInfo seat = new SeatInfo(
                                    resultSet.getInt("seat_id"),
                                    resultSet.getInt("bus_id"),
                                    resultSet.getString("seat_number"),
                                    resultSet.getString("status"),
                                    resultSet.getString("deck"),
                                    resultSet.getString("layout_type")
                            );

                            allSeats.put(seat.seatId, seat);
                        }
                    }
                }

                if (allSeats.isEmpty()) {

                    throw new SQLException(
                            "No seats are configured for this bus.");
                }

                // ======================================
                // 4. VALIDATE SEATS AND CALCULATE TOTAL
                // ======================================

                Set<Integer> uniqueSeatIds =
                        new HashSet<>();

                BigDecimal calculatedTotal =
                        BigDecimal.ZERO;

                for (BookingPassenger passenger : passengers) {

                    if (passenger == null
                            || passenger.getSeatId() <= 0) {

                        throw new SQLException(
                                "Invalid passenger seat information.");
                    }

                    int seatId =
                            passenger.getSeatId();

                    if (!uniqueSeatIds.add(seatId)) {

                        throw new SQLException(
                                "The same seat cannot be booked twice.");
                    }

                    SeatInfo selectedSeat =
                            allSeats.get(seatId);

                    if (selectedSeat == null) {

                        throw new SQLException(
                                "Selected seat does not exist on this bus.");
                    }

                    if (selectedSeat.busId != scheduleBusId) {

                        throw new SQLException(
                                "Selected seat belongs to another bus.");
                    }

                    if (!"ACTIVE".equalsIgnoreCase(
                            selectedSeat.status)) {

                        throw new SQLException(
                                "A selected seat is unavailable.");
                    }

                    // ==================================
                    // DETERMINE INDIVIDUAL SEAT FARE
                    // ==================================

                    BigDecimal individualFare =
                            determineSeatFare(
                                    selectedSeat,
                                    isSleeper,
                                    seaterFare,
                                    doubleUpperFare,
                                    doubleLowerFare,
                                    singleUpperFare,
                                    singleLowerFare
                            );

                    calculatedTotal =
                            calculatedTotal.add(individualFare);

                    // ==================================
                    // RECHECK BOOKING AVAILABILITY
                    // ==================================

                    try (PreparedStatement statement =
                                 connection.prepareStatement(
                                         bookedSeatSql)) {

                        statement.setInt(
                                1, booking.getScheduleId());

                        statement.setInt(
                                2, seatId);

                        try (ResultSet resultSet =
                                     statement.executeQuery()) {

                            if (resultSet.next()
                                    && resultSet.getInt(1) > 0) {

                                throw new SQLException(
                                        "One or more selected seats "
                                        + "have already been booked. "
                                        + "Please select available seats.");
                            }
                        }
                    }
                }

                // ======================================
                // 5. VERIFY SERVLET CALCULATED TOTAL
                // ======================================

                if (booking.getTotalAmount() == null) {

                    throw new SQLException(
                            "Booking total amount is missing.");
                }

                if (calculatedTotal.compareTo(
                        booking.getTotalAmount()) != 0) {

                    throw new SQLException(
                            "Booking fare has changed or is incorrect. "
                            + "Please select your seats again.");
                }

                // Always save the verified database total.
                booking.setTotalAmount(calculatedTotal);

                // ======================================
                // 6. INSERT BOOKING
                // ======================================

                long bookingId;

                try (PreparedStatement statement =
                             connection.prepareStatement(
                                     insertBookingSql,
                                     Statement.RETURN_GENERATED_KEYS)) {

                    statement.setLong(
                            1, booking.getUserId());

                    statement.setInt(
                            2, booking.getScheduleId());

                    statement.setBigDecimal(
                            3, calculatedTotal);

                    statement.setString(
                            4, booking.getBookingStatus());

                    statement.setString(
                            5, booking.getPaymentStatus());

                    if (statement.executeUpdate() != 1) {

                        throw new SQLException(
                                "Unable to create booking.");
                    }

                    try (ResultSet resultSet =
                                 statement.getGeneratedKeys()) {

                        if (!resultSet.next()) {

                            throw new SQLException(
                                    "Booking ID was not generated.");
                        }

                        bookingId =
                                resultSet.getLong(1);
                    }
                }

                // ======================================
                // 7. INSERT PASSENGERS
                // ======================================

                try (PreparedStatement statement =
                             connection.prepareStatement(
                                     insertPassengerSql)) {

                    for (BookingPassenger passenger : passengers) {

                        statement.setLong(
                                1, bookingId);

                        statement.setInt(
                                2, passenger.getSeatId());

                        statement.setString(
                                3, passenger.getPassengerName());

                        statement.setInt(
                                4, passenger.getAge());

                        statement.setString(
                                5, passenger.getGender());

                        statement.setString(
                                6, passenger.getPassengerPhone());

                        if (statement.executeUpdate() != 1) {

                            throw new SQLException(
                                    "Unable to save passenger details.");
                        }
                    }
                }

                // ======================================
                // 8. COMMIT COMPLETE BOOKING
                // ======================================

                connection.commit();

                return bookingId;

            } catch (Exception e) {

                try {

                    connection.rollback();

                } catch (SQLException rollbackException) {

                    e.addSuppressed(rollbackException);
                }

                if (e instanceof SQLException) {

                    throw (SQLException) e;
                }

                throw new SQLException(
                        "Booking transaction failed.", e);

            } finally {

                connection.setAutoCommit(true);
            }
        }
    }

    // =====================================================
    // EXISTING READ METHODS - PRESERVED
    // =====================================================

    public Booking getBookingById(long bookingId)
            throws SQLException {

        String sql =
                "SELECT * FROM booking WHERE booking_id = ?";

        try (Connection connection =
                     DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setLong(1, bookingId);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                if (resultSet.next()) {

                    return mapBooking(resultSet);
                }
            }
        }

        return null;
    }

    public List<Booking> getBookingsByUser(long userId)
            throws SQLException {

        List<Booking> bookings =
                new ArrayList<>();

        String sql =
                "SELECT * FROM booking "
                + "WHERE user_id = ? "
                + "ORDER BY booking_date DESC";

        try (Connection connection =
                     DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setLong(1, userId);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                while (resultSet.next()) {

                    bookings.add(
                            mapBooking(resultSet));
                }
            }
        }

        return bookings;
    }

    public List<Booking> getAllBookings()
            throws SQLException {

        List<Booking> bookings =
                new ArrayList<>();

        String sql =
                "SELECT * FROM booking "
                + "ORDER BY booking_date DESC";

        try (Connection connection =
                     DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(sql);

             ResultSet resultSet =
                     statement.executeQuery()) {

            while (resultSet.next()) {

                bookings.add(
                        mapBooking(resultSet));
            }
        }

        return bookings;
    }

    public boolean updateBookingStatus(
            long bookingId,
            String bookingStatus,
            String paymentStatus)
            throws SQLException {

        String sql =
                "UPDATE booking "
                + "SET booking_status = ?, "
                + "payment_status = ? "
                + "WHERE booking_id = ?";

        try (Connection connection =
                     DBConnection.getConnection();

             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(
                    1, bookingStatus);

            statement.setString(
                    2, paymentStatus);

            statement.setLong(
                    3, bookingId);

            return statement.executeUpdate() > 0;
        }
    }

    // =====================================================
    // MAP BOOKING - PRESERVED
    // =====================================================

    private Booking mapBooking(ResultSet resultSet)
            throws SQLException {

        Booking booking =
                new Booking();

        booking.setBookingId(
                resultSet.getLong("booking_id"));

        booking.setUserId(
                resultSet.getLong("user_id"));

        booking.setScheduleId(
                resultSet.getInt("schedule_id"));

        Timestamp timestamp =
                resultSet.getTimestamp("booking_date");

        if (timestamp != null) {

            booking.setBookingDate(
                    timestamp.toLocalDateTime());
        }

        booking.setTotalAmount(
                resultSet.getBigDecimal("total_amount"));

        booking.setBookingStatus(
                resultSet.getString("booking_status"));

        booking.setPaymentStatus(
                resultSet.getString("payment_status"));

        return booking;
    }
}