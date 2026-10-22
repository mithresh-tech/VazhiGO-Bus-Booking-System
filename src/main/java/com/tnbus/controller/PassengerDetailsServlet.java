package com.tnbus.controller;

import com.tnbus.model.Bus;
import com.tnbus.model.BusSchedule;
import com.tnbus.model.Seat;
import com.tnbus.model.User;

import com.tnbus.service.BusScheduleService;
import com.tnbus.service.BusService;
import com.tnbus.service.SeatService;
import com.tnbus.service.SeatFareService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet("/passengerDetails")
public class PassengerDetailsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BusScheduleService busScheduleService;
    private BusService busService;
    private SeatService seatService;
    private SeatFareService seatFareService;

    @Override
    public void init() {

        busScheduleService = new BusScheduleService();
        busService = new BusService();
        seatService = new SeatService();
        seatFareService = new SeatFareService();
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || !(session.getAttribute("loggedInUser")
                        instanceof User)) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");

            return;
        }

        try {

            // ==========================================
            // VALIDATE REQUEST
            // ==========================================

            String scheduleIdParam =
                    request.getParameter("scheduleId");

            String selectedSeatIdsParam =
                    request.getParameter("selectedSeatIds");

            if (scheduleIdParam == null
                    || scheduleIdParam.isBlank()) {

                throw new IllegalArgumentException(
                        "Schedule ID is required.");
            }

            if (selectedSeatIdsParam == null
                    || selectedSeatIdsParam.isBlank()) {

                throw new IllegalArgumentException(
                        "Please select at least one seat.");
            }

            int scheduleId =
                    Integer.parseInt(scheduleIdParam.trim());

            if (scheduleId <= 0) {

                throw new IllegalArgumentException(
                        "Invalid schedule ID.");
            }

            // ==========================================
            // FETCH SCHEDULE AND BUS
            // ==========================================

            BusSchedule schedule =
                    busScheduleService.getScheduleById(scheduleId);

            if (schedule == null) {

                throw new IllegalArgumentException(
                        "Selected bus schedule was not found.");
            }

            Bus bus =
                    busService.getBusById(schedule.getBusId());

            if (bus == null) {

                throw new IllegalArgumentException(
                        "Bus information was not found.");
            }

            // All seats are needed for consistent U/L mapping.
            List<Seat> allSeats =
                    seatService.getSeatsByBus(schedule.getBusId());

            if (allSeats == null || allSeats.isEmpty()) {

                throw new IllegalArgumentException(
                        "No seats are configured for this bus.");
            }

            // ==========================================
            // VALIDATE SELECTED SEATS
            // ==========================================

            String[] seatIdArray =
                    selectedSeatIdsParam.split(",", -1);

            List<Seat> selectedSeats = new ArrayList<>();

            Set<Integer> uniqueSeatIds = new HashSet<>();

            for (String seatIdText : seatIdArray) {

                if (seatIdText == null || seatIdText.isBlank()) {

                    throw new IllegalArgumentException(
                            "Invalid seat selection.");
                }

                int seatId =
                        Integer.parseInt(seatIdText.trim());

                if (seatId <= 0 || !uniqueSeatIds.add(seatId)) {

                    throw new IllegalArgumentException(
                            "Invalid or duplicate seat selection.");
                }

                Seat selectedSeat = null;

                for (Seat seat : allSeats) {

                    if (seat.getSeatId() == seatId) {

                        selectedSeat = seat;
                        break;
                    }
                }

                if (selectedSeat == null
                        || selectedSeat.getBusId()
                                != schedule.getBusId()) {

                    throw new IllegalArgumentException(
                            "Invalid seat selected for this bus.");
                }

                selectedSeats.add(selectedSeat);
            }

            // ==========================================
            // CHECK BOOKED SEATS
            // ==========================================

            List<Integer> bookedSeatIds =
                    seatService.getBookedSeatIdsBySchedule(scheduleId);

            Set<Integer> bookedSeatSet =
                    new HashSet<>(bookedSeatIds);

            for (Seat seat : selectedSeats) {

                if (bookedSeatSet.contains(seat.getSeatId())) {

                    throw new IllegalArgumentException(
                            "Seat " + seat.getSeatNumber()
                            + " has already been booked.");
                }
            }

            // ==========================================
            // CALCULATE UPPER / LOWER DECK FARES
            // ==========================================

            Map<Integer, BigDecimal> seatFareMap =
                    seatFareService.getSeatFareMap(
                            selectedSeats,
                            bus,
                            schedule,
                            allSeats);

            BigDecimal totalAmount =
                    seatFareService.calculateTotal(
                            selectedSeats,
                            bus,
                            schedule,
                            allSeats);

            // Display labels: U-1, U-2, L-19, etc.
            java.util.Map<Integer, String> seatLabelMap =
                    new java.util.HashMap<>();

            for (Seat seat : selectedSeats) {

                seatLabelMap.put(
                        seat.getSeatId(),
                        seatFareService.getDisplaySeatNumber(
                                seat,
                                bus,
                                allSeats));
            }

            // ==========================================
            // SEND DATA TO JSP
            // ==========================================

            request.setAttribute("schedule", schedule);
            request.setAttribute("bus", bus);
            request.setAttribute("selectedSeats", selectedSeats);

            request.setAttribute("seatFareMap", seatFareMap);
            request.setAttribute("seatLabelMap", seatLabelMap);
            request.setAttribute("totalAmount", totalAmount);

            request.setAttribute(
                    "isSleeper",
                    seatFareService.isSleeper(bus));

            request.getRequestDispatcher(
                    "/passenger-details.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {

            request.setAttribute(
                    "errorMessage",
                    "Invalid schedule or seat selection.");

            request.getRequestDispatcher(
                    "/search.jsp")
                    .forward(request, response);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "errorMessage",
                    "Unable to load passenger details. "
                    + e.getMessage());

            request.getRequestDispatcher(
                    "/search.jsp")
                    .forward(request, response);
        }
    }
}