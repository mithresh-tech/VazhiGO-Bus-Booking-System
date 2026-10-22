<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
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

    private String getSeatCategory(Seat seat, boolean isSleeper) {

        if (!isSleeper) {
            return "Seater";
        }

        String deck = seat.getDeck();
        String layoutType = seat.getLayoutType();

        String deckLabel =
                "UPPER".equalsIgnoreCase(deck)
                        ? "Upper"
                        : "LOWER".equalsIgnoreCase(deck)
                                ? "Lower"
                                : "Unknown Deck";

        String typeLabel;

        if ("SINGLE_SLEEPER".equalsIgnoreCase(layoutType)) {

            typeLabel = "Single";

        } else if ("DOUBLE_SLEEPER".equalsIgnoreCase(layoutType)) {

            typeLabel = "Double";

        } else {

            typeLabel = "Sleeper";
        }

        return typeLabel + " " + deckLabel;
    }
%>

<%
    String contextPath = request.getContextPath();

    BusSchedule schedule =
            (BusSchedule) request.getAttribute("schedule");

    Bus bus =
            (Bus) request.getAttribute("bus");

    @SuppressWarnings("unchecked")
    List<Seat> selectedSeats =
            (List<Seat>) request.getAttribute("selectedSeats");

    @SuppressWarnings("unchecked")
    Map<Integer, BigDecimal> seatFareMap =
            (Map<Integer, BigDecimal>)
                    request.getAttribute("seatFareMap");

    @SuppressWarnings("unchecked")
    Map<Integer, String> seatLabelMap =
            (Map<Integer, String>)
                    request.getAttribute("seatLabelMap");

    BigDecimal totalAmount =
            (BigDecimal) request.getAttribute("totalAmount");

    String errorMessage =
            (String) request.getAttribute("errorMessage");

    Boolean sleeperAttribute =
            (Boolean) request.getAttribute("isSleeper");

    boolean isSleeper =
            Boolean.TRUE.equals(sleeperAttribute);

    if (totalAmount == null) {
        totalAmount = BigDecimal.ZERO;
    }

    boolean hasSeats =
            selectedSeats != null
            && !selectedSeats.isEmpty();

    boolean ready =
            schedule != null
            && bus != null
            && hasSeats
            && seatFareMap != null
            && seatLabelMap != null;

    if (ready) {

        for (Seat seat : selectedSeats) {

            if (seat == null
                    || seatFareMap.get(seat.getSeatId()) == null
                    || seatLabelMap.get(seat.getSeatId()) == null) {

                ready = false;
                break;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Passenger Details | VazhiGo</title>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, Helvetica, sans-serif;
    background: #f4f7fb;
    color: #243247;
}

.topbar {
    background: #12355b;
    color: white;
    padding: 18px 6%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    flex-wrap: wrap;
}

.brand {
    font-size: 25px;
    font-weight: 800;
    letter-spacing: 0.3px;
}

.brand span {
    color: #72dfb0;
}

.tagline {
    font-size: 12px;
    color: #d8e5f3;
    margin-top: 5px;
}

.top-link {
    color: white;
    text-decoration: none;
    font-size: 13px;
    border: 1px solid rgba(255,255,255,0.4);
    border-radius: 7px;
    padding: 10px 15px;
}

.container {
    width: 1100px;
    max-width: 94%;
    margin: 30px auto 55px;
}

.page-heading {
    margin-bottom: 24px;
}

.page-heading h1 {
    font-size: 27px;
    color: #12355b;
    margin: 0 0 8px;
}

.page-heading p {
    color: #66758a;
    font-size: 14px;
    margin: 0;
    line-height: 1.6;
}

.progress {
    display: flex;
    gap: 8px;
    margin-top: 20px;
    flex-wrap: wrap;
}

.progress-step {
    background: #e7edf4;
    color: #66758a;
    padding: 9px 14px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: bold;
}

.progress-step.completed {
    background: #e1f5e9;
    color: #176b40;
}

.progress-step.active {
    background: #12355b;
    color: white;
}

.card {
    background: white;
    border: 1px solid #e4eaf1;
    border-radius: 12px;
    padding: 23px;
    margin-bottom: 20px;
    box-shadow: 0 3px 13px rgba(20, 45, 75, 0.04);
}

.card h2 {
    margin: 0 0 20px;
    font-size: 19px;
    color: #12355b;
}

.journey-grid {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 13px;
}

.journey-item {
    background: #f5f8fc;
    border: 1px solid #edf1f6;
    border-radius: 8px;
    padding: 15px;
    min-width: 0;
}

.journey-item label {
    display: block;
    color: #758398;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 8px;
}

.journey-item strong {
    font-size: 14px;
    color: #20364f;
    overflow-wrap: anywhere;
}

.main-grid {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 320px;
    align-items: start;
    gap: 20px;
}

.passenger-card {
    border-top: 4px solid #12355b;
}

.passenger-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 12px;
    margin-bottom: 20px;
}

.passenger-number {
    font-size: 17px;
    color: #12355b;
    font-weight: bold;
}

.seat-meta {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 8px;
    margin-top: 9px;
}

.seat-badge {
    background: #e9f0fa;
    color: #12355b;
    border-radius: 6px;
    padding: 7px 10px;
    font-size: 12px;
    font-weight: bold;
}

.category-badge {
    background: #f0eaff;
    color: #6142a1;
    border-radius: 6px;
    padding: 7px 10px;
    font-size: 12px;
    font-weight: bold;
}

.fare-badge {
    background: #e4f6e9;
    color: #176b40;
    border-radius: 7px;
    padding: 10px 14px;
    font-size: 17px;
    font-weight: bold;
}

.form-grid {
    display: grid;
    grid-template-columns: 1.5fr 0.65fr 1fr 1.25fr;
    gap: 13px;
}

.form-group {
    min-width: 0;
}

.form-group label {
    display: block;
    font-size: 12px;
    font-weight: bold;
    color: #405269;
    margin-bottom: 8px;
}

.form-group input,
.form-group select {
    display: block;
    width: 100%;
    min-width: 0;
    padding: 12px;
    border: 1px solid #cfd9e5;
    border-radius: 7px;
    font-family: inherit;
    font-size: 14px;
    color: #243247;
    background: white;
}

.form-group input:focus,
.form-group select:focus {
    outline: none;
    border-color: #12355b;
    box-shadow: 0 0 0 3px rgba(18,53,91,0.08);
}

.required {
    color: #d33b3b;
}

.optional {
    font-weight: normal;
    color: #8490a0;
}

.summary-card {
    position: sticky;
    top: 20px;
}

.summary-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    margin-bottom: 18px;
}

