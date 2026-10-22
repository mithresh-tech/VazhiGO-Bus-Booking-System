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
if (session.getAttribute("loggedInUser") == null) {

    response.sendRedirect(
        request.getContextPath() + "/login.jsp"
    );

    return;
}

String ctx = request.getContextPath();

CityService cityService = new CityService();

List<City> cities = cityService.getAllCities();

String errorMessage =
        (String) request.getAttribute("errorMessage");

LocalDate today = LocalDate.now();

LocalDate maximumDate = today.plusYears(1);
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Search Buses | VazhiGo</title>

<link rel="stylesheet"
      href="<%= ctx %>/assets/css/style.css">

<style>

/* =========================================
   VAZHIGO SEARCH PAGE
========================================= */

.vg-navbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
    padding: 18px 7%;
    background: #ffffff;
    border-bottom: 1px solid #e7edf4;
}

.vg-logo {
    font-size: 27px;
    font-weight: 900;
    letter-spacing: -1px;
    color: #102a43;
    text-decoration: none;
    animation: vgLogoEnter .7s ease both;
}

.vg-logo span {
    color: #ff6b57;
}

.vg-nav-links {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 25px;
}

.vg-nav-links a {
    color: #102a43;
    font-size: 14px;
    font-weight: 700;
    text-decoration: none;
}

.vg-nav-links a:hover,
.vg-nav-links a.active {
    color: #ff6b57;
}

/* PAGE BACKGROUND */

.vg-search-page {
    min-height: calc(100vh - 75px);
    position: relative;
    overflow: hidden;
    padding: 75px 20px 110px;

    background:
        radial-gradient(
            circle at 80% 20%,
            rgba(20,184,166,.22),
            transparent 35%
        ),
        linear-gradient(
            130deg,
            #071b30,
            #123b60 60%,
            #081d32
        );

    color: white;
}

.vg-search-page::before {
    content: "";
    position: absolute;
    width: 420px;
    height: 420px;
    border-radius: 50%;
    background: rgba(255,255,255,.035);
    top: -180px;
    right: -110px;
    pointer-events: none;
}

.vg-search-page::after {
    content: "";
    position: absolute;
    width: 340px;
    height: 340px;
    border-radius: 50%;
    border: 1px solid rgba(255,255,255,.08);
    bottom: -160px;
    left: -100px;
    pointer-events: none;
}

/* HEADING */

.vg-search-heading {
    position: relative;
    z-index: 2;
    max-width: 850px;
    margin: 0 auto 38px;
    text-align: center;
    animation: vgFadeUp .8s ease both;
}

.vg-eyebrow {
    display: inline-block;
    margin-bottom: 15px;
    color: #6fe0d0;
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 3px;
}

.vg-search-heading h1 {
    margin: 0 0 17px;
    font-size: clamp(35px, 5vw, 56px);
    line-height: 1.15;
    letter-spacing: -2px;
    color: white;
}

.vg-search-heading h1 span {
    color: #ff9b86;
}

.vg-search-heading p {
    color: #c6d7e6;
    font-size: 16px;
    line-height: 1.8;
}

/* FLOATING ELEMENTS */

.vg-floating {
    position: absolute;
    color: rgba(255,255,255,.12);
    font-size: 40px;
    pointer-events: none;
    animation: vgFloating 5s ease-in-out infinite;
}

.vg-floating.one {
    top: 120px;
    left: 9%;
}

.vg-floating.two {
    top: 200px;
    right: 8%;
    animation-delay: 1.5s;
}

/* SEARCH PANEL */

.vg-search-panel {
    position: relative;
    z-index: 2;
    width: min(1050px, 100%);
    margin: auto;
    padding: 35px;
    border-radius: 22px;
    background: rgba(255,255,255,.97);
    color: #102a43;
    border: 1px solid rgba(255,255,255,.6);
    box-shadow: 0 30px 65px rgba(0,0,0,.25);
    animation: vgPanelEnter .9s ease .2s both;
}

.vg-panel-heading {
    margin-bottom: 27px;
}

.vg-panel-heading h2 {
    margin: 0 0 8px;
    color: #102a43;
    font-size: 23px;
}

.vg-panel-heading p {
    margin: 0;
    color: #718096;
    font-size: 13px;
}

/* FORM */

.vg-search-fields {
    display: grid;
    grid-template-columns: 1fr 50px 1fr 1fr;
    gap: 16px;
    align-items: end;
}

.vg-form-group {
    min-width: 0;
}

