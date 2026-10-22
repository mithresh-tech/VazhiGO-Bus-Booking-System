<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="com.tnbus.model.User" %>

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
    User user = (User) session.getAttribute("loggedInUser");

    if (user == null) {
        response.sendRedirect(
                request.getContextPath() + "/login.jsp");
        return;
    }

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Home | VazhiGo</title>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #f3f6fb;
    color: #243247;
}

.navbar {
    background: #12355b;
    color: white;
    padding: 18px 6%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 16px;
}

.logo {
    font-size: 27px;
    font-weight: 800;
    text-decoration: none;
    color: white;
}

.logo span {
    color: #ffcb65;
}

.nav-links {
    display: flex;
    gap: 24px;
    align-items: center;
    flex-wrap: wrap;
}

.nav-links a {
    color: white;
    text-decoration: none;
    font-size: 14px;
}

.nav-links a:hover {
    color: #ffcb65;
}

.container {
    max-width: 1150px;
    margin: 35px auto;
    padding: 0 20px;
}

.hero {
    background: linear-gradient(120deg, #12355b, #245c88);
    border-radius: 18px;
    padding: 45px;
    color: white;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 25px;
}

.hero-content {
    max-width: 650px;
    min-width: 0;
}

.eyebrow {
    display: inline-block;
    background: rgba(255,255,255,0.14);
    border: 1px solid rgba(255,255,255,0.25);
    border-radius: 20px;
    padding: 8px 14px;
    font-size: 12px;
}

.hero h1 {
    font-size: 34px;
    margin: 22px 0 12px;
    line-height: 1.3;
}

.hero h1 span {
    color: #ffcb65;
}

.hero p {
    color: #dce8f4;
    line-height: 1.7;
}

.hero-visual {
    font-size: 90px;
    line-height: 1;
    flex-shrink: 0;
}

.hero-btn {
    display: inline-block;
    background: #ffcb65;
    color: #12355b;
    text-decoration: none;
    padding: 14px 23px;
    border-radius: 8px;
    font-weight: bold;
    margin-top: 18px;
}

.section-heading {
    margin: 35px 0 20px;
}

.section-heading h2 {
    color: #12355b;
    margin-bottom: 8px;
}

.section-heading p {
    color: #6b7b8f;
    font-size: 14px;
}

.cards {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 22px;
}

.card {
    background: white;
    padding: 30px;
    border: 1px solid #e3eaf2;
    border-radius: 14px;
}

.card-icon {
    display: inline-flex;
    justify-content: center;
    align-items: center;
    width: 55px;
    height: 55px;
    border-radius: 12px;
    background: #e9f1f9;
    font-size: 27px;
}

.card h3 {
    color: #12355b;
    margin-top: 22px;
}

.card p {
    color: #6b7b8f;
    font-size: 14px;
    line-height: 1.7;
    min-height: 48px;
}

.btn {
    display: inline-block;
    background: #12355b;
    color: white;
    padding: 13px 20px;
    border-radius: 8px;
    text-decoration: none;
    font-size: 13px;
    font-weight: bold;
}

.profile-strip {
    background: white;
    border: 1px solid #e3eaf2;
    border-radius: 12px;
    padding: 20px 25px;
    margin-top: 25px;
    display: flex;
    align-items: center;
    gap: 15px;
}

.avatar {
    width: 45px;
    height: 45px;
    border-radius: 50%;
    background: #e9f1f9;
    color: #12355b;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 21px;
    font-weight: bold;
    flex-shrink: 0;
}

.profile-strip strong {
    color: #12355b;
}

.profile-strip p {
    color: #6b7b8f;
    margin: 6px 0 0;
    font-size: 13px;
    overflow-wrap: anywhere;
}

.footer {
    text-align: center;
    padding: 35px 15px;
    font-size: 13px;
    color: #718095;
}

@media(max-width: 700px) {

    .hero {
        padding: 28px;
    }

    .hero h1 {
        font-size: 26px;
    }

    .hero-visual {
        display: none;
    }

    .cards {
        grid-template-columns: 1fr;
    }

    .nav-links {
        gap: 14px;
    }
}

</style>
</head>

<body>

<header class="navbar">

    <a class="logo" href="<%= ctx %>/home.jsp">
        Vazhi<span>Go</span>
    </a>

    <nav class="nav-links">
        <a href="<%= ctx %>/home.jsp">Home</a>
        <a href="<%= ctx %>/search.jsp">Search Buses</a>
        <a href="<%= ctx %>/myBookings">My Bookings</a>
        <a href="<%= ctx %>/logout">Logout</a>
    </nav>

</header>

<main class="container">

    <section class="hero">

        <div class="hero-content">

            <span class="eyebrow">
                YOUR JOURNEY, OUR PRIORITY
            </span>

            <h1>
                Welcome back,<br>
                <span><%= escapeHtml(user.getFullName()) %>!</span>
            </h1>

            <p>
                Your next journey starts here.
                Discover buses across Tamil Nadu,
                choose your favourite seat and
                manage your reservations effortlessly.
            </p>

            <a class="hero-btn" href="<%= ctx %>/search.jsp">
                Explore Buses &rarr;
            </a>

        </div>

        <div class="hero-visual" aria-hidden="true">
            &#128653;
        </div>

    </section>

    <div class="section-heading">
        <h2>What would you like to do?</h2>
        <p>Everything you need for your next trip.</p>
    </div>

    <section class="cards">

        <article class="card">

            <div class="card-icon" aria-hidden="true">
                &#128269;
            </div>

            <h3>Search &amp; Book Buses</h3>

            <p>
                Find available buses, compare fares,
                explore seat layouts and reserve your journey.
            </p>

            <a class="btn" href="<%= ctx %>/search.jsp">
                Search Buses &rarr;
            </a>

        </article>

        <article class="card">

            <div class="card-icon" aria-hidden="true">
                &#127915;
            </div>

            <h3>My Bookings</h3>

            <p>
                Check booking status, complete pending payments,
                view e-tickets and manage cancellations.
            </p>

            <a class="btn" href="<%= ctx %>/myBookings">
                View My Bookings &rarr;
            </a>

        </article>

    </section>

    <section class="profile-strip">

        <div class="avatar" aria-hidden="true">
            &#128100;
        </div>

        <div>
            <strong>Logged in as <%= escapeHtml(user.getFullName()) %></strong>
            <p><%= escapeHtml(user.getEmail()) %></p>
        </div>

    </section>

</main>

<footer class="footer">
    VazhiGo &copy; 2026 | Your Journey, Our Priority
</footer>

</body>
</html>