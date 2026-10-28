// Demo-Login: jede Kombination wird akzeptiert, es gibt noch keine echte Prüfung.
// Die Rolle wird direkt im Cookie gespeichert - das ist die Schwachstelle.
const FLAG = "HTL{c00k13s_s1nd_k31n_z4un}";

function setCookie(name, value, stayLoggedIn) {
  const maxAge = stayLoggedIn ? 60 * 60 * 24 * 30 : ""; // 30 Tage oder Session
  document.cookie = `${name}=${value}; path=/` + (maxAge ? `; max-age=${maxAge}` : "");
}

function getCookie(name) {
  const match = document.cookie.match(new RegExp("(^| )" + name + "=([^;]+)"));
  return match ? match[2] : null;
}

function renderDashboard() {
  const role = getCookie("role");
  const user = getCookie("user") || "Gast";
  if (!role) return;

  document.getElementById("login-form").hidden = true;
  document.getElementById("dashboard").hidden = false;
  document.getElementById("dash-user").textContent = user;
  document.getElementById("dash-role").textContent = role;

  if (role === "teacher") {
    document.getElementById("dash-content").innerHTML =
      `Lehreransicht freigeschaltet. Flag: <code>${FLAG}</code>`;
  } else {
    document.getElementById("dash-content").textContent =
      "Als Gast siehst du nur die öffentliche Übersicht. Keine Noten sichtbar.";
  }
}

document.getElementById("login-form").addEventListener("submit", (e) => {
  e.preventDefault();
  const user = document.getElementById("user").value.trim() || "Gast";
  const stay = document.getElementById("stay").checked;
  setCookie("user", user, stay);
  setCookie("role", "guest", stay);
  renderDashboard();
});

document.getElementById("logout").addEventListener("click", () => {
  setCookie("role", "", false);
  setCookie("user", "", false);
  document.cookie = "role=; path=/; max-age=0";
  document.cookie = "user=; path=/; max-age=0";
  document.getElementById("login-form").hidden = false;
  document.getElementById("dashboard").hidden = true;
});

renderDashboard();
