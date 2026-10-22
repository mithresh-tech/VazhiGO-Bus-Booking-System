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
    String contextPath = request.getContextPath();

    String errorMessage =
            (String) request.getAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Admin Login | VazhiGo</title>

<style>

:root {
    --navy: #102b49;
    --navy-dark: #07192c;
    --gold: #ffc86a;
    --muted: #64748b;
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    min-height: 100vh;
    font-family: 'Segoe UI', Arial, sans-serif;
    background: #edf3f9;
    color: #18304a;
}

/* NAVIGATION */

.navbar {
    position: relative;
    z-index: 2;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
    padding: 22px 6%;
    background: var(--navy);
    color: white;
}

.logo {
    font-size: 27px;
    font-weight: 800;
    letter-spacing: -1px;
}

.logo span {
    color: var(--gold);
}

.navbar a {
    color: white;
    text-decoration: none;
    font-size: 14px;
}

.navbar a:hover {
    color: var(--gold);
}

/* MAIN LAYOUT */

.login-layout {
    display: grid;
    grid-template-columns: 1fr 1fr;
    min-height: calc(100vh - 76px);
}

/* LEFT PANEL */

.visual-panel {
    position: relative;
    overflow: hidden;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 55px;
    color: white;
    background: linear-gradient(
        145deg,
        #153e68,
        #07192c
    );
}

.visual-panel::before,
.visual-panel::after {
    content: "";
    position: absolute;
    border: 1px solid rgba(255,255,255,.12);
    border-radius: 50%;
}

.visual-panel::before {
    width: 480px;
    height: 480px;
    top: -180px;
    right: -170px;
}

.visual-panel::after {
    width: 360px;
    height: 360px;
    bottom: -180px;
    left: -120px;
}

.visual-content {
    position: relative;
    z-index: 1;
    width: 100%;
    max-width: 520px;
    animation: slideIn .8s ease both;
}

.eyebrow {
    display: inline-block;
    padding: 9px 14px;
    border: 1px solid rgba(255,255,255,.25);
    border-radius: 30px;
    font-size: 12px;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: var(--gold);
}

.visual-content h1 {
    font-size: clamp(35px, 4vw, 56px);
    line-height: 1.12;
    letter-spacing: -2px;
    margin: 28px 0 18px;
}

.visual-content h1 span {
    color: var(--gold);
}

.visual-content p {
    max-width: 440px;
    color: #c5d5e7;
    line-height: 1.8;
    font-size: 16px;
}

/* ANIMATED JOURNEY */

.journey-art {
    position: relative;
    height: 190px;
    margin-top: 55px;
}

.road {
    position: absolute;
    left: 0;
    right: 0;
    bottom: 30px;
    height: 75px;
    border-radius: 15px;
    background: #132d48;
    border-top: 3px solid #345776;
    border-bottom: 3px solid #345776;
    overflow: hidden;
}

.road::after {
    content: "";
    position: absolute;
    top: 35px;
    left: 0;
    width: 200%;
    border-top: 3px dashed rgba(255,255,255,.5);
    animation: roadMove 2s linear infinite;
}

.bus {
    position: absolute;
    z-index: 2;
    bottom: 63px;
    left: 12%;
    width: 220px;
    height: 92px;
    animation: busFloat 2.5s ease-in-out infinite;
}

.bus-body {
    position: absolute;
    inset: 0 0 13px;
    border-radius: 16px 23px 8px 8px;
    background: var(--gold);
    box-shadow: inset 0 -10px rgba(0,0,0,.08);
}

.bus-window {
    position: absolute;
    top: 14px;
    width: 35px;
    height: 27px;
    background: #244966;
    border-radius: 5px;
}

.window-one { left: 18px; }
.window-two { left: 61px; }
.window-three { left: 104px; }
.window-four { left: 147px; }

.bus-door {
    position: absolute;
    top: 12px;
    right: 9px;
    width: 28px;
    height: 58px;
    border: 2px solid #244966;
    border-radius: 4px;
}

.wheel {
    position: absolute;
    bottom: 0;
    width: 29px;
    height: 29px;
    border: 7px solid #17283b;
    background: #b9c8d5;
    border-radius: 50%;
}

