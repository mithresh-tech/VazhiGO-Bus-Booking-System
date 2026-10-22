package com.tnbus.controller;

import com.tnbus.dao.BookingDAO;
import com.tnbus.dao.BusScheduleDAO;

import com.tnbus.model.Booking;
import com.tnbus.model.BusSchedule;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneId;

@WebServlet("/trackJourney")
public class JourneyTrackingServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookingDAO bookingDAO;
    private BusScheduleDAO busScheduleDAO;

    @Override
    public void init() {

        bookingDAO = new BookingDAO();

        busScheduleDAO = new BusScheduleDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("loggedInUser") == null
                || !(session.getAttribute("userId") instanceof Number)) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");

            return;
        }

        try {

            long userId = ((Number)
                    session.getAttribute("userId")).longValue();

            String bookingParam =
                    request.getParameter("bookingId");

            if (bookingParam == null
                    || bookingParam.isBlank()) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Booking ID is required.");

                return;
            }

            long bookingId =
                    Long.parseLong(bookingParam.trim());

            if (bookingId <= 0) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid booking ID.");

                return;
            }

            Booking booking =
                    bookingDAO.getBookingById(bookingId);

            // Security: never expose another user's booking.

            if (booking == null
                    || booking.getUserId() != userId) {

                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Booking not found.");

                return;
            }

            if (!"CONFIRMED".equalsIgnoreCase(
                    booking.getBookingStatus())
                    || !"PAID".equalsIgnoreCase(
                            booking.getPaymentStatus())) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Tracking is available only for confirmed, paid bookings.");

                return;
            }

            BusSchedule schedule =
                    busScheduleDAO.getScheduleById(
                            booking.getScheduleId());

            if (schedule == null
                    || schedule.getTravelDate() == null
                    || schedule.getDepartureTime() == null
                    || schedule.getArrivalTime() == null) {

                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Journey schedule is unavailable.");

                return;
            }

            // Use the journey date stored in the database.

            LocalDateTime departure =
                    LocalDateTime.of(
                            schedule.getTravelDate(),
                            schedule.getDepartureTime());

            LocalDateTime arrival =
                    LocalDateTime.of(
                            schedule.getTravelDate(),
                            schedule.getArrivalTime());

            // Handle journeys crossing midnight.

            if (!arrival.isAfter(departure)) {

                arrival = arrival.plusDays(1);
            }

            LocalDateTime now =
                    LocalDateTime.now(
                            ZoneId.of("Asia/Kolkata"));

            long totalMinutes =
                    Duration.between(
                            departure,
                            arrival).toMinutes();

            long elapsedMinutes =
                    Duration.between(
                            departure,
                            now).toMinutes();

            int progress;

            String journeyStatus;

            if (now.isBefore(departure)) {

                progress = 0;

                journeyStatus = "UPCOMING";

            } else if (!now.isBefore(arrival)) {

                progress = 100;

                journeyStatus = "SCHEDULED TIME COMPLETED";

            } else {

                progress = (int) Math.min(
                        100,
                        Math.max(
                                0,
                                elapsedMinutes * 100 / totalMinutes));

                journeyStatus = "ESTIMATED IN PROGRESS";
            }

            request.setAttribute("booking", booking);

            request.setAttribute("schedule", schedule);

            request.setAttribute("departure", departure);

            request.setAttribute("arrival", arrival);

            request.setAttribute("progress", progress);

            request.setAttribute(
                    "journeyStatus",
                    journeyStatus);

            request.getRequestDispatcher(
                    "/journey-tracking.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid booking ID.");

        } catch (Exception e) {

            log("Journey tracking failed", e);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load journey tracking.");
        }
    }
}