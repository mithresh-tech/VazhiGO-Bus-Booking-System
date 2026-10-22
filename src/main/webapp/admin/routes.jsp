<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="java.util.List,java.util.Map" %>
<%@ page import="java.net.URLEncoder" %>

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

    private String param(
            HttpServletRequest request,
            String name) {

        String value = request.getParameter(name);
        return value == null ? "" : value;
    }

    private String encode(String value) {
        return URLEncoder.encode(
            value == null ? "" : value,
            java.nio.charset.StandardCharsets.UTF_8
        );
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
    List<Map<String, Object>> routes =
        (List<Map<String, Object>>) request.getAttribute("routes");

    @SuppressWarnings("unchecked")
    List<String> statuses =
        (List<String>) request.getAttribute("statuses");

    @SuppressWarnings("unchecked")
    Map<String, Object> selectedRoute =
        (Map<String, Object>) request.getAttribute("selectedRoute");

    String error =
        (String) request.getAttribute("errorMessage");

    Long totalRoutes =
        (Long) request.getAttribute("totalRoutes");

    long total = totalRoutes == null ? 0 : totalRoutes;
    int visible = routes == null ? 0 : routes.size();

    String routeId = param(request, "routeId");
    String source = param(request, "source");
    String destination = param(request, "destination");
    String status = param(request, "status");

    int active = 0;

    if (routes != null) {
        for (Map<String, Object> route : routes) {
            if ("ACTIVE".equalsIgnoreCase(
                    String.valueOf(route.get("status")))) {
                active++;
            }
        }
    }

    String filterQuery =
        "routeId=" + encode(routeId)
        + "&source=" + encode(source)
        + "&destination=" + encode(destination)
        + "&status=" + encode(status);
%>

<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Route Management | VazhiGo</title>

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
}

.stats {
    display:grid;
    grid-template-columns:repeat(3,minmax(0,1fr));
    gap:16px;
    margin-bottom:25px;
}

.stat-card,.panel {
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
    color:var(--muted);
    font-size:13px;
}

.filters {
    padding:0 25px 25px;
    display:grid;
    grid-template-columns:repeat(4,minmax(0,1fr));
    gap:15px;
}

.field label {
    display:block;
    margin-bottom:8px;
    font-size:12px;
    font-weight:700;
    color:#52647a;
}

