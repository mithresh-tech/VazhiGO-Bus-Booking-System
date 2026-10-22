<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.tnbus.model.BusSearchCard" %>
<%@ page import="com.tnbus.model.BusAmenity" %>

<%!
    private String escapeHtml(String value) {

        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%

if (session.getAttribute("loggedInUser") == null) {

    response.sendRedirect(
            request.getContextPath() + "/login.jsp");

    return;
}

String ctx = request.getContextPath();

@SuppressWarnings("unchecked")
List<BusSearchCard> busCards =
        (List<BusSearchCard>)
        request.getAttribute("busCards");

@SuppressWarnings("unchecked")
Map<LocalDate, Integer> dateAvailability =
        (Map<LocalDate, Integer>)
        request.getAttribute("dateAvailability");

LocalDate travelDate =
        (LocalDate) request.getAttribute("travelDate");

LocalDate windowStart =
        (LocalDate) request.getAttribute("windowStart");

LocalDate today =
        (LocalDate) request.getAttribute("today");

LocalDate maximumDate =
        (LocalDate) request.getAttribute("maximumDate");

Integer sourceCityId =
        (Integer) request.getAttribute("sourceCityId");

Integer destinationCityId =
        (Integer) request.getAttribute("destinationCityId");

Integer availableBusCount =
        (Integer) request.getAttribute("availableBusCount");

if (busCards == null
        || dateAvailability == null
        || travelDate == null
        || windowStart == null
        || today == null
        || maximumDate == null
        || sourceCityId == null
        || destinationCityId == null
        || availableBusCount == null) {

    response.sendRedirect(ctx + "/search.jsp");
    return;
}

DateTimeFormatter dayFormatter =
        DateTimeFormatter.ofPattern("EEE", Locale.ENGLISH);

DateTimeFormatter dateFormatter =
        DateTimeFormatter.ofPattern("dd MMM", Locale.ENGLISH);

DateTimeFormatter fullDateFormatter =
        DateTimeFormatter.ofPattern("dd MMMM yyyy", Locale.ENGLISH);

DateTimeFormatter timeFormatter =
        DateTimeFormatter.ofPattern("hh:mm a", Locale.ENGLISH);

LocalDate previousWindow = windowStart.minusDays(7);

if (previousWindow.isBefore(today)) {
    previousWindow = today;
}

LocalDate nextWindow = windowStart.plusDays(7);

boolean canGoPrevious = windowStart.isAfter(today);

boolean canGoNext =
        !nextWindow.isAfter(maximumDate);

String baseQuery =
        ctx
        + "/searchBus?sourceCityId="
        + sourceCityId
        + "&destinationCityId="
        + destinationCityId;

String previousUrl =
        baseQuery
        + "&travelDate="
        + previousWindow
        + "&windowStart="
        + previousWindow;

String nextUrl =
        baseQuery
        + "&travelDate="
        + nextWindow
        + "&windowStart="
        + nextWindow;

String routeName = "Your selected route";

if (!busCards.isEmpty()) {

    BusSearchCard firstBus = busCards.get(0);

    routeName =
            firstBus.getSourceCity()
            + " → "
            + firstBus.getDestinationCity();
}

%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Available Buses | VazhiGo</title>

<style>

:root {
    --navy: #102A43;
    --navy-dark: #081D32;
    --coral: #FF6B57;
    --teal: #14B8A6;
    --background: #F7F9FC;
    --white: #FFFFFF;
    --text: #243447;
    --muted: #65758B;
    --border: #E3EAF1;
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: var(--background);
    color: var(--text);
}

a {
    text-decoration: none;
}

button,
input,
select {
    font: inherit;
}

.container {
    width: 1160px;
    max-width: 92%;
    margin: auto;
}

/* NAVIGATION */

.navbar {
    background: white;
    border-bottom: 1px solid var(--border);
}

.nav-inner {
    min-height: 78px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
}

.logo {
    font-size: 27px;
    font-weight: 900;
    letter-spacing: -1px;
    color: var(--navy);
}

.logo span {
    color: var(--coral);
}

.nav-links {
    display: flex;
    gap: 25px;
    align-items: center;
    flex-wrap: wrap;
}

.nav-links a {
    color: var(--navy);
    font-size: 14px;
    font-weight: bold;
}

.nav-links a:hover {
    color: var(--coral);
}

/* PAGE HERO */

.results-hero {
    background:
        radial-gradient(
            circle at 90% 20%,
            rgba(20,184,166,0.20),
            transparent 35%
        ),
        linear-gradient(120deg, #081D32, #123B60);

    padding: 58px 0 80px;
    color: white;
}

.eyebrow {
    font-size: 12px;
    font-weight: bold;
    letter-spacing: 2px;
    color: #77E6D8;
    text-transform: uppercase;
}

.results-hero h1 {
    font-size: clamp(32px, 5vw, 45px);
    margin: 15px 0;
    letter-spacing: -1px;
}

.results-hero p {
    color: #C5D6E7;
    line-height: 1.7;
}

.count-banner {
    display: inline-flex;
    align-items: center;
    gap: 12px;
    margin-top: 14px;
    padding: 13px 19px;
    background: rgba(255,255,255,0.11);
    border: 1px solid rgba(255,255,255,0.18);
    border-radius: 11px;
}

.count-banner strong {
    color: #77E6D8;
    font-size: 24px;
}

/* CALENDAR */

.calendar-section {
    position: relative;
    margin-top: -36px;
}

.calendar-panel {
    background: white;
    padding: 26px;
    border-radius: 16px;
    box-shadow: 0 12px 35px rgba(16,42,67,0.10);
}

.section-title {
    color: var(--navy);
    margin: 0 0 10px;
    font-size: 23px;
}

.section-subtitle {
    color: var(--muted);
    font-size: 13px;
    line-height: 1.6;
}

.calendar-layout {
    display: flex;
    align-items: stretch;
    gap: 10px;
    margin-top: 23px;
}

.calendar-nav {
    display: flex;
    align-items: center;
    justify-content: center;
    min-width: 38px;
    border: 1px solid var(--border);
    border-radius: 9px;
    color: var(--navy);
    background: #F4F7FA;
    font-size: 20px;
}

.calendar-disabled {
    opacity: 0.35;
    cursor: not-allowed;
}

.calendar-grid {
    display: grid;
    grid-template-columns: repeat(7, minmax(0, 1fr));
    flex: 1;
    gap: 9px;
    min-width: 0;
}

.calendar-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 8px;
    min-height: 100px;
    border: 1px solid var(--border);
    border-radius: 10px;
    color: var(--navy);
    background: white;
    text-align: center;
    padding: 9px 5px;
}

.calendar-card:hover {
    border-color: var(--teal);
}

.calendar-card.active {
    background: var(--navy);
    border-color: var(--navy);
    color: white;
}

.calendar-day {
    font-size: 12px;
}

.calendar-date {
    font-size: 16px;
}

.calendar-count {
    font-size: 11px;
    color: var(--teal);
    font-weight: bold;
}

.calendar-card.active .calendar-count {
    color: #77E6D8;
}

.calendar-count.zero {
    color: #9AA7B5;
}

.calendar-note {
    font-size: 12px;
    color: var(--muted);
    margin: 17px 0 0;
}

/* RESULTS */

.results-section {
    padding: 55px 0 80px;
}

.results-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
    margin-bottom: 24px;
}

