if (!window.__tdotFlagFormInitialized) {
  window.__tdotFlagFormInitialized = true;

  const challengeToCardPath = {
    hidden_in_source: "wartungsseite",
    session_cookies: "notenportal",
    sql_injection: "htldb",
  };

  document.querySelectorAll("#flag-form").forEach((form) => {
    form.addEventListener("submit", async (event) => {
      event.preventDefault();

      const challengeId = form.dataset.challenge;
      const flagInput = form.querySelector("#flag-input");
      const feedback = document.getElementById("flag-feedback");
      const solvedNotice = document.getElementById("solved-notice");

      if (!challengeId || !flagInput || !feedback) {
        return;
      }

      const flag = flagInput.value.trim();
      if (!flag) {
        feedback.textContent = "Bitte gib eine Flag ein.";
        feedback.style.color = "var(--danger)";
        return;
      }

      try {
        const response = await fetch("/api/flag", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ challenge_id: challengeId, flag }),
        });

        const payload = await response.json();

        if (payload.correct) {
          feedback.textContent = "";
          feedback.style.color = "";

          flagInput.classList.remove("input--correct");
          void flagInput.offsetWidth;
          flagInput.classList.add("input--correct");

          const targetCard = document.querySelector(
            `.card[data-href="${challengeToCardPath[challengeId] || ""}"]`
          );

          if (targetCard) {
            targetCard.classList.remove("solved");
            void targetCard.offsetWidth;
            targetCard.classList.add("solved");
          }

          if (solvedNotice) {
            solvedNotice.hidden = false;
            solvedNotice.scrollIntoView({ behavior: "smooth", block: "nearest" });
          }
        } else {
          feedback.textContent = "Noch nicht richtig.";
          feedback.style.color = "var(--danger)";
          if (solvedNotice) solvedNotice.hidden = true;
        }
      } catch (error) {
        feedback.textContent = "Fehler beim Prüfen der Flag.";
        feedback.style.color = "var(--danger)";
        if (solvedNotice) solvedNotice.hidden = true;
      }
    });
  });
}