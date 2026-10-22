package com.tnbus.controller;

import com.tnbus.dao.BusDAO;

import com.tnbus.model.Bus;
import com.tnbus.model.BusSchedule;
import com.tnbus.model.Seat;

import com.tnbus.service.BusScheduleService;
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

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/seatSelection")
public class SeatSelectionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BusScheduleService busScheduleService;

    private SeatService seatService;

    private SeatFareService seatFareService;

    private BusDAO busDAO;

    // ==========================================
    // INITIALIZE SERVICES
    // ==========================================

    @Override
    public void init() {

        busScheduleService = new BusScheduleService();

        seatService = new SeatService();

        seatFareService = new SeatFareService();

        busDAO = new BusDAO();
    }

    // ==========================================
    // DISPLAY SEAT SELECTION
    // ==========================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null
                || session.getAttribute("loggedInUser") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");

            return;
        }

        // ======================================
        // 1. VALIDATE SCHEDULE ID
        // ======================================

        int scheduleId;

        try {

            scheduleId = Integer.parseInt(
                    request.getParameter("scheduleId"));

            if (scheduleId <= 0) {

                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {

            forwardToSearch(
                    request,
                    response,
                    "Invalid or missing schedule ID.");

            return;
        }

        try {

            // ==================================
            // 2. RETRIEVE SCHEDULE
            // ==================================

            BusSchedule schedule =
                    busScheduleService.getScheduleById(
                            scheduleId);

            if (schedule == null) {

                forwardToSearch(
                        request,
                        response,
                        "Bus schedule not found.");

                return;
            }

            // ==================================
            // 3. RETRIEVE BUS
            // ==================================

            Bus bus =
                    busDAO.getBusById(
                            schedule.getBusId());

            if (bus == null) {

                forwardToSearch(
                        request,
                        response,
                        "Bus details not found.");

                return;
            }

            // ==================================
            // 4. IDENTIFY BUS TYPE
            // ==================================

            boolean sleeper =
                    seatFareService.isSleeper(bus);

            // ==================================
            // 5. RETRIEVE ALL ACTIVE SEATS
            // ==================================

            List<Seat> seats =
                    seatService.getSeatsByBus(
                            schedule.getBusId());

            // ==================================
            // 6. RETRIEVE BOOKED SEATS
            // ==================================

            List<Integer> bookedSeatIds =
                    seatService.getBookedSeatIdsBySchedule(
                            scheduleId);

            // ==================================
            // 7. RETRIEVE BOOKED SEAT GENDERS
            // ==================================

            Map<Integer, String> bookedSeatGenders =
                    seatService.getBookedSeatGendersBySchedule(
                            scheduleId);

            // ==================================
            // 8. CALCULATE INDIVIDUAL SEAT FARES
            // ==================================

            Map<Integer, BigDecimal> seatFareMap =
                    new HashMap<>();

            for (Seat seat : seats) {

                BigDecimal individualFare =
                        seatFareService.getSeatFare(
                                seat,
                                bus,
                                schedule,
                                seats);

                seatFareMap.put(
                        seat.getSeatId(),
                        individualFare);
            }

            // ==================================
            // 9. SEND DATA TO JSP
            // ==================================

            request.setAttribute(
                    "schedule",
                    schedule);

            request.setAttribute(
                    "bus",
                    bus);

            request.setAttribute(
                    "seats",
                    seats);

            request.setAttribute(
                    "bookedSeatIds",
                    bookedSeatIds);

            request.setAttribute(
                    "bookedSeatGenders",
                    bookedSeatGenders);

            request.setAttribute(
                    "isSleeper",
                    sleeper);

            request.setAttribute(
                    "seatFareMap",
                    seatFareMap);

            // Category-wise pricing for display

            request.setAttribute(
                    "doubleUpperFare",
                    schedule.getDoubleUpperFare());

            request.setAttribute(
                    "doubleLowerFare",
                    schedule.getDoubleLowerFare());

            request.setAttribute(
                    "singleUpperFare",
                    schedule.getSingleUpperFare());

            request.setAttribute(
                    "singleLowerFare",
                    schedule.getSingleLowerFare());

            request.setAttribute(
                    "seaterFare",
                    schedule.getSeaterFare());

            // ==================================
            // 10. OPEN SEAT SELECTION PAGE
            // ==================================

            request.getRequestDispatcher(
                    "/seat-selection.jsp")
                    .forward(request, response);

        } catch (Exception e) {

            log("Unable to load seat selection", e);

            forwardToSearch(
                    request,
                    response,
                    "Unable to load seat selection. Please try again.");
        }
    }

    // ==========================================
    // RETURN TO SEARCH PAGE WITH ERROR
    // ==========================================

    private void forwardToSearch(
            HttpServletRequest request,
            HttpServletResponse response,
            String message)
            throws ServletException, IOException {

        request.setAttribute(
                "errorMessage",
                message);

        request.getRequestDispatcher(
                "/search.jsp")
                .forward(request, response);
    }
}