<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="com.tnbus.model.Booking" %>
<%@ page import="com.tnbus.model.Payment" %>
<%@ page import="com.tnbus.model.User" %>
<%@ page import="com.tnbus.service.BookingService" %>
<%@ page import="com.tnbus.service.PaymentService" %>

<%!
    private String escapeHtml(Object value) {

        if (value == null) return "";

        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    User user =
            (User) session.getAttribute("loggedInUser");

    if (user == null) {

        response.sendRedirect(
                request.getContextPath() + "/login.jsp");

        return;
    }

    long bookingId;

    try {

        bookingId = Long.parseLong(
                request.getParameter("bookingId"));

        if (bookingId <= 0) {
            throw new NumberFormatException();
        }

    } catch (NumberFormatException e) {

        response.sendError(400, "Invalid booking ID.");
        return;
    }

    BookingService bookingService = new BookingService();
    PaymentService paymentService = new PaymentService();

    Booking booking;
    Payment payment;

    try {

        booking = bookingService.getBookingById(bookingId);

        if (booking == null
                || booking.getUserId() != user.getUserId()) {

            response.sendError(404, "Booking not found.");
            return;
        }

        payment =
                paymentService.getPaymentByBookingId(bookingId);

        if (payment == null
                || !"SUCCESS".equalsIgnoreCase(
                        payment.getPaymentStatus())
                || !"PAID".equalsIgnoreCase(
                        booking.getPaymentStatus())) {

            response.sendRedirect(
                    request.getContextPath() + "/myBookings");

            return;
        }

    } catch (Exception e) {

        response.sendError(
                500, "Unable to load payment details.");

        return;
    }

    String ctx = request.getContextPath();

    boolean confirmed =
            "CONFIRMED".equalsIgnoreCase(
                    booking.getBookingStatus());
%>

<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Payment Successful | VazhiGo</title>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    background: #f3f6fb;
    font-family: Arial, sans-serif;
    color: #243247;
}

.navbar {
    background: #12355b;
    padding: 20px 6%;
}

.logo {
    font-size: 26px;
    font-weight: bold;
    color: white;
    text-decoration: none;
}

.logo span {
    color: #ffcb65;
}

.container {
    max-width: 680px;
    margin: 45px auto;
    padding: 0 15px;
}

.success-card {
    background: white;
    border: 1px solid #e2e9f1;
    border-radius: 16px;
    overflow: hidden;
}

.success-header {
    text-align: center;
    padding: 35px 25px;
    background: #edfaf1;
}

.success-icon {
    width: 72px;
    height: 72px;
    border-radius: 50%;
    background: #1d934c;
    color: white;
    font-size: 37px;
    font-weight: bold;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 20px;
}

.success-header h1 {
    color: #18753a;
    font-size: 27px;
    margin: 0 0 12px;
}

.success-header p {
    color: #426650;
    font-size: 14px;
    line-height: 1.7;
    margin: 0;
}

.receipt {
    padding: 30px;
}

.receipt-title {
    font-size: 17px;
    font-weight: bold;
    color: #12355b;
    margin-bottom: 25px;
}

.reference {
    background: #eef4fa;
    padding: 20px;
    border-radius: 10px;
    margin-bottom: 25px;
}

.label {
    display: block;
    color: #718095;
    font-size: 12px;
    margin-bottom: 8px;
}

.reference strong {
    font-size: 23px;
    color: #12355b;
}

.row {
    display: flex;
    justify-content: space-between;
    gap: 15px;
    padding: 14px 0;
    border-bottom: 1px solid #e9eef4;
    font-size: 14px;
}

.row:last-child {
    border-bottom: none;
}

.row span {
    color: #718095;
    flex-shrink: 0;
}

.row strong {
    color: #12355b;
    text-align: right;
    overflow-wrap: anywhere;
}

.amount {
    font-size: 22px;
    color: #18753a !important;
}

.status {
    display: inline-block;
    background: #e2f6e9;
    color: #18753a;
    border-radius: 20px;
    padding: 7px 12px;
    font-size: 12px;
}

