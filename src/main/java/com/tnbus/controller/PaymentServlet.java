package com.tnbus.controller;

import java.io.IOException;

import com.tnbus.model.Booking;
import com.tnbus.model.Payment;
import com.tnbus.model.User;

import com.tnbus.service.BookingService;
import com.tnbus.service.PaymentService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/payment")
public class PaymentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private PaymentService paymentService;
    private BookingService bookingService;

    @Override
    public void init() {

        paymentService = new PaymentService();
        bookingService = new BookingService();
    }

    @Override
    protected void doGet(
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

        User user =
                (User) session.getAttribute("loggedInUser");

        try {

            long bookingId = Long.parseLong(
                    request.getParameter("bookingId"));

            Booking booking =
                    bookingService.getBookingById(bookingId);

            if (booking == null) {

                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Booking not found.");

                return;
            }

            if (booking.getUserId() != user.getUserId()) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Access denied.");

                return;
            }

            if (!"PENDING".equalsIgnoreCase(
                    booking.getBookingStatus())
                    || !"PENDING".equalsIgnoreCase(
                            booking.getPaymentStatus())) {

                response.sendRedirect(
                        request.getContextPath() + "/myBookings");

                return;
            }

            Payment existingPayment =
                    paymentService.getPaymentByBookingId(bookingId);

            if (existingPayment != null) {

                response.sendRedirect(
                        request.getContextPath() + "/myBookings");

                return;
            }

            request.setAttribute("booking", booking);

            request.getRequestDispatcher("/payment.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid booking ID.");

        } catch (Exception e) {

            log("Unable to load payment page", e);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load payment details.");
        }
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

        User user =
                (User) session.getAttribute("loggedInUser");

        long bookingId;

        try {

            bookingId = Long.parseLong(
                    request.getParameter("bookingId"));

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid booking ID.");

            return;
        }

        try {

            String paymentMethod =
                    request.getParameter("paymentMethod");

            boolean success =
                    paymentService.processPayment(
                            bookingId,
                            user.getUserId(),
                            paymentMethod);

            if (success) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/payment-success.jsp?bookingId="
                        + bookingId);

            } else {

                request.setAttribute(
                        "errorMessage",
                        "Payment could not be processed. "
                        + "Please check the booking and payment method.");

                doGet(request, response);
            }

        } catch (Exception e) {

            log("Payment processing failed", e);

            request.setAttribute(
                    "errorMessage",
                    "Unable to process payment. Please try again.");

            doGet(request, response);
        }
    }
}