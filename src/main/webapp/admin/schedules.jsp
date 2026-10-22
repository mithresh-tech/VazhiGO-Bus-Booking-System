<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.tnbus.model.BusSchedule" %>

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
%>

<%
    if (session.getAttribute("loggedInAdmin") == null) {

        response.sendRedirect(
                request.getContextPath() + "/admin-login.jsp");

        return;
    }

    @SuppressWarnings("unchecked")
    List<BusSchedule> schedules =
            (List<BusSchedule>) request.getAttribute("schedules");

    if (schedules == null) {

        response.sendRedirect(
                request.getContextPath() + "/admin/schedules");

        return;
    }

    @SuppressWarnings("unchecked")
    List<String[]> busOptions =
            (List<String[]>) request.getAttribute("busOptions");

    @SuppressWarnings("unchecked")
    List<String[]> routeOptions =
            (List<String[]>) request.getAttribute("routeOptions");

    @SuppressWarnings("unchecked")
    Map<Integer, String> busNumberMap =
            (Map<Integer, String>) request.getAttribute("busNumberMap");

    String cp = request.getContextPath();

    String token = (String) request.getAttribute("csrfToken");

    String success =
            (String) request.getAttribute("successMessage");

    String error =
            (String) request.getAttribute("errorMessage");

    int total =
            (Integer) request.getAttribute("totalSchedules");

    int scheduled =
            (Integer) request.getAttribute("scheduledCount");

    int cancelled =
            (Integer) request.getAttribute("cancelledCount");
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1">

<title>Schedule Management | VazhiGo</title>

<style>

:root {
    --navy: #102b49;
    --dark: #07192c;
    --gold: #ffc86a;
    --bg: #f3f6fb;
    --muted: #728198;
    --border: #e2e9f1;
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: 'Segoe UI', Arial, sans-serif;
    background: var(--bg);
    color: #26364a;
}

.sidebar {
    position: fixed;
    top: 0;
    bottom: 0;
    left: 0;
    width: 245px;
    padding: 30px 18px;
    background: var(--dark);
    color: white;
    z-index: 20;
    overflow-y: auto;
}

.brand {
    font-size: 28px;
    font-weight: 800;
    padding: 0 13px 35px;
}

.brand span {
    color: var(--gold);
}

.nav {
    display: block;
    padding: 15px;
    margin-bottom: 8px;
    border-radius: 10px;
    text-decoration: none;
    color: #c6d5e6;
    font-size: 14px;
}

.nav:hover,
.nav.current {
    background: #244a70;
    color: white;
}

.main {
    margin-left: 245px;
}

.topbar {
    background: white;
    border-bottom: 1px solid var(--border);
    padding: 23px 35px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
}

.content {
    padding: 35px;
    max-width: 1500px;
    margin: auto;
}

.heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 20px;
    margin-bottom: 30px;
}

.heading h1 {
    color: var(--navy);
    margin: 0 0 8px;
}

.heading p {
    margin: 0;
    color: var(--muted);
    font-size: 14px;
}

.btn {
    border: 0;
    padding: 12px 17px;
    border-radius: 9px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 700;
}

.btn-primary {
    background: var(--navy);
    color: white;
}

.btn-gold {
    background: var(--gold);
    color: var(--navy);
}

.btn-light {
    background: #eaf0f7;
    color: var(--navy);
}

.btn-danger {
    background: #fde8e8;
    color: #aa3030;
}

.btn:disabled {
    opacity: .5;
    cursor: not-allowed;
}

