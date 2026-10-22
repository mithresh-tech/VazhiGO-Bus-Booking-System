package com.tnbus.service;

import com.tnbus.model.Bus;
import com.tnbus.model.BusSchedule;
import com.tnbus.model.Seat;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

public class SeatFareService {

    // ==========================================
    // CHECK WHETHER BUS IS SLEEPER
    // ==========================================

    public boolean isSleeper(Bus bus) {

        return bus != null
                && bus.getBusType() != null
                && bus.getBusType()
                        .toUpperCase(Locale.ROOT)
                        .contains("SLEEPER");
    }

    // ==========================================
    // EXTRACT NUMBER FROM SEAT NUMBER
    // Used only for display ordering.
    // NOT used to determine deck or fare.
    // ==========================================

    private int extractNumber(String seatNumber) {

        if (seatNumber == null) {
            return 0;
        }

        String digits = seatNumber.replaceAll("\\D", "");

        if (digits.isEmpty()) {
            return 0;
        }

        try {
            return Integer.parseInt(digits);

        } catch (NumberFormatException e) {
            return 0;
        }
    }

    // ==========================================
    // SORT SEATS CONSISTENTLY
    // ==========================================

    public List<Seat> getOrderedSeats(List<Seat> seats) {

        if (seats == null) {
            throw new IllegalArgumentException(
                    "Bus seats are required.");
        }

        List<Seat> ordered = new ArrayList<>(seats);

        ordered.sort(
                Comparator
                        .comparingInt(
                                (Seat seat) ->
                                        extractNumber(
                                                seat.getSeatNumber()))
                        .thenComparing(
                                seat -> seat.getSeatNumber() == null
                                        ? ""
                                        : seat.getSeatNumber(),
                                String.CASE_INSENSITIVE_ORDER)
                        .thenComparingInt(Seat::getSeatId)
        );

        return ordered;
    }

    // ==========================================
    // IDENTIFY UPPER DECK USING DATABASE METADATA
    // ==========================================

    public boolean isUpperSeat(
            int seatId,
            List<Seat> allSeats) {

        if (allSeats == null) {
            throw new IllegalArgumentException(
                    "Bus seats are required.");
        }

        for (Seat seat : allSeats) {

            if (seat.getSeatId() == seatId) {

                if (seat.getDeck() == null) {
                    throw new IllegalArgumentException(
                            "Seat deck has not been configured.");
                }

                String deck = seat.getDeck()
                        .trim()
                        .toUpperCase(Locale.ROOT);

                if ("UPPER".equals(deck)) {
                    return true;
                }

                if ("LOWER".equals(deck)) {
                    return false;
                }

                throw new IllegalArgumentException(
                        "Invalid seat deck configuration.");
            }
        }

        throw new IllegalArgumentException(
                "Selected seat was not found.");
    }

    // ==========================================
    // DISPLAY SEAT NUMBER
    // ==========================================

    public String getDisplaySeatNumber(
            Seat seat,
            Bus bus,
            List<Seat> allSeats) {

        if (seat == null) {
            throw new IllegalArgumentException(
                    "Seat information is required.");
        }

        if (!isSleeper(bus)) {
            return seat.getSeatNumber();
        }

        if (allSeats == null) {
            throw new IllegalArgumentException(
                    "Bus seats are required.");
        }

        Seat matchedSeat = null;

        for (Seat existing : allSeats) {

            if (existing.getSeatId() == seat.getSeatId()) {
                matchedSeat = existing;
                break;
            }
        }

        if (matchedSeat == null) {
            throw new IllegalArgumentException(
                    "Selected seat was not found.");
        }

        String deck = matchedSeat.getDeck();

        if (deck == null) {
            throw new IllegalArgumentException(
                    "Seat deck has not been configured.");
        }

        String normalizedDeck =
                deck.trim().toUpperCase(Locale.ROOT);

        if (!"UPPER".equals(normalizedDeck)
                && !"LOWER".equals(normalizedDeck)) {

            throw new IllegalArgumentException(
                    "Invalid seat deck configuration.");
        }

        // Keep original seat number so the passenger,
        // booking record and seat-selection screen agree.
        return ("UPPER".equals(normalizedDeck) ? "U-" : "L-")
                + matchedSeat.getSeatNumber();
    }

    // ==========================================
    // CALCULATE INDIVIDUAL SEAT FARE
    // ==========================================