.results-top h2 {
    color: var(--navy);
    margin: 0;
    font-size: 24px;
}

.results-top span {
    color: var(--muted);
    font-size: 13px;
}

/* FILTERS */

.filter-panel {
    background: white;
    border: 1px solid var(--border);
    border-radius: 14px;
    padding: 24px;
    margin-bottom: 20px;
}

.filter-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    margin-bottom: 20px;
}

.filter-heading h3 {
    margin: 0;
    color: var(--navy);
}

.clear-btn {
    border: none;
    background: transparent;
    color: var(--coral);
    font-weight: bold;
    cursor: pointer;
}

.filter-grid {
    display: grid;
    grid-template-columns: 1.4fr 1.4fr 1fr 1fr;
    gap: 20px;
}

.filter-group {
    min-width: 0;
}

.filter-group h4,
.filter-group > label {
    display: block;
    font-size: 13px;
    color: var(--navy);
    font-weight: bold;
    margin: 0 0 13px;
}

.check-label {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 12px;
    color: var(--muted);
    margin-bottom: 10px;
}

.filter-input {
    width: 100%;
    height: 40px;
    border: 1px solid var(--border);
    border-radius: 7px;
    padding: 0 10px;
    margin-bottom: 9px;
    background: white;
}

.filter-error {
    color: #C0392B;
    font-size: 12px;
}

