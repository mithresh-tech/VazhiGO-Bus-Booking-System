<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="com.tnbus.model.TicketDetails" %>
<%@ page import="com.tnbus.model.TicketDetails.TicketPassenger" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%!
    private String escapeHtml(Object value) {

        if (value == null) {
            return "";
        }

        return String.valueOf(value)
                .replace("&", "&amp;")
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

    TicketDetails ticket =
            (TicketDetails) request.getAttribute("ticket");

    if (ticket == null) {

        response.sendRedirect(
                request.getContextPath() + "/myBookings");

        return;
    }

    String contextPath = request.getContextPath();

    DateTimeFormatter dateFormat =
            DateTimeFormatter.ofPattern("dd MMM yyyy");

    DateTimeFormatter timeFormat =
            DateTimeFormatter.ofPattern("hh:mm a");

    String travelDate =
            ticket.getTravelDate() == null
            ? "Not available"
            : ticket.getTravelDate().format(dateFormat);

    String departureTime =
            ticket.getDepartureTime() == null
            ? "Not available"
            : ticket.getDepartureTime().format(timeFormat);

    String arrivalTime =
            ticket.getArrivalTime() == null
            ? "Not available"
            : ticket.getArrivalTime().format(timeFormat);

    boolean sleeper =
            ticket.getBusType() != null
            && ticket.getBusType().toUpperCase(
                    java.util.Locale.ROOT).contains("SLEEPER");
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>
    VazhiGo E-Ticket #<%= ticket.getBookingId() %>
</title>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    padding: 30px 15px;
    font-family: Arial, sans-serif;
    background: #edf2f8;
    color: #243247;
}

.ticket {
    max-width: 850px;
    margin: auto;
    background: white;
    border: 1px solid #dce5ef;
    border-radius: 16px;
    overflow: hidden;
}

.ticket-header {
    background: #12355b;
    color: white;
    padding: 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 15px;
}

.brand {
    font-size: 32px;
    font-weight: bold;
}

.brand span {
    color: #ffcb65;
}

.tagline {
    font-size: 12px;
    margin-top: 6px;
    color: #dce7f4;
}

.ticket-type {
    text-align: right;
}

.ticket-type strong {
    display: block;
    font-size: 19px;
    margin-bottom: 8px;
}

.confirmed {
    display: inline-block;
    background: #dff6e7;
    color: #176b37;
    padding: 8px 13px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: bold;
}

.ticket-content {
    padding: 30px;
}

.reference {
    display: flex;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 15px;
    padding-bottom: 23px;
    border-bottom: 1px dashed #ccd6e2;
}

.label {
    display: block;
    color: #718095;
    font-size: 12px;
    margin-bottom: 8px;
}

.value {
    display: block;
    font-size: 15px;
    font-weight: bold;
    overflow-wrap: anywhere;
}

.reference .value {
    font-size: 19px;
    color: #12355b;
}

.section {
    margin-top: 28px;
}

.section h2 {
    font-size: 17px;
    color: #12355b;
    margin: 0 0 20px;
    padding-bottom: 12px;
    border-bottom: 1px solid #e6ebf1;
}

.route {
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    align-items: center;
    gap: 15px;
    background: #f4f7fb;
    border-radius: 12px;
    padding: 25px;
}

.city {
    font-size: 22px;
    font-weight: bold;
    color: #12355b;
    overflow-wrap: anywhere;
}

.destination {
    text-align: right;
}

.route-line {
    font-size: 25px;
    color: #718095;
}

.journey-grid,
.bus-grid,
.payment-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 22px;
}

.bus-grid {
    grid-template-columns: repeat(2, 1fr);
}

.payment-grid {
    grid-template-columns: repeat(3, 1fr);
}

.table-wrap {
    width: 100%;
    overflow-x: auto;
}

table {
    width: 100%;
    border-collapse: collapse;
    min-width: 480px;
}

