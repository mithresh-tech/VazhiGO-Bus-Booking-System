<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="com.tnbus.model.Booking" %>
<%@ page import="com.tnbus.model.BusSchedule" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    if (session.getAttribute("loggedInUser") == null) {

        response.sendRedirect(
                request.getContextPath() + "/login.jsp");

        return;
    }

    Booking booking =
            (Booking) request.getAttribute("booking");

    BusSchedule schedule =
            (BusSchedule) request.getAttribute("schedule");

    LocalDateTime departure =
            (LocalDateTime) request.getAttribute("departure");

    LocalDateTime arrival =
            (LocalDateTime) request.getAttribute("arrival");

    Integer progressValue =
            (Integer) request.getAttribute("progress");

    String journeyStatus =
            (String) request.getAttribute("journeyStatus");

    if (booking == null || schedule == null
            || departure == null || arrival == null
            || progressValue == null || journeyStatus == null) {

        response.sendRedirect(
                request.getContextPath() + "/myBookings");

        return;
    }

    int progress = progressValue;

    DateTimeFormatter formatter =
            DateTimeFormatter.ofPattern(
                    "dd MMM yyyy, hh:mm a");

    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Journey Tracking | VazhiGo</title>

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
    gap: 15px;
    flex-wrap: wrap;
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
    max-width: 900px;
    margin: 40px auto;
    padding: 0 20px;
}

.card {
    background: white;
    padding: 30px;
    border-radius: 16px;
    border: 1px solid #e5eaf0;
    margin-bottom: 20px;
}

h1, h2 {
    color: #12355b;
}

.demo {
    display: inline-block;
    padding: 9px 14px;
    border-radius: 20px;
    background: #fff1d5;
    color: #946000;
    font-size: 12px;
    font-weight: bold;
}

.status {
    font-weight: bold;
    color: #18753a;
    margin-top: 20px;
}

.progress-track {
    width: 100%;
    height: 18px;
    background: #e5eaf0;
    border-radius: 20px;
    overflow: hidden;
    margin: 25px 0 12px;
}

.progress-fill {
    height: 100%;
    background: #18753a;
    border-radius: 20px;
    transition: width 0.5s ease;
}

.progress-text {
    font-size: 28px;
    font-weight: bold;
    color: #12355b;
}

.journey-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-top: 25px;
}

.journey-grid div {
    padding: 18px;
    background: #f4f7fb;
    border-radius: 10px;
}

.label {
    display: block;
    color: #68788c;
    font-size: 13px;
    margin-bottom: 10px;
}

.value {
    font-weight: bold;
    overflow-wrap: anywhere;
}

.note {
    color: #68788c;
    line-height: 1.7;
    font-size: 14px;
}

.btn {
    display: inline-block;
    background: #12355b;
    color: white;
    text-decoration: none;
    padding: 13px 20px;
    border-radius: 8px;
    font-weight: bold;
    margin: 8px 8px 0 0;
}

.btn-secondary {
    background: #e5eaf0;
    color: #12355b;
}

@media (max-width: 600px) {

    .card {
        padding: 20px;
    }

    .journey-grid {
        grid-template-columns: 1fr;
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

    <div class="card">

        <span class="demo">
            DEMO JOURNEY TRACKING
        </span>

        <h1>Track Your Journey</h1>

        <p>
            Booking #<%= booking.getBookingId() %>
        </p>

        <p>
            Schedule #<%= schedule.getScheduleId() %>
            &nbsp;|&nbsp;
            Bus #<%= schedule.getBusId() %>
        </p>

        <div class="status">
            <%= journeyStatus %>
        </div>

        <h2>Estimated Journey Progress</h2>

        <div class="progress-track"
             role="progressbar"
             aria-label="Estimated journey progress"
             aria-valuemin="0"
             aria-valuemax="100"
             aria-valuenow="<%= progress %>">

            <div class="progress-fill"
                 style="width: <%= progress %>%;">
            </div>

        </div>

        <div class="progress-text">
            <%= progress %>%
        </div>

        <div class="journey-grid">

            <div>

                <span class="label">
                    Scheduled Departure
                </span>

                <span class="value">
                    <%= departure.format(formatter) %>
                </span>

            </div>

            <div>

                <span class="label">
                    Scheduled Arrival
                </span>

                <span class="value">
                    <%= arrival.format(formatter) %>
                </span>

            </div>

            <div>

                <span class="label">
                    Booking Status
                </span>

                <span class="value">
                    <%= booking.getBookingStatus() %>
                </span>

            </div>

            <div>

                <span class="label">
                    Payment Status
                </span>

                <span class="value">
                    <%= booking.getPaymentStatus() %>
                </span>

            </div>

        </div>

    </div>

    <div class="card">

        <h2>Tracking Information</h2>

        <p class="note">

            This is an academic demonstration.

            Journey progress is calculated using the
            scheduled departure and arrival times.

            It does not represent the bus's verified
            physical location or actual arrival status.

            Real GPS tracking is planned as a future
            VazhiGo enhancement.

        </p>

        <a class="btn"
           href="<%= contextPath %>/trackJourney?bookingId=<%= booking.getBookingId() %>">

            Refresh Journey Status

        </a>
        
        <a class="btn"
   style="background:#b42318;"
   href="<%= contextPath %>/emergencySOS?bookingId=<%= booking.getBookingId() %>">

    Emergency SOS (Demo)

</a>

        <a class="btn btn-secondary"
           href="<%= contextPath %>/myBookings">

            Back to My Bookings

        </a>

    </div>

</main>

</body>
</html>