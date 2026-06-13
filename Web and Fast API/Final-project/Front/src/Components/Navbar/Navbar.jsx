import React from "react";
import "./Navbar.css";
import { useLocation } from "react-router-dom";

export default function Navbar() {
  const username = localStorage.getItem("username");
  const location = useLocation();

  // Function to get the tab name based on the current route
  const getTabName = (path) => {
    if (path.includes("/Subscription")) {
      return "Subscription";
    }
    if (path.includes("/History")) {
      return "History";
    }
    if (path.includes("/Settings")) {
      return "Settings"; // Default for /Settings route
    }
    if (path === "/") {
      return "Dashboard";
    }
    if (path === "/Dashboard") {
      return "Dashboard";
    }
    return "Unknown";
  };

  // Determine the current route from location.pathname
  const currentLocation = getTabName(location.pathname);

  return (
    <nav className="navbar navbar-expand-lg nav-background justify-start p-0">
      <div className="container-fluid">
        <div className="logo d-flex align-items-center ms-4">
          <button className="navbar-brand">
            <img
              className="w-20"
              src="https://imgur.com/4YwzsaW.jpg"
              alt="Qualitronix Logo"
            />
          </button>
          <button className="navbar-brand d-none d-md-block">
            <img
              className="w-56"
              src="https://imgur.com/aM95Zwr.png"
              alt="Qualitronix"
            />
          </button>
        </div>
        {/* Dynamically display the current location */}
        <h2 className="current-Page m-auto d-none d-md-block">{currentLocation}</h2>
        <div className="d-flex align-items-center me-4">
          <img
            className="me-2 w-18 rounded-circle"
            src="https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"
            alt="Profile Photo"
          />
          <h3 className="mb-0">{username}</h3>
        </div>
      </div>
    </nav>
  );
}