.summary-heading h2 {
    margin: 0;
}

.count-badge {
    background: #e9f0fa;
    color: #12355b;
    padding: 7px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: bold;
}

.summary-item {
    display: flex;
    justify-content: space-between;
    align-items: start;
    gap: 12px;
    padding: 13px 0;
    border-bottom: 1px solid #edf0f4;
    font-size: 13px;
}

.summary-item:last-of-type {
    border-bottom: none;
}

.summary-seat {
    font-weight: bold;
    color: #243247;
}

.summary-category {
    color: #8290a2;
    font-size: 11px;
    margin-top: 5px;
}

.summary-price {
    font-weight: bold;
    color: #20364f;
    white-space: nowrap;
}

.total-box {
    margin-top: 17px;
    background: #f0f5fb;
    padding: 17px;
    border-radius: 9px;
}

.total-label {
    font-size: 12px;
    color: #62738a;
}

.total-value {
    font-size: 27px;
    font-weight: 800;
    color: #12355b;
    margin-top: 8px;
    overflow-wrap: anywhere;
}

.payment-note {
    color: #728197;
    font-size: 12px;
    line-height: 1.7;
    margin-top: 14px;
}

.actions {
    display: flex;
    gap: 12px;
    justify-content: space-between;
    margin-top: 20px;
    flex-wrap: wrap;
}

.btn {
    display: inline-flex;
    justify-content: center;
    align-items: center;
    text-align: center;
    padding: 13px 20px;
    min-height: 45px;
    border: none;
    border-radius: 7px;
    text-decoration: none;
    font-family: inherit;
    font-size: 14px;
    font-weight: bold;
    cursor: pointer;
}

.btn-back {
    background: #e9edf3;
    color: #34465d;
}

.btn-confirm {
    background: #12355b;
    color: white;
    flex: 1;
}