.vg-form-group label {
    display: block;
    margin-bottom: 10px;
    color: #52677c;
    font-size: 12px;
    font-weight: 800;
}

.vg-form-control {
    width: 100%;
    height: 54px;
    padding: 0 14px;
    border: 1px solid #d9e3ec;
    border-radius: 11px;
    background: #f8fafc;
    color: #102a43;
    font-size: 14px;
    outline: none;
    transition: border-color .2s, box-shadow .2s;
}

.vg-form-control:focus {
    border-color: #14b8a6;
    box-shadow: 0 0 0 4px rgba(20,184,166,.12);
}

/* SWAP BUTTON */

.vg-swap {
    height: 54px;
    width: 50px;
    border-radius: 50%;
    border: 1px solid #d9e3ec;
    background: #edf5fa;
    color: #102a43;
    font-size: 25px;
    cursor: pointer;
    transition: transform .4s, background .2s;
}

.vg-swap:hover {
    background: #dceff0;
}

.vg-swap.rotating {
    transform: rotate(180deg);
}

/* SUBMIT BUTTON */

.vg-search-submit {
    width: 100%;
    margin-top: 25px;
    height: 55px;
    border: none;
    border-radius: 11px;
    background: linear-gradient(
        100deg,
        #ff6b57,
        #ff8d64
    );
    color: white;
    font-size: 15px;
    font-weight: 800;
    cursor: pointer;
    transition: transform .2s, box-shadow .2s;
}

.vg-search-submit:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 24px rgba(255,107,87,.3);
}

.vg-search-submit:disabled {
    opacity: .7;
    cursor: wait;
}

/* VALIDATION */

.vg-error {
    margin-top: 15px;
    padding: 12px 15px;
    border-radius: 8px;
    background: #fff0ed;
    color: #b83a29;
    font-size: 13px;
}

.vg-error[hidden] {
    display: none !important;
}

/* BENEFITS */

.vg-search-benefits {
    position: relative;
    z-index: 2;
    display: flex;
    justify-content: center;
    gap: 30px;
    flex-wrap: wrap;
    margin-top: 38px;
    color: #c7d8e7;
    font-size: 13px;
}

/* ANIMATIONS */

@keyframes vgLogoEnter {
    from {
        opacity: 0;
        transform: translateX(-20px);
    }

    to {
        opacity: 1;
        transform: translateX(0);
    }
}

