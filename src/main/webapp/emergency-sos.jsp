<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.tnbus.model.Booking" %>
<%@ page import="com.tnbus.model.EmergencyRequest" %>

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
    Booking booking =
            (Booking) request.getAttribute("booking");

    if (booking == null) {

        response.sendRedirect(
                request.getContextPath() + "/myBookings");

        return;
    }

    String contextPath = request.getContextPath();

    String token =
            (String) request.getAttribute("sosToken");

    Long successReference =
            (Long) request.getAttribute("successReference");

    @SuppressWarnings("unchecked")
    List<EmergencyRequest> requests =
            (List<EmergencyRequest>)
                    request.getAttribute("emergencyRequests");
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Emergency Assistance | VazhiGo</title>

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
    justify-content: space-between;
    align-items: center;
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
}

.container {
    max-width: 850px;
    margin: 35px auto;
    padding: 0 18px;
}

.card {
    background: white;
    padding: 28px;
    border-radius: 14px;
    border: 1px solid #e5eaf0;
    margin-bottom: 20px;
}

h1, h2 {
    color: #12355b;
}

.warning {
    background: #fff1d5;
    color: #785000;
    border: 1px solid #f1d49b;
    padding: 18px;
    border-radius: 10px;
    line-height: 1.7;
    margin-bottom: 20px;
}

.success {
    background: #e2f6e9;
    color: #18753a;
    padding: 18px;
    border-radius: 10px;
    margin-bottom: 20px;
}

label {
    display: block;
    font-weight: bold;
    margin: 18px 0 9px;
}

select, textarea {
    width: 100%;
    padding: 13px;
    border: 1px solid #ccd5df;
    border-radius: 8px;
    font: inherit;
}

textarea {
    min-height: 130px;
    resize: vertical;
}

button, .btn {
    display: inline-block;
    margin-top: 20px;
    padding: 13px 20px;
    background: #b42318;
    color: white;
    border: 0;
    border-radius: 8px;
    font-weight: bold;
    font-size: 14px;
    cursor: pointer;
    text-decoration: none;
}

.btn {
    background: #12355b;
}

.request {
    padding: 17px 0;
    border-bottom: 1px solid #e5eaf0;
    overflow-wrap: anywhere;
}

.request:last-child {
    border-bottom: 0;
}

.status {
    display: inline-block;
    padding: 7px 12px;
    border-radius: 20px;
    background: #edf0f4;
    font-size: 12px;
    font-weight: bold;
}

small {
    color: #68788c;
}

@media(max-width: 600px) {

    .card {
        padding: 19px;
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
        My Bookings
    </a>

</header>

<main class="container">

    <h1>Emergency Assistance</h1>

    <p>
        Booking #<%= booking.getBookingId() %>
    </p>

    <div class="warning">

        <strong>ACADEMIC DEMO — NOT AN EMERGENCY DISPATCH SERVICE</strong>

        <p>
            Submitting this form only saves a request in the
            VazhiGo demonstration database. It does not
            automatically contact police, ambulance services,
            the bus operator or emergency contacts.
        </p>

        <p>
            For an actual emergency in India, call
            <strong>112</strong> directly.
        </p>

    </div>

    <% if (successReference != null) { %>

        <div class="success">

            Request recorded successfully.<br><br>

            Reference Number:

            <strong>
                SOS-<%= successReference %>
            </strong>

            <p>
                This confirms database recording only,
                not that emergency assistance has been dispatched.
            </p>

        </div>

    <% } %>

    <section class="card">

        <h2>Submit SOS Request</h2>

        <form method="post"
              action="<%= contextPath %>/emergencySOS">

            <input type="hidden"
                   name="bookingId"
                   value="<%= booking.getBookingId() %>">

            <input type="hidden"
                   name="sosToken"
                   value="<%= escapeHtml(token) %>">

            <label for="emergencyType">
                Emergency Type
            </label>

            <select id="emergencyType"
                    name="emergencyType"
                    required>

                <option value="">
                    Select emergency type
                </option>

                <option value="MEDICAL">
                    Medical Emergency
                </option>

                <option value="SAFETY">
                    Passenger Safety Concern
                </option>

                <option value="BREAKDOWN">
                    Bus Breakdown
                </option>

                <option value="OTHER">
                    Other
                </option>

            </select>

            <label for="description">
                Describe the Situation
            </label>

            <textarea id="description"
                      name="description"
                      maxlength="500"
                      required
                      placeholder="Enter the details of your request..."></textarea>

            <small>
                Maximum 500 characters.
            </small>

            <br>

            <button type="submit">
                Record SOS Request
            </button>

        </form>

    </section>

    <section class="card">

        <h2>Previous SOS Requests</h2>

        <% if (requests == null || requests.isEmpty()) { %>

            <p>No SOS requests recorded for this booking.</p>

        <% } else {

            for (EmergencyRequest item : requests) {

        %>

            <div class="request">

                <strong>
                    SOS-<%= item.getEmergencyId() %>
                </strong>

                <p>
                    Type:
                    <%= escapeHtml(item.getEmergencyType()) %>
                </p>

                <p>
                    <%= escapeHtml(item.getDescription()) %>
                </p>

                <span class="status">
                    <%= escapeHtml(item.getEmergencyStatus()) %>
                </span>

                <p>
                    <small>
                        Created:
                        <%= escapeHtml(item.getCreatedAt()) %>
                    </small>
                </p>

            </div>

        <%  }
           } %>

    </section>

    <a class="btn"
       href="<%= contextPath %>/trackJourney?bookingId=<%= booking.getBookingId() %>">

        Back to Journey Tracking

    </a>

</main>

</body>
</html>