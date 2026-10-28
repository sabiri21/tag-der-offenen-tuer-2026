document.querySelectorAll(".card[data-href]").forEach((card) => {
  card.addEventListener("click", (event) => {
    if (event.target.closest("a")) return;
    window.location.href = card.dataset.href;
  });
 
  // Auch per Tastatur bedienbar
  card.setAttribute("tabindex", "0");
  card.setAttribute("role", "link");
  card.addEventListener("keydown", (event) => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      window.location.href = card.dataset.href;
    }
  });
});
 