.btn-confirm:hover {
    background: #0b2949;
}

.error {
    background: #fff0ef;
    color: #a92e2e;
    border: 1px solid #f4c8c5;
    padding: 14px;
    border-radius: 8px;
    margin-bottom: 20px;
    font-size: 13px;
    line-height: 1.6;
}

.empty-state {
    text-align: center;
    padding: 35px 20px;
}

.empty-state h2 {
    margin-bottom: 10px;
}

.empty-state p {
    color: #66758a;
    line-height: 1.7;
    font-size: 14px;
    margin-bottom: 25px;
}

.footer {
    text-align: center;
    font-size: 12px;
    color: #8a97a8;
    padding: 15px;
}

@media (max-width: 900px) {

    .main-grid {
        grid-template-columns: 1fr;
    }

    .summary-card {
        position: static;
    }

}

@media (max-width: 700px) {

    .journey-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .form-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }

}

@media (max-width: 430px) {

    .container {
        max-width: 93%;
        margin-top: 23px;
    }

    .card {
        padding: 17px;
    }

    .page-heading h1 {
        font-size: 23px;
    }

    .journey-grid,
    .form-grid {
        grid-template-columns: 1fr;
    }

    .actions {
        flex-direction: column;
    }

    .btn {
        width: 100%;
    }

}

</style>

</head>

<body>

<header class="topbar">

    <div>

        <div class="brand">
            Vazhi<span>Go</span>
        </div>

        <div class="tagline">
            Your Journey, Our Priority
        </div>

    </div>

    <a class="top-link"
       href="<%= contextPath %>/myBookings">
        My Bookings
    </a>

</header>

