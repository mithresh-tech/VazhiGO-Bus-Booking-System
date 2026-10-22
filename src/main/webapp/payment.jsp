<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="com.tnbus.model.Booking" %>

<%
    if (session.getAttribute("loggedInUser") == null) {
        response.sendRedirect(
                request.getContextPath() + "/login.jsp");
        return;
    }

    Booking booking =
            (Booking) request.getAttribute("booking");

    if (booking == null) {
        response.sendRedirect(
                request.getContextPath() + "/myBookings");
        return;
    }

    String errorMessage =
            (String) request.getAttribute("errorMessage");

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Complete Payment | VazhiGo</title>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    background: #f3f6fb;
    color: #243247;
    font-family: Arial, sans-serif;
}

.navbar {
    background: #12355b;
    padding: 20px 6%;
    color: white;
}

.logo {
    color: white;
    text-decoration: none;
    font-size: 26px;
    font-weight: bold;
}

.logo span {
    color: #ffcb65;
}

.container {
    max-width: 950px;
    margin: 40px auto;
    padding: 0 20px;
}

.heading {
    margin-bottom: 25px;
}

.heading h1 {
    color: #12355b;
    margin-bottom: 9px;
}

.heading p {
    color: #718095;
    font-size: 14px;
}

.checkout {
    display: grid;
    grid-template-columns: minmax(0, 1.5fr) minmax(0, 1fr);
    gap: 22px;
    align-items: start;
}

.panel {
    background: white;
    border: 1px solid #e2e9f1;
    border-radius: 14px;
    padding: 27px;
    min-width: 0;
}

.panel h2 {
    font-size: 19px;
    color: #12355b;
    margin: 0 0 8px;
}

.subtitle {
    font-size: 13px;
    color: #718095;
    margin-bottom: 24px;
    line-height: 1.6;
}

.payment-option {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 18px;
    margin-bottom: 12px;
    border: 2px solid #e2e9f1;
    border-radius: 10px;
    cursor: pointer;
    transition: border-color .2s, background .2s;
}

.payment-option:has(input:checked) {
    border-color: #12355b;
    background: #eef4fa;
}

.payment-option input {
    accent-color: #12355b;
    width: 18px;
    height: 18px;
    flex-shrink: 0;
}

.payment-option strong {
    display: block;
    color: #12355b;
    font-size: 14px;
}

.payment-option small {
    display: block;
    color: #718095;
    font-size: 12px;
    margin-top: 5px;
}

.option-icon {
    width: 42px;
    height: 42px;
    background: #e9f1f9;
    border-radius: 9px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 21px;
    flex-shrink: 0;
}

.summary-row {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    margin: 19px 0;
    font-size: 14px;
}

.summary-row span {
    color: #718095;
}

.summary-row strong {
    color: #12355b;
    text-align: right;
    overflow-wrap: anywhere;
}

.divider {
    border: none;
    border-top: 1px dashed #ccd6e2;
    margin: 25px 0;
}

.total-label {
    color: #718095;
    font-size: 13px;
}

.total-amount {
    font-size: 32px;
    color: #12355b;
    font-weight: bold;
    margin-top: 10px;
    overflow-wrap: anywhere;
}

.status {
    background: #fff1d5;
    color: #946000;
    padding: 7px 11px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: bold;
}

.note {
    background: #fff8e9;
    border: 1px solid #f4dfae;
    border-radius: 9px;
    padding: 15px;
    font-size: 12px;
    color: #77571a;
    line-height: 1.7;
    margin: 22px 0;
}

.btn {
    display: block;
    width: 100%;
    background: #12355b;
    color: white;
    border: none;
    border-radius: 8px;
    padding: 16px;
    min-height: 48px;
    font-weight: bold;
    font-size: 14px;
    cursor: pointer;
}

.btn:disabled {
    opacity: .65;
    cursor: wait;
}

.back {
    display: inline-block;
    color: #12355b;
    text-decoration: none;
    margin-top: 20px;
    font-size: 13px;
    font-weight: bold;
}

