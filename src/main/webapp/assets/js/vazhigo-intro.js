(function () {
    "use strict";

    const intro = document.getElementById("vazhigoIntro");
    const skip = document.getElementById("skipIntro");

    if (!intro || !skip) return;

    let timer;

    function closeIntro() {
        clearTimeout(timer);

        intro.classList.add("vg-hide");

        setTimeout(function () {
            intro.remove();
        }, 800);
    }

    const reducedMotion = window.matchMedia(
        "(prefers-reduced-motion: reduce)"
    ).matches;

    let alreadyPlayed = false;

    try {
        alreadyPlayed =
            sessionStorage.getItem("vazhigoIntroPlayed") === "yes";

        sessionStorage.setItem("vazhigoIntroPlayed", "yes");
    } catch (error) {
        // Continue normally if browser storage is unavailable.
    }

    if (alreadyPlayed || reducedMotion) {
        intro.remove();
        return;
    }

    skip.addEventListener("click", closeIntro);

    timer = setTimeout(closeIntro, 4200);
})();