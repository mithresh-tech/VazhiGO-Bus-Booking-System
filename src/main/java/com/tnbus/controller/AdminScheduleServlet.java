package com.tnbus.controller;

import com.tnbus.model.BusSchedule;
import com.tnbus.service.BusScheduleService;
import com.tnbus.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet("/admin/schedules")
public class AdminScheduleServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BusScheduleService scheduleService;

    @Override
    public void init() {
        scheduleService = new BusScheduleService();
    }

    // ==========================================
    // ADMIN AUTHENTICATION
    // ==========================================

    private HttpSession adminSession(
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

    // ==========================================
    // GET - DISPLAY SCHEDULES
    // ==========================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = adminSession(request, response);

        if (session == null) {
            return;
        }

        try {

            List<BusSchedule> schedules =
                    scheduleService.getAllSchedules();

            int scheduled = 0;
            int cancelled = 0;

            for (BusSchedule item : schedules) {

                if ("SCHEDULED".equalsIgnoreCase(item.getStatus())) {
                    scheduled++;

                } else if ("CANCELLED".equalsIgnoreCase(item.getStatus())) {
                    cancelled++;
                }
            }

            request.setAttribute("schedules", schedules);
            request.setAttribute("totalSchedules", schedules.size());
            request.setAttribute("scheduledCount", scheduled);
            request.setAttribute("cancelledCount", cancelled);

            // Each bus option contains:
            // [0] bus_id
            // [1] dropdown display text
            // [2] actual bus_number

            List<String[]> busOptions = loadBusOptions();

            request.setAttribute("busOptions", busOptions);
            request.setAttribute("routeOptions", loadRouteOptions());

            // Map database bus_id to actual vehicle bus_number.
            // This is used ONLY to display and search registration numbers.

            Map<Integer, String> busNumberMap = new HashMap<>();

            for (String[] bus : busOptions) {

                busNumberMap.put(
                        Integer.parseInt(bus[0]),
                        bus[2]
                );
            }

            request.setAttribute("busNumberMap", busNumberMap);

            String token = UUID.randomUUID().toString();

            session.setAttribute("adminScheduleToken", token);
            request.setAttribute("csrfToken", token);

            request.setAttribute(
                    "successMessage",
                    session.getAttribute("scheduleSuccess"));

            request.setAttribute(
                    "errorMessage",
                    session.getAttribute("scheduleError"));

            session.removeAttribute("scheduleSuccess");
            session.removeAttribute("scheduleError");

            request.getRequestDispatcher("/admin/schedules.jsp")
                    .forward(request, response);

        } catch (SQLException e) {

            log("Unable to load admin schedules", e);

            throw new ServletException(
                    "Unable to load schedule management.", e);
        }
    }

    // ==========================================
    // POST - ADMIN ACTIONS
    // ==========================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = adminSession(request, response);

        if (session == null) {
            return;
        }

        String submittedToken = request.getParameter("csrfToken");

        String savedToken =
                (String) session.getAttribute("adminScheduleToken");

        if (submittedToken == null
                || savedToken == null
                || !savedToken.equals(submittedToken)) {

            session.setAttribute(
                    "scheduleError",
                    "Invalid or expired request. Please refresh and retry.");

            redirect(request, response);
            return;
        }

        // Prevent replaying the same form submission.
        session.removeAttribute("adminScheduleToken");

        String action = request.getParameter("action");

        try {

            if ("add".equals(action)) {

                BusSchedule schedule = readSchedule(request);

                boolean added =
                        scheduleService.addAdminSchedule(schedule);

                if (added) {

                    session.setAttribute(
                            "scheduleSuccess",
                            "New schedule created successfully.");

                } else {

                    session.setAttribute(
                            "scheduleError",
                            "Unable to create schedule.");
                }

            } else if ("edit".equals(action)) {

                BusSchedule schedule = readSchedule(request);

                schedule.setScheduleId(
                        Integer.parseInt(
                                request.getParameter("scheduleId")));

                boolean updated =
                        scheduleService.updateAdminScheduleSafely(schedule);

                if (updated) {

                    session.setAttribute(
                            "scheduleSuccess",
                            "Schedule updated successfully.");

                } else {

                    session.setAttribute(
                            "scheduleError",
                            "Schedule could not be updated. It may have booking history.");
                }

            } else if ("cancel".equals(action)) {

                int scheduleId =
                        Integer.parseInt(
                                request.getParameter("scheduleId"));

                boolean cancelled =
                        scheduleService.cancelAdminSchedule(scheduleId);

                if (cancelled) {

                    session.setAttribute(
                            "scheduleSuccess",
                            "Schedule cancelled successfully.");

                } else {

                    session.setAttribute(
                            "scheduleError",
                            "Schedule cancellation was blocked.");
                }

            } else {

                throw new IllegalArgumentException(
                        "Invalid schedule action.");
            }

        } catch (IllegalArgumentException e) {

            session.setAttribute("scheduleError", e.getMessage());

        } catch (SQLException e) {

            log("Admin schedule database operation failed", e);

            session.setAttribute(
                    "scheduleError",
                    "Database operation failed. Please check the server logs.");

        } catch (Exception e) {

            log("Admin schedule operation failed", e);

            session.setAttribute(
                    "scheduleError",
                    "Unable to complete the requested action.");
        }

        redirect(request, response);
    }

    // ==========================================
    // READ FORM DATA
    // ==========================================

    private BusSchedule readSchedule(HttpServletRequest request) {

        BusSchedule schedule = new BusSchedule();

        schedule.setBusId(
                Integer.parseInt(request.getParameter("busId")));

        schedule.setRouteId(
                Integer.parseInt(request.getParameter("routeId")));

        schedule.setTravelDate(
                LocalDate.parse(request.getParameter("travelDate")));

        schedule.setDepartureTime(
                LocalTime.parse(request.getParameter("departureTime")));

        schedule.setArrivalTime(
                LocalTime.parse(request.getParameter("arrivalTime")));

        schedule.setFare(
                requiredAmount(request.getParameter("fare")));

        schedule.setUpperDeckFare(
                optionalAmount(request.getParameter("upperDeckFare")));

        schedule.setLowerDeckFare(
                optionalAmount(request.getParameter("lowerDeckFare")));

        schedule.setDoubleUpperFare(
                optionalAmount(request.getParameter("doubleUpperFare")));

        schedule.setDoubleLowerFare(
                optionalAmount(request.getParameter("doubleLowerFare")));

        schedule.setSingleUpperFare(
                optionalAmount(request.getParameter("singleUpperFare")));

        schedule.setSingleLowerFare(
                optionalAmount(request.getParameter("singleLowerFare")));

        schedule.setSeaterFare(
                optionalAmount(request.getParameter("seaterFare")));

        schedule.setStatus("SCHEDULED");

        return schedule;
    }

    private BigDecimal requiredAmount(String value) {

        if (value == null || value.isBlank()) {

            throw new IllegalArgumentException(
                    "Base fare is required.");
        }

        return new BigDecimal(value.trim());
    }

    private BigDecimal optionalAmount(String value) {

        if (value == null || value.isBlank()) {
            return null;
        }

        return new BigDecimal(value.trim());
    }

    // ==========================================
    // BUS DROPDOWN + ACTUAL BUS NUMBER
    // ==========================================

    private List<String[]> loadBusOptions() throws SQLException {

        List<String[]> options = new ArrayList<>();

        String sql = """
                SELECT bus_id, bus_number, bus_name, status
                FROM bus
                ORDER BY bus_name, bus_number
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {

            while (rs.next()) {

                String busNumber = rs.getString("bus_number");

                options.add(new String[] {

                        String.valueOf(rs.getInt("bus_id")),

                        busNumber
                            + " - " + rs.getString("bus_name")
                            + " (" + rs.getString("status") + ")",

                        busNumber
                });
            }
        }

        return options;
    }

    // ==========================================
    // ROUTE DROPDOWN - UNCHANGED
    // ==========================================

    private List<String[]> loadRouteOptions() throws SQLException {

        List<String[]> options = new ArrayList<>();

        String sql = """
                SELECT
                    r.route_id,
                    sc.city_name AS source_name,
                    dc.city_name AS destination_name,
                    r.status
                FROM route r
                JOIN city sc
                  ON sc.city_id = r.source_city_id
                JOIN city dc
                  ON dc.city_id = r.destination_city_id
                ORDER BY sc.city_name, dc.city_name
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {

            while (rs.next()) {

                options.add(new String[] {

                        String.valueOf(rs.getInt("route_id")),

                        rs.getString("source_name")
                            + " → "
                            + rs.getString("destination_name")
                            + " (" + rs.getString("status") + ")"
                });
            }
        }

        return options;
    }

    private void redirect(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        response.sendRedirect(
                request.getContextPath() + "/admin/schedules");
    }
}