.stats {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.stat {
    background: white;
    border: 1px solid var(--border);
    border-radius: 15px;
    padding: 25px;
}

.stat small {
    color: var(--muted);
}

.stat h2 {
    color: var(--navy);
    font-size: 35px;
    margin: 14px 0 0;
}

.panel {
    background: white;
    border: 1px solid var(--border);
    border-radius: 15px;
    overflow: hidden;
}

/* TWO INDEPENDENT SEARCH BOXES */

.toolbar {
    padding: 22px;
    display: flex;
    gap: 15px;
    flex-wrap: wrap;
    align-items: flex-end;
}

.search-field {
    flex: 1;
    min-width: 180px;
}

.search-field label {
    display: block;
    margin-bottom: 7px;
    font-size: 12px;
    font-weight: 700;
    color: var(--navy);
}

.search-field input,
.search-field select {
    width: 100%;
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 12px;
    min-height: 44px;
    font-size: 14px;
    background: white;
    color: #26364a;
}

.search-summary {
    padding: 0 22px 18px;
    font-size: 13px;
    color: var(--muted);
}

.table-wrap {
    overflow-x: auto;
}

table {
    width: 100%;
    min-width: 1080px;
    border-collapse: collapse;
}

th,
td {
    padding: 16px;
    border-top: 1px solid var(--border);
    text-align: left;
    font-size: 13px;
}

th {
    background: #f7f9fc;
    color: #64758a;
    font-size: 11px;
    text-transform: uppercase;
}

.badge {
    display: inline-block;
    border-radius: 25px;
    padding: 7px 11px;
    font-size: 11px;
    font-weight: 800;
}

.badge-scheduled {
    background: #e0f5e7;
    color: #16723a;
}

.badge-cancelled {
    background: #fde8e8;
    color: #a12c2c;
}

.actions {
    display: flex;
    gap: 7px;
    align-items: center;
}

.actions form {
    margin: 0;
}

.notice {
    padding: 15px;
    border-radius: 9px;
    margin-bottom: 20px;
}

.notice.success {
    background: #e4f6ea;
    color: #176b37;
}

.notice.error {
    background: #fde9e9;
    color: #a12c2c;
}

.modal {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(4, 17, 32, .7);
    z-index: 50;
    padding: 20px;
    overflow-y: auto;
    align-items: flex-start;
    justify-content: center;
}

.modal.show {
    display: flex;
}

.modal-card {
    background: white;
    width: 100%;
    max-width: 760px;
    border-radius: 17px;
    padding: 28px;
    margin: auto;
}

.modal-card h2 {
    margin: 0 0 8px;
    color: var(--navy);
}

.modal-card p {
    color: var(--muted);
    font-size: 13px;
    line-height: 1.6;
}

.form-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 15px;
}

.field {
    min-width: 0;
}

.field.full {
    grid-column: 1 / -1;
}

.field label {
    display: block;
    margin-bottom: 7px;
    font-size: 13px;
    font-weight: 700;
}

.field input,
.field select {
    width: 100%;
    min-height: 45px;
    padding: 11px;
    border: 1px solid var(--border);
    border-radius: 8px;
    font-size: 16px;
}

.section-label {
    grid-column: 1 / -1;
    padding-top: 15px;
    color: var(--navy);
    font-weight: 800;
    border-top: 1px solid var(--border);
}

.modal-actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 25px;
}

.empty {
    padding: 25px;
    text-align: center;
    color: var(--muted);
}

.menu-btn {
    display: none;
    background: var(--navy);
    color: white;
    border: 0;
    border-radius: 8px;
    padding: 10px 13px;
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

    .menu-btn {
        display: inline-block;
    }

    .content {
        padding: 22px 15px;
    }

    .topbar {
        padding: 18px;
    }
}

@media(max-width: 600px) {

    .stats,
    .form-grid {
        grid-template-columns: 1fr;
    }

    .modal-card {
        padding: 20px;
    }

    .search-field {
        flex: 1 1 100%;
    }
}

</style>

</head>

<body>

<aside class="sidebar" id="sidebar">

    <div class="brand">
        Vazhi<span>Go</span>
    </div>

    <a class="nav"
       href="<%= cp %>/admin/dashboard">
        ▦ &nbsp; Dashboard
    </a>

    <a class="nav"
       href="<%= cp %>/admin/buses">
        🚌 &nbsp; Bus Management
    </a>

    <a class="nav current"
       href="<%= cp %>/admin/schedules">
        ◷ &nbsp; Schedule Management
    </a>

    <a class="nav"
       href="<%= cp %>/admin/emergencies">
        ⚠ &nbsp; Emergency SOS
    </a>

    <a class="nav"
       href="<%= cp %>/index.jsp">
        ↗ &nbsp; View Website
    </a>