    public BigDecimal getSeatFare(
            Seat seat,
            Bus bus,
            BusSchedule schedule,
            List<Seat> allSeats) {

        if (seat == null
                || bus == null
                || schedule == null
                || allSeats == null) {

            throw new IllegalArgumentException(
                    "Incomplete fare information.");
        }

        if (bus.getBusId() != schedule.getBusId()
                || seat.getBusId() != schedule.getBusId()) {

            throw new IllegalArgumentException(
                    "Selected seat belongs to another bus.");
        }

        // Use the actual seat loaded from the database list.
        Seat matchedSeat = null;

        for (Seat existing : allSeats) {

            if (existing.getSeatId() == seat.getSeatId()) {

                matchedSeat = existing;
                break;
            }
        }

        if (matchedSeat == null
                || matchedSeat.getBusId() != schedule.getBusId()) {

            throw new IllegalArgumentException(
                    "Selected seat is invalid.");
        }

        BigDecimal seatFare;

        // ======================================
        // NORMAL SEATER BUS
        // ======================================

        if (!isSleeper(bus)) {

            seatFare = schedule.getSeaterFare();

        } else {

            // ==================================
            // SLEEPER CATEGORY-WISE PRICING
            // ==================================

            String deck = matchedSeat.getDeck();
            String layoutType = matchedSeat.getLayoutType();

            if (deck == null || layoutType == null) {

                throw new IllegalArgumentException(
                        "Sleeper seat layout is incomplete.");
            }

            deck = deck.trim().toUpperCase(Locale.ROOT);

            layoutType = layoutType.trim()
                    .toUpperCase(Locale.ROOT);

            switch (layoutType) {

                case "DOUBLE_SLEEPER":

                    if ("UPPER".equals(deck)) {

                        seatFare = schedule.getDoubleUpperFare();

                    } else if ("LOWER".equals(deck)) {

                        seatFare = schedule.getDoubleLowerFare();

                    } else {

                        throw new IllegalArgumentException(
                                "Invalid sleeper deck.");
                    }

                    break;

                case "SINGLE_SLEEPER":

                    if ("UPPER".equals(deck)) {

                        seatFare = schedule.getSingleUpperFare();

                    } else if ("LOWER".equals(deck)) {

                        seatFare = schedule.getSingleLowerFare();

                    } else {

                        throw new IllegalArgumentException(
                                "Invalid sleeper deck.");
                    }

                    break;

                default:

                    throw new IllegalArgumentException(
                            "Unknown sleeper layout type: "
                            + layoutType);
            }
        }

        // ======================================
        // FINAL FARE VALIDATION
        // ======================================

        if (seatFare == null || seatFare.signum() < 0) {

            throw new IllegalArgumentException(
                    "Fare has not been configured "
                    + "for this bus schedule.");
        }

        return seatFare;
    }

    // ==========================================
    // CALCULATE TOTAL BOOKING AMOUNT
    // ==========================================

    public BigDecimal calculateTotal(
            List<Seat> selectedSeats,
            Bus bus,
            BusSchedule schedule,
            List<Seat> allSeats) {

        if (selectedSeats == null
                || selectedSeats.isEmpty()) {

            throw new IllegalArgumentException(
                    "Please select at least one seat.");
        }

        BigDecimal total = BigDecimal.ZERO;

        Set<Integer> uniqueSeatIds = new HashSet<>();

        for (Seat seat : selectedSeats) {

            if (seat == null
                    || !uniqueSeatIds.add(seat.getSeatId())) {

                throw new IllegalArgumentException(
                        "Invalid or duplicate seat selection.");
            }

            total = total.add(
                    getSeatFare(
                            seat,
                            bus,
                            schedule,
                            allSeats));
        }

        return total;
    }

    // ==========================================
    // CREATE SEAT-WISE FARE MAP
    // ==========================================

    public Map<Integer, BigDecimal> getSeatFareMap(
            List<Seat> selectedSeats,
            Bus bus,
            BusSchedule schedule,
            List<Seat> allSeats) {

        if (selectedSeats == null) {
            throw new IllegalArgumentException(
                    "Selected seats are required.");
        }

        Map<Integer, BigDecimal> fareMap = new HashMap<>();

        Set<Integer> uniqueSeatIds = new HashSet<>();

        for (Seat seat : selectedSeats) {

            if (seat == null
                    || !uniqueSeatIds.add(seat.getSeatId())) {

                throw new IllegalArgumentException(
                        "Invalid or duplicate seat selection.");
            }

            fareMap.put(
                    seat.getSeatId(),
                    getSeatFare(
                            seat,
                            bus,
                            schedule,
                            allSeats));
        }

        return fareMap;
    }
}