.wheel-one { left: 35px; }
.wheel-two { right: 32px; }

.bus-label {
    position: absolute;
    left: 20px;
    bottom: 24px;
    color: #102b49;
    font-size: 12px;
    font-weight: 900;
}

/* RIGHT PANEL */

.form-panel {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 45px 25px;
}

.login-card {
    width: 100%;
    max-width: 440px;
    padding: 42px;
    background: rgba(255,255,255,.94);
    border: 1px solid white;
    border-radius: 22px;
    box-shadow: 0 20px 65px rgba(16,43,73,.09);
    animation: cardAppear .8s ease both;
}

.lock-icon {
    display: grid;
    place-items: center;
    width: 58px;
    height: 58px;
    background: #eaf1f8;
    border-radius: 16px;
    font-size: 26px;
    margin-bottom: 23px;
}

.login-card h2 {
    margin: 0 0 10px;
    color: var(--navy);
    font-size: 30px;
}

.subtitle {
    margin: 0 0 30px;
    color: var(--muted);
    line-height: 1.6;
    font-size: 14px;
}

label {
    display: block;
    margin-bottom: 9px;
    font-size: 14px;
    font-weight: 650;
}

.field {
    margin-bottom: 22px;
}

input {
    width: 100%;
    padding: 15px;
    border: 1px solid #d7e0e9;
    border-radius: 10px;
    outline: none;
    font: inherit;
    font-size: 15px;
    transition: border-color .25s, box-shadow .25s;
}

input:focus {
    border-color: #356f9f;
    box-shadow: 0 0 0 4px rgba(53,111,159,.1);
}

.password-wrap {
    position: relative;
}

.password-wrap input {
    padding-right: 80px;
}

.toggle-password {
    position: absolute;
    right: 8px;
    top: 50%;
    transform: translateY(-50%);
    border: none;
    background: transparent;
    color: #24567c;
    font-size: 13px;
    font-weight: 700;
    padding: 10px;
    cursor: pointer;
}

.login-btn {
    width: 100%;
    min-height: 52px;
    border: 0;
    border-radius: 10px;
    background: var(--navy);
    color: white;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    transition: transform .2s, background .2s;
}

.login-btn:hover {
    background: #194b78;
    transform: translateY(-2px);
}

.login-btn:disabled {
    cursor: wait;
    opacity: .8;
}

.spinner {
    display: none;
    width: 17px;
    height: 17px;
    border: 2px solid rgba(255,255,255,.35);
    border-top-color: white;
    border-radius: 50%;
    animation: spin .7s linear infinite;
    vertical-align: middle;
    margin-right: 9px;
}

.login-btn.loading .spinner {
    display: inline-block;
}

.error {
    padding: 13px;
    background: #fff0f0;
    border: 1px solid #ffd1d1;
    border-radius: 9px;
    color: #a32727;
    font-size: 14px;
    margin-bottom: 22px;
    overflow-wrap: anywhere;
}

.security-note {
    margin-top: 25px;
    padding-top: 20px;
    border-top: 1px solid #e7edf3;
    color: #718096;
    font-size: 12px;
    text-align: center;
    line-height: 1.7;
}

/* ANIMATIONS */

@keyframes slideIn {
    from {
        opacity: 0;
        transform: translateX(-25px);
    }
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

@keyframes cardAppear {
    from {
        opacity: 0;
        transform: translateY(25px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes busFloat {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-6px); }
}

@keyframes roadMove {
    from { transform: translateX(0); }
    to { transform: translateX(-60px); }
}

@keyframes spin {
    to { transform: rotate(360deg); }
}

/* RESPONSIVE */

@media (max-width: 850px) {

    .login-layout {
        grid-template-columns: 1fr;
    }

    .visual-panel {
        min-height: 310px;
        padding: 35px 25px;
    }

    .visual-content h1 {
        font-size: 35px;
    }

    .journey-art {
        display: none;
    }

    .form-panel {
        padding: 35px 18px;
    }
}

@media (max-width: 480px) {

    .navbar {
        padding: 18px;
    }

    .login-card {
        padding: 28px 21px;
    }

    .visual-content h1 {
        font-size: 31px;
    }
}

@media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
        animation: none !important;
        transition: none !important;
    }
}

