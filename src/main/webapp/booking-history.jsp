<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.tnbus.model.Booking" %>

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

    @SuppressWarnings("unchecked")
    List<Booking> bookings =
            (List<Booking>) request.getAttribute("bookings");

    String errorMessage =
            (String) request.getAttribute("errorMessage");

    String contextPath = request.getContextPath();

    int totalBookings = bookings == null ? 0 : bookings.size();

    int confirmedCount = 0;
    int pendingCount = 0;
    int cancelledCount = 0;

    if (bookings != null) {

        for (Booking booking : bookings) {

            String status = booking.getBookingStatus();

            if ("CONFIRMED".equalsIgnoreCase(status)) {
                confirmedCount++;
            } else if ("CANCELLED".equalsIgnoreCase(status)) {
                cancelledCount++;
            } else if ("PENDING".equalsIgnoreCase(status)) {
                pendingCount++;
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

<title>My Bookings | VazhiGo</title>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #f4f7fb;
    color: #243247;
}

.navbar {
    background: #12355b;
    color: white;
    padding: 20px 6%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 15px;
}

.logo {
    font-size: 26px;
    font-weight: bold;
}

.logo span {
    color: #ffcb65;
}

.navbar a {
    color: white;
    text-decoration: none;
    font-size: 14px;
}

.container {
    max-width: 1150px;
    margin: 35px auto;
    padding: 0 20px;
}

.page-heading {
    margin-bottom: 25px;
}

.page-heading h1 {
    margin-bottom: 8px;
    color: #12355b;
}

.page-heading p {
    color: #68788c;
    line-height: 1.5;
}

.stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 15px;
    margin-bottom: 30px;
}

.stat-card {
    background: white;
    padding: 22px;
    border-radius: 12px;
    border: 1px solid #e5eaf0;
}

.stat-card h3 {
    margin: 0 0 12px;
    font-size: 13px;
    color: #68788c;
    text-transform: uppercase;
}

.stat-card strong {
    font-size: 30px;
    color: #12355b;
}

.booking-list {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.booking-card {
    background: white;
    border: 1px solid #e5eaf0;
    border-radius: 14px;
    overflow: hidden;
}

.booking-header {
    padding: 20px 24px;
    background: #f9fbfe;
    border-bottom: 1px solid #e5eaf0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;
}

.booking-header h3 {
    margin: 0 0 6px;
    color: #12355b;
}

.booking-date {
    font-size: 13px;
    color: #68788c;
}

.booking-body {
    padding: 24px;
}

.booking-info {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
}

.info-label {
    display: block;
    color: #68788c;
    font-size: 12px;
    margin-bottom: 9px;
}

.info-value {
    font-size: 15px;
    font-weight: bold;
    overflow-wrap: anywhere;
}

.amount {
    font-size: 22px;
    color: #12355b;
}

.badge {
    display: inline-block;
    padding: 7px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: bold;
}

.confirmed,
.paid {
    background: #e2f6e9;
    color: #18753a;
}

.pending {
    background: #fff1d5;
    color: #946000;
}

.cancelled,
.failed {
    background: #fde7e7;
    color: #a52d2d;
}

.unknown {
    background: #edf0f4;
    color: #536273;
}

.booking-actions {
    border-top: 1px solid #e5eaf0;
    padding: 18px 24px;
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
}

.btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 11px 17px;
    min-height: 42px;
    border-radius: 7px;
    font-size: 13px;
    font-weight: bold;
    text-decoration: none;
    transition: background 0.2s;
}

.btn-primary {
    background: #12355b;
    color: white;
}

.btn-primary:hover {
    background: #205082;
}

.btn-ticket {
    background: #e2f6e9;
    color: #18753a;
}

.btn-danger {
    background: #fde7e7;
    color: #a52d2d;
}

.btn-danger:hover {
    background: #fbd0d0;
}

.btn-payment {
    background: #fff1d5;
    color: #946000;
}

.cancelled-text {
    color: #a52d2d;
    font-size: 13px;
    font-weight: bold;
    align-self: center;
}

.empty-state {
    background: white;
    padding: 55px 25px;
    text-align: center;
    border-radius: 14px;
    border: 1px solid #e5eaf0;
}

.empty-state h2 {
    color: #12355b;
}

.empty-state p {
    color: #68788c;
    margin-bottom: 25px;
}

.error {
    padding: 17px;
    background: #fde7e7;
    color: #a52d2d;
    border-radius: 8px;
    margin-bottom: 20px;
}

.footer {
    text-align: center;
    padding: 30px 15px;
    color: #68788c;
    font-size: 13px;
}

@media (max-width: 850px) {

    .stats {
        grid-template-columns: repeat(2, 1fr);
    }

    .booking-info {
        grid-template-columns: repeat(2, 1fr);
    }
}

@media (max-width: 480px) {

    .container {
        margin-top: 25px;
        padding: 0 12px;
    }

    .stats {
        gap: 10px;
    }

    .stat-card {
        padding: 16px;
    }

    .booking-header,
    .booking-body,
    .booking-actions {
        padding: 17px;
    }

    .booking-info {
        gap: 22px 12px;
    }

    .booking-actions .btn {
        flex: 1 1 100%;
    }
}

</style>

</head>

<body>

<header class="navbar">

    <div class="logo">
        Vazhi<span>Go</span>
    </div>

    <a href="<%= contextPath %>/home.jsp">
        Back to Home
    </a>

</header>

<main class="container">

    <section class="page-heading">

        <h1>My Bookings</h1>

        <p>
            Track your journeys, view tickets and manage
            your booking history.
        </p>

    </section>

    <% if (errorMessage != null) { %>

        <div class="error">
            Unable to load booking history. Please try again.
        </div>

    <% } else { %>

        <!-- BOOKING SUMMARY -->

        <section class="stats">

            <div class="stat-card">
                <h3>Total Bookings</h3>
                <strong><%= totalBookings %></strong>
            </div>

            <div class="stat-card">
                <h3>Confirmed</h3>
                <strong><%= confirmedCount %></strong>
            </div>

            <div class="stat-card">
                <h3>Pending</h3>
                <strong><%= pendingCount %></strong>
            </div>

            <div class="stat-card">
                <h3>Cancelled</h3>
                <strong><%= cancelledCount %></strong>
            </div>

        </section>

        <% if (bookings == null || bookings.isEmpty()) { %>

            <!-- EMPTY BOOKING HISTORY -->

            <section class="empty-state">

                <h2>No bookings found</h2>

                <p>
                    Your upcoming journeys will appear here
                    once you make a booking.
                </p>

                <a class="btn btn-primary"
                   href="<%= contextPath %>/search.jsp">

                    Search for a Bus

                </a>

            </section>

        <% } else { %>

            <!-- BOOKING CARDS -->

            <section class="booking-list">

            <% for (Booking booking : bookings) {

                String bookingStatus =
                        booking.getBookingStatus() == null
                        ? "UNKNOWN"
                        : booking.getBookingStatus().trim();

                String paymentStatus =
                        booking.getPaymentStatus() == null
                        ? "UNKNOWN"
                        : booking.getPaymentStatus().trim();

                boolean confirmed =
                        "CONFIRMED".equalsIgnoreCase(bookingStatus);

                boolean paid =
                        "PAID".equalsIgnoreCase(paymentStatus);

                boolean pending =
                        "PENDING".equalsIgnoreCase(bookingStatus);

                boolean paymentPending =
                        "PENDING".equalsIgnoreCase(paymentStatus);

                boolean cancelled =
                        "CANCELLED".equalsIgnoreCase(bookingStatus);

                boolean canCancel =
                        (confirmed && paid)
                        || (pending && paymentPending);

                String bookingBadge =
                        confirmed ? "confirmed"
                        : cancelled ? "cancelled"
                        : pending ? "pending"
                        : "unknown";

                String paymentBadge =
                        paid ? "paid"
                        : paymentPending ? "pending"
                        : "FAILED".equalsIgnoreCase(paymentStatus)
                            ? "failed"
                            : "unknown";
            %>

                <article class="booking-card">

                    <div class="booking-header">

                        <div>

                            <h3>
                                Booking #<%= booking.getBookingId() %>
                            </h3>

                            <span class="booking-date">

                                Booked on:
                                <%= booking.getBookingDate() == null
                                    ? "Not available"
                                    : booking.getBookingDate()
                                        .toString()
                                        .replace("T", " ") %>

                            </span>

                        </div>

                        <span class="badge <%= bookingBadge %>">
                            <%= escapeHtml(bookingStatus) %>
                        </span>

                    </div>

                    <div class="booking-body">

                        <div class="booking-info">

                            <div>
                                <span class="info-label">
                                    Schedule ID
                                </span>

                                <span class="info-value">
                                    #<%= booking.getScheduleId() %>
                                </span>
                            </div>

                            <div>
                                <span class="info-label">
                                    Total Amount
                                </span>

                                <span class="info-value amount">
                                    &#8377;
                                    <%= booking.getTotalAmount() == null
                                        ? "0.00"
                                        : booking.getTotalAmount()
                                            .toPlainString() %>
                                </span>
                            </div>

                            <div>
                                <span class="info-label">
                                    Booking Status
                                </span>

                                <span class="badge <%= bookingBadge %>">
                                    <%= escapeHtml(bookingStatus) %>
                                </span>
                            </div>

                            <div>
                                <span class="info-label">
                                    Payment Status
                                </span>

                                <span class="badge <%= paymentBadge %>">
                                    <%= escapeHtml(paymentStatus) %>
                                </span>
                            </div>

                        </div>

                    </div>

                    <div class="booking-actions">

                        <a class="btn btn-primary"
                           href="<%= contextPath %>/bookingDetails?bookingId=<%= booking.getBookingId() %>">

                            View Details

                        </a>

                        <% if (confirmed && paid) { %>

                            <a class="btn btn-ticket"
                               href="<%= contextPath %>/viewTicket?bookingId=<%= booking.getBookingId() %>">

                                View Ticket

                            </a>
                            
                            <a class="btn btn-primary"
   href="<%= contextPath %>/trackJourney?bookingId=<%= booking.getBookingId() %>">

    Track Journey

</a>

                        <% } %>

                        <% if (pending && paymentPending) { %>

                            <a class="btn btn-payment"
                               href="<%= contextPath %>/payment?bookingId=<%= booking.getBookingId() %>">

                                Complete Payment

                            </a>

                        <% } %>

                        <% if (canCancel) { %>

                            <a class="btn btn-danger"
                               href="<%= contextPath %>/cancel-booking.jsp?bookingId=<%= booking.getBookingId() %>">

                                Cancel Booking

                            </a>

                        <% } else if (cancelled) { %>

                            <span class="cancelled-text">
                                Booking Cancelled
                            </span>

                        <% } %>

                    </div>

                </article>

            <% } %>

            </section>

        <% } %>

    <% } %>

</main>

<footer class="footer">

    VazhiGo &copy; 2026 |
    Your Journey, Our Priority

</footer>

</body>
</html>