.pending-status {
    background: #fff1d5;
    color: #946000;
}

.transaction {
    background: #f8fafc;
    border: 1px dashed #ccd6e2;
    border-radius: 9px;
    padding: 16px;
    margin-top: 20px;
}

.transaction strong {
    color: #12355b;
    font-size: 13px;
    overflow-wrap: anywhere;
    word-break: break-word;
}

.actions {
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    margin-top: 28px;
}

.btn {
    flex: 1 1 180px;
    min-height: 46px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 13px 17px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: bold;
    text-decoration: none;
    text-align: center;
}

.btn-primary {
    background: #12355b;
    color: white;
}

.btn-secondary {
    background: #eef4fa;
    color: #12355b;
}

.note {
    text-align: center;
    font-size: 12px;
    color: #718095;
    line-height: 1.7;
    margin-top: 22px;
}

.footer {
    text-align: center;
    padding: 25px 15px;
    font-size: 12px;
    color: #718095;
}

@media(max-width: 480px) {

    .container {
        margin-top: 20px;
    }

    .receipt {
        padding: 20px;
    }

    .row {
        font-size: 12px;
    }

    .row span {
        flex-shrink: 1;
    }
}

</style>
</head>

<body>

<header class="navbar">

    <a class="logo" href="<%= ctx %>/home.jsp">
        Vazhi<span>Go</span>
    </a>

</header>

<main class="container">

    <section class="success-card">

        <div class="success-header">

            <div class="success-icon" aria-hidden="true">
                &#10003;
            </div>

            <h1>Payment Successful!</h1>

            <p>
                Your demo payment has been processed successfully.
                <% if (confirmed) { %>
                    Your bus booking is confirmed.
                <% } %>
            </p>

        </div>

        <div class="receipt">

            <div class="receipt-title">
                Payment Receipt
            </div>

            <div class="reference">

                <span class="label">
                    BOOKING REFERENCE
                </span>

                <strong>
                    VG-<%= booking.getBookingId() %>
                </strong>

            </div>

            <div class="row">

                <span>Booking ID</span>

                <strong>
                    #<%= booking.getBookingId() %>
                </strong>

            </div>

            <div class="row">

                <span>Amount Paid</span>

                <strong class="amount">
                    &#8377;<%= payment.getAmount() == null
                        ? "0.00"
                        : payment.getAmount().toPlainString() %>
                </strong>

            </div>

            <div class="row">

                <span>Payment Method</span>

                <strong>
                    <%= escapeHtml(
                        payment.getPaymentMethod()) %>
                </strong>

            </div>

            <div class="row">

                <span>Payment Status</span>

                <strong>
                    <span class="status">
                        <%= escapeHtml(
                            payment.getPaymentStatus()) %>
                    </span>
                </strong>

            </div>

            <div class="row">

                <span>Booking Status</span>

                <strong>

                    <span class="status <%= confirmed
                        ? ""
                        : "pending-status" %>">

                        <%= escapeHtml(
                            booking.getBookingStatus()) %>

                    </span>

                </strong>

            </div>

            <div class="transaction">

                <span class="label">
                    TRANSACTION REFERENCE
                </span>

                <strong>
                    <%= escapeHtml(
                        payment.getTransactionReference()) %>
                </strong>

            </div>

            <div class="actions">

                <% if (confirmed) { %>

                    <a class="btn btn-primary"
                       href="<%= ctx %>/viewTicket?bookingId=<%= booking.getBookingId() %>">

                        View E-Ticket &rarr;

                    </a>

                <% } %>

                <a class="btn btn-secondary"
                   href="<%= ctx %>/myBookings">

                    View My Bookings

                </a>

            </div>

            <p class="note">
                VazhiGo academic demonstration.
                No real money has been transferred.
            </p>

        </div>

    </section>

</main>

<footer class="footer">
    VazhiGo &copy; 2026 | Your Journey, Our Priority
</footer>

</body>
</html>