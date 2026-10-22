<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.tnbus.model.Seat" %>
<%@ page import="com.tnbus.model.Bus" %>
<%@ page import="com.tnbus.model.BusSchedule" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String bookedClass(
            boolean booked,
            String gender) {

        if (!booked) {
            return "";
        }

        if ("MALE".equalsIgnoreCase(gender)
                || "M".equalsIgnoreCase(gender)) {
            return "male-booked";
        }

        if ("FEMALE".equalsIgnoreCase(gender)
                || "F".equalsIgnoreCase(gender)) {
            return "female-booked";
        }

        return "booked-seat";
    }

    private String bookedDescription(String gender) {
        if ("MALE".equalsIgnoreCase(gender)
                || "M".equalsIgnoreCase(gender)) {
            return "Booked - Male";
        }

        if ("FEMALE".equalsIgnoreCase(gender)
                || "F".equalsIgnoreCase(gender)) {
            return "Booked - Female";
        }

        return "Booked";
    }

    private String seatCategory(Seat seat) {
        if ("SINGLE_SLEEPER".equalsIgnoreCase(
                seat.getLayoutType())) {
            return "Single sleeper";
        }

        if ("DOUBLE_SLEEPER".equalsIgnoreCase(
                seat.getLayoutType())) {
            return "Double sleeper";
        }

        return "Seater";
    }
%>

