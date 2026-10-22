package com.tnbus.controller;

import com.tnbus.model.Booking;
import com.tnbus.service.BookingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/myBookings")
public class MyBookingsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookingService bookingService;

    @Override
    public void init() {
        bookingService = new BookingService();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        // Check login
        if (session == null
                || session.getAttribute("loggedInUser") == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp");

            return;
        }

        try {

            // Get user ID from login session
            Object userIdObject =
                    session.getAttribute("userId");

            if (userIdObject == null) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/login.jsp");

                return;
            }

            long userId =
                    ((Number) userIdObject).longValue();

            // Get bookings for logged-in user
            List<Booking> bookings =
                    bookingService.getBookingsByUser(userId);

            request.setAttribute(
                    "bookings",
                    bookings);

            request.getRequestDispatcher(
                    "/booking-history.jsp")
                    .forward(request, response);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "errorMessage",
                    "Unable to load booking history. "
                    + e.getMessage());

            request.getRequestDispatcher(
                    "/booking-history.jsp")
                    .forward(request, response);
        }
    }
}