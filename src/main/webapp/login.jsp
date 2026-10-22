<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%!
private String escapeHtml(String value) {
    if (value == null) return "";

    return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
}
%>

<%
String ctx = request.getContextPath();

String errorMessage =
        (String) request.getAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Sign In | VazhiGo</title>

<link rel="stylesheet"
      href="<%= ctx %>/assets/css/style.css">

<link rel="stylesheet"
      href="<%= ctx %>/assets/css/vazhigo-animation.css">

</head>

<body>

<main class="auth-page">

    <section class="auth-visual">

        <div class="vg-brand">
            Vazhi<span>Go</span>
        </div>

        <div class="vg-tagline">
            Your Journey, Our Priority
        </div>

        <h1>
            Welcome Back,<br>
            Traveller!
        </h1>

        <p>
            Your next journey is just a few clicks away.
            Sign in to explore available buses,
            book seats and manage your tickets.
        </p>

        <!-- ANIMATED BUS SCENE -->

        <div class="vg-scene" aria-hidden="true">

            <div class="vg-moon"></div>

            <div class="vg-hill"></div>

            <div class="vg-hill second"></div>

            <div class="vg-road"></div>

            <div class="vg-bus">

                <div class="vg-bus-body">

                    <div class="vg-bus-window"></div>

                    <div class="vg-bus-light"></div>

                </div>

                <div class="vg-wheel back"></div>

                <div class="vg-wheel front"></div>

            </div>

        </div>

    </section>

    <section class="auth-panel">

        <div class="auth-card">

            <a class="back-home"
               href="<%= ctx %>/index.jsp">

                &larr; Back to Home

            </a>

            <h2>Sign In</h2>

            <p class="auth-subtitle">
                Enter your account details to continue.
            </p>

            <% if (errorMessage != null) { %>

                <div class="error-message" role="alert">
                    <%= escapeHtml(errorMessage) %>
                </div>

            <% } %>

            <form action="<%= ctx %>/login"
                  method="post">

                <div class="form-group">

                    <label for="email">
                        Email Address
                    </label>

                    <input class="form-control"
                           type="email"
                           id="email"
                           name="email"
                           placeholder="Enter your email"
                           autocomplete="email"
                           maxlength="254"
                           required>

                </div>

                <div class="form-group">

                    <label for="password">
                        Password
                    </label>

                    <div class="password-field">

                        <input class="form-control"
                               type="password"
                               id="password"
                               name="password"
                               placeholder="Enter your password"
                               autocomplete="current-password"
                               required>

                        <button class="password-toggle"
                                type="button"
                                id="togglePassword"
                                aria-label="Show password"
                                aria-pressed="false">

                            Show

                        </button>

                    </div>

                </div>

                <button class="btn btn-accent submit-btn"
                        type="submit">

                    Sign In &rarr;

                </button>

            </form>

            <div class="auth-links">

                Don't have an account?

                <a href="<%= ctx %>/register.jsp">
                    Create Account
                </a>

            </div>

        </div>

    </section>

</main>

<script>

(function () {

    const password =
        document.getElementById("password");

    const toggle =
        document.getElementById("togglePassword");

    toggle.addEventListener("click", function () {

        const isHidden =
            password.type === "password";

        password.type =
            isHidden ? "text" : "password";

        toggle.textContent =
            isHidden ? "Hide" : "Show";

        toggle.setAttribute(
            "aria-label",
            isHidden ? "Hide password" : "Show password"
        );

        toggle.setAttribute(
            "aria-pressed",
            String(isHidden)
        );

    });

})();

</script>

</body>
</html>