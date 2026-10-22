<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.tnbus.model.Booking" %>
<%@ page import="com.tnbus.model.BookingPassenger" %>

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

    Booking booking =
            (Booking) request.getAttribute("booking");

    @SuppressWarnings("unchecked")
    List<BookingPassenger> passengers =
            (List<BookingPassenger>)
                    request.getAttribute("passengers");

    String errorMessage =
            (String) request.getAttribute("errorMessage");

    String contextPath = request.getContextPath();

    boolean confirmed = false;
    boolean paid = false;
    boolean pending = false;
    boolean paymentPending = false;
    boolean cancelled = false;
    boolean canCancel = false;

    String bookingStatus = "UNKNOWN";
    String paymentStatus = "UNKNOWN";

    if (booking != null) {

        bookingStatus =
                booking.getBookingStatus() == null
                ? "UNKNOWN"
                : booking.getBookingStatus().trim();

        paymentStatus =
                booking.getPaymentStatus() == null
                ? "UNKNOWN"
                : booking.getPaymentStatus().trim();

        confirmed =
                "CONFIRMED".equalsIgnoreCase(bookingStatus);

        paid =
                "PAID".equalsIgnoreCase(paymentStatus);

        pending =
                "PENDING".equalsIgnoreCase(bookingStatus);

        paymentPending =
                "PENDING".equalsIgnoreCase(paymentStatus);

        cancelled =
                "CANCELLED".equalsIgnoreCase(bookingStatus);

        canCancel =
                (confirmed && paid)
                || (pending && paymentPending);
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Booking Details | VazhiGo</title>

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
    padding: 20px 6%;
    color: white;
    display: flex;
    justify-content: space-between;
    align-items: center;
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
    max-width: 1050px;
    margin: 35px auto;
    padding: 0 20px;
}

.page-heading {
    margin-bottom: 25px;
}

.page-heading h1 {
    color: #12355b;
    margin-bottom: 8px;
}

.page-heading p {
    color: #68788c;
    line-height: 1.5;
}

.card {
    background: white;
    border: 1px solid #e5eaf0;
    border-radius: 14px;
    margin-bottom: 22px;
    overflow: hidden;
}

.card-header {
    padding: 20px 24px;
    border-bottom: 1px solid #e5eaf0;
    background: #f9fbfe;
}

.card-header h2 {
    margin: 0;
    font-size: 19px;
    color: #12355b;
}

.card-body {
    padding: 24px;
}

.details-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 25px 20px;
}

.label {
    display: block;
    color: #68788c;
    font-size: 12px;
    margin-bottom: 9px;
}

.value {
    font-size: 15px;
    font-weight: bold;
    overflow-wrap: anywhere;
}

.amount {
    color: #12355b;
    font-size: 24px;
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

.table-wrap {
    width: 100%;
    overflow-x: auto;
}

table {
    width: 100%;
    border-collapse: collapse;
    min-width: 560px;
}

th {
    background: #f1f5fa;
    color: #12355b;
    font-size: 13px;
    text-align: left;
    padding: 15px;
}

td {
    padding: 15px;
    border-bottom: 1px solid #e5eaf0;
    font-size: 14px;
}

tr:last-child td {
    border-bottom: none;
}

.seat-badge {
    background: #e9f0f8;
    color: #12355b;
    padding: 6px 10px;
    border-radius: 6px;
    font-weight: bold;
}

.actions {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    margin-top: 25px;
}

.btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 44px;
    padding: 12px 18px;
    border-radius: 7px;
    font-size: 13px;
    font-weight: bold;
    text-decoration: none;
}

.btn-primary {
    background: #12355b;
    color: white;
}

.btn-ticket {
    background: #e2f6e9;
    color: #18753a;
}

.btn-payment {
    background: #fff1d5;
    color: #946000;
}

.btn-danger {
    background: #fde7e7;
    color: #a52d2d;
}

.error {
    background: #fde7e7;
    color: #a52d2d;
    padding: 18px;
    border-radius: 8px;
    margin-bottom: 20px;
}

.info-note {
    font-size: 13px;
    color: #68788c;
    margin-top: 18px;
    line-height: 1.6;
}

.footer {
    text-align: center;
    padding: 30px 15px;
    color: #68788c;
    font-size: 13px;
}

@media (max-width: 700px) {

    .details-grid {
        grid-template-columns: repeat(2, 1fr);
    }

}

