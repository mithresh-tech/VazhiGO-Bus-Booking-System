package com.tnbus.controller;

import com.tnbus.dao.BookingDAO;
import com.tnbus.dao.EmergencyRequestDAO;

import com.tnbus.model.Booking;
import com.tnbus.model.EmergencyRequest;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;

@WebServlet("/emergencySOS")
public class EmergencySOSServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookingDAO bookingDAO;
    private EmergencyRequestDAO emergencyDAO;

    @Override
    public void init() {

        bookingDAO = new BookingDAO();
        emergencyDAO = new EmergencyRequestDAO();
    }

    private boolean validType(String type) {

        return "MEDICAL".equals(type)
                || "SAFETY".equals(type)
                || "BREAKDOWN".equals(type)
                || "OTHER".equals(type);
    }

    private Booking verifyBooking(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException, SQLException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("loggedInUser") == null
                || !(session.getAttribute("userId") instanceof Number)) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");

            return null;
        }

        long bookingId;

        try {

            bookingId = Long.parseLong(
                    request.getParameter("bookingId"));

            if (bookingId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid booking ID.");

            return null;
        }

        long userId = ((Number)
                session.getAttribute("userId")).longValue();

        Booking booking = bookingDAO.getBookingById(bookingId);

        if (booking == null || booking.getUserId() != userId) {

            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Booking not found.");

            return null;
        }

        if (!"CONFIRMED".equalsIgnoreCase(
                booking.getBookingStatus())
                || !"PAID".equalsIgnoreCase(
                        booking.getPaymentStatus())) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "SOS requests require a confirmed, paid booking.");

            return null;
        }

        return booking;
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {

            Booking booking = verifyBooking(request, response);

            if (booking == null) {
                return;
            }

            HttpSession session = request.getSession(false);

            String token = UUID.randomUUID().toString();

            session.setAttribute(
                    "sosToken_" + booking.getBookingId(), token);

            request.setAttribute("sosToken", token);
            request.setAttribute("booking", booking);

            request.setAttribute(
                    "emergencyRequests",
                    emergencyDAO.getRequestsByBookingId(
                            booking.getBookingId()));

            String successId = request.getParameter("success");

            if (successId != null) {

                try {

                    long reference = Long.parseLong(successId);

                    boolean belongsToBooking = false;

                    for (EmergencyRequest item :
                            emergencyDAO.getRequestsByBookingId(
                                    booking.getBookingId())) {

                        if (item.getEmergencyId() == reference) {
                            belongsToBooking = true;
                            break;
                        }
                    }

                    if (belongsToBooking) {
                        request.setAttribute(
                                "successReference", reference);
                    }

                } catch (NumberFormatException ignored) {
                    // Ignore invalid success reference.
                }
            }

            request.getRequestDispatcher("/emergency-sos.jsp")
                    .forward(request, response);

        } catch (SQLException e) {

            log("Unable to load SOS page", e);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load SOS page.");
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {

            Booking booking = verifyBooking(request, response);

            if (booking == null) {
                return;
            }

            HttpSession session = request.getSession(false);

            String tokenKey =
                    "sosToken_" + booking.getBookingId();

            String submittedToken =
                    request.getParameter("sosToken");

            String expectedToken;

            // Consume the token once to prevent duplicate submissions.
            synchronized (session) {

                expectedToken =
                        (String) session.getAttribute(tokenKey);

                if (expectedToken != null
                        && expectedToken.equals(submittedToken)) {

                    session.removeAttribute(tokenKey);

                } else {

                    expectedToken = null;
                }
            }

            if (expectedToken == null) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Invalid or expired SOS form. Please reopen the form.");

                return;
            }

            String type = request.getParameter("emergencyType");
            String description = request.getParameter("description");

            if (description != null) {
                description = description.trim();
            }

            if (!validType(type)
                    || description == null
                    || description.isBlank()
                    || description.length() > 500) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Select a valid type and enter a description "
                        + "between 1 and 500 characters.");

                return;
            }

            EmergencyRequest emergency = new EmergencyRequest();

            emergency.setBookingId(booking.getBookingId());
            emergency.setEmergencyType(type);
            emergency.setDescription(description);
            emergency.setEmergencyStatus("OPEN");

            long emergencyId =
                    emergencyDAO.createEmergencyRequest(emergency);

            response.sendRedirect(
                    request.getContextPath()
                    + "/emergencySOS?bookingId="
                    + booking.getBookingId()
                    + "&success=" + emergencyId);

        } catch (SQLException e) {

            log("Unable to submit SOS request", e);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to record SOS request.");
        }
    }
}