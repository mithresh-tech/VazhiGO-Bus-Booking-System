<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="com.tnbus.model.User" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Cancel Booking</title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f7fb;
        }

        .container {
            width: 90%;
            max-width: 500px;
            margin: 60px auto;
            padding: 30px;
            background: white;
            border-radius: 10px;
            box-sizing: border-box;
        }

        h2 {
            color: #12355b;
        }

        label {
            display: block;
            margin-top: 20px;
            font-weight: bold;
        }

        input, textarea {
            width: 100%;
            padding: 12px;
            margin-top: 8px;
            box-sizing: border-box;
        }

        button, .btn {
            display: inline-block;
            padding: 12px 18px;
            margin-top: 20px;
            background: #c0392b;
            color: white;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            cursor: pointer;
        }

        .secondary {
            background: #12355b;
        }

        .error {
            color: #c0392b;
        }
    </style>
</head>

<body>

<%
    User user = (User) session.getAttribute("loggedInUser");

    if (user == null) {
        response.sendRedirect(
            request.getContextPath() + "/login.jsp");
        return;
    }

    String bookingId = request.getParameter("bookingId");

    if (bookingId == null || bookingId.isBlank()) {
        response.sendRedirect(
            request.getContextPath() + "/myBookings");
        return;
    }

    String errorMessage =
        (String) request.getAttribute("errorMessage");
%>

<div class="container">

    <h2>Cancel Booking</h2>

    <p>
        Please confirm the booking ID and provide a cancellation reason.
    </p>

    <% if (errorMessage != null) { %>
        <p class="error"><%= errorMessage %></p>
    <% } %>

    <form action="<%= request.getContextPath() %>/cancelBooking"
          method="post">

        <label for="bookingId">Booking ID</label>

        <input type="number"
               id="bookingId"
               name="bookingId"
               value="<%= bookingId %>"
               readonly
               required>

        <label for="reason">Cancellation Reason</label>

        <textarea id="reason"
                  name="reason"
                  rows="4"
                  maxlength="255"
                  required
                  placeholder="Enter your cancellation reason"></textarea>

        <button type="submit">Confirm Cancellation</button>

    </form>

    <a class="btn secondary"
       href="<%= request.getContextPath() %>/myBookings">
        Back to Booking History
    </a>

</div>

</body>
</html>