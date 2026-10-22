package com.tnbus.controller;

import java.io.IOException;

import com.tnbus.model.User;
import com.tnbus.service.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserService userService = new UserService();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // Get form data
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");

        // Basic validation
        if (fullName == null || fullName.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {

            request.setAttribute(
                    "error",
                    "All fields are required."
            );

            request.getRequestDispatcher("/register.jsp")
                   .forward(request, response);

            return;
        }

        // Create User object
        User user = new User();

        user.setFullName(fullName.trim());
        user.setEmail(email.trim());
        user.setPhone(phone.trim());
        user.setPassword(password);
        user.setStatus("ACTIVE");

        try {

            // Save user into database
            boolean registered = userService.registerUser(user);

            if (registered) {

                // Registration successful
                response.sendRedirect(
                        request.getContextPath() + "/login.jsp"
                );

            } else {

                // Registration failed
                request.setAttribute(
                        "error",
                        "Registration failed. Email or phone may already exist."
                );

                request.getRequestDispatcher("/register.jsp")
                       .forward(request, response);
            }

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "error",
                    "Registration failed: " + e.getMessage()
            );

            request.getRequestDispatcher("/register.jsp")
                   .forward(request, response);
        }
    }
}