th {
    background: #eef3f9;
    color: #12355b;
    text-align: left;
    font-size: 12px;
    padding: 14px;
}

td {
    padding: 14px;
    border-bottom: 1px solid #e6ebf1;
    font-size: 13px;
}

.seat {
    display: inline-block;
    background: #e5eef8;
    color: #12355b;
    padding: 7px 11px;
    border-radius: 6px;
    font-weight: bold;
}

.fare {
    color: #12355b;
    font-size: 24px;
    font-weight: bold;
}

.paid {
    color: #18753a;
    font-weight: bold;
}

.ticket-footer {
    border-top: 1px dashed #ccd6e2;
    margin-top: 30px;
    padding-top: 20px;
    color: #718095;
    font-size: 12px;
    line-height: 1.7;
}

.actions {
    max-width: 850px;
    margin: 25px auto;
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 12px;
}

.btn {
    border: none;
    border-radius: 8px;
    padding: 14px 22px;
    min-height: 44px;
    font-size: 14px;
    font-weight: bold;
    text-decoration: none;
    cursor: pointer;
}

.btn-primary {
    background: #12355b;
    color: white;
}

.btn-secondary {
    background: white;
    color: #12355b;
    border: 1px solid #ccd6e2;
}

@media (max-width: 600px) {

    body {
        padding: 12px;
    }

    .ticket-header,
    .ticket-content {
        padding: 20px;
    }

    .ticket-type {
        text-align: left;
    }

    .route {
        padding: 17px;
        gap: 8px;
    }

    .city {
        font-size: 16px;
    }

    .journey-grid,
    .payment-grid {
        grid-template-columns: repeat(2, 1fr);
    }

    .bus-grid {
        grid-template-columns: 1fr 1fr;
    }

    .actions .btn {
        flex: 1 1 100%;
        text-align: center;
    }
}

@media print {

    @page {
        size: A4;
        margin: 12mm;
    }

    body {
        padding: 0;
        background: white;
        -webkit-print-color-adjust: exact;
        print-color-adjust: exact;
    }

    .ticket {
        max-width: 100%;
        border: 1px solid #ddd;
        border-radius: 0;
    }

    .actions {
        display: none !important;
    }

    .section,
    .reference,
    .route,
    tr {
        break-inside: avoid;
    }

    .ticket-header {
        background: #12355b !important;
        color: white !important;
    }
}

</style>

</head>

<body>