.field input,.field select {
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

.field input:focus,.field select:focus {
    outline:2px solid #9db8d3;
}

.actions {
    display:flex;
    gap:10px;
    align-items:end;
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
}

.table-wrap { overflow-x:auto; }

table {
    width:100%;
    min-width:850px;
    border-collapse:collapse;
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
}

.success {
    background:#e2f6e9;
    color:#18753a;
}

.danger {
    background:#fde8e8;
    color:#ae3030;
}

.neutral {
    background:#edf1f5;
    color:#566579;
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
    padding:17px;
    background:#f7f9fc;
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
    .filters,.details-grid {
        grid-template-columns:repeat(2,minmax(0,1fr));
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
    .stats,.filters,.details-grid {
        grid-template-columns:1fr;
    }

    .heading h1 { font-size:24px; }
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

        <a class="nav-link active" href="<%= cp %>/admin/routes">
            ⇄ &nbsp; Route Management
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

        <div class="topbar-title">Route Management</div>
    </div>

    <div class="admin-pill">Administrator</div>

</header>

<main class="content">

    <div class="heading">
        <h1>Route Management</h1>
        <p>Monitor bus routes, city connections and linked schedules.</p>
    </div>

    <% if (error != null) { %>
        <div class="error" role="alert"><%= esc(error) %></div>
    <% } %>

    <section class="stats">

        <div class="stat-card">
            <div class="stat-label">Total Routes</div>
            <div class="stat-number"><%= total %></div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Visible Results</div>
            <div class="stat-number"><%= visible %></div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Active Results</div>
            <div class="stat-number"><%= active %></div>
        </div>

    </section>

    <section class="panel">

        <div class="panel-head">
            <div>
                <h2>Search &amp; Filter Routes</h2>
                <p>Combine Route ID, source, destination and status filters.</p>
            </div>

            <span class="badge neutral">READ ONLY</span>
        </div>

        <form class="filters" method="get"
              action="<%= cp %>/admin/routes">

            <div class="field">
                <label for="routeId">Route ID</label>

                <input type="number" id="routeId" name="routeId"
                       min="1" step="1"
                       placeholder="Exact Route ID"
                       value="<%= esc(routeId) %>">
            </div>

            <div class="field">
                <label for="source">Source City</label>

                <input type="text" id="source" name="source"
                       maxlength="100"
                       placeholder="Search source"
                       value="<%= esc(source) %>">
            </div>

            <div class="field">
                <label for="destination">Destination City</label>

                <input type="text" id="destination" name="destination"
                       maxlength="100"
                       placeholder="Search destination"
                       value="<%= esc(destination) %>">
            </div>

            <div class="field">
                <label for="status">Route Status</label>

                <select id="status" name="status">
                    <option value="">All Statuses</option>

                    <% if (statuses != null) {
                        for (String s : statuses) { %>

                        <option value="<%= esc(s) %>"
                            <%= s.equalsIgnoreCase(status)
                                    ? "selected" : "" %>>
                            <%= esc(s) %>
                        </option>

                    <%  }
                       } %>
                </select>
            </div>

            <div class="actions">

                <button class="btn btn-primary" type="submit">
                    Apply Filters
                </button>

                <a class="btn btn-secondary"
                   href="<%= cp %>/admin/routes">
                    Reset
                </a>

            </div>

        </form>

    </section>

    <section class="panel">

        <div class="panel-head">
            <div>
                <h2>Route Records</h2>
                <p>Existing route information from the database.</p>
            </div>

            <span class="badge neutral">
                <%= visible %> Records
            </span>
        </div>

        <div class="table-wrap">

            <table>

                <thead>
                    <tr>
                        <th>Route ID</th>
                        <th>Source</th>
                        <th>Destination</th>
                        <th>Distance</th>
                        <th>Schedules</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody>

                <% if (routes != null && !routes.isEmpty()) {

                    for (Map<String, Object> route : routes) {

                        String routeStatus =
                            String.valueOf(route.get("status"));

                        String badgeClass =
                            "ACTIVE".equalsIgnoreCase(routeStatus)
                                ? "success"
                                : "INACTIVE".equalsIgnoreCase(routeStatus)
                                    ? "danger" : "neutral";
                %>

                    <tr>

                        <td>
                            <strong>
                                #<%= esc(route.get("route_id")) %>
                            </strong>
                        </td>

                        <td>
                            <strong>
                                <%= esc(route.get("source_city")) %>
                            </strong>

                            <span class="subtext">
                                City ID:
                                <%= esc(route.get("source_city_id")) %>
                            </span>
                        </td>

                        <td>
                            <strong>
                                <%= esc(route.get("destination_city")) %>
                            </strong>

                            <span class="subtext">
                                City ID:
                                <%= esc(route.get("destination_city_id")) %>
                            </span>
                        </td>

                        <td>
                            <%= esc(route.get("distance_km")) %> km
                        </td>

                        <td>
                            <%= esc(route.get("schedule_count")) %>
                        </td>

                        <td>
                            <span class="badge <%= badgeClass %>">
                                <%= esc(routeStatus) %>
                            </span>
                        </td>

                        <td>
                            <a class="btn btn-view"
                               href="<%= cp %>/admin/routes?<%= esc(filterQuery) %>&amp;details=<%= esc(route.get("route_id")) %>#routeDetails">
                                View Details
                            </a>
                        </td>

                    </tr>

                <%  }
                   } else { %>

                    <tr>
                        <td colspan="7" class="empty">
                            No matching route records found.
                        </td>
                    </tr>

                <% } %>

                </tbody>

            </table>

        </div>

    </section>

    <% if (selectedRoute != null) { %>

    <section class="panel" id="routeDetails">

        <div class="panel-head">

            <div>
                <h2>
                    Route #<%= esc(selectedRoute.get("route_id")) %>
                </h2>
                <p>Complete route information.</p>
            </div>

            <a class="btn btn-secondary"
               href="<%= cp %>/admin/routes?<%= esc(filterQuery) %>">
                Close Details
            </a>

        </div>

        <div class="details-grid">

            <div class="detail-item">
                <small>Route ID</small>
                <strong>
                    #<%= esc(selectedRoute.get("route_id")) %>
                </strong>
            </div>

            <div class="detail-item">
                <small>Source City</small>
                <strong>
                    <%= esc(selectedRoute.get("source_city")) %>
                </strong>
            </div>

            <div class="detail-item">
                <small>Source City ID</small>
                <strong>
                    <%= esc(selectedRoute.get("source_city_id")) %>
                </strong>
            </div>

            <div class="detail-item">
                <small>Destination City</small>
                <strong>
                    <%= esc(selectedRoute.get("destination_city")) %>
                </strong>
            </div>

            <div class="detail-item">
                <small>Destination City ID</small>
                <strong>
                    <%= esc(selectedRoute.get("destination_city_id")) %>
                </strong>
            </div>

            <div class="detail-item">
                <small>Distance</small>
                <strong>
                    <%= esc(selectedRoute.get("distance_km")) %> km
                </strong>
            </div>

            <div class="detail-item">
                <small>Linked Schedules</small>
                <strong>
                    <%= esc(selectedRoute.get("schedule_count")) %>
                </strong>
            </div>

            <div class="detail-item">
                <small>Route Status</small>
                <strong>
                    <%= esc(selectedRoute.get("status")) %>
                </strong>
            </div>

        </div>

        <div class="notice">
            This page is read-only. Existing routes and linked schedules
            are not modified.
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