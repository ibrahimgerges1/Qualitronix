export function storeAccessToken(token) {
  localStorage.setItem("accessToken", token);
  localStorage.setItem("lastTokenUpdateTime", Date.now().toString());
}

export function getAccessToken() {
  return localStorage.getItem("accessToken");
}

export function getLastTokenUpdateTime() {
  return parseInt(localStorage.getItem("lastTokenUpdateTime"));
}

export function clearAuthData() {
  localStorage.clear(); // Or selectively remove specific keys
}
