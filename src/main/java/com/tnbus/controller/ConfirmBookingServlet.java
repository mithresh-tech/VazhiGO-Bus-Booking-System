package com.tnbus.controller;

import com.tnbus.dao.BookingDAO;

import com.tnbus.model.Booking;
import com.tnbus.model.BookingPassenger;
import com.tnbus.model.Bus;
import com.tnbus.model.BusSchedule;
import com.tnbus.model.Seat;
import com.tnbus.model.User;

import com.tnbus.service.BusScheduleService;
import com.tnbus.service.BusService;
import com.tnbus.service.SeatService;
import com.tnbus.service.SeatFareService;

import com.tnbus.util.ValidationUtil;

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
import java.util.Set;

@WebServlet("/confirmBooking")
public class ConfirmBookingServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookingDAO bookingDAO;

    private BusScheduleService busScheduleService;
    private BusService busService;
    private SeatService seatService;
    private SeatFareService seatFareService;

    @Override
    public void init() {

        bookingDAO = new BookingDAO();

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

            User user =
                    (User) session.getAttribute("loggedInUser");

            String scheduleIdParam =
                    request.getParameter("scheduleId");

            String[] seatIds =
                    request.getParameterValues("seatIds");

            String[] passengerNames =
                    request.getParameterValues("passengerName");

            String[] ages =
                    request.getParameterValues("age");

            String[] genders =
                    request.getParameterValues("gender");

            String[] passengerPhones =
                    request.getParameterValues("passengerPhone");

            // ==========================================
            // VALIDATE REQUEST
            // ==========================================

            if (scheduleIdParam == null
                    || scheduleIdParam.isBlank()) {

                throw new IllegalArgumentException(
                        "Schedule ID is required.");
            }

            if (seatIds == null || seatIds.length == 0) {

                throw new IllegalArgumentException(
                        "Please select at least one seat.");
            }

            int passengerCount = seatIds.length;

            if (passengerNames == null
                    || ages == null
                    || genders == null
                    || passengerPhones == null
                    || passengerNames.length != passengerCount
                    || ages.length != passengerCount
                    || genders.length != passengerCount
                    || passengerPhones.length != passengerCount) {

                throw new IllegalArgumentException(
                        "Passenger details are incomplete.");
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
                        "Selected schedule was not found.");
            }

            Bus bus =
                    busService.getBusById(schedule.getBusId());

            if (bus == null) {

                throw new IllegalArgumentException(
                        "Bus information was not found.");
            }

            List<Seat> allSeats =
                    seatService.getSeatsByBus(schedule.getBusId());

            if (allSeats == null || allSeats.isEmpty()) {

                throw new IllegalArgumentException(
                        "No seats are configured for this bus.");
            }

            // ==========================================
            // PREPARE PASSENGERS
            // ==========================================

            List<BookingPassenger> passengers =
                    new ArrayList<>();

            List<Seat> selectedSeats =
                    new ArrayList<>();

            Set<Integer> uniqueSeatIds =
                    new HashSet<>();

            for (int i = 0; i < passengerCount; i++) {

                if (seatIds[i] == null
                        || seatIds[i].isBlank()) {

                    throw new IllegalArgumentException(
                            "Invalid seat selection.");
                }

                int seatId =
                        Integer.parseInt(seatIds[i].trim());

                if (seatId <= 0
                        || !uniqueSeatIds.add(seatId)) {

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

                String name =
                        passengerNames[i] == null
                                ? ""
                                : passengerNames[i].trim();

                int age =
                        Integer.parseInt(ages[i].trim());

                String gender =
                        genders[i] == null
                                ? ""
                                : genders[i].trim();

                String phone =
                        passengerPhones[i] == null
                                ? ""
                                : passengerPhones[i].trim();

                if (!ValidationUtil.isValidName(name)) {

                    throw new IllegalArgumentException(
                            "Invalid passenger name.");
                }

                if (!ValidationUtil.isValidAge(age)) {

                    throw new IllegalArgumentException(
                            "Invalid passenger age.");
                }

                if (gender.equalsIgnoreCase("M")
                        || gender.equalsIgnoreCase("MALE")) {

                    gender = "MALE";

                } else if (gender.equalsIgnoreCase("F")
                        || gender.equalsIgnoreCase("FEMALE")) {

                    gender = "FEMALE";

                } else if (gender.equalsIgnoreCase("OTHER")) {

                    gender = "OTHER";

                } else {

                    throw new IllegalArgumentException(
                            "Please select a valid gender.");
                }

                BookingPassenger passenger =
                        new BookingPassenger();

                passenger.setSeatId(seatId);
                passenger.setPassengerName(name);
                passenger.setAge(age);
                passenger.setGender(gender);
                passenger.setPassengerPhone(phone);

                passengers.add(passenger);

                selectedSeats.add(selectedSeat);
            }

            // ==========================================
            // CALCULATE ACTUAL SEAT FARES
            // ==========================================

            BigDecimal totalAmount =
                    seatFareService.calculateTotal(
                            selectedSeats,
                            bus,
                            schedule,
                            allSeats);

            // ==========================================
            // PREPARE BOOKING
            // ==========================================

            Booking booking = new Booking();

            booking.setUserId(user.getUserId());
            booking.setScheduleId(scheduleId);

            booking.setTotalAmount(totalAmount);

            booking.setBookingStatus("PENDING");
            booking.setPaymentStatus("PENDING");

            // ==========================================
            // SAVE BOOKING AND PASSENGERS
            // ==========================================

            long bookingId =
                    bookingDAO.createBookingWithPassengers(
                            booking,
                            passengers);

            if (bookingId <= 0) {

                throw new IllegalArgumentException(
                        "Unable to create booking.");
            }

            // ==========================================
            // REDIRECT TO EXISTING PAYMENT FLOW
            // ==========================================

            response.sendRedirect(
                    request.getContextPath()
                    + "/payment?bookingId="
                    + bookingId);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "errorMessage",
                    "Unable to confirm booking. "
                    + e.getMessage());

            request.getRequestDispatcher(
                    "/search.jsp")
                    .forward(request, response);
        }
    }
}