@keyframes vgFadeUp {
    from {
        opacity: 0;
        transform: translateY(25px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes vgPanelEnter {
    from {
        opacity: 0;
        transform: translateY(40px) scale(.97);
    }

    to {
        opacity: 1;
        transform: translateY(0) scale(1);
    }
}

@keyframes vgFloating {
    0%, 100% {
        transform: translateY(0);
    }

    50% {
        transform: translateY(-18px);
    }
}

/* RESPONSIVE */

@media (max-width: 850px) {

    .vg-search-fields {
        grid-template-columns: 1fr 50px 1fr;
    }

    .vg-date-group {
        grid-column: 1 / -1;
    }
}

@media (max-width: 600px) {

    .vg-navbar {
        flex-direction: column;
        padding: 18px;
    }

    .vg-nav-links {
        justify-content: center;
        gap: 15px;
    }

    .vg-search-page {
        padding: 55px 15px 80px;
    }

    .vg-search-panel {
        padding: 23px 17px;
    }

    .vg-search-fields {
        grid-template-columns: 1fr;
    }

    .vg-swap {
        margin: auto;
    }

    .vg-date-group {
        grid-column: auto;
    }

    .vg-search-heading h1 {
        letter-spacing: -1px;
    }

    .vg-floating {
        display: none;
    }
}

@media (prefers-reduced-motion: reduce) {

    .vg-logo,
    .vg-search-heading,
    .vg-search-panel,
    .vg-floating {
        animation: none !important;
    }

    .vg-swap,
    .vg-search-submit {
        transition: none;
    }
}

</style>

</head>

<body>

<!-- NAVIGATION -->

<header class="vg-navbar">

    <a href="<%= ctx %>/home.jsp"
       class="vg-logo">

        Vazhi<span>Go.</span>

    </a>

    <nav class="vg-nav-links"
         aria-label="Main navigation">

        <a href="<%= ctx %>/home.jsp">
            Home
        </a>

        <a href="<%= ctx %>/myBookings">
            My Bookings
        </a>

        <a href="<%= ctx %>/search.jsp"
           class="active"
           aria-current="page">

            Search Buses

        </a>

    </nav>

</header>

<!-- SEARCH PAGE -->

<main class="vg-search-page">

    <div class="vg-floating one" aria-hidden="true">
        ✦
    </div>

    <div class="vg-floating two" aria-hidden="true">
        ✧
    </div>

    <div class="vg-search-heading">

        <span class="vg-eyebrow">
            EXPLORE • DISCOVER • TRAVEL
        </span>

        <h1>
            Where will your
            <span>next journey</span>
            take you?
        </h1>

        <p>
            Explore comfortable bus journeys across Tamil Nadu.
            Find your route, choose your travel date
            and discover the perfect ride with VazhiGo.
        </p>

    </div>

    <section class="vg-search-panel"
             aria-label="Search available buses">

        <div class="vg-panel-heading">

            <h2>Find Your Perfect Journey</h2>

            <p>
                Select your departure, destination and travel date.
            </p>

        </div>

        <form action="<%= ctx %>/searchBus"
              method="post"
              id="busSearchForm">

            <div class="vg-search-fields">

                <!-- SOURCE CITY -->

                <div class="vg-form-group">

                    <label for="sourceCityId">
                        DEPARTURE CITY
                    </label>

                    <select class="vg-form-control"
                            name="sourceCityId"
                            id="sourceCityId"
                            required="required">

                        <option value="">
                            Select Source City
                        </option>

                        <% for (City city : cities) { %>

                            <option value="<%= city.getCityId() %>">
                                <%= escapeHtml(city.getCityName()) %>
                            </option>

                        <% } %>

                    </select>

                </div>

                <!-- SWAP -->

                <button class="vg-swap"
                        type="button"
                        id="swapCities"
                        aria-label="Swap source and destination">

                    &#8644;

                </button>

                <!-- DESTINATION CITY -->

                <div class="vg-form-group">

                    <label for="destinationCityId">
                        DESTINATION CITY
                    </label>

                    <select class="vg-form-control"
                            name="destinationCityId"
                            id="destinationCityId"
                            required="required">

                        <option value="">
                            Select Destination City
                        </option>

                        <% for (City city : cities) { %>

                            <option value="<%= city.getCityId() %>">
                                <%= escapeHtml(city.getCityName()) %>
                            </option>

                        <% } %>

                    </select>

                </div>

                <!-- JOURNEY DATE -->

                <div class="vg-form-group vg-date-group">

                    <label for="travelDate">
                        JOURNEY DATE
                    </label>

                    <input class="vg-form-control"
                           type="date"
                           name="travelDate"
                           id="travelDate"
                           min="<%= today %>"
                           max="<%= maximumDate %>"
                           required="required">

                </div>

            </div>

            <% if (errorMessage != null && !errorMessage.isBlank()) { %>

                <div class="vg-error" role="alert">
                    <%= escapeHtml(errorMessage) %>
                </div>

            <% } %>

            <div id="searchValidation"
                 class="vg-error"
                 role="alert"
                 hidden="hidden"></div>

            <button class="vg-search-submit"
                    type="submit"
                    id="searchSubmit">

                Search Available Buses &rarr;

            </button>

        </form>

    </section>

    <div class="vg-search-benefits">

        <span>✓ Easy Bus Discovery</span>

        <span>✓ Visual Seat Selection</span>

        <span>✓ Convenient Booking</span>

        <span>✓ Digital Tickets</span>

    </div>

</main>

<script>

(function () {

    "use strict";

    const source =
        document.getElementById("sourceCityId");

    const destination =
        document.getElementById("destinationCityId");

    const swap =
        document.getElementById("swapCities");

    const form =
        document.getElementById("busSearchForm");

    const validation =
        document.getElementById("searchValidation");

    const submit =
        document.getElementById("searchSubmit");

    swap.addEventListener("click", function () {

        const oldSource = source.value;

        source.value = destination.value;

        destination.value = oldSource;

        swap.classList.remove("rotating");

        void swap.offsetWidth;

        swap.classList.add("rotating");

        setTimeout(function () {
            swap.classList.remove("rotating");
        }, 400);

    });

    form.addEventListener("submit", function (event) {

        if (source.value === destination.value) {

            event.preventDefault();

            validation.textContent =
                "Source and destination cannot be the same.";

            validation.hidden = false;

            return;
        }

        validation.hidden = true;

        submit.disabled = true;

        submit.textContent = "Searching Buses...";

    });

})();

</script>

</body>
</html>