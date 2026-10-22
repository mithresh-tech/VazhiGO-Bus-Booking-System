<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.tnbus.model.Admin" %>

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

    private long numberValue(
            Map<String, Object> map,
            String key) {

        if (map == null || !(map.get(key) instanceof Number)) {
            return 0L;
        }

        return ((Number) map.get(key)).longValue();
    }

    private String badgeClass(String status) {

        if ("CONFIRMED".equalsIgnoreCase(status)
                || "PAID".equalsIgnoreCase(status)) {
            return "confirmed";
        }

        if ("PENDING".equalsIgnoreCase(status)) {
            return "pending";
        }

        if ("CANCELLED".equalsIgnoreCase(status)
                || "FAILED".equalsIgnoreCase(status)) {
            return "cancelled";
        }

        return "default";
    }
%>

<%
    Admin admin =
        (Admin) session.getAttribute("loggedInAdmin");

    if (admin == null) {

        response.sendRedirect(
            request.getContextPath() + "/admin-login.jsp"
        );

        return;
    }

    @SuppressWarnings("unchecked")
    Map<String, Object> summary =
        (Map<String, Object>)
            request.getAttribute("dashboardSummary");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> recentBookings =
        (List<Map<String, Object>>)
            request.getAttribute("recentBookings");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> topRoutes =
        (List<Map<String, Object>>)
            request.getAttribute("topRoutes");

    String contextPath = request.getContextPath();

    String errorMessage =
        (String) request.getAttribute("errorMessage");

    if (summary == null && errorMessage == null) {

        response.sendRedirect(
            contextPath + "/admin/dashboard"
        );

        return;
    }

    long userCount =
        numberValue(summary, "total_users");

    long busCount =
        numberValue(summary, "total_buses");

    long bookingCount =
        numberValue(summary, "total_bookings");

    long routeCount =
        numberValue(summary, "total_routes");

    long scheduleCount =
        numberValue(summary, "total_schedules");

    long todayBookings =
        numberValue(summary, "today_bookings");

    long confirmedCount =
        numberValue(summary, "confirmed_bookings");

    long pendingCount =
        numberValue(summary, "pending_bookings");

    long cancelledCount =
        numberValue(summary, "cancelled_bookings");

    Object confirmedPaidAmount =
        summary == null
            ? "0.00"
            : summary.get("confirmed_paid_amount");

    if (confirmedPaidAmount == null) {
        confirmedPaidAmount = "0.00";
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Admin Dashboard | VazhiGo</title>

<style>

:root {
    --navy: #102b49;
    --navy-dark: #07192c;
    --gold: #ffc86a;
    --bg: #f3f6fb;
    --text: #243247;
    --muted: #728198;
    --border: #e4eaf2;
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: 'Segoe UI', Arial, sans-serif;
    background: var(--bg);
    color: var(--text);
}

a {
    text-decoration: none;
}

/* SIDEBAR */

.sidebar {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    width: 245px;
    background: var(--navy-dark);
    color: white;
    padding: 28px 18px;
    display: flex;
    flex-direction: column;
    z-index: 10;
    overflow-y: auto;
}

.brand {
    padding: 5px 13px 32px;
    font-size: 27px;
    font-weight: 800;
    letter-spacing: -1px;
}

.brand span {
    color: var(--gold);
}

.sidebar-label {
    padding: 0 13px;
    margin: 15px 0;
    font-size: 11px;
    letter-spacing: 2px;
    color: #91a8c0;
}

.nav-link {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 14px;
    margin-bottom: 7px;
    border-radius: 10px;
    color: #c6d5e6;
    font-size: 14px;
    transition: background .25s, transform .25s;
}

.nav-link:hover {
    background: #183b60;
    transform: translateX(4px);
    color: white;
}

.nav-link.active {
    background: #244a70;
    color: white;
}

.nav-link.sos {
    color: #ffb8b8;
}

.sidebar-bottom {
    margin-top: auto;
    border-top: 1px solid #28405b;
    padding-top: 20px;
}

/* MAIN */

.main {
    margin-left: 245px;
    min-height: 100vh;
}

.topbar {
    background: white;
    padding: 22px 35px;
    border-bottom: 1px solid var(--border);
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
}

.topbar-title {
    font-size: 17px;
    font-weight: 700;
    color: var(--navy);
}

.admin-pill {
    display: flex;
    align-items: center;
    gap: 11px;
    font-size: 14px;
}

.avatar {
    width: 39px;
    height: 39px;
    border-radius: 12px;
    background: #e7eff7;
    display: grid;
    place-items: center;
    color: var(--navy);
    font-weight: 800;
}

.content {
    max-width: 1450px;
    margin: auto;
    padding: 35px;
}

.heading {
    margin-bottom: 30px;
    animation: rise .6s ease both;
}

.heading h1 {
    margin: 0 0 9px;
    font-size: 29px;
    color: var(--navy);
}

.heading p {
    color: var(--muted);
    margin: 0;
    font-size: 14px;
    line-height: 1.6;
}

/* STATISTICS */

.stats {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 20px;
    margin-bottom: 25px;
}

.stat-card {
    background: white;
    padding: 25px;
    border: 1px solid var(--border);
    border-radius: 16px;
    position: relative;
    overflow: hidden;
    animation: rise .7s ease both;
}

.stat-card::after {
    content: "";
    position: absolute;
    right: -20px;
    top: -25px;
    width: 110px;
    height: 110px;
    border-radius: 50%;
    background: #f1f5fa;
}

.stat-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: relative;
    z-index: 1;
}