</aside>

<div class="main">

<header class="topbar">

    <div style="display:flex;align-items:center;gap:12px;">

        <button type="button"
                class="menu-btn"
                id="menuButton">
            ☰
        </button>

        <strong>Schedule Management</strong>

    </div>

    <span>VazhiGo Admin</span>

</header>

<main class="content">

    <div class="heading">

        <div>

            <h1>Manage Journeys</h1>

            <p>
                Configure bus journeys, departure times and category-wise fares.
            </p>

        </div>

        <button type="button"
                class="btn btn-gold"
                id="addButton">
            + Add Schedule
        </button>

    </div>

    <% if (success != null) { %>

        <div class="notice success" role="status">
            <%= esc(success) %>
        </div>

    <% } %>

    <% if (error != null) { %>

        <div class="notice error" role="alert">
            <%= esc(error) %>
        </div>

    <% } %>

    <section class="stats">

        <div class="stat">
            <small>Total Schedules</small>
            <h2><%= total %></h2>
        </div>

        <div class="stat">
            <small>Scheduled</small>
            <h2><%= scheduled %></h2>
        </div>

        <div class="stat">
            <small>Cancelled</small>
            <h2><%= cancelled %></h2>
        </div>

    </section>

    <section class="panel">

        <!-- TWO SEPARATE SEARCH INPUTS -->

        <div class="toolbar">

            <div class="search-field">

                <label for="scheduleSearch">
                    Search by Schedule ID
                </label>

                <input type="search"
                       id="scheduleSearch"
                       placeholder="Example: 3"
                       inputmode="numeric"
                       autocomplete="off">

            </div>

            <div class="search-field">

                <label for="busNumberSearch">
                    Search by Bus Number
                </label>

                <input type="search"
                       id="busNumberSearch"
                       placeholder="Example: TN01AB1234"
                       autocomplete="off">

            </div>

            <div class="search-field">

                <label for="statusFilter">
                    Schedule Status
                </label>

                <select id="statusFilter">

                    <option value="ALL">All Status</option>
                    <option value="SCHEDULED">Scheduled</option>
                    <option value="CANCELLED">Cancelled</option>

                </select>

            </div>

            <button type="button"
                    class="btn btn-light"
                    id="clearSearchButton">

                Clear Search

            </button>

        </div>

        <div class="search-summary"
             id="searchSummary"
             role="status"
             aria-live="polite">

            Showing <%= schedules.size() %> schedules

        </div>

        <div class="table-wrap">

            <table>

                <thead>

                    <tr>
                        <th>Schedule ID</th>
                        <th>Bus Number</th>
                        <th>Route</th>
                        <th>Travel Date</th>
                        <th>Departure</th>
                        <th>Arrival</th>
                        <th>Base Fare</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>

                </thead>

                <tbody id="scheduleTableBody">

                <% for (BusSchedule item : schedules) {

                    boolean canManage =
                            "SCHEDULED".equalsIgnoreCase(
                                    item.getStatus());

                    String actualBusNumber =
                            busNumberMap.get(item.getBusId());

                    if (actualBusNumber == null) {
                        actualBusNumber = "";
                    }
                %>

                    <tr class="schedule-row"

                        data-schedule-id="<%= item.getScheduleId() %>"

                        data-bus-number="<%= esc(actualBusNumber) %>"

                        data-status="<%= esc(item.getStatus()) %>">

                        <td>
                            #<%= item.getScheduleId() %>
                        </td>

                        <td>
                            <%= esc(actualBusNumber) %>
                        </td>

                        <td>
                            Route #<%= item.getRouteId() %>
                        </td>

                        <td>
                            <%= item.getTravelDate() %>
                        </td>

                        <td>
                            <%= item.getDepartureTime() %>
                        </td>

                        <td>
                            <%= item.getArrivalTime() %>
                        </td>

                        <td>
                            ₹<%= item.getFare() %>
                        </td>

                        <td>

                            <span class="badge <%= canManage
                                    ? "badge-scheduled"
                                    : "badge-cancelled" %>">

                                <%= esc(item.getStatus()) %>

                            </span>

                        </td>

                        <td>

                            <div class="actions">

                                <button type="button"
                                        class="btn btn-light edit-btn"

                                        data-id="<%= item.getScheduleId() %>"
                                        data-bus="<%= item.getBusId() %>"
                                        data-route="<%= item.getRouteId() %>"
                                        data-date="<%= item.getTravelDate() %>"
                                        data-departure="<%= item.getDepartureTime() %>"
                                        data-arrival="<%= item.getArrivalTime() %>"

                                        data-fare="<%= esc(item.getFare()) %>"
                                        data-upper="<%= esc(item.getUpperDeckFare()) %>"
                                        data-lower="<%= esc(item.getLowerDeckFare()) %>"
                                        data-double-upper="<%= esc(item.getDoubleUpperFare()) %>"
                                        data-double-lower="<%= esc(item.getDoubleLowerFare()) %>"
                                        data-single-upper="<%= esc(item.getSingleUpperFare()) %>"
                                        data-single-lower="<%= esc(item.getSingleLowerFare()) %>"
                                        data-seater="<%= esc(item.getSeaterFare()) %>"

                                        <%= canManage ? "" : "disabled" %>>

                                    Edit

                                </button>

                                <form method="post"
                                      action="<%= cp %>/admin/schedules"
                                      class="cancel-form">

                                    <input type="hidden"
                                           name="csrfToken"
                                           value="<%= esc(token) %>">

                                    <input type="hidden"
                                           name="action"
                                           value="cancel">

                                    <input type="hidden"
                                           name="scheduleId"
                                           value="<%= item.getScheduleId() %>">

                                    <button type="submit"
                                            class="btn btn-danger"
                                            <%= canManage ? "" : "disabled" %>>

                                        Cancel

                                    </button>

                                </form>

                            </div>

                        </td>

                    </tr>

                <% } %>

                </tbody>

            </table>

            <div class="empty"
                 id="emptyMessage"
                 style="display:none;">

                No matching schedules found.

            </div>

            <% if (schedules.isEmpty()) { %>

                <div class="empty">
                    No schedules available.
                </div>

            <% } %>

        </div>

    </section>

