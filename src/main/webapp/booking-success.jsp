<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Booking Successful</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            text-align: center;
        }

        .container {
            width: 500px;
            margin: 100px auto;
            background: white;
            padding: 40px;
            border-radius: 10px;
        }

        h1 {
            color: #1e8449;
        }

        .btn {
            display: inline-block;
            padding: 12px 20px;
            margin: 10px;
            background: #12355b;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
    </style>
</head>

<body>

<div class="container">

    <h1>Booking Successful!</h1>

    <%
        String bookingId =
                request.getParameter("bookingId");
    %>

    <p>
        Your booking has been created successfully.
    </p>

    <p>
        <strong>Booking ID:</strong>
        <%= bookingId %>
    </p>
    
    <div class="button-row">

    <a href="<%= request.getContextPath() %>/myBookings">
        My Bookings
    </a>

    <a href="<%= request.getContextPath() %>/home.jsp">
        Home
    </a>

</div>

    

</div>

</body>
</html>