(() => {
  "use strict";
  const root = document.getElementById("session5-results");
  if (!root) return;
  const form = root.querySelector("#s5-filters"), list = root.querySelector("#s5-list");
  if (!form || !list) return;
  const cards = Array.from(list.querySelectorAll(".s5-card"));
  const minInput = form.querySelector("#s5-min"), maxInput = form.querySelector("#s5-max"), sort = form.querySelector("#s5-sort");
  const error = form.querySelector("#s5-error"), count = root.querySelector("#s5-count"), empty = root.querySelector("#s5-no-match");
  function period(time) {
    const hour = Number(time.split(":")[0]);
    if (hour >= 5 && hour < 12) return "morning";
    if (hour >= 12 && hour < 17) return "afternoon";
    if (hour >= 17 && hour < 21) return "evening";
    return "night";
  }
  function update() {
    const types = new Set(Array.from(form.querySelectorAll('input[name="type"]:checked'), x => x.value));
    const periods = new Set(Array.from(form.querySelectorAll('input[name="period"]:checked'), x => x.value));
    const min = minInput.value.trim() === "" ? null : Number(minInput.value);
    const max = maxInput.value.trim() === "" ? null : Number(maxInput.value);
    const invalid = (min !== null && (!Number.isFinite(min) || min < 0)) || (max !== null && (!Number.isFinite(max) || max < 0)) || (min !== null && max !== null && min > max);
    error.textContent = invalid ? "Enter a valid fare range. Minimum cannot exceed maximum." : "";
    let visible = 0;
    cards.forEach(card => {
      const fare = Number(card.dataset.fare);
      const match = !invalid && (!types.size || types.has(card.dataset.type)) && (!periods.size || periods.has(period(card.dataset.departure))) && (min === null || fare >= min) && (max === null || fare <= max);
      card.hidden = !match;
      if (match) visible++;
    });
    const methods = {
      priceAsc: (a,b) => Number(a.dataset.fare) - Number(b.dataset.fare),
      priceDesc: (a,b) => Number(b.dataset.fare) - Number(a.dataset.fare),
      departureAsc: (a,b) => a.dataset.departure.localeCompare(b.dataset.departure),
      departureDesc: (a,b) => b.dataset.departure.localeCompare(a.dataset.departure)
    };
    const compare = methods[sort.value] || ((a,b) => Number(a.dataset.order) - Number(b.dataset.order));
    cards.sort((a,b) => compare(a,b) || Number(a.dataset.order) - Number(b.dataset.order)).forEach(card => list.appendChild(card));
    count.textContent = `Showing ${visible} of ${cards.length} buses`;
    empty.hidden = visible !== 0;
  }
  form.addEventListener("input", update);
  form.addEventListener("change", update);
  form.addEventListener("reset", () => setTimeout(update, 0));
  root.querySelector("#s5-clear-empty").addEventListener("click", () => form.reset());
  update();
})();
