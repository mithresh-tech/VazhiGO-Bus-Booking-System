<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.tnbus.model.Admin" %>
<%@ page import="com.tnbus.model.Bus" %>

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
    Admin admin =
            (Admin) session.getAttribute("loggedInAdmin");

    if (admin == null) {

        response.sendRedirect(
                request.getContextPath() + "/admin-login.jsp");

        return;
    }

    @SuppressWarnings("unchecked")
    List<Bus> buses =
            (List<Bus>) request.getAttribute("buses");

    if (buses == null) {

        response.sendRedirect(
                request.getContextPath() + "/admin/buses");

        return;
    }

    String contextPath = request.getContextPath();

    String token =
            (String) request.getAttribute("csrfToken");

    String success =
            (String) request.getAttribute("successMessage");

    String error =
            (String) request.getAttribute("errorMessage");

    int total = (Integer) request.getAttribute("totalBuses");
    int active = (Integer) request.getAttribute("activeBuses");
    int inactive = (Integer) request.getAttribute("inactiveBuses");
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1">

<title>Bus Management | VazhiGo</title>

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
    background: var(--dark);
    color: white;
    padding: 30px 18px;
    z-index: 20;
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
    color: #c6d5e6;
    text-decoration: none;
    padding: 15px;
    border-radius: 10px;
    margin-bottom: 8px;
    font-size: 14px;
}

.nav:hover,
.nav.active {
    background: #244a70;
    color: white;
}

.main {
    margin-left: 245px;
}

.topbar {
    padding: 23px 35px;
    background: white;
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
}

.topbar strong {
    color: var(--navy);
}

.content {
    padding: 35px;
    max-width: 1500px;
    margin: auto;
}

.heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
    flex-wrap: wrap;
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
    padding: 12px 18px;
    border-radius: 9px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 700;
    transition: transform .2s, opacity .2s;
}

