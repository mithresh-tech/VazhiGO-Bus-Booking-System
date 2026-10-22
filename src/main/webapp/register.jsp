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

<title>Create Account | VazhiGo</title>

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
            Discover More.<br>
            Travel Better.
        </h1>

        <p>
            Create your account to explore bus services,
            reserve your preferred seats and manage
            your journeys across Tamil Nadu.
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

            <h2>Create Account</h2>

            <p class="auth-subtitle">
                Join VazhiGo and start your journey.
            </p>

            <% if (errorMessage != null) { %>

                <div class="error-message" role="alert">
                    <%= escapeHtml(errorMessage) %>
                </div>

            <% } %>

            <form action="<%= ctx %>/register"
                  method="post">

                <div class="form-group">

                    <label for="fullName">
                        Full Name
                    </label>

                    <input class="form-control"
                           type="text"
                           id="fullName"
                           name="fullName"
                           placeholder="Enter your full name"
                           autocomplete="name"
                           maxlength="100"
                           required>

                </div>

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

                    <label for="phone">
                        Phone Number
                    </label>

                    <input class="form-control"
                           type="tel"
                           id="phone"
                           name="phone"
                           placeholder="Enter your phone number"
                           autocomplete="tel"
                           maxlength="15"
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
                               placeholder="Create a password"
                               autocomplete="new-password"
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

                    Create Account &rarr;

                </button>

            </form>

            <div class="auth-links">

                Already have an account?

                <a href="<%= ctx %>/login.jsp">
                    Sign In
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