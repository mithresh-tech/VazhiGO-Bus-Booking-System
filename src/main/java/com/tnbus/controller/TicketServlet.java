package com.tnbus.controller;

import java.io.IOException;

import com.tnbus.dao.TicketDAO;
import com.tnbus.model.TicketDetails;
import com.tnbus.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/viewTicket")
public class TicketServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private TicketDAO ticketDAO;

    @Override
    public void init() {

        ticketDAO = new TicketDAO();
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

            return;
        }

        try {

            TicketDetails ticket =
                    ticketDAO.getTicketDetails(
                            bookingId,
                            user.getUserId());

            if (ticket == null) {

                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Confirmed ticket not found or access denied.");

                return;
            }

            if (ticket.getPassengers() == null
                    || ticket.getPassengers().isEmpty()) {

                response.sendError(
                        HttpServletResponse.SC_CONFLICT,
                        "Passenger details are unavailable.");

                return;
            }

            request.setAttribute("ticket", ticket);

            request.getRequestDispatcher("/ticket.jsp")
                    .forward(request, response);

        } catch (Exception e) {

            log("Ticket generation failed for booking: "
                    + bookingId, e);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to generate ticket.");
        }
    }
}