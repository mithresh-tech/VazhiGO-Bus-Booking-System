package com.tnbus.controller;

import com.tnbus.dao.EmergencyRequestDAO;
import com.tnbus.model.EmergencyRequest;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

@WebServlet("/admin/emergencies")
public class AdminEmergencyServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private EmergencyRequestDAO emergencyDAO;

    @Override
    public void init() {
        emergencyDAO = new EmergencyRequestDAO();
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        return session != null
                && session.getAttribute("loggedInAdmin") != null;
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect(
                    request.getContextPath() + "/admin-login.jsp");
            return;
        }

        try {
            List<EmergencyRequest> emergencies =
                    emergencyDAO.getAllEmergencyRequests();

            int open = 0;
            int inProgress = 0;
            int resolved = 0;

            for (EmergencyRequest item : emergencies) {

                switch (item.getEmergencyStatus()) {
                    case "OPEN" -> open++;
                    case "IN_PROGRESS" -> inProgress++;
                    case "RESOLVED" -> resolved++;
                    default -> { }
                }
            }

            HttpSession session = request.getSession(false);

            String token = UUID.randomUUID().toString();
            session.setAttribute("adminSosToken", token);

            request.setAttribute("adminSosToken", token);
            request.setAttribute("emergencies", emergencies);
            request.setAttribute("openCount", open);
            request.setAttribute("progressCount", inProgress);
            request.setAttribute("resolvedCount", resolved);

            request.getRequestDispatcher(
                    "/admin/emergencies.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            log("Unable to load emergency requests", e);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load emergency requests.");
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        String suppliedToken = request.getParameter("csrfToken");
        boolean validToken;

        synchronized (session) {
            String expectedToken =
                    (String) session.getAttribute("adminSosToken");

            validToken = expectedToken != null
                    && expectedToken.equals(suppliedToken);

            if (validToken) {
                session.removeAttribute("adminSosToken");
            }
        }

        if (!validToken) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Invalid or expired form. Reload the dashboard.");
            return;
        }

        try {
            long emergencyId = Long.parseLong(
                    request.getParameter("emergencyId"));

            String status = request.getParameter("status");

            if (emergencyId <= 0
                    || !("OPEN".equals(status)
                    || "IN_PROGRESS".equals(status)
                    || "RESOLVED".equals(status))) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid emergency request.");
                return;
            }

            boolean updated =
                    emergencyDAO.updateEmergencyStatus(
                            emergencyId, status);

            if (!updated) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Emergency request not found.");
                return;
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/emergencies?updated=1");

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid emergency ID.");

        } catch (SQLException e) {

            log("Unable to update emergency status", e);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to update emergency status.");
        }
    }
}