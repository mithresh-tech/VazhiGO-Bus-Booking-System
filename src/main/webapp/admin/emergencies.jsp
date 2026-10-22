<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.tnbus.model.EmergencyRequest" %>

<%!
    private String escapeHtml(Object value) {
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
    List<EmergencyRequest> emergencies =
            (List<EmergencyRequest>)
                    request.getAttribute("emergencies");

    if (emergencies == null) {
        response.sendRedirect(
                request.getContextPath() + "/admin/dashboard");
        return;
    }

    String contextPath = request.getContextPath();

    String token =
            (String) request.getAttribute("adminSosToken");

    int openCount = (Integer) request.getAttribute("openCount");
    int progressCount = (Integer) request.getAttribute("progressCount");
    int resolvedCount = (Integer) request.getAttribute("resolvedCount");
%>

<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Admin SOS Dashboard | VazhiGo</title>

<style>
* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #f4f7fb;
    color: #243247;
}

.navbar {
    background: #12355b;
    color: white;
    padding: 20px 5%;
    display: flex;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 15px;
}

.navbar a {
    color: white;
    text-decoration: none;
}

.container {
    max-width: 1250px;
    margin: 35px auto;
    padding: 0 18px;
}

h1 { color: #12355b; }

.demo {
    background: #fff1d5;
    padding: 15px;
    border-radius: 9px;
    line-height: 1.6;
    margin-bottom: 20px;
}

.stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 15px;
    margin: 25px 0;
}

.stat {
    background: white;
    padding: 22px;
    border-radius: 12px;
    border: 1px solid #e5eaf0;
}

.stat strong {
    display: block;
    margin-top: 12px;
    font-size: 30px;
    color: #12355b;
}

.toolbar {
    margin-bottom: 18px;
}

select {
    padding: 10px;
    border: 1px solid #ccd5df;
    border-radius: 7px;
    font-size: 14px;
}

.table-wrap {
    overflow-x: auto;
    background: white;
    border-radius: 12px;
    border: 1px solid #e5eaf0;
}

table {
    width: 100%;
    border-collapse: collapse;
    min-width: 850px;
}

th, td {
    padding: 15px;
    text-align: left;
    border-bottom: 1px solid #e5eaf0;
    vertical-align: top;
}

th {
    background: #edf2f8;
    color: #12355b;
}

.description {
    max-width: 280px;
    overflow-wrap: anywhere;
}

.badge {
    display: inline-block;
    padding: 7px 11px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: bold;
}

.OPEN {
    background: #fde7e7;
    color: #a52d2d;
}

.IN_PROGRESS {
    background: #fff1d5;
    color: #946000;
}

.RESOLVED {
    background: #e2f6e9;
    color: #18753a;
}

form {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
}

button {
    border: 0;
    background: #12355b;
    color: white;
    padding: 11px 14px;
    border-radius: 7px;
    cursor: pointer;
}

.success {
    padding: 15px;
    background: #e2f6e9;
    color: #18753a;
    border-radius: 8px;
    margin-bottom: 20px;
}

@media(max-width: 650px) {
    .stats {
        grid-template-columns: repeat(2, 1fr);
    }
}
</style>
</head>

<body>

<header class="navbar">
    <strong>VazhiGo | Admin SOS</strong>

    <a href="<%= contextPath %>/admin/dashboard">
        Back to Dashboard
    </a>
</header>

<main class="container">

    <h1>Emergency Request Management</h1>

    <div class="demo">
        <strong>ACADEMIC DEMO</strong><br>
        Requests displayed here are database records.
        Updating a status does not dispatch emergency services,
        contact the bus operator or confirm real-world assistance.
    </div>

    <% if ("1".equals(request.getParameter("updated"))) { %>
        <div class="success">
            Request status updated successfully.
        </div>
    <% } %>

    <section class="stats">

        <div class="stat">
            Total
            <strong><%= emergencies.size() %></strong>
        </div>

        <div class="stat">
            Open
            <strong><%= openCount %></strong>
        </div>

        <div class="stat">
            In Progress
            <strong><%= progressCount %></strong>
        </div>

        <div class="stat">
            Resolved
            <strong><%= resolvedCount %></strong>
        </div>

    </section>

    <div class="toolbar">
        <label for="statusFilter">Filter by status: </label>

        <select id="statusFilter">
            <option value="ALL">All Requests</option>
            <option value="OPEN">Open</option>
            <option value="IN_PROGRESS">In Progress</option>
            <option value="RESOLVED">Resolved</option>
        </select>
    </div>

    <div class="table-wrap">

        <table id="emergencyTable">

            <thead>
                <tr>
                    <th>Reference</th>
                    <th>Booking</th>
                    <th>Type</th>
                    <th>Description</th>
                    <th>Created</th>
                    <th>Status</th>
                    <th>Update Status</th>
                </tr>
            </thead>

            <tbody>

            <% if (emergencies.isEmpty()) { %>

                <tr>
                    <td colspan="7">
                        No emergency requests recorded.
                    </td>
                </tr>

            <% } else {

                for (EmergencyRequest item : emergencies) {

            %>

                <tr data-status="<%= escapeHtml(item.getEmergencyStatus()) %>">

                    <td>
                        <strong>SOS-<%= item.getEmergencyId() %></strong>
                    </td>

                    <td>#<%= item.getBookingId() %></td>

                    <td><%= escapeHtml(item.getEmergencyType()) %></td>

                    <td class="description">
                        <%= escapeHtml(item.getDescription()) %>
                    </td>

                    <td><%= escapeHtml(item.getCreatedAt()) %></td>

                    <td>
                        <span class="badge <%= escapeHtml(item.getEmergencyStatus()) %>">
                            <%= escapeHtml(item.getEmergencyStatus()) %>
                        </span>
                    </td>

                    <td>
                        <form method="post"
                              action="<%= contextPath %>/admin/emergencies">

                            <input type="hidden"
                                   name="csrfToken"
                                   value="<%= escapeHtml(token) %>">

                            <input type="hidden"
                                   name="emergencyId"
                                   value="<%= item.getEmergencyId() %>">

                            <select name="status"
                                    aria-label="New status for SOS-<%= item.getEmergencyId() %>">

                                <option value="OPEN"
                                    <%= "OPEN".equals(item.getEmergencyStatus()) ? "selected" : "" %>>
                                    Open
                                </option>

                                <option value="IN_PROGRESS"
                                    <%= "IN_PROGRESS".equals(item.getEmergencyStatus()) ? "selected" : "" %>>
                                    In Progress
                                </option>

                                <option value="RESOLVED"
                                    <%= "RESOLVED".equals(item.getEmergencyStatus()) ? "selected" : "" %>>
                                    Resolved
                                </option>

                            </select>

                            <button type="submit">
                                Update
                            </button>

                        </form>
                    </td>

                </tr>

            <%  }
               } %>

            </tbody>
        </table>

    </div>

</main>

<script>
const filter = document.getElementById("statusFilter");

filter.addEventListener("change", function () {

    const selected = this.value;

    document.querySelectorAll(
        "#emergencyTable tbody tr[data-status]"
    ).forEach(function (row) {

        row.hidden = selected !== "ALL"
                && row.dataset.status !== selected;
    });
});
</script>

</body>
</html>