.error {
    background: #fde7e7;
    color: #a52d2d;
    padding: 14px;
    border-radius: 8px;
    margin-bottom: 20px;
    font-size: 13px;
}

.footer {
    text-align: center;
    padding: 35px 15px;
    font-size: 12px;
    color: #718095;
}

@media(max-width: 700px) {

    .checkout {
        grid-template-columns: 1fr;
    }

    .container {
        margin-top: 25px;
        padding: 0 13px;
    }

    .panel {
        padding: 20px;
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

    <div class="heading">

        <h1>Complete Your Payment</h1>

        <p>
            You're just one step away from confirming your journey.
        </p>

    </div>

    <% if (errorMessage != null) { %>

        <div class="error" role="alert">
            Payment could not be completed. Please check
            your booking and try again.
        </div>

    <% } %>

    <div class="checkout">

        <!-- PAYMENT METHODS -->

        <section class="panel">

            <h2>Select Payment Method</h2>

            <p class="subtitle">
                Choose your preferred demo payment option.
            </p>

            <form id="paymentForm"
                  action="<%= ctx %>/payment"
                  method="post">

                <input type="hidden"
                       name="bookingId"
                       value="<%= booking.getBookingId() %>">

                <label class="payment-option">

                    <input type="radio"
                           name="paymentMethod"
                           value="UPI"
                           checked
                           required>

                    <span class="option-icon" aria-hidden="true">
                        &#128241;
                    </span>

                    <span>
                        <strong>UPI</strong>
                        <small>Demo UPI payment</small>
                    </span>

                </label>

                <label class="payment-option">

                    <input type="radio"
                           name="paymentMethod"
                           value="CARD">

                    <span class="option-icon" aria-hidden="true">
                        &#128179;
                    </span>

                    <span>
                        <strong>Debit / Credit Card</strong>
                        <small>Simulated card payment</small>
                    </span>

                </label>

                <label class="payment-option">

                    <input type="radio"
                           name="paymentMethod"
                           value="NET_BANKING">

                    <span class="option-icon" aria-hidden="true">
                        &#127974;
                    </span>

                    <span>
                        <strong>Net Banking</strong>
                        <small>Simulated bank payment</small>
                    </span>

                </label>

                <div class="note">

                    <strong>Academic demonstration only.</strong>
                    No actual money will be transferred.
                    Do not enter real banking credentials.

                </div>

                <button id="payButton"
                        class="btn"
                        type="submit">

                    Confirm Demo Payment

                </button>

            </form>

            <a class="back" href="<%= ctx %>/myBookings">
                &larr; Back to My Bookings
            </a>

        </section>

        <!-- BOOKING SUMMARY -->

        <aside class="panel">

            <h2>Booking Summary</h2>

            <p class="subtitle">
                Review your reservation before confirming.
            </p>

            <div class="summary-row">
                <span>Booking ID</span>
                <strong>#<%= booking.getBookingId() %></strong>
            </div>

            <div class="summary-row">
                <span>Schedule ID</span>
                <strong>#<%= booking.getScheduleId() %></strong>
            </div>

            <div class="summary-row">
                <span>Booking Status</span>
                <strong>
                    <span class="status">
                        <%= booking.getBookingStatus() %>
                    </span>
                </strong>
            </div>

            <hr class="divider">

            <div class="total-label">
                TOTAL PAYABLE
            </div>

            <div class="total-amount">
                &#8377;<%= booking.getTotalAmount() == null
                    ? "0.00"
                    : booking.getTotalAmount().toPlainString() %>
            </div>

            <p class="subtitle" style="margin-top:15px; margin-bottom:0;">
                Your ticket will be available after
                successful demo payment.
            </p>

        </aside>

    </div>

</main>

<footer class="footer">
    VazhiGo &copy; 2026 | Your Journey, Our Priority
</footer>

<script>

(function () {

    const form = document.getElementById("paymentForm");
    const button = document.getElementById("payButton");

    form.addEventListener("submit", function () {

        if (!form.checkValidity()) {
            return;
        }

        button.disabled = true;
        button.textContent = "Processing Demo Payment...";

    });

})();

</script>

</body>
</html>