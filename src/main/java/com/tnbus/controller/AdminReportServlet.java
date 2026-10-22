package com.tnbus.controller;

import com.tnbus.dao.AdminReportDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

@WebServlet("/admin/reports")
public class AdminReportServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AdminReportDAO reportDAO;

    @Override
    public void init() {
        reportDAO = new AdminReportDAO();
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

        LocalDate today = LocalDate.now();

        LocalDate from = today.withDayOfMonth(1);
        LocalDate to = today;

        try {

            String fromParam = request.getParameter("from");
            String toParam = request.getParameter("to");

            if (fromParam != null && !fromParam.isBlank()) {
                from = LocalDate.parse(fromParam);
            }

            if (toParam != null && !toParam.isBlank()) {
                to = LocalDate.parse(toParam);
            }

            if (from.isAfter(to)) {
                throw new IllegalArgumentException(
                    "From Date cannot be later than To Date."
                );
            }

            if (to.isAfter(today)) {
                throw new IllegalArgumentException(
                    "To Date cannot be in the future."
                );
            }

            if (from.isBefore(today.minusYears(10))) {
                throw new IllegalArgumentException(
                    "Please select a date within the last 10 years."
                );
            }

            request.setAttribute(
                "summary",
                reportDAO.getSummary(from, to)
            );

            request.setAttribute(
                "bookingStatuses",
                reportDAO.getBookingStatusReport(from, to)
            );

            request.setAttribute(
                "paymentStatuses",
                reportDAO.getPaymentStatusReport(from, to)
            );

            request.setAttribute(
                "routeReports",
                reportDAO.getRouteReport(from, to)
            );

            request.setAttribute(
                "dailyReports",
                reportDAO.getDailyReport(from, to)
            );

        } catch (DateTimeParseException e) {

            request.setAttribute(
                "errorMessage",
                "Invalid date format. Please select valid dates."
            );

        } catch (IllegalArgumentException e) {

            request.setAttribute(
                "errorMessage",
                e.getMessage()
            );

        } catch (Exception e) {

            log("Admin Reports error", e);

            request.setAttribute(
                "errorMessage",
                "Unable to load report information."
            );
        }

        request.setAttribute("fromDate", from.toString());
        request.setAttribute("toDate", to.toString());

        request.getRequestDispatcher("/admin/reports.jsp")
               .forward(request, response);
    }
}