</style>

</head>

<body>

<header class="navbar">

    <div class="logo">
        Vazhi<span>Go</span>
    </div>

    <a href="<%= contextPath %>/index.jsp">
        ← Back to Home
    </a>

</header>

<main class="login-layout">

    <!-- LEFT VISUAL PANEL -->

    <section class="visual-panel">

        <div class="visual-content">

            <div class="eyebrow">
                Management Portal
            </div>

            <h1>
                Every journey.<br>
                <span>One dashboard.</span>
            </h1>

            <p>
                Welcome to the VazhiGo administration portal.
                Manage your bus booking operations through
                one centralized workspace.
            </p>

            <div class="journey-art"
                 aria-hidden="true">

                <div class="road"></div>

                <div class="bus">

                    <div class="bus-body">

                        <div class="bus-window window-one"></div>
                        <div class="bus-window window-two"></div>
                        <div class="bus-window window-three"></div>
                        <div class="bus-window window-four"></div>

                        <div class="bus-door"></div>

                        <div class="bus-label">
                            VAZHIGO
                        </div>

                    </div>

                    <div class="wheel wheel-one"></div>
                    <div class="wheel wheel-two"></div>

                </div>

            </div>

        </div>

    </section>

    <!-- LOGIN PANEL -->

    <section class="form-panel">

        <div class="login-card">

            <div class="lock-icon"
                 aria-hidden="true">
                🔐
            </div>

            <h2>Admin Sign In</h2>

            <p class="subtitle">
                Enter your administrator credentials
                to access the management dashboard.
            </p>

            <% if (errorMessage != null
                    && !errorMessage.isBlank()) { %>

                <div class="error" role="alert">
                    <%= escapeHtml(errorMessage) %>
                </div>

            <% } %>

            <form id="adminLoginForm"
                  action="<%= contextPath %>/adminLogin"
                  method="post">

                <div class="field">

                    <label for="email">
                        Email Address
                    </label>

                    <input
                        id="email"
                        type="email"
                        name="email"
                        placeholder="Enter admin email"
                        autocomplete="username"
                        maxlength="254"
                        required>

                </div>

                <div class="field">

                    <label for="password">
                        Password
                    </label>

                    <div class="password-wrap">

                        <input
                            id="password"
                            type="password"
                            name="password"
                            placeholder="Enter password"
                            autocomplete="current-password"
                            required>

                        <button
                            type="button"
                            class="toggle-password"
                            id="togglePassword"
                            aria-label="Show password"
                            aria-pressed="false">

                            Show

                        </button>

                    </div>

                </div>

                <button
                    class="login-btn"
                    id="loginButton"
                    type="submit">

                    <span class="spinner"
                          aria-hidden="true"></span>

                    <span id="buttonText">
                        Sign In to Dashboard
                    </span>

                </button>

            </form>

            <div class="security-note">
                VazhiGo Administration Portal<br>
                Authorized administrators only.
            </div>

        </div>

    </section>

</main>

<script>

const passwordInput =
        document.getElementById("password");

const togglePassword =
        document.getElementById("togglePassword");

togglePassword.addEventListener("click", function () {

    const isHidden = passwordInput.type === "password";

    passwordInput.type = isHidden ? "text" : "password";

    togglePassword.textContent = isHidden ? "Hide" : "Show";

    togglePassword.setAttribute(
        "aria-label",
        isHidden ? "Hide password" : "Show password"
    );

    togglePassword.setAttribute(
        "aria-pressed",
        String(isHidden)
    );

});

const loginForm =
        document.getElementById("adminLoginForm");

const loginButton =
        document.getElementById("loginButton");

const buttonText =
        document.getElementById("buttonText");

loginForm.addEventListener("submit", function () {

    if (!loginForm.checkValidity()) {
        return;
    }

    loginButton.classList.add("loading");

    buttonText.textContent = "Signing In...";

    // Prevent repeat clicks without disabling the form's
    // submit button before the browser sends the request.
    loginButton.style.pointerEvents = "none";

});

</script>

</body>
</html>