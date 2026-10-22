<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="java.util.List,java.util.Map" %>
<%@ page import="com.tnbus.model.Admin" %>

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

    private String badge(Object value) {
        String status = value == null ? "" :
                String.valueOf(value).toUpperCase();

        switch (status) {
            case "CONFIRMED":
            case "PAID":
            case "COMPLETED":
                return "success";
            case "PENDING":
            case "REQUESTED":
                return "warning";
            case "CANCELLED":
            case "FAILED":
                return "danger";
            case "REFUNDED":
                return "info";
            default:
                return "neutral";
        }
    }
%>

<%
    Admin admin = (Admin) session.getAttribute("loggedInAdmin");

    if (admin == null) {
        response.sendRedirect(
                request.getContextPath() + "/admin-login.jsp");
        return;
    }

    String cp = request.getContextPath();

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> bookings =
            (List<Map<String, Object>>) request.getAttribute("bookings");

    @SuppressWarnings("unchecked")
    Map<String, Object> selected =
            (Map<String, Object>) request.getAttribute("selectedBooking");

    @SuppressWarnings("unchecked")
    Map<String, Object> details =
            (Map<String, Object>) request.getAttribute("bookingDetails");

    String error = (String) request.getAttribute("errorMessage");

    String bookingId = request.getParameter("bookingId");
    String userId = request.getParameter("userId");
    String scheduleId = request.getParameter("scheduleId");
    String bookingStatus = request.getParameter("bookingStatus");
    String paymentStatus = request.getParameter("paymentStatus");

    if (bookingId == null) bookingId = "";
    if (userId == null) userId = "";
    if (scheduleId == null) scheduleId = "";
    if (bookingStatus == null) bookingStatus = "";
    if (paymentStatus == null) paymentStatus = "";

    Integer totalBookings =
            (Integer) request.getAttribute("totalBookings");

    int total = totalBookings == null ? 0 : totalBookings;
    int visible = bookings == null ? 0 : bookings.size();

    int confirmed = 0;
    int pending = 0;
    int cancelled = 0;

    if (bookings != null) {
        for (Map<String, Object> row : bookings) {
            String status = String.valueOf(row.get("booking_status"));

            if ("CONFIRMED".equalsIgnoreCase(status)) confirmed++;
            else if ("PENDING".equalsIgnoreCase(status)) pending++;
            else if ("CANCELLED".equalsIgnoreCase(status)) cancelled++;
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Booking Management | VazhiGo</title>

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
    font-family:'Segoe UI',Arial,sans-serif;
    background:var(--bg);
    color:var(--text);
}

a { text-decoration:none; }

.sidebar {
    position:fixed;
    inset:0 auto 0 0;
    width:245px;
    background:var(--dark);
    color:white;
    padding:28px 18px;
    display:flex;
    flex-direction:column;
    z-index:20;
}

.brand {
    padding:5px 13px 32px;
    font-size:27px;
    font-weight:800;
    letter-spacing:-1px;
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
    display:flex;
    align-items:center;
    gap:12px;
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
    background:white;
    border-bottom:1px solid var(--border);
    padding:22px 35px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    gap:15px;
}

.topbar-title {
    font-size:17px;
    font-weight:700;
    color:var(--navy);
}

.admin-pill {
    display:flex;
    align-items:center;
    gap:11px;
    font-size:14px;
}

.avatar {
    width:39px;
    height:39px;
    border-radius:12px;
    background:#e7eff7;
    display:grid;
    place-items:center;
    color:var(--navy);
    font-weight:800;
}

.content {
    max-width:1500px;
    margin:auto;
    padding:35px;
}

.heading {
    margin-bottom:25px;
}

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

.stats {
    display:grid;
    grid-template-columns:repeat(4,minmax(0,1fr));
    gap:16px;
    margin-bottom:25px;
}

.stat-card,
.panel {
    background:white;
    border:1px solid var(--border);
    border-radius:16px;
}

.stat-card { padding:23px; }

.stat-label {
    color:var(--muted);
    font-size:13px;
    font-weight:600;
}

.stat-number {
    margin-top:14px;
    font-size:32px;
    font-weight:800;
    color:var(--navy);
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
    font-size:13px;
    color:var(--muted);
}

.filters {
    padding:0 25px 25px;
    display:grid;
    grid-template-columns:repeat(3,minmax(0,1fr));
    gap:15px;
}

.field label {
    display:block;
    margin-bottom:8px;
    font-size:12px;
    font-weight:700;
    color:#52647a;
}

.field input,
.field select {
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

.field input:focus,
.field select:focus {
    outline:2px solid #9db8d3;
    border-color:#668cad;
}

.filter-actions {
    display:flex;
    align-items:end;
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

.btn-view {
    background:#e8f0f9;
    color:#17466e;
    white-space:nowrap;
}

.btn:hover { filter:brightness(.95); }

.table-wrap { overflow-x:auto; }

table {
    width:100%;
    border-collapse:collapse;
    min-width:1050px;
}

th,td {
    padding:16px 17px;
    text-align:left;
    border-top:1px solid var(--border);
    font-size:13px;
    vertical-align:middle;
}

th {
    background:#f7f9fc;
    color:#63758c;
    text-transform:uppercase;
    letter-spacing:.5px;
    font-size:11px;
}

tbody tr:hover { background:#fafcff; }

.subtext {
    display:block;
    margin-top:5px;
    color:var(--muted);
    font-size:12px;
}

.badge {
    display:inline-block;
    padding:7px 11px;
    border-radius:20px;
    font-size:11px;
    font-weight:800;
    white-space:nowrap;
}

.success { background:#e2f6e9; color:#18753a; }
.warning { background:#fff2d9; color:#966000; }
.danger { background:#fde8e8; color:#ae3030; }
.info { background:#e4efff; color:#245ca4; }
.neutral { background:#edf1f5; color:#566579; }

.error {
    padding:16px;
    margin-bottom:20px;
    background:#fff0f0;
    border:1px solid #ffd1d1;
    color:#a32727;
    border-radius:10px;
}

.empty {
    padding:35px;
    text-align:center;
    color:var(--muted);
}

.details-grid {
    display:grid;
    grid-template-columns:repeat(3,minmax(0,1fr));
    gap:15px;
    padding:0 25px 25px;
}

.detail-item {
    background:#f7f9fc;
    padding:17px;
    border-radius:11px;
    min-width:0;
}

.detail-item small {
    display:block;
    margin-bottom:9px;
    color:var(--muted);
    font-size:12px;
}

.detail-item strong {
    display:block;
    overflow-wrap:anywhere;
    font-size:14px;
    color:var(--navy);
}

.section-title {
    margin:0;
    padding:20px 25px;
    border-top:1px solid var(--border);
    color:var(--navy);
    font-size:16px;
}

.notice {
    padding:15px 25px;
    background:#fff8e9;
    color:#805d20;
    font-size:12px;
    line-height:1.6;
}

.mobile-menu {
    display:none;
    border:0;
    border-radius:8px;
    padding:10px 13px;
    background:var(--navy);
    color:white;
    cursor:pointer;
}

@media(max-width:1100px) {
    .stats { grid-template-columns:repeat(2,minmax(0,1fr)); }
    .filters { grid-template-columns:repeat(2,minmax(0,1fr)); }
    .details-grid { grid-template-columns:repeat(2,minmax(0,1fr)); }
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
    .stats,
    .filters,
    .details-grid {
        grid-template-columns:1fr;
    }

    .heading h1 { font-size:24px; }
    .panel-head { padding:20px; }
    .filters { padding:0 20px 20px; }
}

@media(prefers-reduced-motion:reduce) {
    *,*::before,*::after {
        animation:none!important;
        transition:none!important;
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

        <a class="nav-link active" href="<%= cp %>/admin/bookings">
            🎫 &nbsp; Booking Management
        </a>
        
        <a class="nav-link"
   href="<%= cp %>/admin/users">
    ♙ &nbsp; User Management
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
        <button class="mobile-menu" id="menuButton"
                type="button" aria-label="Toggle navigation"
                aria-expanded="false">☰</button>

        <div class="topbar-title">Booking Management</div>
    </div>

    <div class="admin-pill">
        <div class="avatar">A</div>
        <span><%= esc(admin.getAdminName()) %></span>
    </div>

</header>

<main class="content">

    <div class="heading">
        <h1>Booking Management</h1>
        <p>Monitor reservations, passenger information and payment records.</p>
    </div>

    <% if (error != null) { %>
        <div class="error" role="alert"><%= esc(error) %></div>
    <% } %>

    <section class="stats">

        <div class="stat-card">
            <div class="stat-label">Total Bookings</div>
            <div class="stat-number"><%= total %></div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Visible Results</div>
            <div class="stat-number"><%= visible %></div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Confirmed Results</div>
            <div class="stat-number"><%= confirmed %></div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Cancelled Results</div>
            <div class="stat-number"><%= cancelled %></div>
        </div>

    </section>

    <section class="panel">

        <div class="panel-head">
            <div>
                <h2>Search &amp; Filter</h2>
                <p>Search IDs independently or combine multiple filters.</p>
            </div>
            <span class="badge neutral">READ ONLY</span>
        </div>

        <form class="filters" method="get"
              action="<%= cp %>/admin/bookings">

            <div class="field">
                <label for="bookingId">Booking ID</label>
                <input id="bookingId" name="bookingId" type="number"
                       min="1" step="1" placeholder="Exact Booking ID"
                       value="<%= esc(bookingId) %>">
            </div>

            <div class="field">
                <label for="userId">User ID</label>
                <input id="userId" name="userId" type="number"
                       min="1" step="1" placeholder="Exact User ID"
                       value="<%= esc(userId) %>">
            </div>

            <div class="field">
                <label for="scheduleId">Schedule ID</label>
                <input id="scheduleId" name="scheduleId" type="number"
                       min="1" step="1" placeholder="Exact Schedule ID"
                       value="<%= esc(scheduleId) %>">
            </div>

            <div class="field">
                <label for="bookingStatus">Booking Status</label>
                <select id="bookingStatus" name="bookingStatus">
                    <option value="">All Booking Statuses</option>
                    <% for (String s : new String[]{"CONFIRMED","PENDING","CANCELLED"}) { %>
                        <option value="<%= s %>"
                            <%= s.equalsIgnoreCase(bookingStatus) ? "selected" : "" %>>
                            <%= s %>
                        </option>
                    <% } %>
                </select>
            </div>

            <div class="field">
                <label for="paymentStatus">Payment Status</label>
                <select id="paymentStatus" name="paymentStatus">
                    <option value="">All Payment Statuses</option>
                    <% for (String s : new String[]{"PAID","PENDING","FAILED","REFUNDED"}) { %>
                        <option value="<%= s %>"
                            <%= s.equalsIgnoreCase(paymentStatus) ? "selected" : "" %>>
                            <%= s %>
                        </option>
                    <% } %>
                </select>
            </div>

            <div class="filter-actions">
                <button class="btn btn-primary" type="submit">Apply Filters</button>
                <a class="btn btn-secondary" href="<%= cp %>/admin/bookings">
                    Reset
                </a>
            </div>

        </form>
    </section>

    <section class="panel">

        <div class="panel-head">
            <div>
                <h2>Booking Records</h2>
                <p>Latest bookings appear first.</p>
            </div>
            <span class="badge neutral"><%= visible %> Records</span>
        </div>

        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Booking</th>
                        <th>Customer</th>
                        <th>Bus / Route</th>
                        <th>Travel Date</th>
                        <th>Passengers</th>
                        <th>Amount</th>
                        <th>Booking Status</th>
                        <th>Payment</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody>

                <% if (bookings != null && !bookings.isEmpty()) {

                    for (Map<String, Object> row : bookings) {

                        Object id = row.get("booking_id");
                %>

                    <tr>
                        <td>
                            <strong>#<%= esc(id) %></strong>
                            <span class="subtext">
                                Schedule #<%= esc(row.get("schedule_id")) %>
                            </span>
                        </td>

                        <td>
                            <strong><%= esc(row.get("full_name")) %></strong>
                            <span class="subtext">
                                User #<%= esc(row.get("user_id")) %>
                            </span>
                        </td>

                        <td>
                            <strong><%= esc(row.get("bus_number")) %></strong>
                            <span class="subtext">
                                <%= esc(row.get("source_city")) %>
                                →
                                <%= esc(row.get("destination_city")) %>
                            </span>
                        </td>

                        <td><%= esc(row.get("travel_date")) %></td>

                        <td><%= esc(row.get("passenger_count")) %></td>

                        <td>₹ <%= esc(row.get("total_amount")) %></td>

                        <td>
                            <span class="badge <%= badge(row.get("booking_status")) %>">
                                <%= esc(row.get("booking_status")) %>
                            </span>
                        </td>

                        <td>
                            <span class="badge <%= badge(row.get("payment_status")) %>">
                                <%= esc(row.get("payment_status")) %>
                            </span>
                        </td>

                        <td>
                            <a class="btn btn-view"
                               href="<%= cp %>/admin/bookings?details=<%= esc(id) %>">
                                View Details
                            </a>
                        </td>
                    </tr>

                <%  }
                   } else { %>

                    <tr>
                        <td colspan="9" class="empty">
                            No booking records match your filters.
                        </td>
                    </tr>

                <% } %>

                </tbody>
            </table>
        </div>
    </section>

    <% if (selected != null && details != null) {

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> passengers =
                (List<Map<String, Object>>) details.get("passengers");

        @SuppressWarnings("unchecked")
        Map<String, Object> payment =
                (Map<String, Object>) details.get("payment");

        @SuppressWarnings("unchecked")
        Map<String, Object> cancellation =
                (Map<String, Object>) details.get("cancellation");
    %>

    <section class="panel" id="bookingDetails">

        <div class="panel-head">
            <div>
                <h2>Booking #<%= esc(selected.get("booking_id")) %> Details</h2>
                <p>Complete read-only reservation information.</p>
            </div>

            <a class="btn btn-secondary"
               href="<%= cp %>/admin/bookings">
                Close Details
            </a>
        </div>

        <div class="details-grid">

            <div class="detail-item">
                <small>Customer Name</small>
                <strong><%= esc(selected.get("full_name")) %></strong>
            </div>

            <div class="detail-item">
                <small>Email</small>
                <strong><%= esc(selected.get("email")) %></strong>
            </div>

            <div class="detail-item">
                <small>Phone</small>
                <strong><%= esc(selected.get("phone")) %></strong>
            </div>

            <div class="detail-item">
                <small>Bus</small>
                <strong>
                    <%= esc(selected.get("bus_number")) %> –
                    <%= esc(selected.get("bus_name")) %>
                </strong>
            </div>

            <div class="detail-item">
                <small>Route</small>
                <strong>
                    <%= esc(selected.get("source_city")) %> →
                    <%= esc(selected.get("destination_city")) %>
                </strong>
            </div>

            <div class="detail-item">
                <small>Travel Date</small>
                <strong><%= esc(selected.get("travel_date")) %></strong>
            </div>

            <div class="detail-item">
                <small>Departure</small>
                <strong><%= esc(selected.get("departure_time")) %></strong>
            </div>

            <div class="detail-item">
                <small>Arrival</small>
                <strong><%= esc(selected.get("arrival_time")) %></strong>
            </div>

            <div class="detail-item">
                <small>Booking Date</small>
                <strong><%= esc(selected.get("booking_date")) %></strong>
            </div>

            <div class="detail-item">
                <small>Total Amount</small>
                <strong>₹ <%= esc(selected.get("total_amount")) %></strong>
            </div>

            <div class="detail-item">
                <small>Booking Status</small>
                <strong><%= esc(selected.get("booking_status")) %></strong>
            </div>

            <div class="detail-item">
                <small>Payment Status</small>
                <strong><%= esc(selected.get("payment_status")) %></strong>
            </div>

        </div>

        <h3 class="section-title">Passenger &amp; Seat Information</h3>

        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Passenger</th>
                        <th>Age</th>
                        <th>Gender</th>
                        <th>Phone</th>
                        <th>Seat</th>
                        <th>Seat Type</th>
                        <th>Deck</th>
                    </tr>
                </thead>
                <tbody>

                <% if (passengers != null && !passengers.isEmpty()) {

                    for (Map<String, Object> p : passengers) { %>

                    <tr>
                        <td><%= esc(p.get("passenger_name")) %></td>
                        <td><%= esc(p.get("age")) %></td>
                        <td><%= esc(p.get("gender")) %></td>
                        <td><%= esc(p.get("passenger_phone")) %></td>
                        <td><strong><%= esc(p.get("seat_number")) %></strong></td>
                        <td><%= esc(p.get("seat_type")) %></td>
                        <td><%= esc(p.get("deck")) %></td>
                    </tr>

                <%  }
                   } else { %>

                    <tr>
                        <td colspan="7" class="empty">
                            No passenger records found.
                        </td>
                    </tr>

                <% } %>

                </tbody>
            </table>
        </div>

        <h3 class="section-title">Payment Information</h3>

        <% if (payment != null) { %>

        <div class="details-grid">

            <div class="detail-item">
                <small>Payment ID</small>
                <strong>#<%= esc(payment.get("payment_id")) %></strong>
            </div>

            <div class="detail-item">
                <small>Payment Method</small>
                <strong><%= esc(payment.get("payment_method")) %></strong>
            </div>

            <div class="detail-item">
                <small>Amount</small>
                <strong>₹ <%= esc(payment.get("amount")) %></strong>
            </div>

            <div class="detail-item">
                <small>Transaction Reference</small>
                <strong><%= esc(payment.get("transaction_reference")) %></strong>
            </div>

            <div class="detail-item">
                <small>Payment Date</small>
                <strong><%= esc(payment.get("payment_date")) %></strong>
            </div>

            <div class="detail-item">
                <small>Payment Status</small>
                <strong><%= esc(payment.get("payment_status")) %></strong>
            </div>

        </div>

        <% } else { %>
            <div class="empty">No payment transaction recorded for this booking.</div>
        <% } %>

        <h3 class="section-title">Cancellation / Refund Information</h3>

        <% if (cancellation != null) { %>

        <div class="details-grid">

            <div class="detail-item">
                <small>Cancellation ID</small>
                <strong>#<%= esc(cancellation.get("cancellation_id")) %></strong>
            </div>

            <div class="detail-item">
                <small>Cancellation Date</small>
                <strong><%= esc(cancellation.get("cancellation_date")) %></strong>
            </div>

            <div class="detail-item">
                <small>Reason</small>
                <strong><%= esc(cancellation.get("reason")) %></strong>
            </div>

            <div class="detail-item">
                <small>Refund Amount</small>
                <strong>₹ <%= esc(cancellation.get("refund_amount")) %></strong>
            </div>

            <div class="detail-item">
                <small>Cancellation Status</small>
                <strong><%= esc(cancellation.get("cancellation_status")) %></strong>
            </div>

        </div>

        <% } else { %>
            <div class="empty">No cancellation record exists for this booking.</div>
        <% } %>

        <div class="notice">
            This administration page is read-only. Payment processing,
            booking cancellation and refunds must use their existing
            dedicated application workflows.
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
    menuButton.setAttribute("aria-expanded", String(open));
});

document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
        sidebar.classList.remove("open");
        menuButton.setAttribute("aria-expanded", "false");
    }
});

if (document.getElementById("bookingDetails")) {
    document.getElementById("bookingDetails")
            .scrollIntoView({ behavior:"smooth", block:"start" });
}
</script>

</body>
</html>