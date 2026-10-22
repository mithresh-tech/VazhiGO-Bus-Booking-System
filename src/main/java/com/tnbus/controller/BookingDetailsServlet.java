package com.tnbus.controller;

import com.tnbus.model.Booking;
import com.tnbus.model.BookingPassenger;
import com.tnbus.service.BookingPassengerService;
import com.tnbus.service.BookingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/bookingDetails")
public class BookingDetailsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookingService bookingService;
    private BookingPassengerService bookingPassengerService;

    @Override
    public void init() {

        bookingService = new BookingService();

        bookingPassengerService =
                new BookingPassengerService();
    }

    @Override
    protected void doGet(
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

            String bookingIdParam =
                    request.getParameter("bookingId");

            if (bookingIdParam == null
                    || bookingIdParam.isBlank()) {

                request.setAttribute(
                        "errorMessage",
                        "Booking ID is required.");

                request.getRequestDispatcher(
                        "/booking-history.jsp")
                        .forward(request, response);

                return;
            }

            long bookingId =
                    Long.parseLong(
                            bookingIdParam);

            if (bookingId <= 0) {

                request.setAttribute(
                        "errorMessage",
                        "Invalid booking ID.");

                request.getRequestDispatcher(
                        "/booking-history.jsp")
                        .forward(request, response);

                return;
            }

            Booking booking =
                    bookingService.getBookingById(
                            bookingId);

            /*
             * Make sure the logged-in user can
             * view only their own booking.
             */
            Object userIdObject =
                    session.getAttribute("userId");

            if (userIdObject == null) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/login.jsp");

                return;
            }

            long loggedInUserId =
                    ((Number) userIdObject).longValue();

            if (booking.getUserId()
                    != loggedInUserId) {

                request.setAttribute(
                        "errorMessage",
                        "You are not authorized to view this booking.");

                request.getRequestDispatcher(
                        "/booking-history.jsp")
                        .forward(request, response);

                return;
            }

            List<BookingPassenger> passengers =
                    bookingPassengerService
                            .getPassengersByBooking(
                                    bookingId);

            request.setAttribute(
                    "booking",
                    booking);

            request.setAttribute(
                    "passengers",
                    passengers);

            request.getRequestDispatcher(
                    "/booking-details.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {

            request.setAttribute(
                    "errorMessage",
                    "Invalid booking ID.");

            request.getRequestDispatcher(
                    "/booking-history.jsp")
                    .forward(request, response);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "errorMessage",
                    "Unable to load booking details. "
                    + e.getMessage());

            request.getRequestDispatcher(
                    "/booking-history.jsp")
                    .forward(request, response);
        }
    }
}