</main>

</div>

<!-- ADD / EDIT MODAL -->

<div class="modal"
     id="scheduleModal"
     role="dialog"
     aria-modal="true"
     aria-labelledby="modalTitle">

    <div class="modal-card">

        <h2 id="modalTitle">
            Add Schedule
        </h2>

        <p>
            Existing passenger bookings and payment records are protected.
        </p>

        <form method="post"
              action="<%= cp %>/admin/schedules"
              id="scheduleForm">

            <input type="hidden"
                   name="csrfToken"
                   value="<%= esc(token) %>">

            <input type="hidden"
                   name="action"
                   id="formAction"
                   value="add">

            <input type="hidden"
                   name="scheduleId"
                   id="scheduleId">

            <div class="form-grid">

                <div class="field">

                    <label for="busId">
                        Select Bus
                    </label>

                    <select name="busId"
                            id="busId"
                            required>

                        <option value="">
                            Select Bus
                        </option>

                        <% for (String[] bus : busOptions) { %>

                            <option value="<%= esc(bus[0]) %>">
                                <%= esc(bus[1]) %>
                            </option>

                        <% } %>

                    </select>

                </div>

                <div class="field">

                    <label for="routeId">
                        Select Route
                    </label>

                    <select name="routeId"
                            id="routeId"
                            required>

                        <option value="">
                            Select Route
                        </option>

                        <% for (String[] route : routeOptions) { %>

                            <option value="<%= esc(route[0]) %>">
                                <%= esc(route[1]) %>
                            </option>

                        <% } %>

                    </select>

                </div>

                <div class="field">

                    <label for="travelDate">
                        Travel Date
                    </label>

                    <input type="date"
                           name="travelDate"
                           id="travelDate"
                           required>

                </div>

                <div class="field">

                    <label for="departureTime">
                        Departure Time
                    </label>

                    <input type="time"
                           name="departureTime"
                           id="departureTime"
                           required>

                </div>

                <div class="field">

                    <label for="arrivalTime">
                        Arrival Time
                    </label>

                    <input type="time"
                           name="arrivalTime"
                           id="arrivalTime"
                           required>

                </div>

                <div class="field">

                    <label for="fare">
                        Base Fare (₹)
                    </label>

                    <input type="number"
                           name="fare"
                           id="fare"
                           min="0"
                           max="99999999.99"
                           step="0.01"
                           required>

                </div>

                <div class="section-label">
                    Category-wise Pricing (₹)
                </div>

                <div class="field">

                    <label for="upperDeckFare">
                        Upper Deck Fare
                    </label>

                    <input type="number"
                           name="upperDeckFare"
                           id="upperDeckFare"
                           min="0"
                           step="0.01">

                </div>

                <div class="field">

                    <label for="lowerDeckFare">
                        Lower Deck Fare
                    </label>

                    <input type="number"
                           name="lowerDeckFare"
                           id="lowerDeckFare"
                           min="0"
                           step="0.01">

                </div>

                <div class="field">

                    <label for="doubleUpperFare">
                        Double Upper Fare
                    </label>

                    <input type="number"
                           name="doubleUpperFare"
                           id="doubleUpperFare"
                           min="0"
                           step="0.01">

                </div>

                <div class="field">

                    <label for="doubleLowerFare">
                        Double Lower Fare
                    </label>

                    <input type="number"
                           name="doubleLowerFare"
                           id="doubleLowerFare"
                           min="0"
                           step="0.01">

                </div>

                <div class="field">

                    <label for="singleUpperFare">
                        Single Upper Fare
                    </label>

                    <input type="number"
                           name="singleUpperFare"
                           id="singleUpperFare"
                           min="0"
                           step="0.01">

                </div>

                <div class="field">

                    <label for="singleLowerFare">
                        Single Lower Fare
                    </label>

                    <input type="number"
                           name="singleLowerFare"
                           id="singleLowerFare"
                           min="0"
                           step="0.01">

                </div>

                <div class="field full">

                    <label for="seaterFare">
                        Seater Fare
                    </label>

                    <input type="number"
                           name="seaterFare"
                           id="seaterFare"
                           min="0"
                           step="0.01">

                </div>

            </div>

            <div class="modal-actions">

                <button type="button"
                        class="btn btn-light"
                        id="closeButton">

                    Cancel

                </button>

                <button type="submit"
                        class="btn btn-primary"
                        id="saveButton">

                    Save Schedule

                </button>

            </div>

        </form>

    </div>