<%
    BusSchedule schedule =
            (BusSchedule) request.getAttribute("schedule");

    Bus bus =
            (Bus) request.getAttribute("bus");

    @SuppressWarnings("unchecked")
    List<Seat> seats =
            (List<Seat>) request.getAttribute("seats");

    @SuppressWarnings("unchecked")
    List<Integer> bookedSeatIds =
            (List<Integer>) request.getAttribute("bookedSeatIds");

    @SuppressWarnings("unchecked")
    Map<Integer, String> bookedSeatGenders =
            (Map<Integer, String>)
            request.getAttribute("bookedSeatGenders");

    @SuppressWarnings("unchecked")
    Map<Integer, BigDecimal> seatFareMap =
            (Map<Integer, BigDecimal>)
            request.getAttribute("seatFareMap");

    boolean isSleeper = Boolean.TRUE.equals(
            request.getAttribute("isSleeper"));

    BigDecimal doubleUpperFare =
            (BigDecimal) request.getAttribute("doubleUpperFare");

    BigDecimal doubleLowerFare =
            (BigDecimal) request.getAttribute("doubleLowerFare");

    BigDecimal singleUpperFare =
            (BigDecimal) request.getAttribute("singleUpperFare");

    BigDecimal singleLowerFare =
            (BigDecimal) request.getAttribute("singleLowerFare");

    BigDecimal seaterFare =
            (BigDecimal) request.getAttribute("seaterFare");

    String errorMessage =
            (String) request.getAttribute("errorMessage");

    String ctx = request.getContextPath();

    if (seats == null) {
        seats = Collections.emptyList();
    }

    if (bookedSeatIds == null) {
        bookedSeatIds = Collections.emptyList();
    }

    if (bookedSeatGenders == null) {
        bookedSeatGenders = Collections.emptyMap();
    }

    if (seatFareMap == null) {
        seatFareMap = Collections.emptyMap();
    }

    Set<Integer> bookedSet =
            new HashSet<>(bookedSeatIds);

    int availableCount = 0;

    for (Seat seat : seats) {
        if (!bookedSet.contains(seat.getSeatId())) {
            availableCount++;
        }
    }

    List<Seat> orderedSeats = new ArrayList<>(seats);

    orderedSeats.sort((a, b) -> {
        String first = a.getSeatNumber() == null
                ? "" : a.getSeatNumber();

        String second = b.getSeatNumber() == null
                ? "" : b.getSeatNumber();

        String firstDigits = first.replaceAll("\\D", "");
        String secondDigits = second.replaceAll("\\D", "");

        int firstNumber = firstDigits.isEmpty()
                ? 0 : Integer.parseInt(firstDigits);

        int secondNumber = secondDigits.isEmpty()
                ? 0 : Integer.parseInt(secondDigits);

        int result = Integer.compare(firstNumber, secondNumber);

        if (result != 0) {
            return result;
        }

        result = first.compareToIgnoreCase(second);

        return result != 0
                ? result
                : Integer.compare(a.getSeatId(), b.getSeatId());
    });

    /*
     * Sleeper layout:
     *
     * row_number:    1 through 6
     * column_number: 1 = single, 2 and 3 = double
     *
     * This is based on the database mapping completed
     * in the previous steps.
     */

    Map<String, Seat> sleeperPositions = new HashMap<>();

    if (isSleeper) {
        for (Seat seat : seats) {

            if (seat.getDeck() == null
                    || seat.getRowNumber() == null
                    || seat.getColumnNumber() == null) {
                continue;
            }

            String key =
                    seat.getDeck().trim().toUpperCase(Locale.ROOT)
                    + "-"
                    + seat.getRowNumber()
                    + "-"
                    + seat.getColumnNumber();

            sleeperPositions.put(key, seat);
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Select Seats | VazhiGo</title>

<link rel="stylesheet"
      href="<%= ctx %>/assets/css/style.css">

<style>
.seat-page {
    max-width: 1250px;
    margin: 35px auto;
    padding: 0 20px 50px;
}

.seat-heading {
    margin-bottom: 25px;
}

.seat-heading h1 {
    color: #12355b;
    font-size: 30px;
    margin-bottom: 8px;
}

.seat-heading p {
    color: #66758a;
}

.seat-layout {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 330px;
    gap: 24px;
    align-items: start;
}

.seat-panel {
    background: #fff;
    padding: 24px;
    border-radius: 16px;
    border: 1px solid #e0e6ee;
    box-shadow: 0 5px 20px rgba(0,0,0,.04);
    min-width: 0;
}

.seat-panel h2 {
    color: #12355b;
    font-size: 21px;
    margin-bottom: 18px;
}

.journey-details {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 12px;
    margin-bottom: 28px;
}

.journey-detail {
    background: #f4f7fb;
    padding: 13px;
    border-radius: 9px;
    min-width: 0;
}

.journey-detail small {
    display: block;
    color: #66758a;
    margin-bottom: 6px;
}

.journey-detail strong {
    color: #18283b;
    overflow-wrap: anywhere;
}

.seat-topline {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;
    margin-bottom: 18px;
}

.available-count {
    background: #e4f5e9;
    color: #206b3b;
    border-radius: 30px;
    padding: 8px 13px;
    font-size: 13px;
    font-weight: 700;
}

.seat-legend {
    display: flex;
    flex-wrap: wrap;
    gap: 12px 18px;
    margin-bottom: 25px;
}

.seat-legend-item {
    display: flex;
    align-items: center;
    gap: 7px;
    font-size: 13px;
    color: #435166;
}

.legend-square {
    width: 19px;
    height: 19px;
    border-radius: 5px;
    border: 1px solid;
    flex-shrink: 0;
}

.legend-available {
    background: #dff5e5;
    border-color: #48a667;
}

.legend-selected {
    background: #ffe17a;
    border-color: #d49b00;
}

.legend-male {
    background: #dbeafe;
    border-color: #3b82f6;
}

.legend-female {
    background: #fce7f3;
    border-color: #ec4899;
}

.legend-booked {
    background: #e5e7eb;
    border-color: #9ca3af;
}

/* SLEEPER LAYOUT */

.deck-container {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 18px;
}

.deck-panel {
    min-width: 0;
    padding: 15px;
    background: #f9fbfd;
    border: 2px solid #dbe3ec;
    border-radius: 16px;
}

.deck-heading {
    padding-bottom: 13px;
    margin-bottom: 15px;
    border-bottom: 1px dashed #ccd6e2;
}

.deck-heading h3 {
    color: #12355b;
    font-size: 18px;
    margin: 0 0 7px;
}

.deck-heading p {
    font-size: 12px;
    color: #66758a;
    margin: 0;
}

.deck-front {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 8px;
    margin-bottom: 16px;
    color: #66758a;
    font-size: 12px;
}

.driver-position {
    padding: 8px 10px;
    background: #e8eef6;
    border-radius: 8px;
    color: #12355b;
    font-weight: 700;
}

.sleeper-labels {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 17px
                           minmax(0, 1fr) minmax(0, 1fr);
    gap: 6px;
    margin-bottom: 10px;
    font-size: 11px;
    color: #66758a;
    text-align: center;
}

.sleeper-labels .double-label {
    grid-column: 3 / 5;
}

.sleeper-row {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 17px
                           minmax(0, 1fr) minmax(0, 1fr);
    gap: 6px;
    margin-bottom: 10px;
    align-items: stretch;
}

.aisle {
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 9px;
    color: #9aa7b7;
}

.empty-seat {
    min-height: 62px;
    border: 1px dashed #d1d9e3;
    border-radius: 8px;
}

/* SEATER LAYOUT */

.bus-shell {
    max-width: 480px;
    margin: 0 auto;
    padding: 20px;
    background: #f9fbfd;
    border: 2px solid #dbe3ec;
    border-radius: 22px;
}

.seater-grid {
    display: grid;
    grid-template-columns:
        minmax(0, 1fr)
        minmax(0, 1fr)
        20px
        minmax(0, 1fr)
        minmax(0, 1fr);
    gap: 12px 8px;
}

.seater-cell {
    min-width: 0;
}

/* SEAT BUTTONS */

.seat-button {
    width: 100%;
    min-width: 0;
    min-height: 62px;
    padding: 7px 2px;
    border-radius: 9px;
    border: 1.5px solid #48a667;
    background: #dff5e5;
    color: #206b3b;
    font-size: 12px;
    font-weight: 700;
    cursor: pointer;
    transition: background .15s, transform .15s;
}

.seat-button span {
    display: block;
    overflow-wrap: anywhere;
}

.seat-price {
    font-size: 11px;
    margin-top: 5px;
    font-weight: 600;
}

.seat-button:not(:disabled):hover {
    transform: translateY(-2px);
}

.seat-button:focus-visible {
    outline: 3px solid #12355b;
    outline-offset: 3px;
}

.seat-button.selected-seat {
    background: #ffe17a;
    border-color: #d49b00;
    color: #614500;
}

.seat-button.male-booked {
    background: #dbeafe;
    border-color: #3b82f6;
    color: #1d4ed8;
    cursor: not-allowed;
}

.seat-button.female-booked {
    background: #fce7f3;
    border-color: #ec4899;
    color: #be185d;
    cursor: not-allowed;
}

.seat-button.booked-seat {
    background: #e5e7eb;
    border-color: #9ca3af;
    color: #5b6472;
    cursor: not-allowed;
}

.seat-button:disabled {
    opacity: 1;
}

.seat-help {
    margin-top: 17px;
    color: #66758a;
    font-size: 12px;
    text-align: center;
}

/* SUMMARY */

.summary-panel {
    position: sticky;
    top: 20px;
}

.summary-row {
    display: flex;
    justify-content: space-between;
    gap: 15px;
    padding: 12px 0;
    border-bottom: 1px solid #e0e6ee;
    font-size: 13px;
}

.summary-row strong {
    color: #18283b;
    text-align: right;
}

.selected-seat-list {
    margin: 18px 0;
    padding: 15px;
    background: #f4f7fb;
    border-radius: 10px;
    min-height: 55px;
    color: #66758a;
    font-size: 14px;
}

.selected-item {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    padding: 8px 0;
    border-bottom: 1px solid #dbe3ec;
}

.selected-item:last-child {
    border-bottom: none;
}

.summary-total {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    margin: 20px 0;
}

.summary-total strong {
    font-size: 23px;
    color: #12355b;
}

.seat-continue {
    width: 100%;
    min-height: 48px;
    border: 0;
    border-radius: 9px;
    background: #ff7043;
    color: #fff;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
}

.seat-continue:hover:not(:disabled) {
    background: #e85d31;
}

.seat-continue:disabled {
    background: #aeb7c4;
    cursor: not-allowed;
}

.seat-back {
    display: inline-block;
    margin-top: 17px;
    color: #12355b;
    text-decoration: none;
    font-size: 14px;
}

.seat-error {
    padding: 13px 16px;
    background: #fff0f0;
    color: #a92323;
    border-radius: 9px;
    margin-bottom: 20px;
}

@media (max-width: 950px) {
    .seat-layout {
        grid-template-columns: 1fr;
    }

    .summary-panel {
        position: static;
    }
}

@media (max-width: 650px) {
    .deck-container {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 500px) {
    .seat-page {
        padding: 0 12px 30px;
    }

    .seat-panel {
        padding: 15px;
    }

    .journey-details {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .bus-shell {
        padding: 12px;
    }

    .seater-grid {
        gap: 9px 5px;
        grid-template-columns:
            minmax(0, 1fr)
            minmax(0, 1fr)
            16px
            minmax(0, 1fr)
            minmax(0, 1fr);
    }
}
</style>
</head>

<body>

<header class="navbar">

    <a class="logo" href="<%= ctx %>/home.jsp">
        VazhiGo
    </a>

    <nav class="nav-links">
        <a href="<%= ctx %>/search.jsp">Search Buses</a>
        <a href="<%= ctx %>/myBookings">My Bookings</a>
    </nav>

</header>

<main class="seat-page">

<div class="seat-heading">
    <h1>Choose Your Seats</h1>
    <p>Select your preferred seats and review the fare before continuing.</p>
</div>

<% if (errorMessage != null) { %>

<div class="seat-error" role="alert">
    <%= escapeHtml(errorMessage) %>
</div>

<% } %>

<% if (schedule != null && bus != null) { %>

<div class="seat-layout">

<section class="seat-panel">

<h2>Journey Details</h2>

<div class="journey-details">

    <div class="journey-detail">
        <small>Bus Name</small>
        <strong><%= escapeHtml(bus.getBusName()) %></strong>
    </div>

    <div class="journey-detail">
        <small>Bus Type</small>
        <strong><%= escapeHtml(bus.getBusType()) %></strong>
    </div>

    <div class="journey-detail">
        <small>Travel Date</small>
        <strong><%= schedule.getTravelDate() %></strong>
    </div>

    <div class="journey-detail">
        <small>Departure</small>
        <strong><%= schedule.getDepartureTime() %></strong>
    </div>

    <div class="journey-detail">
        <small>Arrival</small>
        <strong><%= schedule.getArrivalTime() %></strong>
    </div>

    <div class="journey-detail">
        <small>Starting Fare</small>
        <strong>₹<%= schedule.getFare() %></strong>
    </div>

</div>

<div class="seat-topline">
    <h2>Seat Layout</h2>

    <span class="available-count">
        <%= availableCount %> seats available
    </span>
</div>

<div class="seat-legend">

    <div class="seat-legend-item">
        <span class="legend-square legend-available"></span>
        Available
    </div>

    <div class="seat-legend-item">
        <span class="legend-square legend-selected"></span>
        Selected
    </div>

    <div class="seat-legend-item">
        <span class="legend-square legend-male"></span>
        Male Booked
    </div>

    <div class="seat-legend-item">
        <span class="legend-square legend-female"></span>
        Female Booked
    </div>

    <div class="seat-legend-item">
        <span class="legend-square legend-booked"></span>
        Other / Unavailable
    </div>

</div>

<% if (isSleeper) { %>

<!-- =========================================
     SLEEPER: LOWER AND UPPER DECKS
     ========================================= -->

<div class="deck-container">

<%
    String[] decks = {"LOWER", "UPPER"};

    for (String deck : decks) {

        boolean upper = "UPPER".equals(deck);

        String deckTitle =
                upper ? "Upper Deck" : "Lower Deck";

        BigDecimal singleFare =
                upper ? singleUpperFare : singleLowerFare;

        BigDecimal doubleFare =
                upper ? doubleUpperFare : doubleLowerFare;
%>

<div class="deck-panel">

    <div class="deck-heading">
        <h3><%= deckTitle %></h3>

        <p>
            Single: ₹<%= singleFare %>
            &nbsp;|&nbsp;
            Double: ₹<%= doubleFare %>
        </p>
    </div>

    <div class="deck-front">
        <span>FRONT OF BUS</span>

        <% if (!upper) { %>
            <span class="driver-position">◉ DRIVER</span>
        <% } %>
    </div>

    <div class="sleeper-labels">
        <span>Single</span>
        <span></span>
        <span class="double-label">Double sleeper</span>
    </div>

    <% for (int row = 1; row <= 6; row++) { %>

    <div class="sleeper-row">

        <% for (int column = 1; column <= 3; column++) {

            if (column == 2) {
        %>
            <div class="aisle" aria-hidden="true">│</div>
        <%
            }

            String key = deck + "-" + row + "-" + column;

            Seat seat = sleeperPositions.get(key);

            if (seat == null) {
        %>

            <div class="empty-seat"
                 aria-label="No seat configured"></div>

        <%
                continue;
            }

            int seatId = seat.getSeatId();

            boolean booked = bookedSet.contains(seatId);

            String gender = bookedSeatGenders.get(seatId);

            String stateClass = bookedClass(booked, gender);

            String stateDescription =
                    bookedDescription(gender);

            BigDecimal price = seatFareMap.get(seatId);

            String label =
                    (upper ? "U-" : "L-")
                    + seat.getSeatNumber();

            String category = seatCategory(seat);
        %>

        <% if (booked) { %>

            <button
                type="button"
                class="seat-button <%= stateClass %>"
                title="<%= escapeHtml(label) %>: <%= stateDescription %>"
                aria-label="<%= escapeHtml(label) %>, <%= stateDescription %>"
                disabled>

                <span><%= escapeHtml(label) %></span>
                <span class="seat-price">₹<%= price %></span>

            </button>

        <% } else { %>

            <button
                type="button"
                class="seat-button"
                data-seat-id="<%= seatId %>"
                data-seat-number="<%= escapeHtml(label) %>"
                data-seat-category="<%= escapeHtml(category) %>"
                data-seat-price="<%= price %>"
                aria-label="<%= escapeHtml(label) %>, <%= escapeHtml(category) %>, ₹<%= price %>, available"
                aria-pressed="false">

                <span><%= escapeHtml(label) %></span>
                <span class="seat-price">₹<%= price %></span>

            </button>

        <% } %>

        <% } %>

    </div>

    <% } %>

</div>

<% } %>

</div>

<% } else { %>

<!-- =========================================
     NORMAL SEATER BUS
     ========================================= -->

<div class="bus-shell">

    <div class="deck-front">
        <span>FRONT OF BUS</span>
        <span class="driver-position">◉ DRIVER</span>
    </div>

    <div class="seater-grid">

    <%
        int seaterIndex = 0;

        for (Seat seat : orderedSeats) {

            /*
             * Every four seats:
             * two on the left, aisle, two on the right.
             */

            if (seaterIndex > 0 && seaterIndex % 4 == 2) {
    %>

        <div class="aisle" aria-hidden="true"></div>

    <%
            }

            seaterIndex++;

            int seatId = seat.getSeatId();

            boolean booked = bookedSet.contains(seatId);

            String gender = bookedSeatGenders.get(seatId);

            String stateClass = bookedClass(booked, gender);

            String stateDescription =
                    bookedDescription(gender);

            String label = seat.getSeatNumber();

            BigDecimal price = seatFareMap.get(seatId);
    %>

        <div class="seater-cell">

        <% if (booked) { %>

            <button
                type="button"
                class="seat-button <%= stateClass %>"
                aria-label="<%= escapeHtml(label) %>, <%= stateDescription %>"
                disabled>

                <span><%= escapeHtml(label) %></span>
                <span class="seat-price">₹<%= price %></span>

            </button>

        <% } else { %>

            <button
                type="button"
                class="seat-button"
                data-seat-id="<%= seatId %>"
                data-seat-number="<%= escapeHtml(label) %>"
                data-seat-category="Seater"
                data-seat-price="<%= price %>"
                aria-label="<%= escapeHtml(label) %>, ₹<%= price %>, available"
                aria-pressed="false">

                <span><%= escapeHtml(label) %></span>
                <span class="seat-price">₹<%= price %></span>

            </button>

        <% } %>

        </div>

    <% } %>

    </div>

</div>

<% } %>

<p class="seat-help">
    Tap an available seat to select it.
    Tap again to deselect it.
</p>

</section>

<!-- =========================================
     BOOKING SUMMARY
     ========================================= -->

<aside class="seat-panel summary-panel">

<h2>Booking Summary</h2>

<% if (isSleeper) { %>

<div class="summary-row">
    <span>Double Upper</span>
    <strong>₹<%= doubleUpperFare %></strong>
</div>

<div class="summary-row">
    <span>Double Lower</span>
    <strong>₹<%= doubleLowerFare %></strong>
</div>

<div class="summary-row">
    <span>Single Upper</span>
    <strong>₹<%= singleUpperFare %></strong>
</div>

<div class="summary-row">
    <span>Single Lower</span>
    <strong>₹<%= singleLowerFare %></strong>
</div>

<% } else { %>

<div class="summary-row">
    <span>Fare per Seat</span>
    <strong>₹<%= seaterFare %></strong>
</div>

<% } %>

<div class="summary-row">
    <span>Seats Selected</span>
    <strong id="seatCount">0</strong>
</div>

<div class="selected-seat-list"
     id="selectedSeats"
     aria-live="polite">

    No seats selected yet.

</div>

<div class="summary-total">

    <span>Total Fare</span>

    <strong>
        ₹<span id="totalAmount">0.00</span>
    </strong>

</div>

<form
    method="post"
    action="<%= ctx %>/passengerDetails"
    id="seatForm">

    <input
        type="hidden"
        name="scheduleId"
        value="<%= schedule.getScheduleId() %>">

    <input
        type="hidden"
        name="selectedSeatIds"
        id="selectedSeatIds"
        value="">

    <button
        type="submit"
        class="seat-continue"
        id="continueButton"
        disabled>

        Continue to Passenger Details

    </button>

</form>

<a class="seat-back" href="<%= ctx %>/search.jsp">
    ← Back to Search
</a>

</aside>

</div>

<% } %>

</main>

<script>
(function () {

    const seatButtons =
            document.querySelectorAll(
                    ".seat-button[data-seat-id]");

    const selectedSeats = new Map();

    const seatCount =
            document.getElementById("seatCount");

    const selectedSeatsElement =
            document.getElementById("selectedSeats");

    const totalAmount =
            document.getElementById("totalAmount");

    const selectedSeatIds =
            document.getElementById("selectedSeatIds");

    const continueButton =
            document.getElementById("continueButton");

    const seatForm =
            document.getElementById("seatForm");

    if (!seatForm) {
        return;
    }

    // Convert decimal rupees to integer paise.
    function toPaise(value) {

        const parts = String(value).split(".");

        const rupees = Number(parts[0]);

        const paise = Number(
            (parts[1] || "").padEnd(2, "0").slice(0, 2)
        );

        return rupees * 100 + paise;
    }

    function formatPrice(paise) {
        return (paise / 100).toFixed(2);
    }

    // Update the booking summary.
    function updateSummary() {

        const selected =
                Array.from(selectedSeats.values());

        seatCount.textContent = selected.length;

        selectedSeatIds.value =
                selected.map(seat => seat.id).join(",");

        continueButton.disabled =
                selected.length === 0;

        selectedSeatsElement.replaceChildren();

        if (selected.length === 0) {

            selectedSeatsElement.textContent =
                    "No seats selected yet.";

            totalAmount.textContent = "0.00";

            return;
        }

        let totalPaise = 0;

        selected.forEach(function (seat) {

            totalPaise += seat.pricePaise;

            const row =
                    document.createElement("div");

            row.className = "selected-item";

            const details =
                    document.createElement("span");

            details.textContent =
                    seat.number + " (" + seat.category + ")";

            const price =
                    document.createElement("strong");

            price.textContent =
                    "₹" + formatPrice(seat.pricePaise);

            row.appendChild(details);
            row.appendChild(price);

            selectedSeatsElement.appendChild(row);
        });

        totalAmount.textContent =
                formatPrice(totalPaise);
    }

    // Select or deselect an available seat.
    seatButtons.forEach(function (button) {

        button.addEventListener("click", function () {

            const id = button.dataset.seatId;

            const number = button.dataset.seatNumber;

            const category = button.dataset.seatCategory;

            const pricePaise =
                    toPaise(button.dataset.seatPrice);

            if (selectedSeats.has(id)) {

                selectedSeats.delete(id);

                button.classList.remove("selected-seat");

                button.setAttribute("aria-pressed", "false");

                button.setAttribute(
                        "aria-label",
                        number + ", available");

            } else {

                selectedSeats.set(id, {
                    id: id,
                    number: number,
                    category: category,
                    pricePaise: pricePaise
                });

                button.classList.add("selected-seat");

                button.setAttribute("aria-pressed", "true");

                button.setAttribute(
                        "aria-label",
                        number + ", selected");
            }

            updateSummary();
        });
    });

    // Prevent submission without selecting seats.
    seatForm.addEventListener("submit", function (event) {

        if (selectedSeats.size === 0) {

            event.preventDefault();

            alert("Please select at least one seat.");
        }
    });

    updateSummary();

})();
</script>

</body>
</html>