<main class="container">

    <section class="page-heading">

        <h1>Passenger Details</h1>

        <p>
            Complete the passenger information for your
            selected seats before proceeding to payment.
        </p>

        <div class="progress">

            <span class="progress-step completed">
                1. Select Seats ✓
            </span>

            <span class="progress-step active">
                2. Passenger Details
            </span>

            <span class="progress-step">
                3. Payment
            </span>

        </div>

    </section>

    <% if (errorMessage != null && !errorMessage.isBlank()) { %>

        <div class="error" role="alert">
            <%= escapeHtml(errorMessage) %>
        </div>

    <% } %>

    <% if (ready) { %>

        <!-- JOURNEY DETAILS -->

        <section class="card">

            <h2>Journey Information</h2>

            <div class="journey-grid">

                <div class="journey-item">

                    <label>Bus Name</label>

                    <strong>
                        <%= escapeHtml(bus.getBusName()) %>
                    </strong>

                </div>

                <div class="journey-item">

                    <label>Bus Type</label>

                    <strong>
                        <%= escapeHtml(bus.getBusType()) %>
                    </strong>

                </div>

                <div class="journey-item">

                    <label>Travel Date</label>

                    <strong>
                        <%= schedule.getTravelDate() %>
                    </strong>

                </div>

                <div class="journey-item">

                    <label>Selected Seats</label>

                    <strong>
                        <%= selectedSeats.size() %>
                    </strong>

                </div>

            </div>

        </section>

        <!-- PASSENGER FORM -->

        <form action="<%= contextPath %>/confirmBooking"
              method="post">

            <input type="hidden"
                   name="scheduleId"
                   value="<%= schedule.getScheduleId() %>">

            <div class="main-grid">

                <div>

                    <%
                        int passengerIndex = 0;

                        for (Seat seat : selectedSeats) {

                            int seatId = seat.getSeatId();

                            String displayLabel =
                                    seatLabelMap.get(seatId);

                            String category =
                                    getSeatCategory(seat, isSleeper);

                            BigDecimal individualFare =
                                    seatFareMap.get(seatId);
                    %>

                        <section class="card passenger-card">

                            <div class="passenger-header">

                                <div>

                                    <div class="passenger-number">
                                        Passenger <%= passengerIndex + 1 %>
                                    </div>

                                    <div class="seat-meta">

                                        <span class="seat-badge">
                                            Seat <%= escapeHtml(displayLabel) %>
                                        </span>

                                        <span class="category-badge">
                                            <%= escapeHtml(category) %>
                                        </span>

                                    </div>

                                </div>

                                <div class="fare-badge">
                                    ₹<%= individualFare.toPlainString() %>
                                </div>

                            </div>

                            <!-- Preserve original database seat ID -->

                            <input type="hidden"
                                   name="seatIds"
                                   value="<%= seatId %>">

                            <div class="form-grid">

                                <div class="form-group">

                                    <label for="passengerName<%= passengerIndex %>">
                                        Full Name
                                        <span class="required">*</span>
                                    </label>

                                    <input
                                        type="text"
                                        id="passengerName<%= passengerIndex %>"
                                        name="passengerName"
                                        required
                                        maxlength="100"
                                        autocomplete="off"
                                        placeholder="Passenger name">

                                </div>

                                <div class="form-group">

                                    <label for="age<%= passengerIndex %>">
                                        Age
                                        <span class="required">*</span>
                                    </label>

                                    <input
                                        type="number"
                                        id="age<%= passengerIndex %>"
                                        name="age"
                                        min="1"
                                        max="120"
                                        required
                                        placeholder="Age">

                                </div>

                                <div class="form-group">

                                    <label for="gender<%= passengerIndex %>">
                                        Gender
                                        <span class="required">*</span>
                                    </label>

                                    <select
                                        id="gender<%= passengerIndex %>"
                                        name="gender"
                                        required>

                                        <option value="">
                                            Select Gender
                                        </option>

                                        <option value="MALE">
                                            Male
                                        </option>

                                        <option value="FEMALE">
                                            Female
                                        </option>

                                        <option value="OTHER">
                                            Other
                                        </option>

                                    </select>

                                </div>

                                <div class="form-group">

                                    <label for="phone<%= passengerIndex %>">
                                        Phone
                                        <span class="optional">
                                            (Optional)
                                        </span>
                                    </label>

                                    <input
                                        type="tel"
                                        id="phone<%= passengerIndex %>"
                                        name="passengerPhone"
                                        maxlength="15"
                                        placeholder="Phone number">

                                </div>

                            </div>

                        </section>

                    <%
                            passengerIndex++;
                        }
                    %>

                </div>

                <!-- FARE SUMMARY -->

                <aside class="card summary-card">

                    <div class="summary-heading">

                        <h2>Fare Summary</h2>

                        <span class="count-badge">
                            <%= selectedSeats.size() %>
                            Seat<%= selectedSeats.size() == 1 ? "" : "s" %>
                        </span>

                    </div>

                    <% for (Seat seat : selectedSeats) {

                        int seatId = seat.getSeatId();

                        String category =
                                getSeatCategory(seat, isSleeper);
                    %>

                        <div class="summary-item">

                            <div>

                                <div class="summary-seat">
                                    Seat
                                    <%= escapeHtml(seatLabelMap.get(seatId)) %>
                                </div>

                                <div class="summary-category">
                                    <%= escapeHtml(category) %>
                                </div>

                            </div>

                            <div class="summary-price">
                                ₹<%= seatFareMap.get(seatId).toPlainString() %>
                            </div>

                        </div>

                    <% } %>

                    <div class="total-box">

                        <div class="total-label">
                            Total Amount
                        </div>

                        <div class="total-value">
                            ₹<%= totalAmount.toPlainString() %>
                        </div>

                    </div>

                    <p class="payment-note">
                        Fares are calculated securely by VazhiGo
                        using the selected seat categories.
                        You will proceed to the payment page
                        after confirming passenger details.
                    </p>

                    <div class="actions">

                        <a class="btn btn-back"
                           href="<%= contextPath %>/seatSelection?scheduleId=<%= schedule.getScheduleId() %>">
                            Back
                        </a>

                        <button type="submit"
                                class="btn btn-confirm">
                            Proceed to Payment →
                        </button>

                    </div>

                </aside>

            </div>

        </form>

    <% } else { %>

        <section class="card empty-state">

            <h2>Passenger Details Unavailable</h2>

            <p>
                We could not load the selected seats.
                Please return to the seat-selection page
                and select your seats again.
            </p>

            <a class="btn btn-back"
               href="<%= contextPath %>/search.jsp">
                Back to Search
            </a>

        </section>

    <% } %>

</main>

<footer class="footer">
    © 2026 VazhiGo — Your Journey, Our Priority
</footer>

</body>
</html>