.filter-count {
    font-size: 13px;
    color: var(--muted);
    margin-bottom: 17px;
}

/* BUS CARD */

.bus-list {
    display: grid;
    gap: 22px;
}

.bus-card {
    display: grid;
    grid-template-columns: 235px minmax(0, 1fr);
    background: white;
    border: 1px solid var(--border);
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 5px 18px rgba(16,42,67,0.04);
}

/* Ensure filtered-out buses are actually hidden */
.bus-card[hidden],
.empty-box[hidden] {
    display: none !important;
}


.bus-image {
    position: relative;
    min-height: 280px;
    background: #EAF0F5;
}

.bus-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.bus-image-fallback {
    padding: 55px 20px;
    text-align: center;
    color: var(--navy);
    font-size: 45px;
}

.bus-type-badge {
    position: absolute;
    top: 15px;
    left: 12px;
    background: var(--navy);
    color: white;
    padding: 8px 12px;
    border-radius: 7px;
    font-size: 11px;
    font-weight: bold;
}

.bus-content {
    padding: 23px;
    min-width: 0;
}

.bus-top {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 15px;
}

.bus-top h3 {
    margin: 0 0 7px;
    color: var(--navy);
    font-size: 21px;
}

.bus-number {
    font-size: 12px;
    color: var(--muted);
    margin: 0;
}

.available-badge {
    color: #087F72;
    background: #E5F8F4;
    padding: 9px 12px;
    border-radius: 7px;
    font-size: 12px;
    font-weight: bold;
    white-space: nowrap;
}

.sold-badge {
    color: #B42318;
    background: #FDECE9;
    padding: 9px 12px;
    border-radius: 7px;
    font-size: 12px;
    font-weight: bold;
}

.journey-line {
    display: flex;
    align-items: center;
    gap: 20px;
    margin: 24px 0;
}

.journey-point {
    display: flex;
    flex-direction: column;
    gap: 7px;
}

.journey-point strong {
    color: var(--navy);
    font-size: 20px;
}

.journey-point span {
    font-size: 12px;
    color: var(--muted);
}

.journey-arrow {
    flex: 1;
    border-top: 2px dashed #C8D5E1;
    position: relative;
    min-width: 20px;
}

.journey-arrow::after {
    content: "➜";
    position: absolute;
    right: -2px;
    top: -12px;
    background: white;
    color: var(--teal);
}

.journey-date {
    font-size: 12px;
    color: var(--muted);
}

/* GALLERY */

.bus-gallery {
    border-top: 1px solid var(--border);
    padding-top: 14px;
    margin-top: 16px;
}

.bus-gallery summary {
    cursor: pointer;
    color: var(--navy);
    font-size: 12px;
    font-weight: bold;
}

.gallery-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 10px;
    margin-top: 15px;
}

.gallery-grid figure {
    margin: 0;
    min-width: 0;
}

.gallery-grid img {
    width: 100%;
    height: 100px;
    object-fit: cover;
    border-radius: 7px;
}

.gallery-grid figcaption {
    color: var(--muted);
    font-size: 11px;
    margin-top: 5px;
}

.gallery-note {
    color: var(--muted);
    font-size: 11px;
}

/* CARD FOOTER */

.bus-footer {
    border-top: 1px solid var(--border);
    margin-top: 20px;
    padding-top: 19px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
}

.price small {
    display: block;
    font-size: 11px;
    color: var(--muted);
    margin-bottom: 6px;
}

