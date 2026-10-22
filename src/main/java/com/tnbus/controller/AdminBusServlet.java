package com.tnbus.controller;

import com.tnbus.model.Bus;
import com.tnbus.service.BusService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

@WebServlet("/admin/buses")
public class AdminBusServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BusService busService;

    @Override
    public void init() {
        busService = new BusService();
    }

    private HttpSession getAdminSession(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("loggedInAdmin") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/admin-login.jsp");

            return null;
        }

        return session;
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                getAdminSession(request, response);

        if (session == null) {
            return;
        }

        try {

            List<Bus> buses = busService.getAllBuses();

            int active = 0;
            int inactive = 0;

            for (Bus bus : buses) {

                if ("ACTIVE".equalsIgnoreCase(bus.getStatus())) {
                    active++;
                } else {
                    inactive++;
                }
            }

            String token = UUID.randomUUID().toString();

            session.setAttribute("adminBusToken", token);

            request.setAttribute("csrfToken", token);
            request.setAttribute("buses", buses);

            request.setAttribute("totalBuses", buses.size());
            request.setAttribute("activeBuses", active);
            request.setAttribute("inactiveBuses", inactive);

            String message =
                    (String) session.getAttribute("busSuccessMessage");

            String error =
                    (String) session.getAttribute("busErrorMessage");

            session.removeAttribute("busSuccessMessage");
            session.removeAttribute("busErrorMessage");

            request.setAttribute("successMessage", message);
            request.setAttribute("errorMessage", error);

            request.getRequestDispatcher("/admin/buses.jsp")
                    .forward(request, response);

        } catch (SQLException e) {

            throw new ServletException(
                    "Unable to load bus management.", e);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session =
                getAdminSession(request, response);

        if (session == null) {
            return;
        }

        String submittedToken =
                request.getParameter("csrfToken");

        String savedToken =
                (String) session.getAttribute("adminBusToken");

        if (savedToken == null
                || submittedToken == null
                || !savedToken.equals(submittedToken)) {

            session.setAttribute(
                    "busErrorMessage",
                    "Invalid or expired request. Please try again.");

            redirect(request, response);
            return;
        }

        // Single-use form token.
        session.removeAttribute("adminBusToken");

        String action = request.getParameter("action");

        try {

            if ("add".equals(action)) {

                Bus bus = readBus(request);

                bus.setTotalSeats(
                        Integer.parseInt(
                                request.getParameter("totalSeats")));

                boolean added = busService.addAdminBus(bus);

                session.setAttribute(
                        "busSuccessMessage",
                        added
                            ? "New bus added successfully. Configure its seats before activation."
                            : "Unable to add bus.");

            } else if ("edit".equals(action)) {

                Bus bus = readBus(request);

                bus.setBusId(
                        Integer.parseInt(
                                request.getParameter("busId")));

                boolean updated =
                        busService.updateAdminBusDetails(bus);

                session.setAttribute(
                        "busSuccessMessage",
                        updated
                            ? "Bus details updated successfully."
                            : "No changes were made.");

            } else if ("status".equals(action)) {

                int busId = Integer.parseInt(
                        request.getParameter("busId"));

                String status =
                        request.getParameter("status");

                boolean updated =
                        busService.updateAdminBusStatus(
                                busId, status);

                session.setAttribute(
                        "busSuccessMessage",
                        updated
                            ? "Bus status updated successfully."
                            : "Bus status could not be updated. Please refresh and retry.");

            } else {

                throw new IllegalArgumentException(
                        "Invalid management action.");
            }

        } catch (NumberFormatException e) {

            session.setAttribute(
                    "busErrorMessage",
                    "Please enter valid numeric values.");

        } catch (IllegalArgumentException e) {

            session.setAttribute(
                    "busErrorMessage",
                    e.getMessage());

        } catch (SQLException e) {

            if (e.getErrorCode() == 1062) {

                session.setAttribute(
                        "busErrorMessage",
                        "This bus number already exists.");

            } else {

                log("Admin bus operation failed", e);

                session.setAttribute(
                        "busErrorMessage",
                        "Database operation failed. Please check the server logs.");
            }

        } catch (Exception e) {

            log("Admin bus operation failed", e);

            session.setAttribute(
                    "busErrorMessage",
                    "Unable to complete the requested operation.");
        }

        redirect(request, response);
    }

    private Bus readBus(HttpServletRequest request) {

        Bus bus = new Bus();

        bus.setBusNumber(
                trim(request.getParameter("busNumber")));

        bus.setBusName(
                trim(request.getParameter("busName")));

        bus.setBusType(
                trim(request.getParameter("busType")));

        return bus;
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private void redirect(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        response.sendRedirect(
                request.getContextPath() + "/admin/buses");
    }
}