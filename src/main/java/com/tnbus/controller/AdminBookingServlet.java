package com.tnbus.controller;

import com.tnbus.dao.AdminBookingDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.*;

@WebServlet("/admin/bookings")
public class AdminBookingServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AdminBookingDAO bookingDAO;

    @Override
    public void init() {
        bookingDAO = new AdminBookingDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("loggedInAdmin") == null) {

            response.sendRedirect(
                request.getContextPath() + "/admin-login.jsp"
            );
            return;
        }

        try {

            List<Map<String, Object>> allBookings =
                    bookingDAO.getAllBookings();

            String bookingId = trim(request.getParameter("bookingId"));
            String userId = trim(request.getParameter("userId"));
            String scheduleId = trim(request.getParameter("scheduleId"));

            String bookingStatus =
                    trim(request.getParameter("bookingStatus"));

            String paymentStatus =
                    trim(request.getParameter("paymentStatus"));

            List<Map<String, Object>> filtered = new ArrayList<>();

            for (Map<String, Object> booking : allBookings) {

                if (!matchesId(booking.get("booking_id"), bookingId)
                        || !matchesId(booking.get("user_id"), userId)
                        || !matchesId(booking.get("schedule_id"), scheduleId)) {
                    continue;
                }

                if (!bookingStatus.isEmpty()
                        && !bookingStatus.equalsIgnoreCase(
                            String.valueOf(booking.get("booking_status")))) {
                    continue;
                }

                if (!paymentStatus.isEmpty()
                        && !paymentStatus.equalsIgnoreCase(
                            String.valueOf(booking.get("payment_status")))) {
                    continue;
                }

                filtered.add(booking);
            }

            request.setAttribute("bookings", filtered);
            request.setAttribute("totalBookings", allBookings.size());

            String detailsId = trim(request.getParameter("details"));

            if (!detailsId.isEmpty()) {

                try {

                    long id = Long.parseLong(detailsId);

                    if (id <= 0) {
                        throw new NumberFormatException();
                    }

                    Map<String, Object> selected = null;

                    for (Map<String, Object> booking : allBookings) {

                        if (Long.parseLong(
                                booking.get("booking_id").toString()) == id) {

                            selected = booking;
                            break;
                        }
                    }

                    if (selected != null) {

                        request.setAttribute("selectedBooking", selected);

                        request.setAttribute(
                            "bookingDetails",
                            bookingDAO.getBookingDetails(id)
                        );

                    } else {

                        request.setAttribute(
                            "errorMessage",
                            "Booking not found."
                        );
                    }

                } catch (NumberFormatException e) {

                    request.setAttribute(
                        "errorMessage",
                        "Invalid booking ID."
                    );
                }
            }

        } catch (Exception e) {

            log("Unable to load admin bookings", e);

            request.setAttribute(
                "errorMessage",
                "Unable to load booking information."
            );
        }

        request.getRequestDispatcher("/admin/bookings.jsp")
               .forward(request, response);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean matchesId(Object actual, String search) {

        if (search.isEmpty()) {
            return true;
        }

        if (!search.matches("[0-9]+")) {
            return false;
        }

        try {
            return Long.parseLong(search)
                    == Long.parseLong(String.valueOf(actual));

        } catch (NumberFormatException e) {
            return false;
        }
    }
}