@media (max-width: 480px) {

    .container {
        padding: 0 12px;
        margin-top: 25px;
    }

    .details-grid {
        grid-template-columns: 1fr 1fr;
        gap: 22px 12px;
    }

    .card-header,
    .card-body {
        padding: 17px;
    }

    .actions .btn {
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

    <a href="<%= contextPath %>/myBookings">
        Back to My Bookings
    </a>

</header>

<main class="container">

    <section class="page-heading">

        <h1>Booking Details</h1>

        <p>
            Review your reservation, passenger information
            and payment status.
        </p>

    </section>

    <% if (errorMessage != null || booking == null) { %>

        <div class="error">

            <%= errorMessage == null
                ? "Booking details could not be found."
                : "Unable to display booking details. Please try again." %>

        </div>

        <a class="btn btn-primary"
           href="<%= contextPath %>/myBookings">

            Back to My Bookings

        </a>

    <% } else {

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

        <!-- BOOKING INFORMATION -->

        <section class="card">

            <div class="card-header">
                <h2>Reservation Information</h2>
            </div>

            <div class="card-body">

                <div class="details-grid">

                    <div>
                        <span class="label">Booking ID</span>

                        <span class="value">
                            #<%= booking.getBookingId() %>
                        </span>
                    </div>

                    <div>
                        <span class="label">Schedule ID</span>

                        <span class="value">
                            #<%= booking.getScheduleId() %>
                        </span>
                    </div>

                    <div>
                        <span class="label">Booking Date</span>

                        <span class="value">

                            <%= booking.getBookingDate() == null
                                ? "Not available"
                                : escapeHtml(
                                    booking.getBookingDate()
                                        .toString()
                                        .replace("T", " ")
                                  ) %>

                        </span>
                    </div>

                    <div>
                        <span class="label">Total Amount</span>

                        <span class="value amount">

                            &#8377;<%= booking.getTotalAmount() == null
                                ? "0.00"
                                : booking.getTotalAmount()
                                    .toPlainString() %>

                        </span>
                    </div>

                    <div>
                        <span class="label">Booking Status</span>

                        <span class="badge <%= bookingBadge %>">
                            <%= escapeHtml(bookingStatus) %>
                        </span>
                    </div>

                    <div>
                        <span class="label">Payment Status</span>

                        <span class="badge <%= paymentBadge %>">
                            <%= escapeHtml(paymentStatus) %>
                        </span>
                    </div>

                </div>

            </div>

        </section>

        <!-- PASSENGER INFORMATION -->

        <section class="card">

            <div class="card-header">
                <h2>Passenger Information</h2>
            </div>

            <div class="card-body">

                <% if (passengers == null || passengers.isEmpty()) { %>

                    <p>No passenger details found.</p>

                <% } else { %>

                    <div class="table-wrap">

                        <table>

                            <thead>

                                <tr>
                                    <th>S.No</th>
                                    <th>Passenger Name</th>
                                    <th>Age</th>
                                    <th>Gender</th>
                                    <th>Phone Number</th>
                                    <th>Seat ID</th>
                                </tr>

                            </thead>

                            <tbody>

                            <%
                                int serialNumber = 1;

                                for (BookingPassenger passenger : passengers) {
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
                                        <%= escapeHtml(
                                            passenger.getPassengerPhone()) %>
                                    </td>

                                    <td>
                                        <span class="seat-badge">
                                            #<%= passenger.getSeatId() %>
                                        </span>
                                    </td>

                                </tr>

                            <% } %>

                            </tbody>

                        </table>

                    </div>

                    <p class="info-note">
                        Seat IDs shown here are internal reservation
                        references. Actual seat numbers are available
                        on the confirmed e-ticket.
                    </p>

                <% } %>

            </div>

        </section>

        <!-- ACTION BUTTONS -->

        <div class="actions">

            <a class="btn btn-primary"
               href="<%= contextPath %>/myBookings">

                Back to My Bookings

            </a>

            <% if (confirmed && paid) { %>

                <a class="btn btn-ticket"
                   href="<%= contextPath %>/viewTicket?bookingId=<%= booking.getBookingId() %>">

                    View E-Ticket

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

            <% } %>

        </div>

    <% } %>

</main>

<footer class="footer">

    VazhiGo &copy; 2026 |
    Your Journey, Our Priority

</footer>

</body>
</html>