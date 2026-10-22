package com.tnbus.controller;

import java.io.IOException;

import com.tnbus.model.Booking;
import com.tnbus.model.Cancellation;
import com.tnbus.model.User;

import com.tnbus.service.BookingService;
import com.tnbus.service.CancellationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cancelBooking")
public class CancellationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private CancellationService cancellationService;
    private BookingService bookingService;

    @Override
    public void init() {

        cancellationService = new CancellationService();
        bookingService = new BookingService();
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || !(session.getAttribute("loggedInUser") instanceof User)) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");

            return;
        }

        User loggedInUser =
                (User) session.getAttribute("loggedInUser");

        String bookingIdParameter =
                request.getParameter("bookingId");

        String reason =
                request.getParameter("reason");

        long bookingId;

        try {

            bookingId = Long.parseLong(bookingIdParameter);

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid booking ID.");

            return;
        }

        try {

            Booking booking =
                    bookingService.getBookingById(bookingId);

            if (booking == null) {

                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Booking not found.");

                return;
            }

            // Ensure this booking belongs to the logged-in user
            if (booking.getUserId() != loggedInUser.getUserId()) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "You cannot cancel another user's booking.");

                return;
            }

            if ("CANCELLED".equalsIgnoreCase(
                    booking.getBookingStatus())) {

                showError(
                        request,
                        response,
                        bookingId,
                        "This booking is already cancelled.");

                return;
            }

            if (reason == null || reason.isBlank()
                    || reason.trim().length() > 255) {

                showError(
                        request,
                        response,
                        bookingId,
                        "Please enter a valid cancellation reason.");

                return;
            }

            Cancellation existingCancellation =
                    cancellationService
                            .getCancellationByBookingId(bookingId);

            if (existingCancellation != null) {

                showError(
                        request,
                        response,
                        bookingId,
                        "A cancellation request already exists for this booking.");

                return;
            }

            Cancellation cancellation = new Cancellation();

            cancellation.setBookingId(bookingId);
            cancellation.setReason(reason.trim());
            cancellation.setCancellationStatus("REQUESTED");

            boolean result =
                    cancellationService.addCancellation(cancellation);

            if (result) {

                response.sendRedirect(
                        request.getContextPath() + "/myBookings");

            } else {

                showError(
                        request,
                        response,
                        bookingId,
                        "Cancellation could not be completed. "
                        + "The booking may already have a cancellation request.");
            }

        } catch (Exception e) {

            log("Cancellation failed for booking ID: " + bookingId, e);

            showError(
                    request,
                    response,
                    bookingId,
                    "Unable to process cancellation. Please try again.");
        }
    }

    private void showError(
            HttpServletRequest request,
            HttpServletResponse response,
            long bookingId,
            String message)
            throws ServletException, IOException {

        request.setAttribute("errorMessage", message);

        request.getRequestDispatcher(
                "/cancel-booking.jsp?bookingId=" + bookingId)
                .forward(request, response);
    }
}