</div>

<script>

// ==========================================
// SIDEBAR
// ==========================================

const sidebar = document.getElementById("sidebar");

document.getElementById("menuButton")
    .addEventListener("click", function () {

        sidebar.classList.toggle("open");
    });


// ==========================================
// MODAL
// ==========================================

const modal = document.getElementById("scheduleModal");

const form = document.getElementById("scheduleForm");

const actionField = document.getElementById("formAction");

const idField = document.getElementById("scheduleId");

const title = document.getElementById("modalTitle");

const saveButton = document.getElementById("saveButton");

function openModal() {

    modal.classList.add("show");

    document.getElementById("busId").focus();
}

function closeModal() {

    modal.classList.remove("show");
}


// ==========================================
// ADD SCHEDULE
// ==========================================

document.getElementById("addButton")
    .addEventListener("click", function () {

        form.reset();

        actionField.value = "add";

        idField.value = "";

        title.textContent = "Add New Schedule";

        saveButton.textContent = "Create Schedule";

        openModal();
    });


// ==========================================
// EDIT SCHEDULE
// ==========================================

document.querySelectorAll(".edit-btn")
    .forEach(function (button) {

        button.addEventListener("click", function () {

            form.reset();

            actionField.value = "edit";

            idField.value = button.dataset.id;

            const values = {

                busId: button.dataset.bus,
                routeId: button.dataset.route,
                travelDate: button.dataset.date,
                departureTime: button.dataset.departure,
                arrivalTime: button.dataset.arrival,
                fare: button.dataset.fare,
                upperDeckFare: button.dataset.upper,
                lowerDeckFare: button.dataset.lower,
                doubleUpperFare: button.dataset.doubleUpper,
                doubleLowerFare: button.dataset.doubleLower,
                singleUpperFare: button.dataset.singleUpper,
                singleLowerFare: button.dataset.singleLower,
                seaterFare: button.dataset.seater
            };

            Object.keys(values).forEach(function (key) {

                const input = document.getElementById(key);

                if (input) {

                    input.value =
                        values[key] === "null"
                        ? ""
                        : (values[key] || "");
                }
            });

            title.textContent = "Edit Schedule";

            saveButton.textContent = "Save Changes";

            openModal();
        });
    });


