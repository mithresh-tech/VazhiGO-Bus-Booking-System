<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="com.tnbus.model.City" %>
<%@ page import="com.tnbus.service.CityService" %>

<%!
    private String escapeHtml(String value) {

        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    String ctx = request.getContextPath();

    boolean loggedIn =
            session.getAttribute("loggedInUser") != null;
    
    boolean adminLoggedIn =
            session.getAttribute("loggedInAdmin") != null;

    CityService cityService = new CityService();

    List<City> cities = cityService.getAllCities();

    LocalDate today = LocalDate.now();

    LocalDate maximumDate = today.plusYears(1);

    String searchAction = loggedIn
            ? ctx + "/searchBus"
            : ctx + "/login.jsp";
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>VazhiGo | Your Journey, Our Priority</title>

<style>

:root {
    --navy: #102A43;
    --navy-dark: #081D32;
    --coral: #FF6B57;
    --teal: #14B8A6;
    --background: #F7F9FC;
    --text: #243447;
    --muted: #65758B;
    --white: #FFFFFF;
}

* {
    box-sizing: border-box;
}

html {
    scroll-behavior: smooth;
}

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: var(--background);
    color: var(--text);
}

a {
    text-decoration: none;
}

button,
input,
select {
    font: inherit;
}

.container {
    width: 1160px;
    max-width: 92%;
    margin: auto;
}

/* ==========================================
   NAVIGATION
========================================== */

.navbar {
    background: var(--white);
    border-bottom: 1px solid #E8EDF3;
}

.nav-inner {
    min-height: 78px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
}

.logo {
    font-size: 27px;
    font-weight: 900;
    color: var(--navy);
    letter-spacing: -1px;
}

.logo span {
    color: var(--coral);
}

.nav-links {
    display: flex;
    align-items: center;
    gap: 26px;
    flex-wrap: wrap;
}

.nav-links a {
    color: var(--navy);
    font-size: 14px;
    font-weight: 600;
}

.nav-links a:hover {
    color: var(--coral);
}

.nav-cta {
    background: var(--coral);
    color: white !important;
    padding: 12px 20px;
    border-radius: 9px;
}

/* ==========================================
   HERO
========================================== */

.hero {
    background:
        radial-gradient(
            circle at 85% 15%,
            rgba(20,184,166,0.22),
            transparent 35%
        ),
        linear-gradient(
            120deg,
            #081D32,
            #123B60
        );

    color: white;
    padding: 82px 0 120px;
    position: relative;
    overflow: hidden;
}

.hero-grid {
    display: grid;
    grid-template-columns: 1.15fr 0.85fr;
    align-items: center;
    gap: 35px;
}

.eyebrow {
    display: inline-block;
    color: #74E7D7;
    font-size: 12px;
    font-weight: bold;
    letter-spacing: 2px;
    text-transform: uppercase;
    margin-bottom: 18px;
}

.hero h1 {
    font-size: clamp(37px, 5vw, 61px);
    line-height: 1.12;
    letter-spacing: -2px;
    margin: 0 0 22px;
}

.hero h1 span {
    color: #FF9A83;
}

.hero p {
    max-width: 540px;
    color: #C5D6E7;
    line-height: 1.8;
    font-size: 16px;
}

.hero-actions {
    display: flex;
    gap: 14px;
    flex-wrap: wrap;
    margin-top: 30px;
}

.btn {
    display: inline-flex;
    justify-content: center;
    align-items: center;
    border: none;
    padding: 14px 24px;
    border-radius: 9px;
    font-size: 14px;
    font-weight: bold;
    cursor: pointer;
}

.btn-primary {
    background: var(--coral);
    color: white;
}

.btn-outline {
    color: white;
    border: 1px solid #7892AC;
}

