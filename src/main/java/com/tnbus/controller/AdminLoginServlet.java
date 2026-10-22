package com.tnbus.controller;

import com.tnbus.model.Admin;
import com.tnbus.service.AdminService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/adminLogin")
public class AdminLoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AdminService adminService;

    @Override
    public void init() {
        adminService = new AdminService();
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String email =
                request.getParameter("email");

        String password =
                request.getParameter("password");

        try {

            Admin admin =
                    adminService.loginAdmin(
                            email,
                            password);

            HttpSession session =
                    request.getSession();

            session.setAttribute(
                    "loggedInAdmin",
                    admin);

            session.setAttribute(
                    "adminId",
                    admin.getAdminId());

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/dashboard");

        } catch (Exception e) {

            request.setAttribute(
                    "errorMessage",
                    e.getMessage());

            request.getRequestDispatcher(
                    "/admin-login.jsp")
                    .forward(request, response);
        }
    }
}