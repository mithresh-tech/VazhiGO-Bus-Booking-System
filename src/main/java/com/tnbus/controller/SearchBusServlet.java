package com.tnbus.controller;

import com.tnbus.dao.BusSearchCardDAO;
import com.tnbus.dao.BusAmenityDAO;

import com.tnbus.model.BusSearchCard;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;

import java.util.List;
import java.util.Map;

@WebServlet("/searchBus")
public class SearchBusServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int CALENDAR_DAYS = 7;

    private BusSearchCardDAO busSearchCardDAO;

    private BusAmenityDAO busAmenityDAO;

    // =====================================================
    // INITIALISE DAO OBJECTS
    // =====================================================

    @Override
    public void init() {

        busSearchCardDAO = new BusSearchCardDAO();

        // STEP 20A - Initialise amenity DAO
        busAmenityDAO = new BusAmenityDAO();
    }

    // =====================================================
    // GET - DATE CALENDAR NAVIGATION
    // =====================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        processSearch(request, response);
    }

    // =====================================================
    // POST - ORIGINAL SEARCH FORM
    // =====================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        processSearch(request, response);
    }

    // =====================================================
    // COMMON SEARCH METHOD
    // =====================================================

    private void processSearch(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("loggedInUser") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");

            return;
        }

        try {

            // -----------------------------------------
            // Read search parameters
            // -----------------------------------------

            String sourceParam =
                    request.getParameter("sourceCityId");

            String destinationParam =
                    request.getParameter("destinationCityId");

            String dateParam =
                    request.getParameter("travelDate");

            String windowParam =
                    request.getParameter("windowStart");

            // -----------------------------------------
            // Validate required fields
            // -----------------------------------------

            if (sourceParam == null || sourceParam.isBlank()
                    || destinationParam == null
                    || destinationParam.isBlank()
                    || dateParam == null || dateParam.isBlank()) {

                throw new IllegalArgumentException(
                        "Please complete all search fields.");
            }

            int sourceCityId =
                    Integer.parseInt(sourceParam.trim());

            int destinationCityId =
                    Integer.parseInt(destinationParam.trim());

            LocalDate travelDate =
                    LocalDate.parse(dateParam.trim());

            LocalDate today = LocalDate.now();

            LocalDate maximumDate =
                    today.plusYears(1);

            if (sourceCityId <= 0
                    || destinationCityId <= 0) {

                throw new IllegalArgumentException(
                        "Please select valid cities.");
            }

            if (sourceCityId == destinationCityId) {

                throw new IllegalArgumentException(
                        "Source and destination cannot be the same.");
            }

            if (travelDate.isBefore(today)) {

                throw new IllegalArgumentException(
                        "Past journey dates are not allowed.");
            }

            if (travelDate.isAfter(maximumDate)) {

                throw new IllegalArgumentException(
                        "Please select a date within the next year.");
            }

            // -----------------------------------------
            // Determine calendar window
            // -----------------------------------------

            LocalDate windowStart = travelDate;

            if (windowParam != null
                    && !windowParam.isBlank()) {

                windowStart =
                        LocalDate.parse(windowParam.trim());
            }

            if (windowStart.isBefore(today)) {

                windowStart = today;
            }

            if (windowStart.isAfter(maximumDate)) {

                throw new IllegalArgumentException(
                        "Selected calendar range is invalid.");
            }

            // -----------------------------------------
            // Load date-wise availability
            // -----------------------------------------

            Map<LocalDate, Integer> dateAvailability =
                    busSearchCardDAO.getDateWiseAvailability(
                            sourceCityId,
                            destinationCityId,
                            windowStart,
                            CALENDAR_DAYS);

            // -----------------------------------------
            // Load buses for selected date
            // -----------------------------------------

            List<BusSearchCard> cards =
                    busSearchCardDAO.searchBusCards(
                            sourceCityId,
                            destinationCityId,
                            travelDate);

            // -----------------------------------------
            // STEP 20A - Load optional bus amenities
            // -----------------------------------------

            for (BusSearchCard card : cards) {

                try {

                    card.setAmenity(
                            busAmenityDAO.getAmenitiesByBusId(
                                    card.getBusId()));

                } catch (SQLException e) {

                    log(
                        "Unable to load amenities for bus ID: "
                                + card.getBusId(),
                        e
                    );

                    // Amenity failure must not stop bus search.
                    card.setAmenity(null);
                }
            }

            // -----------------------------------------
            // Calculate available bus count
            // -----------------------------------------

            int availableBusCount = 0;

            for (BusSearchCard card : cards) {

                if (card.getAvailableSeats() > 0) {

                    availableBusCount++;
                }
            }

            // -----------------------------------------
            // Set request attributes
            // -----------------------------------------

            request.setAttribute(
                    "busCards",
                    cards);

            request.setAttribute(
                    "dateAvailability",
                    dateAvailability);

            request.setAttribute(
                    "availableBusCount",
                    availableBusCount);

            request.setAttribute(
                    "sourceCityId",
                    sourceCityId);

            request.setAttribute(
                    "destinationCityId",
                    destinationCityId);

            request.setAttribute(
                    "travelDate",
                    travelDate);

            request.setAttribute(
                    "windowStart",
                    windowStart);

            request.setAttribute(
                    "today",
                    today);

            request.setAttribute(
                    "maximumDate",
                    maximumDate);

            // -----------------------------------------
            // Forward to results page
            // -----------------------------------------

            request.getRequestDispatcher(
                    "/search-results.jsp")
                    .forward(request, response);

        } catch (NumberFormatException
                 | DateTimeParseException e) {

            request.setAttribute(
                    "errorMessage",
                    "Invalid city or journey date.");

            request.getRequestDispatcher(
                    "/search.jsp")
                    .forward(request, response);

        } catch (IllegalArgumentException e) {

            request.setAttribute(
                    "errorMessage",
                    e.getMessage());

            request.getRequestDispatcher(
                    "/search.jsp")
                    .forward(request, response);

        } catch (Exception e) {

            log("Bus search failed", e);

            request.setAttribute(
                    "errorMessage",
                    "Unable to load bus availability. "
                    + "Please try again.");

            request.getRequestDispatcher(
                    "/search.jsp")
                    .forward(request, response);
        }
    }
}