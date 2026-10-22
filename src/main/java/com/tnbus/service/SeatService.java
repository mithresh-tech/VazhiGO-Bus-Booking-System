package com.tnbus.service;

import com.tnbus.dao.SeatDAO;
import com.tnbus.exception.SeatNotAvailableException;
import com.tnbus.model.Seat;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class SeatService {

    private final SeatDAO seatDAO;

    public SeatService() {
        this.seatDAO = new SeatDAO();
    }

    /**
     * Gets all active seats for a particular bus.
     */
    public List<Seat> getSeatsByBus(int busId)
            throws SQLException {

        if (busId <= 0) {
            return List.of();
        }

        return seatDAO.getSeatsByBus(busId);
    }

    /**
     * Gets a particular seat by seat ID.
     *
     * Throws an exception if the seat
     * does not exist or is inactive.
     */
    public Seat getSeatById(int seatId)
            throws SQLException, SeatNotAvailableException {

        if (seatId <= 0) {

            throw new SeatNotAvailableException(
                    "Invalid seat ID.");
        }

        Seat seat = seatDAO.getSeatById(seatId);

        if (seat == null) {

            throw new SeatNotAvailableException(
                    "Seat not found.");
        }

        if (!"ACTIVE".equalsIgnoreCase(
                seat.getStatus())) {

            throw new SeatNotAvailableException(
                    "Seat is not available.");
        }

        return seat;
    }

    /**
     * Gets already booked seat IDs
     * for a particular schedule.
     */
    public List<Integer> getBookedSeatIdsBySchedule(
            int scheduleId) throws SQLException {

        if (scheduleId <= 0) {
            return List.of();
        }

        return seatDAO.getBookedSeatIdsBySchedule(
                scheduleId);
    }

    /**
     * NEW METHOD:
     *
     * Gets booked seat IDs with passenger genders.
     */
    public Map<Integer, String> getBookedSeatGendersBySchedule(
            int scheduleId) throws SQLException {

        if (scheduleId <= 0) {
            return Map.of();
        }

        return seatDAO.getBookedSeatGendersBySchedule(
                scheduleId);
    }
}