.hero-visual {
    min-height: 330px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.bus-illustration {
    position: relative;
    width: 100%;
    max-width: 450px;
    padding: 38px 25px;
    background: rgba(255,255,255,0.08);
    border: 1px solid rgba(255,255,255,0.15);
    border-radius: 25px;
    text-align: center;
}

.bus-icon {
    font-size: 125px;
    line-height: 1.3;
}

.bus-illustration h3 {
    font-size: 22px;
    margin: 12px 0 8px;
}

.bus-illustration p {
    font-size: 13px;
    margin: 0;
}

/* ==========================================
   SEARCH PANEL
========================================== */

.search-wrapper {
    position: relative;
    margin-top: -65px;
    z-index: 2;
}

.search-panel {
    background: white;
    padding: 28px;
    border-radius: 17px;
    box-shadow: 0 15px 45px rgba(16,42,67,0.13);
}

.search-panel h2 {
    margin: 0 0 20px;
    color: var(--navy);
    font-size: 21px;
}

.search-fields {
    display: grid;
    grid-template-columns: 1fr 44px 1fr 1fr auto;
    align-items: end;
    gap: 13px;
}

.form-group {
    min-width: 0;
}

.form-group label {
    display: block;
    font-size: 12px;
    font-weight: bold;
    color: var(--muted);
    margin-bottom: 9px;
}

.form-control {
    width: 100%;
    height: 49px;
    padding: 0 12px;
    border: 1px solid #D8E1EB;
    border-radius: 8px;
    background: white;
    color: var(--navy);
    font-size: 14px;
}

.form-control:focus {
    outline: none;
    border-color: var(--teal);
}

.swap-btn {
    height: 49px;
    width: 44px;
    border: 1px solid #D8E1EB;
    background: #F3F8FC;
    border-radius: 8px;
    cursor: pointer;
    color: var(--navy);
    font-size: 22px;
}

.search-btn {
    height: 49px;
    white-space: nowrap;
}

.validation {
    color: #C0392B;
    font-size: 13px;
    margin-top: 12px;
}

/* ==========================================
   COMMON SECTIONS
========================================== */

.section {
    padding: 85px 0;
}

.section-heading {
    text-align: center;
    margin-bottom: 36px;
}

.section-heading h2 {
    color: var(--navy);
    font-size: 32px;
    margin: 0 0 12px;
}

.section-heading p {
    color: var(--muted);
    font-size: 14px;
    line-height: 1.7;
}

.grid-3 {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 22px;
}

.info-card {
    background: white;
    padding: 27px;
    border: 1px solid #E8EDF3;
    border-radius: 15px;
    transition: transform 0.2s ease;
}

.info-card:hover {
    transform: translateY(-5px);
}

.info-icon {
    font-size: 36px;
    margin-bottom: 16px;
}

.info-card h3 {
    color: var(--navy);
    margin: 0 0 10px;
}

.info-card p {
    color: var(--muted);
    font-size: 13px;
    line-height: 1.8;
    margin: 0;
}

/* ==========================================
   ROUTES
========================================== */

.routes {
    background: #EDF3F8;
}

.route-card {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    padding: 23px;
    background: white;
    border-radius: 13px;
    color: var(--navy);
    font-weight: bold;
}

.route-arrow {
    color: var(--coral);
    font-size: 22px;
}

/* ==========================================
   CTA
========================================== */

.cta-section {
    background: var(--navy);
    color: white;
    text-align: center;
    padding: 65px 20px;
}

.cta-section h2 {
    font-size: 32px;
    margin: 0 0 13px;
}

.cta-section p {
    color: #C5D6E7;
    margin-bottom: 25px;
}

/* ==========================================
   FOOTER
========================================== */

.footer {
    background: var(--navy-dark);
    color: #AFC1D3;
    padding: 35px 0;
}

.footer-inner {
    display: flex;
    justify-content: space-between;
    gap: 20px;
    flex-wrap: wrap;
    font-size: 13px;
}

.footer strong {
    color: white;
    font-size: 19px;
}

/* ==========================================
   RESPONSIVE
========================================== */

@media (max-width: 950px) {

    .hero-grid {
        grid-template-columns: 1fr;
    }

    .hero-visual {
        min-height: 220px;
    }

    .search-fields {
        grid-template-columns: 1fr 44px 1fr;
    }

    .search-btn {
        grid-column: 1 / -1;
    }

    .grid-3 {
        grid-template-columns: repeat(2, 1fr);
    }
}

@media (max-width: 600px) {

    .nav-inner {
        padding: 18px 0;
        flex-direction: column;
    }

    .nav-links {
        justify-content: center;
        gap: 15px;
    }

    .hero {
        padding: 55px 0 105px;
    }

    .hero h1 {
        letter-spacing: -1px;
    }

    .bus-icon {
        font-size: 85px;
    }

    .search-fields {
        grid-template-columns: 1fr;
    }

    .swap-btn {
        width: 100%;
    }

    .search-btn {
        grid-column: auto;
    }

    .grid-3 {
        grid-template-columns: 1fr;
    }

    .section {
        padding: 55px 0;
    }

    .section-heading h2 {
        font-size: 27px;
    }
}

</style>
<link rel="stylesheet"
      href="<%= ctx %>/assets/css/vazhigo-intro.css">
</head>

<body>

<!-- VAZHIGO CINEMATIC INTRO -->

<div class="vg-intro" id="vazhigoIntro" role="region"
     aria-label="VazhiGo welcome introduction">

    <button class="vg-skip"
            type="button"
            id="skipIntro">
        Skip Intro &rarr;
    </button>

    <div class="vg-intro-content">

        <div class="vg-intro-kicker">
            THE JOURNEY BEGINS
        </div>

        <img class="vg-intro-bus"
     src="<%= ctx %>/assets/images/buses/bus-exterior.jpg"
     alt="VazhiGO Bus">

        <h1 class="vg-intro-logo">
            Vazhi<span>Go.</span>
        </h1>

        <p class="vg-intro-tagline">
            YOUR JOURNEY, OUR PRIORITY
        </p>

        <div class="vg-intro-road"></div>

    </div>

</div>

<!-- NAVIGATION -->

<header class="navbar">

    <div class="container nav-inner">

        <a href="<%= ctx %>/index.jsp"
           class="logo">
            Vazhi<span>Go.</span>
        </a>

        <nav class="nav-links" aria-label="Main navigation">

    <a href="<%= ctx %>/index.jsp">Home</a>

    <a href="<%= ctx %>/search.jsp">Book Tickets</a>

    <% if (adminLoggedIn) { %>

        <a href="<%= ctx %>/admin/dashboard"
           class="nav-cta">
            Admin Dashboard
        </a>

    <% } else if (loggedIn) { %>

        <a href="<%= ctx %>/myBookings">
            My Bookings
        </a>

    <% } else { %>

        <a href="<%= ctx %>/login.jsp">
            Login
        </a>

        <a href="<%= ctx %>/register.jsp"
           class="nav-cta">
            Get Started
        </a>

    <% } %>

</nav>

    </div>

</header>

<!-- HERO -->

<section class="hero">

    <div class="container hero-grid">

        <div>

            <span class="eyebrow">
                Explore Tamil Nadu With Confidence
            </span>

            <h1>
                Every Journey<br>
                Begins With <span>VazhiGo.</span>
            </h1>

            <p>
                Discover comfortable journeys across Tamil Nadu.
                Find your perfect bus, choose your preferred seat
                and enjoy a simpler travel booking experience.
            </p>

            <div class="hero-actions">

                <a href="#find-buses"
                   class="btn btn-primary">
                    Explore Buses &rarr;
                </a>

                <% if (!loggedIn) { %>

                    <a href="<%= ctx %>/register.jsp"
                       class="btn btn-outline">
                        Create Account
                    </a>

                <% } %>

            </div>

        </div>

        <div class="hero-visual">

            <div class="bus-illustration">

                <div class="bus-icon">
                    &#128652;
                </div>

                <h3>Travel Beyond Ordinary</h3>

                <p>
                    Comfortable journeys. Memorable destinations.
                </p>

            </div>

        </div>

    </div>

</section>

<!-- SEARCH WIDGET -->

<div class="container search-wrapper"
     id="find-buses">

    <div class="search-panel">

        <h2>Find Your Next Journey</h2>

        <form id="homeSearchForm"
              action="<%= searchAction %>"
              method="<%= loggedIn ? "post" : "get" %>">

            <div class="search-fields">

                <div class="form-group">

                    <label for="sourceCityId">From</label>

                    <select class="form-control"
                            id="sourceCityId"
                            name="sourceCityId"
                            required>

                        <option value="">Departure City</option>

                        <% for (City city : cities) { %>

                            <option value="<%= city.getCityId() %>">
                                <%= escapeHtml(city.getCityName()) %>
                            </option>

                        <% } %>

                    </select>

                </div>

                <button class="swap-btn"
                        type="button"
                        id="swapCities"
                        aria-label="Swap cities">
                    &#8644;
                </button>

                <div class="form-group">

                    <label for="destinationCityId">To</label>

                    <select class="form-control"
                            id="destinationCityId"
                            name="destinationCityId"
                            required>

                        <option value="">Arrival City</option>

                        <% for (City city : cities) { %>

                            <option value="<%= city.getCityId() %>">
                                <%= escapeHtml(city.getCityName()) %>
                            </option>

                        <% } %>

                    </select>

                </div>

                <div class="form-group">

                    <label for="travelDate">Journey Date</label>

                    <input class="form-control"
                           type="date"
                           id="travelDate"
                           name="travelDate"
                           min="<%= today %>"
                           max="<%= maximumDate %>"
                           required>

                </div>

                <button class="btn btn-primary search-btn"
                        type="submit">
                    Search Buses &rarr;
                </button>

            </div>

            <div class="validation"
                 id="searchValidation"
                 role="alert"
                 hidden="hidden"></div>

            <% if (!loggedIn) { %>

                <p style="font-size:12px;color:#65758B;margin-top:15px;">
                    Login is required to view available buses
                    and complete your booking.
                </p>

            <% } %>

        </form>

    </div>

</div>

<!-- BUS CATEGORIES -->

<section class="section">

    <div class="container">

        <div class="section-heading">

            <h2>Choose Your Travel Experience</h2>

            <p>
                Different journeys deserve different levels of comfort.
            </p>

        </div>

        <div class="grid-3">

            <article class="info-card">

                <div class="info-icon">&#128652;</div>

                <h3>AC Sleeper</h3>

                <p>
                    Relax in comfortable Upper and Lower berths
                    with Single and Double Sleeper options.
                </p>

            </article>

            <article class="info-card">

                <div class="info-icon">&#128186;</div>

                <h3>AC Seater</h3>

                <p>
                    Enjoy comfortable seating with a convenient
                    2+2 arrangement for your journey.
                </p>

            </article>

            <article class="info-card">

                <div class="info-icon">&#10024;</div>

                <h3>Seater + Sleeper</h3>

                <p>
                    A flexible combination of seating and
                    sleeping arrangements for different preferences.
                </p>

            </article>

        </div>

    </div>

</section>

<!-- POPULAR ROUTES -->

<section class="section routes">

    <div class="container">

        <div class="section-heading">

            <h2>Explore Popular Routes</h2>

            <p>
                Discover some of Tamil Nadu's favourite destinations.
            </p>

        </div>

        <div class="grid-3">

            <div class="route-card">
                Chennai → Coimbatore
                <span class="route-arrow">&rarr;</span>
            </div>

            <div class="route-card">
                Chennai → Madurai
                <span class="route-arrow">&rarr;</span>
            </div>

            <div class="route-card">
                Chennai → Trichy
                <span class="route-arrow">&rarr;</span>
            </div>

            <div class="route-card">
                Chennai → Salem
                <span class="route-arrow">&rarr;</span>
            </div>

            <div class="route-card">
                Chennai → Tirunelveli
                <span class="route-arrow">&rarr;</span>
            </div>

            <div class="route-card">
                Coimbatore → Madurai
                <span class="route-arrow">&rarr;</span>
            </div>

        </div>

    </div>

</section>

<!-- WHY CHOOSE US -->

<section class="section">

    <div class="container">

        <div class="section-heading">

            <h2>Why Travel With VazhiGo?</h2>

            <p>
                Designed to make planning your journey simpler.
            </p>

        </div>

        <div class="grid-3">

            <article class="info-card">

                <div class="info-icon">&#128269;</div>

                <h3>Easy Bus Discovery</h3>

                <p>
                    Compare available bus schedules,
                    departure timings and fares.
                </p>

            </article>

            <article class="info-card">

                <div class="info-icon">&#128186;</div>

                <h3>Choose Your Comfort</h3>

                <p>
                    Select your preferred available seats
                    through our visual booking interface.
                </p>

            </article>

            <article class="info-card">

                <div class="info-icon">&#127915;</div>

                <h3>Digital Booking</h3>

                <p>
                    Manage reservations and access
                    your booking information online.
                </p>

            </article>

        </div>

    </div>

</section>

<!-- CALL TO ACTION -->

<section class="cta-section">

    <h2>Ready for Your Next Journey?</h2>

    <p>
        Discover your next destination with VazhiGo.
    </p>

    <a href="#find-buses"
       class="btn btn-primary">
        Find Your Bus &rarr;
    </a>

</section>

<!-- FOOTER -->

<footer class="footer">

    <div class="container footer-inner">

        <div>
            <strong>VazhiGo.</strong>
            <p>Your Journey, Our Priority.</p>
        </div>

        <div>
            &copy; 2026 VazhiGo.
            Academic Project Demonstration.
        </div>

    </div>

</footer>

<script>

(function () {

    const source =
        document.getElementById("sourceCityId");

    const destination =
        document.getElementById("destinationCityId");

    const swap =
        document.getElementById("swapCities");

    const form =
        document.getElementById("homeSearchForm");

    const validation =
        document.getElementById("searchValidation");

    swap.addEventListener("click", function () {

        const oldSource = source.value;

        source.value = destination.value;

        destination.value = oldSource;
    });

    form.addEventListener("submit", function (event) {

        if (source.value === destination.value) {

            event.preventDefault();

            validation.textContent =
                "Source and destination cannot be the same.";

            validation.hidden = false;

        } else {

            validation.hidden = true;
        }
    });

})();

</script>

<script src="<%= ctx %>/assets/js/vazhigo-intro.js"></script>
</body>
</html>