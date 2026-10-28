const form = document.getElementById("search-form");
const input = document.getElementById("search-input");
const result = document.getElementById("result");
const resultAvatar = document.getElementById("result-avatar");
const resultName = document.getElementById("result-name");
const noResult = document.getElementById("no-result");

form.addEventListener("submit", async (e) => {
  e.preventDefault();
  const res = await fetch("/api/htldb?name=" + encodeURIComponent(input.value.trim()));

  if (res.ok) {
    const match = await res.json();
    resultAvatar.src = match.image;
    resultAvatar.alt = match.name;
    resultName.textContent = match.name;
    result.hidden = false;
    noResult.hidden = true;
  } else {
    result.hidden = true;
    noResult.hidden = false;
  }
});