<main class="ticket">

    <!-- BRAND HEADER -->

    <header class="ticket-header">

        <div>

            <div class="brand">
                Vazhi<span>Go</span>
            </div>

            <div class="tagline">
                Your Journey, Our Priority
            </div>

        </div>

        <div class="ticket-type">

            <strong>Electronic Bus Ticket</strong>

            <span class="confirmed">
                BOOKING CONFIRMED
            </span>

        </div>

    </header>

    <div class="ticket-content">

        <!-- BOOKING REFERENCE -->

        <div class="reference">

            <div>

                <span class="label">
                    Booking Reference
                </span>

                <span class="value">
                    VG-<%= ticket.getBookingId() %>
                </span>

            </div>

            <div>

                <span class="label">
                    Booking ID
                </span>

                <span class="value">
                    #<%= ticket.getBookingId() %>
                </span>

            </div>

        </div>

        <!-- JOURNEY -->

        <section class="section">

            <h2>Journey Information</h2>

            <div class="route">

                <div>

                    <span class="label">FROM</span>

                    <div class="city">
                        <%= escapeHtml(ticket.getSourceCity()) %>
                    </div>

                </div>

                <div class="route-line">
                    &#8594;
                </div>

                <div class="destination">

                    <span class="label">TO</span>

                    <div class="city">
                        <%= escapeHtml(ticket.getDestinationCity()) %>
                    </div>

                </div>

            </div>

            <div class="journey-grid"
                 style="margin-top:22px;">

                <div>
                    <span class="label">Travel Date</span>
                    <span class="value">
                        <%= travelDate %>
                    </span>
                </div>

                <div>
                    <span class="label">Departure</span>
                    <span class="value">
                        <%= departureTime %>
                    </span>
                </div>

                <div>
                    <span class="label">Arrival</span>
                    <span class="value">
                        <%= arrivalTime %>
                    </span>
                </div>

            </div>

        </section>

        <!-- BUS INFORMATION -->

        <section class="section">

            <h2>Bus Information</h2>

            <div class="bus-grid">

                <div>
                    <span class="label">Bus Name</span>
                    <span class="value">
                        <%= escapeHtml(ticket.getBusName()) %>
                    </span>
                </div>

                <div>
                    <span class="label">Bus Number</span>
                    <span class="value">
                        <%= escapeHtml(ticket.getBusNumber()) %>
                    </span>
                </div>

                <div>
                    <span class="label">Bus Type</span>
                    <span class="value">
                        <%= escapeHtml(ticket.getBusType()) %>
                    </span>
                </div>

                <div>
                    <span class="label">Seat Category</span>
                    <span class="value">
                        <%= sleeper ? "Sleeper" : "Seater" %>
                    </span>
                </div>

            </div>

        </section>

        <!-- PASSENGER DETAILS -->

        <section class="section">

            <h2>Passenger Details</h2>

            <div class="table-wrap">

                <table>

                    <thead>

                        <tr>
                            <th>S.No</th>
                            <th>Passenger Name</th>
                            <th>Age</th>
                            <th>Gender</th>
                            <th>Seat Number</th>
                        </tr>

                    </thead>

                    <tbody>

                    <%
                        int serialNumber = 1;

                        if (ticket.getPassengers() != null) {

                            for (TicketPassenger passenger :
                                    ticket.getPassengers()) {
                    %>

                        <tr>

                            <td>
                                <%= serialNumber++ %>
                            </td>

                            <td>
                                <%= escapeHtml(
                                    passenger.getPassengerName()) %>
                            </td>

                            <td>
                                <%= passenger.getAge() %>
                            </td>

                            <td>
                                <%= escapeHtml(
                                    passenger.getGender()) %>
                            </td>

                            <td>
                                <span class="seat">
                                    <%= escapeHtml(
                                        passenger.getSeatNumber()) %>
                                </span>
                            </td>

                        </tr>

                    <%
                            }
                        }
                    %>

                    </tbody>

                </table>

            </div>

        </section>

        <!-- PAYMENT -->

        <section class="section">

            <h2>Payment Summary</h2>

            <div class="payment-grid">

                <div>

                    <span class="label">Total Fare</span>

                    <span class="fare">
                        &#8377;<%= ticket.getTotalAmount() == null
                            ? "0.00"
                            : ticket.getTotalAmount().toPlainString() %>
                    </span>

                </div>

                <div>

                    <span class="label">Booking Status</span>

                    <span class="paid">
                        <%= escapeHtml(ticket.getBookingStatus()) %>
                    </span>

                </div>

                <div>

                    <span class="label">Payment Status</span>

                    <span class="paid">
                        <%= escapeHtml(ticket.getPaymentStatus()) %>
                    </span>

                </div>

            </div>

        </section>

        <!-- FOOTER -->

        <footer class="ticket-footer">

            <strong>Important Information</strong>

            <p>
                Please verify your journey details before departure.
                Carry a valid identity document when travelling.
            </p>

            <p>
                This ticket is generated by VazhiGo for academic
                demonstration purposes. Payment processing is simulated.
            </p>

            <p>
                VazhiGo &copy; 2026 |
                Your Journey, Our Priority
            </p>

        </footer>

    </div>

</main>

<!-- PRINT ACTIONS -->

<div class="actions">

    <button class="btn btn-primary"
            type="button"
            onclick="window.print()">

        Print / Save as PDF

    </button>

    <a class="btn btn-secondary"
       href="<%= contextPath %>/myBookings">

        Back to My Bookings

    </a>

</div>

</body>
</html>