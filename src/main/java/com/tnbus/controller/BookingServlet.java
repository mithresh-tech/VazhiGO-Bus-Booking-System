package com.tnbus.controller;

import com.tnbus.model.Booking;
import com.tnbus.model.BusSchedule;
import com.tnbus.model.User;
import com.tnbus.service.BookingService;
import com.tnbus.service.BusScheduleService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;


@WebServlet("/booking")
public class BookingServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookingService bookingService;
    private BusScheduleService busScheduleService;

    @Override
    public void init() {
        bookingService = new BookingService();
        busScheduleService =
                new BusScheduleService();
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null
                || session.getAttribute(
                        "loggedInUser") == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp");

            return;
        }

        try {

            User user =
                    (User) session.getAttribute(
                            "loggedInUser");

            int scheduleId =
                    Integer.parseInt(
                            request.getParameter(
                                    "scheduleId"));

            BusSchedule schedule =
                    busScheduleService
                            .getScheduleById(scheduleId);

            Booking booking = new Booking();

            booking.setUserId(
                    user.getUserId());

            booking.setScheduleId(
                    scheduleId);

            booking.setTotalAmount(
                    schedule.getFare());

            booking.setBookingStatus(
                    "PENDING");

            booking.setPaymentStatus(
                    "PENDING");

            long bookingId =
                    bookingService.createBooking(
                            booking);

            response.sendRedirect(
                    request.getContextPath()
                    + "/booking-success.jsp?bookingId="
                    + bookingId);

        } catch (Exception e) {

            request.setAttribute(
                    "errorMessage",
                    e.getMessage());

            request.getRequestDispatcher(
                    "/booking.jsp")
                    .forward(request, response);
        }
    }
}