.price strong {
    font-size: 26px;
    color: var(--navy);
}

.btn {
    display: inline-flex;
    justify-content: center;
    align-items: center;
    background: var(--coral);
    color: white;
    padding: 13px 20px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: bold;
    border: none;
    cursor: pointer;
}

.btn:hover {
    background: #E75B49;
}

.empty-box {
    background: white;
    padding: 55px 25px;
    border: 1px solid var(--border);
    border-radius: 15px;
    text-align: center;
}

.empty-box h3 {
    color: var(--navy);
}

.empty-box p {
    color: var(--muted);
    line-height: 1.7;
}

.bottom-link {
    display: inline-block;
    margin-top: 35px;
    color: var(--navy);
    font-size: 13px;
    font-weight: bold;
}

/* RESPONSIVE */

@media (max-width: 950px) {

    .filter-grid {
        grid-template-columns: repeat(2, 1fr);
    }

    .calendar-layout {
        overflow-x: auto;
    }

    .calendar-grid {
        min-width: 650px;
    }
}

@media (max-width: 650px) {

    .nav-inner {
        flex-direction: column;
        padding: 17px 0;
    }

    .nav-links {
        justify-content: center;
        gap: 15px;
    }

    .bus-card {
        grid-template-columns: 1fr;
    }

    .bus-image {
        height: 190px;
        min-height: 190px;
    }

    .bus-top {
        flex-wrap: wrap;
    }

    .journey-line {
        gap: 12px;
    }

    .journey-point strong {
        font-size: 16px;
    }

    .filter-grid {
        grid-template-columns: 1fr;
    }

    .results-top {
        flex-direction: column;
        align-items: flex-start;
    }

    .gallery-grid {
        grid-template-columns: repeat(2, 1fr);
    }

    .bus-footer {
        flex-wrap: wrap;
    }
}

