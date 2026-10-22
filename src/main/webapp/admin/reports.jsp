<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="java.util.List,java.util.Map" %>

<%!
    private String esc(Object value) {

        if (value == null) return "";

        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private Object val(Map<String, Object> map, String key) {
        return map == null || map.get(key) == null
                ? "0" : map.get(key);
    }
%>

<%
    if (session.getAttribute("loggedInAdmin") == null) {

        response.sendRedirect(
            request.getContextPath() + "/admin-login.jsp"
        );

        return;
    }

    String cp = request.getContextPath();

    @SuppressWarnings("unchecked")
    Map<String, Object> summary =
        (Map<String, Object>) request.getAttribute("summary");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> bookingStatuses =
        (List<Map<String, Object>>) request.getAttribute("bookingStatuses");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> paymentStatuses =
        (List<Map<String, Object>>) request.getAttribute("paymentStatuses");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> routeReports =
        (List<Map<String, Object>>) request.getAttribute("routeReports");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> dailyReports =
        (List<Map<String, Object>>) request.getAttribute("dailyReports");

    String fromDate =
        (String) request.getAttribute("fromDate");

    String toDate =
        (String) request.getAttribute("toDate");

    String error =
        (String) request.getAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Reports  &amp; Analytics | VazhiGo</title>

<style>

:root {
    --navy:#102b49;
    --dark:#07192c;
    --gold:#ffc86a;
    --bg:#f3f6fb;
    --text:#243247;
    --muted:#728198;
    --border:#e4eaf2;
}

* { box-sizing:border-box; }

body {
    margin:0;
    background:var(--bg);
    color:var(--text);
    font-family:'Segoe UI',Arial,sans-serif;
}

a { text-decoration:none; }

.sidebar {
    position:fixed;
    inset:0 auto 0 0;
    width:245px;
    background:var(--dark);
    padding:28px 18px;
    display:flex;
    flex-direction:column;
    z-index:20;
}

.brand {
    padding:5px 13px 32px;
    color:white;
    font-size:27px;
    font-weight:800;
}

.brand span { color:var(--gold); }

.sidebar-label {
    padding:0 13px;
    margin:15px 0;
    font-size:11px;
    letter-spacing:2px;
    color:#91a8c0;
}

.nav-link {
    display:block;
    padding:14px;
    margin-bottom:7px;
    border-radius:10px;
    color:#c6d5e6;
    font-size:14px;
}

.nav-link:hover,
.nav-link.active {
    background:#244a70;
    color:white;
}

.nav-link.sos { color:#ffb8b8; }

.sidebar-bottom {
    margin-top:auto;
    border-top:1px solid #28405b;
    padding-top:20px;
}

.main {
    margin-left:245px;
    min-height:100vh;
}

.topbar {
    padding:23px 35px;
    background:white;
    border-bottom:1px solid var(--border);
    display:flex;
    justify-content:space-between;
    align-items:center;
    gap:15px;
}

.topbar-title {
    color:var(--navy);
    font-size:17px;
    font-weight:750;
}

.admin-pill {
    padding:10px 15px;
    background:#edf2f8;
    border-radius:25px;
    font-size:13px;
    font-weight:700;
}

.content {
    max-width:1500px;
    margin:auto;
    padding:35px;
}

.heading { margin-bottom:25px; }

.heading h1 {
    margin:0 0 9px;
    font-size:29px;
    color:var(--navy);
}

.heading p {
    margin:0;
    color:var(--muted);
    font-size:14px;
    line-height:1.6;
}

.panel,.stat-card {
    background:white;
    border:1px solid var(--border);
    border-radius:16px;
}

.panel {
    margin-bottom:25px;
    overflow:hidden;
}

.panel-head {
    padding:23px 25px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    gap:15px;
    flex-wrap:wrap;
}

.panel-head h2 {
    margin:0;
    font-size:18px;
    color:var(--navy);
}

.panel-head p {
    margin:7px 0 0;
    color:var(--muted);
    font-size:13px;
}

.stats {
    display:grid;
    grid-template-columns:repeat(3,minmax(0,1fr));
    gap:16px;
    margin-bottom:25px;
}

.stat-card { padding:23px; }

.stat-label {
    color:var(--muted);
    font-size:13px;
    font-weight:600;
}

.stat-number {
    margin-top:14px;
    font-size:29px;
    font-weight:800;
    color:var(--navy);
    overflow-wrap:anywhere;
}

.filters {
    padding:0 25px 25px;
    display:flex;
    align-items:end;
    flex-wrap:wrap;
    gap:15px;
}

.field {
    flex:1 1 180px;
    min-width:0;
}

.field label {
    display:block;
    margin-bottom:8px;
    font-size:12px;
    font-weight:700;
    color:#52647a;
}

.field input {
    width:100%;
    min-width:0;
    padding:13px;
    border:1px solid #dce4ee;
    border-radius:9px;
    background:white;
    color:var(--text);
    font:inherit;
    font-size:14px;
}

.actions {
    display:flex;
    gap:10px;
    flex-wrap:wrap;
}

.btn {
    display:inline-flex;
    align-items:center;
    justify-content:center;
    min-height:43px;
    padding:11px 17px;
    border:0;
    border-radius:9px;
    font:inherit;
    font-size:13px;
    font-weight:750;
    cursor:pointer;
}

.btn-primary {
    background:var(--navy);
    color:white;
}

.btn-secondary {
    background:#edf2f8;
    color:var(--navy);
}

.table-wrap { overflow-x:auto; }

table {
    width:100%;
    border-collapse:collapse;
    min-width:550px;
}

th,td {
    padding:16px 17px;
    text-align:left;
    border-top:1px solid var(--border);
    font-size:13px;
}

th {
    background:#f7f9fc;
    color:#63758c;
    text-transform:uppercase;
    font-size:11px;
    letter-spacing:.5px;
}

tbody tr:hover { background:#fafcff; }

.badge {
    display:inline-block;
    padding:7px 11px;
    border-radius:20px;
    background:#edf1f5;
    color:#566579;
    font-size:11px;
    font-weight:800;
}

.error {
    padding:16px;
    margin-bottom:20px;
    background:#fff0f0;
    color:#a32727;
    border:1px solid #ffd1d1;
    border-radius:10px;
}

.empty {
    padding:30px;
    text-align:center;
    color:var(--muted);
}

.report-grid {
    display:grid;
    grid-template-columns:repeat(2,minmax(0,1fr));
    gap:20px;
    margin-bottom:25px;
}

.report-grid .panel { margin-bottom:0; }

.notice {
    padding:17px 25px;
    background:#fff8e9;
    color:#805d20;
    font-size:12px;
    line-height:1.6;
}

.mobile-menu {
    display:none;
    padding:10px 13px;
    border:0;
    border-radius:8px;
    background:var(--navy);
    color:white;
    cursor:pointer;
}

@media(max-width:1100px) {
    .stats {
        grid-template-columns:repeat(2,minmax(0,1fr));
    }

    .report-grid {
        grid-template-columns:1fr;
    }
}

@media(max-width:900px) {
    .sidebar {
        transform:translateX(-100%);
        transition:transform .3s;
    }

    .sidebar.open { transform:translateX(0); }
    .main { margin-left:0; }
    .mobile-menu { display:block; }
    .content { padding:24px 18px; }
    .topbar { padding:18px; }
}

@media(max-width:600px) {
    .stats { grid-template-columns:1fr; }
    .heading h1 { font-size:24px; }
}

@media(prefers-reduced-motion:reduce) {
    *,*::before,*::after {
        transition:none!important;
        animation:none!important;
    }
}

</style>

</head>

<body>

<aside class="sidebar" id="sidebar">

    <div class="brand">Vazhi<span>Go</span></div>

    <div class="sidebar-label">ADMIN WORKSPACE</div>

    <nav>

        <a class="nav-link" href="<%= cp %>/admin/dashboard">
            ▦ &nbsp; Overview
        </a>

        <a class="nav-link" href="<%= cp %>/admin/buses">
            🚌 &nbsp; Bus Management
        </a>

        <a class="nav-link" href="<%= cp %>/admin/schedules">
            ◷ &nbsp; Schedule Management
        </a>

        <a class="nav-link" href="<%= cp %>/admin/bookings">
            🎫 &nbsp; Booking Management
        </a>

        <a class="nav-link" href="<%= cp %>/admin/users">
            ♙ &nbsp; User Management
        </a>

        <a class="nav-link" href="<%= cp %>/admin/routes">
            ⇄ &nbsp; Route Management
        </a>

        <a class="nav-link active" href="<%= cp %>/admin/reports">
            ▥ &nbsp; Reports &amp; Analytics
        </a>

        <a class="nav-link sos" href="<%= cp %>/admin/emergencies">
            ⚠ &nbsp; Emergency SOS
        </a>

        <a class="nav-link" href="<%= cp %>/index.jsp">
            ↗ &nbsp; View Website
        </a>

    </nav>

    <div class="sidebar-bottom">

        <a class="nav-link" href="<%= cp %>/logout">
            ↪ &nbsp; Logout
        </a>

    </div>

</aside>

<div class="main">

<header class="topbar">

    <div style="display:flex;align-items:center;gap:12px;">

        <button class="mobile-menu"
                id="menuButton"
                type="button"
                aria-label="Toggle navigation"
                aria-expanded="false">☰</button>

        <div class="topbar-title">
            Reports &amp; Analytics
        </div>

    </div>

    <div class="admin-pill">Administrator</div>

</header>

<main class="content">

    <div class="heading">

        <h1>Reports &amp; Analytics</h1>

        <p>
            Monitor booking activity, confirmed paid booking value,
            payment statuses and route performance.
        </p>

    </div>

    <% if (error != null) { %>

        <div class="error" role="alert">
            <%= esc(error) %>
        </div>

    <% } %>

    <section class="panel">

        <div class="panel-head">

            <div>
                <h2>Report Date Range</h2>
                <p>Filter reports by booking creation date.</p>
            </div>

            <span class="badge">READ ONLY</span>

        </div>

        <form class="filters"
              method="get"
              action="<%= cp %>/admin/reports">

            <div class="field">

                <label for="from">From Date</label>

                <input type="date"
                       id="from"
                       name="from"
                       required
                       value="<%= esc(fromDate) %>">

            </div>

            <div class="field">

                <label for="to">To Date</label>

                <input type="date"
                       id="to"
                       name="to"
                       required
                       value="<%= esc(toDate) %>">

            </div>

            <div class="actions">

                <button class="btn btn-primary" type="submit">
                    Generate Report
                </button>

                <a class="btn btn-secondary"
                   href="<%= cp %>/admin/reports">
                    Reset
                </a>

            </div>

        </form>

    </section>

    <% if (summary != null) { %>

    <section class="stats">

        <div class="stat-card">

            <div class="stat-label">Total Bookings</div>

            <div class="stat-number">
                <%= esc(val(summary,"total_bookings")) %>
            </div>

        </div>

        <div class="stat-card">

            <div class="stat-label">Confirmed Bookings</div>

            <div class="stat-number">
                <%= esc(val(summary,"confirmed_bookings")) %>
            </div>

        </div>

        <div class="stat-card">

            <div class="stat-label">Cancelled Bookings</div>

            <div class="stat-number">
                <%= esc(val(summary,"cancelled_bookings")) %>
            </div>

        </div>

        <div class="stat-card">

            <div class="stat-label">Pending Bookings</div>

            <div class="stat-number">
                <%= esc(val(summary,"pending_bookings")) %>
            </div>

        </div>

        <div class="stat-card">

            <div class="stat-label">Confirmed &amp; Paid Booking Value</div>

            <div class="stat-number">
                ₹ <%= esc(val(summary,"confirmed_paid_amount")) %>
            </div>

        </div>

        <div class="stat-card">

            <div class="stat-label">Report Period</div>

            <div style="margin-top:14px;font-size:15px;font-weight:750;">
                <%= esc(fromDate) %>
                <br>to<br>
                <%= esc(toDate) %>
            </div>

        </div>

    </section>

    <div class="report-grid">

        <section class="panel">

            <div class="panel-head">
                <h2>Booking Status Report</h2>
            </div>

            <div class="table-wrap">

                <table>

                    <thead>
                        <tr>
                            <th>Booking Status</th>
                            <th>Total</th>
                        </tr>
                    </thead>

                    <tbody>

                    <% if (bookingStatuses != null &&
                            !bookingStatuses.isEmpty()) {

                        for (Map<String,Object> row : bookingStatuses) { %>

                        <tr>
                            <td>
                                <span class="badge">
                                    <%= esc(row.get("status")) %>
                                </span>
                            </td>

                            <td>
                                <%= esc(row.get("total")) %>
                            </td>
                        </tr>

                    <%  }
                       } else { %>

                        <tr>
                            <td colspan="2" class="empty">
                                No booking data available.
                            </td>
                        </tr>

                    <% } %>

                    </tbody>

                </table>

            </div>

        </section>

        <section class="panel">

            <div class="panel-head">
                <h2>Payment Status Report</h2>
            </div>

            <div class="table-wrap">

                <table>

                    <thead>
                        <tr>
                            <th>Payment Status</th>
                            <th>Total</th>
                        </tr>
                    </thead>

                    <tbody>

                    <% if (paymentStatuses != null &&
                            !paymentStatuses.isEmpty()) {

                        for (Map<String,Object> row : paymentStatuses) { %>

                        <tr>
                            <td>
                                <span class="badge">
                                    <%= esc(row.get("status")) %>
                                </span>
                            </td>

                            <td>
                                <%= esc(row.get("total")) %>
                            </td>
                        </tr>

                    <%  }
                       } else { %>

                        <tr>
                            <td colspan="2" class="empty">
                                No payment status data available.
                            </td>
                        </tr>

                    <% } %>

                    </tbody>

                </table>

            </div>

        </section>

    </div>

    <section class="panel">

        <div class="panel-head">

            <div>
                <h2>Route-Wise Booking Performance</h2>
                <p>Booking activity grouped by route.</p>
            </div>

        </div>

        <div class="table-wrap">

            <table>

                <thead>

                    <tr>
                        <th>Route ID</th>
                        <th>Route</th>
                        <th>Total Bookings</th>
                        <th>Confirmed</th>
                        <th>Cancelled</th>
                        <th>Confirmed &amp; Paid Value</th>
                    </tr>

                </thead>

                <tbody>

                <% if (routeReports != null &&
                        !routeReports.isEmpty()) {

                    for (Map<String,Object> row : routeReports) { %>

                    <tr>

                        <td>
                            #<%= esc(row.get("route_id")) %>
                        </td>

                        <td>
                            <strong>
                                <%= esc(row.get("source_city")) %>
                                →
                                <%= esc(row.get("destination_city")) %>
                            </strong>
                        </td>

                        <td>
                            <%= esc(row.get("total_bookings")) %>
                        </td>

                        <td>
                            <%= esc(row.get("confirmed_bookings")) %>
                        </td>

                        <td>
                            <%= esc(row.get("cancelled_bookings")) %>
                        </td>

                        <td>
                            ₹ <%= esc(row.get("confirmed_paid_amount")) %>
                        </td>

                    </tr>

                <%  }
                   } else { %>

                    <tr>
                        <td colspan="6" class="empty">
                            No route booking data for this period.
                        </td>
                    </tr>

                <% } %>

                </tbody>

            </table>

        </div>

    </section>

    <section class="panel">

        <div class="panel-head">

            <div>
                <h2>Daily Booking Report</h2>
                <p>Booking activity grouped by booking date.</p>
            </div>

        </div>

        <div class="table-wrap">

            <table>

                <thead>

                    <tr>
                        <th>Date</th>
                        <th>Total Bookings</th>
                        <th>Confirmed &amp; Paid Value</th>
                    </tr>

                </thead>

                <tbody>

                <% if (dailyReports != null &&
                        !dailyReports.isEmpty()) {

                    for (Map<String,Object> row : dailyReports) { %>

                    <tr>

                        <td>
                            <%= esc(row.get("report_date")) %>
                        </td>

                        <td>
                            <%= esc(row.get("total_bookings")) %>
                        </td>

                        <td>
                            ₹ <%= esc(row.get("confirmed_paid_amount")) %>
                        </td>

                    </tr>

                <%  }
                   } else { %>

                    <tr>
                        <td colspan="3" class="empty">
                            No daily booking records available.
                        </td>
                    </tr>

                <% } %>

                </tbody>

            </table>

        </div>

        <div class="notice">

            This academic reporting module uses existing booking records.
            Confirmed &amp; Paid Booking Value is not a verified
            bank-settlement or net-revenue figure. Refund adjustments
            are not included. No payment transactions are performed here.

        </div>

    </section>

    <% } %>

</main>

</div>

<script>

const menuButton = document.getElementById("menuButton");
const sidebar = document.getElementById("sidebar");

menuButton.addEventListener("click", function () {

    const open = sidebar.classList.toggle("open");

    menuButton.setAttribute(
        "aria-expanded",
        String(open)
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