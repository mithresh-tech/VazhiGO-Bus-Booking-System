package com.tnbus.controller;

import com.tnbus.dao.AdminRouteDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/admin/routes")
public class AdminRouteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AdminRouteDAO routeDAO;

    @Override
    public void init() {
        routeDAO = new AdminRouteDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
                session.getAttribute("loggedInAdmin") == null) {

            response.sendRedirect(
                request.getContextPath() + "/admin-login.jsp"
            );
            return;
        }

        response.setHeader(
            "Cache-Control",
            "no-store, no-cache, must-revalidate"
        );
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String routeId = trim(request.getParameter("routeId"));
        String source = trim(request.getParameter("source"));
        String destination = trim(request.getParameter("destination"));
        String status = trim(request.getParameter("status"));
        String details = trim(request.getParameter("details"));

        try {

            if (!routeId.isEmpty()) {
                validateId(routeId);
            }

            request.setAttribute(
                "routes",
                routeDAO.getRoutes(
                    routeId, source, destination, status
                )
            );

            request.setAttribute(
                "totalRoutes",
                routeDAO.getTotalRoutes()
            );

            request.setAttribute(
                "statuses",
                routeDAO.getStatuses()
            );

            if (!details.isEmpty()) {

                int id = validateId(details);

                MapResult result = new MapResult(
                    routeDAO.getRouteById(id)
                );

                if (result.value == null) {
                    request.setAttribute(
                        "errorMessage",
                        "Route not found."
                    );
                } else {
                    request.setAttribute(
                        "selectedRoute",
                        result.value
                    );
                }
            }

        } catch (NumberFormatException e) {

            request.setAttribute(
                "errorMessage",
                "Please enter a valid positive Route ID."
            );

        } catch (Exception e) {

            log("Admin Route Management error", e);

            request.setAttribute(
                "errorMessage",
                "Unable to load route information."
            );
        }

        request.getRequestDispatcher("/admin/routes.jsp")
               .forward(request, response);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private int validateId(String value) {

        if (!value.matches("[0-9]+")) {
            throw new NumberFormatException();
        }

        int id = Integer.parseInt(value);

        if (id <= 0) {
            throw new NumberFormatException();
        }

        return id;
    }

    private static class MapResult {

        private final java.util.Map<String, Object> value;

        private MapResult(java.util.Map<String, Object> value) {
            this.value = value;
        }
    }
}