/* STEP 20B: optional demo amenities */
.amenity-options { display:flex; flex-wrap:wrap; gap:8px 16px; }
.amenity-options .check-label { margin:0; }
.amenity-strip { display:flex; flex-wrap:wrap; align-items:center; gap:7px; margin:12px 0; }
.amenity-chip { border:1px solid var(--border); border-radius:999px; padding:5px 10px; font-size:12px; color:var(--navy); background:#f5f8fb; }
.amenity-note { font-size:11px; color:var(--muted); }
</style>

</head>

<body>

<header class="navbar">

    <div class="container nav-inner">

        <a class="logo"
           href="<%= ctx %>/index.jsp">
            Vazhi<span>Go.</span>
        </a>

        <nav class="nav-links" aria-label="Main navigation">

            <a href="<%= ctx %>/home.jsp">Home</a>

            <a href="<%= ctx %>/search.jsp">Search Again</a>

            <a href="<%= ctx %>/myBookings">My Bookings</a>

        </nav>

    </div>

</header>

<section class="results-hero">

    <div class="container">

        <span class="eyebrow">
            FIND YOUR PERFECT JOURNEY
        </span>

        <h1>Available Buses</h1>

        <p><%= escapeHtml(routeName) %></p>

        <p>
            Journey Date:
            <strong>
                <%= travelDate.format(fullDateFormatter) %>
            </strong>
        </p>

        <div class="count-banner">

            <strong><%= availableBusCount %></strong>

            <span>
                <%= availableBusCount == 1
                    ? "Bus Available for Booking"
                    : "Buses Available for Booking" %>
            </span>

        </div>

    </div>

</section>

<main>

<!-- DATE CALENDAR -->

<section class="calendar-section">

    <div class="container">

        <div class="calendar-panel">

            <h2 class="section-title">
                Choose Your Travel Date
            </h2>

            <p class="section-subtitle">
                Explore bus availability across different dates.
            </p>

            <div class="calendar-layout">

                <% if (canGoPrevious) { %>

                    <a class="calendar-nav"
                       href="<%= previousUrl %>"
                       aria-label="Previous dates">
                        &#10094;
                    </a>

                <% } else { %>

                    <span class="calendar-nav calendar-disabled">
                        &#10094;
                    </span>

                <% } %>

                <div class="calendar-grid">

                    <% for (Map.Entry<LocalDate, Integer> entry
                            : dateAvailability.entrySet()) {

                        LocalDate date = entry.getKey();

                        int count = entry.getValue();

                        boolean selected =
                                date.equals(travelDate);

                        boolean beyondLimit =
                                date.isAfter(maximumDate);

                        String dateUrl =
                                baseQuery
                                + "&travelDate="
                                + date
                                + "&windowStart="
                                + windowStart;
                    %>

                        <% if (beyondLimit) { %>

                            <span class="calendar-card calendar-disabled">

                                <span class="calendar-day">
                                    <%= date.format(dayFormatter) %>
                                </span>

                                <strong class="calendar-date">
                                    <%= date.format(dateFormatter) %>
                                </strong>

                                <span class="calendar-count zero">
                                    Unavailable
                                </span>

                            </span>

                        <% } else { %>

                            <a href="<%= dateUrl %>"
                               class="calendar-card <%= selected ? "active" : "" %>"
                               <%= selected ? "aria-current=\"date\"" : "" %>>

                                <span class="calendar-day">
                                    <%= date.format(dayFormatter) %>
                                </span>

                                <strong class="calendar-date">
                                    <%= date.format(dateFormatter) %>
                                </strong>

                                <span class="calendar-count <%= count == 0 ? "zero" : "" %>">

                                    <%= count == 0
                                        ? "No Buses"
                                        : count + (count == 1
                                            ? " Bus"
                                            : " Buses") %>

                                </span>

                            </a>

                        <% } %>

                    <% } %>

                </div>

                <% if (canGoNext) { %>

                    <a class="calendar-nav"
                       href="<%= nextUrl %>"
                       aria-label="Next dates">
                        &#10095;
                    </a>

                <% } else { %>

                    <span class="calendar-nav calendar-disabled">
                        &#10095;
                    </span>

                <% } %>

            </div>

            <p class="calendar-note">
                Availability reflects active schedules
                and currently unbooked seats.
            </p>

        </div>

    </div>

</section>

<!-- RESULTS -->

<section class="results-section">

    <div class="container">

        <div class="results-top">

            <h2>
                Buses for
                <%= travelDate.format(fullDateFormatter) %>
            </h2>

            <span>
                <%= busCards.size() %> scheduled service(s)
            </span>

        </div>

        <% if (busCards.isEmpty()) { %>

            <div class="empty-box">

                <div style="font-size:45px;">&#128652;</div>

                <h3>No Buses Found</h3>

                <p>
                    No scheduled buses were found for this
                    route and journey date.
                    Try selecting another date above.
                </p>

                <a class="btn"
                   href="<%= ctx %>/search.jsp">
                    Change Journey
                </a>

            </div>

        <% } else { %>

            <!-- FILTER PANEL -->

            <form id="busFilters"
                  class="filter-panel"
                  aria-label="Filter and sort buses">

                <div class="filter-heading">

                    <h3>Filter &amp; Sort Buses</h3>

                    <button type="reset"
                            class="clear-btn">
                        Clear All
                    </button>

                </div>

                <div class="filter-grid">

                    <div class="filter-group">

                        <h4>Bus Type</h4>

                        <label class="check-label">
                            <input type="checkbox"
                                   name="type"
                                   value="AC Sleeper">
                            AC Sleeper
                        </label>

                        <label class="check-label">
                            <input type="checkbox"
                                   name="type"
                                   value="AC Seater">
                            AC Seater
                        </label>

                        <label class="check-label">
                            <input type="checkbox"
                                   name="type"
                                   value="Non-AC Seater">
                            Non-AC Seater
                        </label>

                    </div>

                    <div class="filter-group">

                        <h4>Departure Time</h4>

                        <label class="check-label">
                            <input type="checkbox"
                                   name="period"
                                   value="morning">
                            Morning
                        </label>

                        <label class="check-label">
                            <input type="checkbox"
                                   name="period"
                                   value="afternoon">
                            Afternoon
                        </label>

                        <label class="check-label">
                            <input type="checkbox"
                                   name="period"
                                   value="evening">
                            Evening
                        </label>

                        <label class="check-label">
                            <input type="checkbox"
                                   name="period"
                                   value="night">
                            Night
                        </label>

                    </div>

                    <div class="filter-group">

                        <h4>Fare Range (₹)</h4>

                        <input class="filter-input"
                               type="number"
                               id="minFare"
                               min="0"
                               placeholder="Minimum fare">

                        <input class="filter-input"
                               type="number"
                               id="maxFare"
                               min="0"
                               placeholder="Maximum fare">

                        <p class="filter-error"
                           id="filterError"
                           role="status"
                           aria-live="polite"></p>

                    </div>

                    <div class="filter-group">

                        <label for="sortBy">Sort By</label>

                        <select class="filter-input"
                                id="sortBy">

                            <option value="default">
                                Default
                            </option>

                            <option value="priceAsc">
                                Price: Low to High
                            </option>

                            <option value="priceDesc">
                                Price: High to Low
                            </option>

                            <option value="departureAsc">
                                Departure: Earliest
                            </option>

                            <option value="departureDesc">
                                Departure: Latest
                            </option>

                        </select>

                    </div>

                </div>

                <div class="filter-group" style="margin-top:18px">
                    <h4>Demo amenities (match all selected)</h4>
                    <div class="amenity-options">
                        <label class="check-label"><input type="checkbox" name="amenity" value="wifi"> Wi-Fi</label>
                        <label class="check-label"><input type="checkbox" name="amenity" value="charging"> Charging</label>
                        <label class="check-label"><input type="checkbox" name="amenity" value="food"> Food</label>
                        <label class="check-label"><input type="checkbox" name="amenity" value="restroom"> Restroom</label>
                        <label class="check-label"><input type="checkbox" name="amenity" value="blanket"> Blanket</label>
                        <label class="check-label"><input type="checkbox" name="amenity" value="water"> Water bottle</label>
                    </div>
                </div>

            </form>

            <p class="filter-count"
               id="filterCount"
               aria-live="polite">
                Showing <%= busCards.size() %>
                of <%= busCards.size() %> buses
            </p>

            <div class="empty-box"
                 id="noFilterResults"
                 hidden="hidden">

                <h3>No buses match your filters</h3>

                <p>
                    Try adjusting the selected filters.
                </p>

                <button class="btn"
                        type="button"
                        id="clearEmptyFilters">
                    Clear Filters
                </button>

            </div>

            <!-- BUS CARDS -->

            <div class="bus-list" id="busList">

                <% int originalOrder = 0; %>

                <% for (BusSearchCard bus : busCards) { %>
                <% BusAmenity amenity = bus.getAmenity(); %>

                    <article class="bus-card filter-card"

                        data-type="<%= escapeHtml(bus.getBusType()) %>"

                        data-fare="<%= bus.getFare() %>"

                        data-departure="<%= bus.getDepartureTime() %>"

                        data-order="<%= originalOrder++ %>"
                        data-amenities="<%= amenity == null ? "" :
                            (amenity.isWifi() ? "wifi " : "") +
                            (amenity.isCharging() ? "charging " : "") +
                            (amenity.isFood() ? "food " : "") +
                            (amenity.isRestroom() ? "restroom " : "") +
                            (amenity.isBlanket() ? "blanket " : "") +
                            (amenity.isWaterBottle() ? "water " : "") %>">

                        <div class="bus-image">

                            <img
                                src="<%= ctx %>/assets/images/buses/bus-exterior.jpg"
                                alt="Representative bus exterior"
                                onerror="this.hidden=true;this.nextElementSibling.hidden=false;">

                            <div class="bus-image-fallback"
                                 hidden="hidden">
                                &#128652;
                            </div>

                            <span class="bus-type-badge">
                                <%= escapeHtml(bus.getBusType()) %>
                            </span>

                        </div>

                        <div class="bus-content">

                            <div class="bus-top">

                                <div>

                                    <h3>
                                        <%= escapeHtml(bus.getBusName()) %>
                                    </h3>

                                    <p class="bus-number">
                                        <%= escapeHtml(bus.getBusNumber()) %>
                                    </p>

                                </div>

                                <% if (bus.getAvailableSeats() > 0) { %>

                                    <span class="available-badge">
                                        <%= bus.getAvailableSeats() %>
                                        seats available
                                    </span>

                                <% } else { %>

                                    <span class="sold-badge">
                                        Sold Out
                                    </span>

                                <% } %>

                            </div>

                            <div class="journey-line">

                                <div class="journey-point">

                                    <strong>
                                        <%= bus.getDepartureTime().format(timeFormatter) %>
                                    </strong>

                                    <span>
                                        <%= escapeHtml(bus.getSourceCity()) %>
                                    </span>

                                </div>

                                <div class="journey-arrow"></div>

                                <div class="journey-point">

                                    <strong>
                                        <%= bus.getArrivalTime().format(timeFormatter) %>
                                    </strong>

                                    <span>
                                        <%= escapeHtml(bus.getDestinationCity()) %>
                                    </span>

                                </div>

                            </div>

                            <p class="journey-date">
                                Journey Date:
                                <strong>
                                    <%= bus.getTravelDate() %>
                                </strong>
                            </p>

                            <% if (amenity != null) { %>
                            <div class="amenity-strip" aria-label="Configured demo amenities">
                                <% if (amenity.isWifi()) { %><span class="amenity-chip">Wi-Fi</span><% } %>
                                <% if (amenity.isCharging()) { %><span class="amenity-chip">Charging</span><% } %>
                                <% if (amenity.isFood()) { %><span class="amenity-chip">Food</span><% } %>
                                <% if (amenity.isRestroom()) { %><span class="amenity-chip">Restroom</span><% } %>
                                <% if (amenity.isBlanket()) { %><span class="amenity-chip">Blanket</span><% } %>
                                <% if (amenity.isWaterBottle()) { %><span class="amenity-chip">Water bottle</span><% } %>
                                <span class="amenity-note">Sample amenities · academic demo, not operator-verified</span>
                            </div>
                            <% } %>

                            <details class="bus-gallery">

                                <summary>View Bus Photos</summary>

                                <div class="gallery-grid">

                                    <figure>

                                        <img
                                            src="<%= ctx %>/assets/images/buses/bus-exterior.jpg"
                                            alt="Representative bus exterior"
                                            onerror="this.hidden=true;this.nextElementSibling.hidden=false;">

                                        <span hidden="hidden">
                                            Photo unavailable
                                        </span>

                                        <figcaption>Exterior</figcaption>

                                    </figure>

                                    <figure>

                                        <img
                                            src="<%= ctx %>/assets/images/buses/bus-interior.jpg"
                                            alt="Representative bus interior"
                                            onerror="this.hidden=true;this.nextElementSibling.hidden=false;">

                                        <span hidden="hidden">
                                            Photo unavailable
                                        </span>

                                        <figcaption>Interior</figcaption>

                                    </figure>

                                    <figure>

                                        <img
                                            src="<%= ctx %>/assets/images/buses/bus-sleeper.jpg"
                                            alt="Representative sleeper interior"
                                            onerror="this.hidden=true;this.nextElementSibling.hidden=false;">

                                        <span hidden="hidden">
                                            Photo unavailable
                                        </span>

                                        <figcaption>Additional View</figcaption>

                                    </figure>

                                </div>

                                <p class="gallery-note">
                                    Representative images for
                                    academic demonstration.
                                </p>

                            </details>

                            <div class="bus-footer">

                                <div class="price">

                                    <small>
                                        Current configured fare
                                    </small>

                                    <strong>
                                        &#8377;<%= bus.getFare() %>
                                    </strong>

                                </div>

                                <% if (bus.getAvailableSeats() > 0) { %>

                                    <a class="btn"
                                       href="<%= ctx %>/seatSelection?scheduleId=<%= bus.getScheduleId() %>">

                                        Select Seats &rarr;

                                    </a>

                                <% } else { %>

                                    <span class="sold-badge">
                                        Sold Out
                                    </span>

                                <% } %>

                            </div>

                        </div>

                    </article>

                <% } %>

            </div>

        <% } %>

        <a class="bottom-link"
           href="<%= ctx %>/search.jsp">

            &larr; Change Source or Destination

        </a>

    </div>

</section>

</main>

<script>

(function () {

    const form = document.getElementById("busFilters");

    if (!form) {
        return;
    }

    const list = document.getElementById("busList");

    const cards = Array.from(
        list.querySelectorAll(".filter-card")
    );

    const minInput = document.getElementById("minFare");
    const maxInput = document.getElementById("maxFare");

    const sortInput = document.getElementById("sortBy");

    const count = document.getElementById("filterCount");

    const noResults =
        document.getElementById("noFilterResults");

    const error =
        document.getElementById("filterError");

    function departurePeriod(time) {

        const hour = Number(time.split(":")[0]);

        if (hour >= 5 && hour < 12) return "morning";

        if (hour >= 12 && hour < 17) return "afternoon";

        if (hour >= 17 && hour < 21) return "evening";

        return "night";
    }

    function applyFilters() {

        const types = Array.from(
            form.querySelectorAll(
                'input[name="type"]:checked'
            )
        ).map(input => input.value.toLowerCase());

        const periods = Array.from(
            form.querySelectorAll(
                'input[name="period"]:checked'
            )
        ).map(input => input.value);

        const selectedAmenities = Array.from(
            form.querySelectorAll('input[name="amenity"]:checked')
        ).map(input => input.value);

        const min =
            minInput.value === ""
            ? 0
            : Number(minInput.value);

        const max =
            maxInput.value === ""
            ? Infinity
            : Number(maxInput.value);

        if (!Number.isFinite(min)
                || min < 0
                || (maxInput.value !== ""
                    && (!Number.isFinite(max) || max < 0))
                || min > max) {

            error.textContent =
                "Please enter a valid fare range.";

            return;
        }

        error.textContent = "";

        let visible = 0;

        cards.forEach(card => {

            const type =
                card.dataset.type.toLowerCase();

            const fare =
                Number(card.dataset.fare);

            const period =
                departurePeriod(card.dataset.departure);

            const typeMatch =
                types.length === 0
                || types.includes(type);

            const periodMatch =
                periods.length === 0
                || periods.includes(period);

            const fareMatch =
                fare >= min && fare <= max;

            const offeredAmenities = (card.dataset.amenities || "")
                .trim().split(/\s+/).filter(Boolean);
            const amenityMatch = selectedAmenities.every(
                item => offeredAmenities.includes(item)
            );

            const show =
                typeMatch && periodMatch && fareMatch && amenityMatch;

            card.hidden = !show;

            if (show) {
                visible++;
            }
        });

        const sort = sortInput.value;

        const sorted = cards.slice();

        sorted.sort((a, b) => {

            if (sort === "priceAsc") {
                return Number(a.dataset.fare)
                    - Number(b.dataset.fare);
            }

            if (sort === "priceDesc") {
                return Number(b.dataset.fare)
                    - Number(a.dataset.fare);
            }

            if (sort === "departureAsc") {
                return a.dataset.departure.localeCompare(
                    b.dataset.departure
                );
            }

            if (sort === "departureDesc") {
                return b.dataset.departure.localeCompare(
                    a.dataset.departure
                );
            }

            return Number(a.dataset.order)
                - Number(b.dataset.order);
        });

        sorted.forEach(card => list.appendChild(card));

        count.textContent =
            "Showing " + visible
            + " of " + cards.length + " buses";

        noResults.hidden = visible !== 0;
    }

    form.addEventListener("input", applyFilters);
    form.addEventListener("change", applyFilters);

    form.addEventListener("reset", function () {

        setTimeout(applyFilters, 0);
    });

    document.getElementById("clearEmptyFilters")
        .addEventListener("click", function () {

            form.reset();
            applyFilters();
        });

    applyFilters();

})();

</script>

</body>
</html>