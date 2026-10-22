package com.tnbus.controller;

import com.tnbus.model.User;
import com.tnbus.service.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserService userService;

    @Override
    public void init() {
        userService = new UserService();
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            User user = userService.loginUser(email, password);

            HttpSession session = request.getSession();
            session.setAttribute("loggedInUser", user);
            session.setAttribute("userId", user.getUserId());

            response.sendRedirect(
                    request.getContextPath() + "/home.jsp");

        } catch (Exception e) {

            request.setAttribute(
                    "errorMessage",
                    e.getMessage());

            request.getRequestDispatcher(
                    "/login.jsp").forward(request, response);
        }
    }
}