.stat-icon {
    width: 46px;
    height: 46px;
    border-radius: 13px;
    display: grid;
    place-items: center;
    background: #eaf1f8;
    font-size: 21px;
}

.stat-label {
    color: var(--muted);
    font-size: 13px;
    font-weight: 600;
}

.stat-number {
    font-size: 35px;
    font-weight: 800;
    color: var(--navy);
    margin-top: 18px;
    position: relative;
    z-index: 1;
    overflow-wrap: anywhere;
}

/* BOOKING SUMMARY */

.summary {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 15px;
    margin-bottom: 30px;
}

.summary-item {
    background: white;
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 19px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
}

.summary-item strong {
    font-size: 24px;
    color: var(--navy);
    overflow-wrap: anywhere;
}

.revenue-card {
    grid-column: 1 / -1;
    background: #fffaf0;
    border-color: #f1dfb8;
}

.revenue-card strong {
    font-size: 28px;
}

/* QUICK ACCESS */

.quick-access {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
    flex-wrap: wrap;
    padding: 25px;
    margin-bottom: 30px;
    border-radius: 15px;
    background: linear-gradient(110deg, #173d64, #102b49);
    color: white;
}

.quick-access h3 {
    margin: 0 0 8px;
}

.quick-access p {
    margin: 0;
    color: #c6d5e6;
    font-size: 13px;
    line-height: 1.6;
}

.sos-btn {
    display: inline-block;
    padding: 13px 19px;
    background: white;
    color: #a82b2b;
    border-radius: 9px;
    font-weight: 750;
    font-size: 13px;
    transition: transform .2s;
}

.sos-btn:hover {
    transform: translateY(-3px);
}

/* TABLES */

.table-card {
    background: white;
    border: 1px solid var(--border);
    border-radius: 16px;
    overflow: hidden;
    margin-bottom: 25px;
    animation: rise .8s ease both;
}

.table-heading {
    padding: 24px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    flex-wrap: wrap;
}

.table-heading h3 {
    margin: 0;
    color: var(--navy);
}

.table-heading p {
    color: var(--muted);
    margin: 7px 0 0;
    font-size: 13px;
}

.table-wrap {
    overflow-x: auto;
}

table {
    width: 100%;
    border-collapse: collapse;
    min-width: 760px;
}

th, td {
    padding: 16px 20px;
    text-align: left;
    border-top: 1px solid var(--border);
    font-size: 13px;
}

th {
    background: #f7f9fc;
    color: #63758c;
    text-transform: uppercase;
    letter-spacing: .6px;
    font-size: 11px;
}

tbody tr:hover {
    background: #fafcff;
}

.badge {
    display: inline-block;
    padding: 7px 11px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 800;
    white-space: nowrap;
}

.confirmed,
.paid {
    background: #e2f6e9;
    color: #18753a;
}

.pending {
    background: #fff2d9;
    color: #966000;
}

.cancelled,
.failed {
    background: #fde8e8;
    color: #ae3030;
}

.default {
    background: #edf1f5;
    color: #566579;
}

.action-link {
    background: #e8f0f9;
    color: #17466e;
}

.action-link:hover {
    background: #d7e7f7;
}

.empty {
    text-align: center;
    color: var(--muted);
    padding: 30px;
}

.error {
    background: #fff0f0;
    color: #a32727;
    border: 1px solid #ffd1d1;
    padding: 16px;
    border-radius: 10px;
    margin-bottom: 20px;
}

/* ANIMATION */

@keyframes rise {

    from {
        opacity: 0;
        transform: translateY(18px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

/* MOBILE */

.mobile-menu {
    display: none;
    border: 0;
    border-radius: 8px;
    padding: 10px 13px;
    background: var(--navy);
    color: white;
    cursor: pointer;
}

@media(max-width: 900px) {

    .sidebar {
        transform: translateX(-100%);
        transition: transform .3s;
    }

    .sidebar.open {
        transform: translateX(0);
    }

    .main {
        margin-left: 0;
    }

    .mobile-menu {
        display: block;
    }

    .content {
        padding: 24px 18px;
    }

    .topbar {
        padding: 18px;
    }
}

@media(max-width: 600px) {

    .stats,
    .summary {
        grid-template-columns: 1fr;
    }

    .heading h1 {
        font-size: 24px;
    }

    .stat-number {
        font-size: 30px;
    }

    .summary-item {
        align-items: flex-start;
        flex-direction: column;
    }

    .revenue-card {
        grid-column: auto;
    }

    .admin-pill span {
        display: none;
    }
}

@media(prefers-reduced-motion: reduce) {

    *,
    *::before,
    *::after {
        animation: none !important;
        transition: none !important;
    }
}

</style>

</head>

<body>

<!-- SIDEBAR -->

<aside class="sidebar" id="sidebar">

    <div class="brand">
        Vazhi<span>Go</span>
    </div>

    <div class="sidebar-label">
        ADMIN WORKSPACE
    </div>

    <nav>

        <a class="nav-link active"
           href="<%= contextPath %>/admin/dashboard">
            ▦ &nbsp; Overview
        </a>

        <a class="nav-link"
           href="<%= contextPath %>/admin/buses">
            🚌 &nbsp; Bus Management
        </a>

        <a class="nav-link"
           href="<%= contextPath %>/admin/schedules">
            ◷ &nbsp; Schedule Management
        </a>

        <a class="nav-link"
           href="<%= contextPath %>/admin/bookings">
            🎫 &nbsp; Booking Management
        </a>

        <a class="nav-link"
           href="<%= contextPath %>/admin/users">
            ♙ &nbsp; User Management
        </a>

        <a class="nav-link"
           href="<%= contextPath %>/admin/routes">
            ⇄ &nbsp; Route Management
        </a>

        <a class="nav-link"
           href="<%= contextPath %>/admin/reports">
            ▥ &nbsp; Reports &amp; Analytics
        </a>

        <a class="nav-link sos"
           href="<%= contextPath %>/admin/emergencies">
            ⚠ &nbsp; Emergency SOS
        </a>

        <a class="nav-link"
           href="<%= contextPath %>/index.jsp">
            ↗ &nbsp; View Website
        </a>

    </nav>

    <div class="sidebar-bottom">

        <a class="nav-link"
           href="<%= contextPath %>/logout">
            ↪ &nbsp; Logout
        </a>

    </div>

</aside>

<!-- MAIN -->

<div class="main">

    <header class="topbar">

        <div style="display:flex;align-items:center;gap:12px;">

            <button class="mobile-menu"
                    id="menuButton"
                    type="button"
                    aria-label="Toggle navigation"
                    aria-expanded="false">
                ☰
            </button>

            <div class="topbar-title">
                Administration Overview
            </div>

        </div>

        <div class="admin-pill">

            <div class="avatar">A</div>

            <span>
                <%= escapeHtml(admin.getAdminName()) %>
            </span>

        </div>

    </header>

    <main class="content">

        <!-- HEADING -->

        <div class="heading">

            <h1>
                Welcome back,
                <%= escapeHtml(admin.getAdminName()) %>!
            </h1>

            <p>
                Here's an overview of your VazhiGo
                booking management system.
            </p>

        </div>

        <% if (errorMessage != null) { %>

            <div class="error" role="alert">
                <%= escapeHtml(errorMessage) %>
            </div>

        <% } %>

        <!-- PRIMARY STATISTICS -->

        <section class="stats">

            <div class="stat-card">

                <div class="stat-top">
                    <span class="stat-label">Total Users</span>
                    <span class="stat-icon">👥</span>
                </div>

                <div class="stat-number">
                    <%= userCount %>
                </div>

            </div>

            <div class="stat-card">

                <div class="stat-top">
                    <span class="stat-label">Total Buses</span>
                    <span class="stat-icon">🚌</span>
                </div>

                <div class="stat-number">
                    <%= busCount %>
                </div>

            </div>

            <div class="stat-card">

                <div class="stat-top">
                    <span class="stat-label">Total Bookings</span>
                    <span class="stat-icon">🎫</span>
                </div>

                <div class="stat-number">
                    <%= bookingCount %>
                </div>

            </div>

        </section>

        <!-- ADDITIONAL STATISTICS -->

        <section class="stats">

            <div class="stat-card">

                <div class="stat-top">
                    <span class="stat-label">Total Routes</span>
                    <span class="stat-icon">⇄</span>
                </div>

                <div class="stat-number">
                    <%= routeCount %>
                </div>

            </div>

            <div class="stat-card">

                <div class="stat-top">
                    <span class="stat-label">Total Schedules</span>
                    <span class="stat-icon">◷</span>
                </div>

                <div class="stat-number">
                    <%= scheduleCount %>
                </div>

            </div>

            <div class="stat-card">

                <div class="stat-top">
                    <span class="stat-label">Today's Bookings</span>
                    <span class="stat-icon">🎫</span>
                </div>

                <div class="stat-number">
                    <%= todayBookings %>
                </div>

            </div>

        </section>

        <!-- BOOKING STATUS SUMMARY -->

        <section class="summary">

            <div class="summary-item">

                <span>Confirmed Bookings</span>

                <strong>
                    <%= confirmedCount %>
                </strong>

            </div>

            <div class="summary-item">

                <span>Pending Bookings</span>

                <strong>
                    <%= pendingCount %>
                </strong>

            </div>

            <div class="summary-item">

                <span>Cancelled Bookings</span>

                <strong>
                    <%= cancelledCount %>
                </strong>

            </div>

            <div class="summary-item revenue-card">

                <span>
                    Confirmed &amp; Paid Booking Value
                </span>

                <strong>
                    ₹ <%= escapeHtml(confirmedPaidAmount) %>
                </strong>

            </div>

        </section>

        <!-- SOS QUICK ACCESS -->

        <section class="quick-access">

            <div>

                <h3>Emergency Request Management</h3>

                <p>
                    Review and manage passenger SOS requests
                    in the academic demo dashboard.
                </p>

            </div>

            <a class="sos-btn"
               href="<%= contextPath %>/admin/emergencies">

                View SOS Requests →

            </a>

        </section>

        <!-- RECENT BOOKINGS -->

        <section class="table-card">

            <div class="table-heading">

                <div>

                    <h3>Recent Bookings</h3>

                    <p>
                        Latest 10 booking records from VazhiGo.
                    </p>

                </div>

                <a class="badge action-link"
                   href="<%= contextPath %>/admin/bookings">

                    View All Bookings →

                </a>

            </div>

            <div class="table-wrap">

                <table>

                    <thead>

                        <tr>
                            <th>Booking ID</th>
                            <th>User ID</th>
                            <th>Schedule ID</th>
                            <th>Booking Date</th>
                            <th>Amount</th>
                            <th>Booking Status</th>
                            <th>Payment</th>
                        </tr>

                    </thead>

                    <tbody>

                    <%
                        if (recentBookings != null
                                && !recentBookings.isEmpty()) {

                            for (Map<String, Object> booking
                                    : recentBookings) {

                                String bookingStatus =
                                    String.valueOf(
                                        booking.get("booking_status")
                                    );

                                String paymentStatus =
                                    String.valueOf(
                                        booking.get("payment_status")
                                    );

                                String bookingClass =
                                    badgeClass(bookingStatus);

                                String paymentClass =
                                    badgeClass(paymentStatus);
                    %>

                        <tr>

                            <td>
                                #<%= escapeHtml(
                                    booking.get("booking_id")
                                ) %>
                            </td>

                            <td>
                                <%= escapeHtml(
                                    booking.get("user_id")
                                ) %>
                            </td>

                            <td>
                                <%= escapeHtml(
                                    booking.get("schedule_id")
                                ) %>
                            </td>

                            <td>
                                <%= escapeHtml(
                                    booking.get("booking_date")
                                ) %>
                            </td>

                            <td>
                                ₹ <%= escapeHtml(
                                    booking.get("total_amount")
                                ) %>
                            </td>

                            <td>

                                <span class="badge <%= bookingClass %>">
                                    <%= escapeHtml(bookingStatus) %>
                                </span>

                            </td>

                            <td>

                                <span class="badge <%= paymentClass %>">
                                    <%= escapeHtml(paymentStatus) %>
                                </span>

                            </td>

                        </tr>

                    <%
                            }
                        } else {
                    %>

                        <tr>

                            <td colspan="7" class="empty">
                                No recent booking records available.
                            </td>

                        </tr>

                    <% } %>

                    </tbody>

                </table>

            </div>

        </section>

        <!-- TOP ROUTES -->

        <section class="table-card">

            <div class="table-heading">

                <div>

                    <h3>Top Performing Routes</h3>

                    <p>
                        Five routes with the highest booking counts.
                    </p>

                </div>

                <a class="badge action-link"
                   href="<%= contextPath %>/admin/reports">

                    Full Reports →

                </a>

            </div>

            <div class="table-wrap">

                <table>

                    <thead>

                        <tr>
                            <th>Route ID</th>
                            <th>Source</th>
                            <th>Destination</th>
                            <th>Total Bookings</th>
                            <th>Confirmed &amp; Paid Value</th>
                        </tr>

                    </thead>

                    <tbody>

                    <%
                        if (topRoutes != null && !topRoutes.isEmpty()) {

                            for (Map<String, Object> route : topRoutes) {
                    %>

                        <tr>

                            <td>
                                #<%= escapeHtml(
                                    route.get("route_id")
                                ) %>
                            </td>

                            <td>
                                <%= escapeHtml(
                                    route.get("source_city")
                                ) %>
                            </td>

                            <td>
                                <%= escapeHtml(
                                    route.get("destination_city")
                                ) %>
                            </td>

                            <td>
                                <%= escapeHtml(
                                    route.get("total_bookings")
                                ) %>
                            </td>

                            <td>
                                ₹ <%= escapeHtml(
                                    route.get("confirmed_paid_amount")
                                ) %>
                            </td>

                        </tr>

                    <%
                            }
                        } else {
                    %>

                        <tr>

                            <td colspan="5" class="empty">
                                No route booking information available.
                            </td>

                        </tr>

                    <% } %>

                    </tbody>

                </table>

            </div>

        </section>

    </main>

</div>

<script>

const menuButton =
    document.getElementById("menuButton");

const sidebar =
    document.getElementById("sidebar");

menuButton.addEventListener("click", function () {

    const isOpen =
        sidebar.classList.toggle("open");

    menuButton.setAttribute(
        "aria-expanded",
        String(isOpen)
    );

});

document.addEventListener("keydown", function (event) {

    if (event.key === "Escape") {

        sidebar.classList.remove("open");

        menuButton.setAttribute(
            "aria-expanded",
            "false"
        );
    }

});

</script>

</body>
</html>