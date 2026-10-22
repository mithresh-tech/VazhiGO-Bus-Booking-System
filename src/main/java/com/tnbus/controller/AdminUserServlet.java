package com.tnbus.controller;

import com.tnbus.dao.AdminUserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AdminUserDAO adminUserDAO;

    @Override
    public void init() {
        adminUserDAO = new AdminUserDAO();
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

        String userId = trim(request.getParameter("userId"));
        String keyword = trim(request.getParameter("keyword"));
        String status = trim(request.getParameter("status"));
        String details = trim(request.getParameter("details"));

        try {

            if (!userId.isEmpty()) {
                validateId(userId);
            }

            request.setAttribute(
                "users",
                adminUserDAO.getUsers(userId, keyword, status)
            );

            request.setAttribute(
                "totalUsers",
                adminUserDAO.getTotalUsers()
            );

            request.setAttribute(
                "availableStatuses",
                adminUserDAO.getAvailableStatuses()
            );

            if (!details.isEmpty()) {

                long selectedId = validateId(details);

                request.setAttribute(
                    "selectedUser",
                    adminUserDAO.getUserById(selectedId)
                );
            }

        } catch (NumberFormatException e) {

            request.setAttribute(
                "errorMessage",
                "Please enter a valid positive User ID."
            );

        } catch (Exception e) {

            log("Admin User Management error", e);

            request.setAttribute(
                "errorMessage",
                "Unable to load user information."
            );
        }

        request.getRequestDispatcher("/admin/users.jsp")
               .forward(request, response);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private long validateId(String value) {

        if (!value.matches("[0-9]+")) {
            throw new NumberFormatException();
        }

        long id = Long.parseLong(value);

        if (id <= 0) {
            throw new NumberFormatException();
        }

        return id;
    }
}