// ==========================================
// CLOSE MODAL
// ==========================================

document.getElementById("closeButton")
    .addEventListener("click", closeModal);

modal.addEventListener("click", function (event) {

    if (event.target === modal) {
        closeModal();
    }
});

document.addEventListener("keydown", function (event) {

    if (event.key === "Escape") {

        closeModal();

        sidebar.classList.remove("open");
    }
});


// ==========================================
// CANCEL CONFIRMATION
// ==========================================

document.querySelectorAll(".cancel-form")
    .forEach(function (cancelForm) {

        cancelForm.addEventListener("submit", function (event) {

            if (!confirm(
                    "Cancel this schedule? This action is blocked if any booking history exists.")) {

                event.preventDefault();
            }
        });
    });


// ==========================================
// TWO INDEPENDENT SEARCH BOXES
// ==========================================

const scheduleSearch =
    document.getElementById("scheduleSearch");

const busNumberSearch =
    document.getElementById("busNumberSearch");

const statusFilter =
    document.getElementById("statusFilter");

const emptyMessage =
    document.getElementById("emptyMessage");

const searchSummary =
    document.getElementById("searchSummary");

const scheduleRows =
    document.querySelectorAll(
        "#scheduleTableBody .schedule-row"
    );

function filterSchedules() {

    // Schedule ID: exact numeric match only.

    const scheduleValue =
        scheduleSearch.value.trim();

    // Bus Number: registration number only.
    // Spaces and hyphens are ignored for easier searching.

    const busValue =
        busNumberSearch.value
            .toUpperCase()
            .replace(/[\s-]/g, "")
            .trim();

    const selectedStatus = statusFilter.value;

    let visibleCount = 0;

    scheduleRows.forEach(function (row) {

        const actualScheduleId =
            row.dataset.scheduleId;

        const actualBusNumber =
            (row.dataset.busNumber || "")
                .toUpperCase()
                .replace(/[\s-]/g, "");

        // These are independent comparisons.
        // Bus ID is never used for searching.

        const matchesSchedule =
            scheduleValue === ""
            || actualScheduleId === scheduleValue;

        const matchesBusNumber =
            busValue === ""
            || actualBusNumber.includes(busValue);

        const matchesStatus =
            selectedStatus === "ALL"
            || row.dataset.status === selectedStatus;

        const shouldDisplay =
            matchesSchedule
            && matchesBusNumber
            && matchesStatus;

        row.style.display =
            shouldDisplay ? "" : "none";

        if (shouldDisplay) {
            visibleCount++;
        }
    });

    emptyMessage.style.display =
        visibleCount === 0 && scheduleRows.length > 0
        ? "block"
        : "none";

    searchSummary.textContent =
        "Showing " + visibleCount
        + " of " + scheduleRows.length
        + " schedules";
}


// Schedule ID input: numbers only.

scheduleSearch.addEventListener("input", function () {

    scheduleSearch.value =
        scheduleSearch.value.replace(/[^0-9]/g, "");

    filterSchedules();
});


// Bus Number input: letters and numbers allowed.

busNumberSearch.addEventListener(
    "input",
    filterSchedules
);


// Status filter.

statusFilter.addEventListener(
    "change",
    filterSchedules
);


// Clear both searches and status filter.

document.getElementById("clearSearchButton")
    .addEventListener("click", function () {

        scheduleSearch.value = "";

        busNumberSearch.value = "";

        statusFilter.value = "ALL";

        filterSchedules();
    });


// Initialize.

filterSchedules();

</script>

</body>
</html>