.btn:hover {
    transform: translateY(-2px);
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

.btn-success {
    background: #e1f5e8;
    color: #18753a;
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
    animation: rise .6s ease both;
}

.stat:nth-child(2) {
    animation-delay: .1s;
}

.stat:nth-child(3) {
    animation-delay: .2s;
}

.stat small {
    color: var(--muted);
    font-size: 13px;
}

.stat h2 {
    color: var(--navy);
    font-size: 36px;
    margin: 15px 0 0;
}

.panel {
    background: white;
    border: 1px solid var(--border);
    border-radius: 15px;
    overflow: hidden;
    animation: rise .7s ease both;
}

.toolbar {
    padding: 22px;
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    justify-content: space-between;
}

.toolbar input,
.toolbar select {
    border: 1px solid var(--border);
    padding: 12px;
    border-radius: 8px;
    font-size: 14px;
    min-height: 44px;
}

.toolbar input {
    flex: 1;
    min-width: 180px;
}

.table-wrap {
    overflow-x: auto;
}

table {
    width: 100%;
    min-width: 900px;
    border-collapse: collapse;
}

th, td {
    padding: 17px;
    text-align: left;
    border-top: 1px solid var(--border);
    font-size: 13px;
}

th {
    background: #f7f9fc;
    color: #64758a;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: .5px;
}

tbody tr:hover {
    background: #fafcff;
}

.badge {
    display: inline-block;
    border-radius: 30px;
    padding: 7px 11px;
    font-size: 11px;
    font-weight: 800;
}

.active {
    background: #e0f5e7;
    color: #16723a;
}

.inactive {
    background: #edf0f4;
    color: #687586;
}

.actions {
    display: flex;
    align-items: center;
    gap: 7px;
}

.actions form {
    margin: 0;
}

.notice {
    padding: 15px;
    border-radius: 9px;
    margin-bottom: 20px;
    font-size: 14px;
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
    background: rgba(4, 17, 32, .68);
    z-index: 50;
    padding: 20px;
    overflow-y: auto;
    align-items: center;
    justify-content: center;
}

.modal.show {
    display: flex;
}

.modal-card {
    background: white;
    width: 100%;
    max-width: 510px;
    border-radius: 17px;
    padding: 28px;
    animation: rise .25s ease;
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

.field {
    margin: 17px 0;
}

.field label {
    display: block;
    margin-bottom: 8px;
    font-size: 13px;
    font-weight: 700;
}

.field input,
.field select {
    width: 100%;
    min-height: 45px;
    padding: 12px;
    border: 1px solid var(--border);
    border-radius: 8px;
    font-size: 16px;
}

.field input:focus,
.field select:focus {
    outline: 2px solid #8aa8c8;
}

.modal-actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 25px;
}

.empty {
    text-align: center;
    padding: 30px;
    color: var(--muted);
}

.menu-btn {
    display: none;
    background: var(--navy);
    color: white;
    border: 0;
    border-radius: 8px;
    padding: 10px 13px;
    cursor: pointer;
}

@keyframes rise {
    from {
        opacity: 0;
        transform: translateY(15px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
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

    .stats {
        grid-template-columns: 1fr;
    }

    .heading h1 {
        font-size: 24px;
    }

    .toolbar input,
    .toolbar select {
        width: 100%;
    }

    .modal-card {
        padding: 20px;
    }
}

@media(prefers-reduced-motion: reduce) {
    *, *::before, *::after {
        animation: none !important;
        transition: none !important;
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
       href="<%= contextPath %>/admin/dashboard">
        ▦ &nbsp; Dashboard
    </a>

    <a class="nav active"
       href="<%= contextPath %>/admin/buses">
        🚌 &nbsp; Bus Management
    </a>

    <a class="nav"
       href="<%= contextPath %>/admin/emergencies">
        ⚠ &nbsp; Emergency SOS
    </a>

    <a class="nav"
       href="<%= contextPath %>/index.jsp">
        ↗ &nbsp; View Website
    </a>

</aside>

<div class="main">

<header class="topbar">

    <div style="display:flex;align-items:center;gap:12px;">

        <button type="button"
                class="menu-btn"
                id="menuButton"
                aria-label="Toggle navigation">
            ☰
        </button>

        <strong>Bus Management</strong>

    </div>

    <span>
        <%= esc(admin.getAdminName()) %>
    </span>

</header>

<main class="content">

    <div class="heading">

        <div>
            <h1>Manage Your Fleet</h1>

            <p>
                Add, update and manage VazhiGo buses.
            </p>
        </div>

        <button type="button"
                class="btn btn-gold"
                id="addBusButton">
            + Add New Bus
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
            <small>Total Buses</small>
            <h2><%= total %></h2>
        </div>

        <div class="stat">
            <small>Active Buses</small>
            <h2><%= active %></h2>
        </div>

        <div class="stat">
            <small>Inactive Buses</small>
            <h2><%= inactive %></h2>
        </div>

    </section>

    <section class="panel">

        <div class="toolbar">

            <input type="search"
                   id="searchInput"
                   placeholder="Search bus number, name or type..."
                   aria-label="Search buses">

            <select id="statusFilter"
                    aria-label="Filter by status">

                <option value="ALL">All Status</option>
                <option value="ACTIVE">Active</option>
                <option value="INACTIVE">Inactive</option>

            </select>

        </div>

        <div class="table-wrap">

            <table id="busTable">

                <thead>
                    <tr>
                        <th>Bus ID</th>
                        <th>Bus Number</th>
                        <th>Bus Name</th>
                        <th>Bus Type</th>
                        <th>Seats</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>

                <tbody>

                <% for (Bus bus : buses) {

                    boolean isActive =
                            "ACTIVE".equalsIgnoreCase(bus.getStatus());
                %>

                    <tr class="bus-row"
                        data-search="<%= esc(
                            (bus.getBusNumber() + " "
                            + bus.getBusName() + " "
                            + bus.getBusType()).toLowerCase()
                        ) %>"
                        data-status="<%= esc(bus.getStatus()) %>">

                        <td>
                            #<%= bus.getBusId() %>
                        </td>

                        <td>
                            <strong>
                                <%= esc(bus.getBusNumber()) %>
                            </strong>
                        </td>

                        <td>
                            <%= esc(bus.getBusName()) %>
                        </td>

                        <td>
                            <%= esc(bus.getBusType()) %>
                        </td>

                        <td>
                            <%= bus.getTotalSeats() %>
                        </td>

                        <td>

                            <span class="badge
                                <%= isActive ? "active" : "inactive" %>">

                                <%= esc(bus.getStatus()) %>

                            </span>

                        </td>

                        <td>

                            <div class="actions">

                                <button type="button"
                                        class="btn btn-light edit-btn"
                                        data-id="<%= bus.getBusId() %>"
                                        data-number="<%= esc(bus.getBusNumber()) %>"
                                        data-name="<%= esc(bus.getBusName()) %>"
                                        data-type="<%= esc(bus.getBusType()) %>">
                                    Edit
                                </button>

                                <form method="post"
                                      action="<%= contextPath %>/admin/buses"
                                      class="status-form">

                                    <input type="hidden"
                                           name="csrfToken"
                                           value="<%= esc(token) %>">

                                    <input type="hidden"
                                           name="action"
                                           value="status">

                                    <input type="hidden"
                                           name="busId"
                                           value="<%= bus.getBusId() %>">

                                    <input type="hidden"
                                           name="status"
                                           value="<%= isActive
                                                ? "INACTIVE"
                                                : "ACTIVE" %>">

                                    <button type="submit"
                                            class="btn <%= isActive
                                                ? "btn-danger"
                                                : "btn-success" %>">

                                        <%= isActive
                                                ? "Deactivate"
                                                : "Activate" %>

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
                No matching buses found.
            </div>

            <% if (buses.isEmpty()) { %>

                <div class="empty">
                    No buses available.
                </div>

            <% } %>

        </div>

    </section>

</main>

</div>

<!-- ADD / EDIT MODAL -->

<div class="modal"
     id="busModal"
     role="dialog"
     aria-modal="true"
     aria-labelledby="modalTitle">

    <div class="modal-card">

        <h2 id="modalTitle">Add New Bus</h2>

        <p id="modalDescription">
            Enter the new bus details.
        </p>

        <form method="post"
              action="<%= contextPath %>/admin/buses"
              id="busForm">

            <input type="hidden"
                   name="csrfToken"
                   value="<%= esc(token) %>">

            <input type="hidden"
                   name="action"
                   id="formAction"
                   value="add">

            <input type="hidden"
                   name="busId"
                   id="busId">

            <div class="field">

                <label for="busNumber">
                    Bus Number
                </label>

                <input type="text"
                       name="busNumber"
                       id="busNumber"
                       maxlength="30"
                       required>

            </div>

            <div class="field">

                <label for="busName">
                    Bus Name
                </label>

                <input type="text"
                       name="busName"
                       id="busName"
                       maxlength="100"
                       required>

            </div>

            <div class="field">

                <label for="busType">
                    Bus Type
                </label>

                <select name="busType"
                        id="busType"
                        required>

                    <option value="">Select Bus Type</option>

                    <option value="AC Sleeper">AC Sleeper</option>
                    <option value="Non-AC Sleeper">Non-AC Sleeper</option>
                    <option value="AC Seater">AC Seater</option>
                    <option value="Non-AC Seater">Non-AC Seater</option>
                    <option value="AC Semi Sleeper">AC Semi Sleeper</option>
                    <option value="Non-AC Semi Sleeper">Non-AC Semi Sleeper</option>

                </select>

            </div>

            <div class="field" id="seatField">

                <label for="totalSeats">
                    Total Seats
                </label>

                <input type="number"
                       name="totalSeats"
                       id="totalSeats"
                       min="1"
                       max="100"
                       required>

                <p>
                    New buses are created as INACTIVE.
                    Seat layout must be configured before activation.
                </p>

            </div>

            <div class="modal-actions">

                <button type="button"
                        class="btn btn-light"
                        id="cancelButton">
                    Cancel
                </button>

                <button type="submit"
                        class="btn btn-primary"
                        id="saveButton">
                    Save Bus
                </button>

            </div>

        </form>

    </div>

</div>

<script>

const sidebar = document.getElementById("sidebar");
const menuButton = document.getElementById("menuButton");

menuButton.addEventListener("click", function () {
    sidebar.classList.toggle("open");
});

const modal = document.getElementById("busModal");
const form = document.getElementById("busForm");

const actionField = document.getElementById("formAction");
const busIdField = document.getElementById("busId");

const busNumber = document.getElementById("busNumber");
const busName = document.getElementById("busName");
const busType = document.getElementById("busType");

const totalSeats = document.getElementById("totalSeats");
const seatField = document.getElementById("seatField");

const modalTitle = document.getElementById("modalTitle");
const modalDescription =
        document.getElementById("modalDescription");

const saveButton = document.getElementById("saveButton");

function openModal() {
    modal.classList.add("show");
    busNumber.focus();
}

function closeModal() {
    modal.classList.remove("show");
}

document.getElementById("addBusButton")
        .addEventListener("click", function () {

    form.reset();

    actionField.value = "add";
    busIdField.value = "";

    seatField.style.display = "block";
    totalSeats.disabled = false;
    totalSeats.required = true;

    modalTitle.textContent = "Add New Bus";

    modalDescription.textContent =
        "New buses start as INACTIVE until their seat layout is configured.";

    saveButton.textContent = "Add Bus";

    openModal();
});

document.querySelectorAll(".edit-btn")
        .forEach(function (button) {

    button.addEventListener("click", function () {

        form.reset();

        actionField.value = "edit";

        busIdField.value = button.dataset.id;
        busNumber.value = button.dataset.number;
        busName.value = button.dataset.name;

        const type = button.dataset.type;

        if (![...busType.options].some(
                option => option.value === type)) {

            const option = document.createElement("option");
            option.value = type;
            option.textContent = type;
            busType.appendChild(option);
        }

        busType.value = type;

        seatField.style.display = "none";

        totalSeats.required = false;
        totalSeats.disabled = true;

        modalTitle.textContent = "Edit Bus Details";

        modalDescription.textContent =
            "Seat capacity and existing schedules remain unchanged.";

        saveButton.textContent = "Save Changes";

        openModal();
    });

});

document.getElementById("cancelButton")
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

document.querySelectorAll(".status-form")
        .forEach(function (statusForm) {

    statusForm.addEventListener("submit", function (event) {

        const status =
            statusForm.querySelector(
                'input[name="status"]').value;

        const message = status === "INACTIVE"
            ? "Deactivate this bus? Current or future schedules will block this action."
            : "Activate this bus? Its seat layout must already be configured.";

        if (!confirm(message)) {
            event.preventDefault();
        }

    });

});

// SEARCH AND FILTER

const searchInput = document.getElementById("searchInput");
const statusFilter = document.getElementById("statusFilter");

function filterBuses() {

    const search = searchInput.value.toLowerCase().trim();
    const status = statusFilter.value;

    let visible = 0;

    document.querySelectorAll(".bus-row")
            .forEach(function (row) {

        const matchesSearch =
            row.dataset.search.includes(search);

        const matchesStatus =
            status === "ALL"
            || row.dataset.status === status;

        const show = matchesSearch && matchesStatus;

        row.style.display = show ? "" : "none";

        if (show) visible++;
    });

    document.getElementById("emptyMessage").style.display =
        visible === 0 ? "block" : "none";
}

searchInput.addEventListener("input", filterBuses);
statusFilter.addEventListener("change", filterBuses);

</script>

</body>
</html>