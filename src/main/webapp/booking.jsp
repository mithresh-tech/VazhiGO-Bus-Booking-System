<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Book Bus</title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f7fb;
        }

        .container {
            width: 500px;
            margin: 70px auto;
            background: white;
            padding: 35px;
            border-radius: 10px;
        }

        h2 {
            color: #12355b;
        }

        input {
            width: 100%;
            padding: 12px;
            margin-top: 8px;
            box-sizing: border-box;
        }

        button {
            width: 100%;
            padding: 13px;
            margin-top: 25px;
            background: #12355b;
            color: white;
            border: none;
            border-radius: 5px;
        }

        .error {
            color: #c0392b;
        }
    </style>
</head>

<body>

<%
    if (session.getAttribute("loggedInUser") == null) {
        response.sendRedirect(
                request.getContextPath() + "/login.jsp");
        return;
    }

    String scheduleId =
            request.getParameter("scheduleId");

    String errorMessage =
            (String) request.getAttribute("errorMessage");
%>

<div class="container">

    <h2>Confirm Bus Booking</h2>

    <%
        if (errorMessage != null) {
    %>

        <p class="error">
            <%= errorMessage %>
        </p>

    <%
        }
    %>

    <form action="<%= request.getContextPath() %>/booking"
          method="post">

        <label>Schedule ID</label>

        <input type="number"
               name="scheduleId"
               value="<%= scheduleId != null ? scheduleId : "" %>"
               required>

        <button type="submit">
            Confirm Booking
        </button>

    </form>

    <br>

    <a href="search.jsp">Back to Search</a>

</div>

</body>
</html>