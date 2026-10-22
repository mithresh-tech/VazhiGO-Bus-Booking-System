package com.tnbus.controller;

import com.tnbus.dao.AdminDashboardDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AdminDashboardDAO dashboardDAO;

    @Override
    public void init() {

        dashboardDAO = new AdminDashboardDAO();
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

        try {

            request.setAttribute(
                "dashboardSummary",
                dashboardDAO.getDashboardSummary()
            );

            request.setAttribute(
                "recentBookings",
                dashboardDAO.getRecentBookings()
            );

            request.setAttribute(
                "topRoutes",
                dashboardDAO.getTopRoutes()
            );

        } catch (Exception e) {

            log("Unable to load admin dashboard", e);

            request.setAttribute(
                "errorMessage",
                "Unable to load dashboard information."
            );
        }

        request.getRequestDispatcher("/admin/dashboard.jsp")
               .forward(request, response);
    }
}