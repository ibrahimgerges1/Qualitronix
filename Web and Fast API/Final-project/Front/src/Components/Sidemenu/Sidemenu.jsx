import axios from "axios";
import React, { useState, useEffect } from "react";
import "./Sidemenu.css";
import { Link, useNavigate, useLocation } from "react-router-dom";
import Upload from "../Upload/Upload";

export default function Sidemenu() {
  const [activeButton, setActiveButton] = useState("Dashboard");
  const [showUploadModal, setShowUploadModal] = useState(false);
  const aT = localStorage.getItem("accessToken");
  const refreshToken = localStorage.getItem("refreshToken");
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    const savedTab = localStorage.getItem("activeTab");
    if (savedTab) {
      setActiveButton(savedTab);
    }

    // Sync with current path in case of refresh without click
    const path = location.pathname.split("/")[1];
    if (path && !["", "Login"].includes(path)) {
      setActiveButton(path === "Settings" ? "Setting" : path);
      localStorage.setItem("activeTab", path === "Settings" ? "Setting" : path);
    }
  }, [location]);

  const handleButtonClick = (buttonName) => {
    setActiveButton(buttonName);
    localStorage.setItem("activeTab", buttonName);
  };

  const handleLogout = async () => {
    try {
      await axios.get("http://13.48.37.38:3000/auth/signOut", {
        headers: {
          "Content-Type": "application/json",
          accesstoken: `${aT}`,
          refreshtoken: refreshToken,
        },
      });
    } catch (error) {
      console.error("Logout error:", error.response?.data || error.message);
    } finally {
      localStorage.clear();
      navigate("/Login");
    }
  };

  return (
    <>
      <div className="Menu_Background text_color p-0">
        <ul className="nav nav-pills flex-column mb-auto py-1">
          <li className="nav-item mt-2 py-2 text-center">
            <h5>Menu</h5>
          </li>
          <li className="nav-item py-1">
            <button
              className="nav-link text-white w-100 text-start"
              onClick={() => setShowUploadModal(true)}
            >
              <i className="fas fa-cloud-upload-alt me-2"></i>
              Upload
            </button>
          </li>
          <li className="nav-item py-1">
            <Link to="/Dashboard" className="text-white">
              <button
                onClick={() => handleButtonClick("Dashboard")}
                className={`nav-link text-white w-100 text-start ${
                  activeButton === "Dashboard" ? "active-button" : ""
                }`}
              >
                <i className="fas fa-home me-2"></i>
                Dashboard
              </button>
            </Link>
          </li>
          <li className="nav-item py-1">
            <Link to="/Subscription" className="text-white">
              <button
                onClick={() => handleButtonClick("Subscription")}
                className={`nav-link text-white w-100 text-start ${
                  activeButton === "Subscription" ? "active-button" : ""
                }`}
              >
                <i className="fas fa-ticket-alt me-2"></i>
                Subscription
              </button>
            </Link>
          </li>
          <li className="nav-item py-1">
            <Link to="/History" className="text-white">
              <button
                onClick={() => handleButtonClick("History")}
                className={`nav-link text-white w-100 text-start ${
                  activeButton === "History" ? "active-button" : ""
                }`}
              >
                <i className="fas fa-history me-2"></i>
                History
              </button>
            </Link>
          </li>
          <li className="nav-item mt-1 py-1 text-center">Others</li>
          <li className="nav-item py-1">
            <Link to="/Settings" className="text-white no-underline">
              <button
                onClick={() => handleButtonClick("Setting")}
                className={`nav-link text-white w-100 text-start ${
                  activeButton === "Setting" ? "active-button" : ""
                }`}
              >
                <i className="fas fa-cog me-2"></i>
                Setting
              </button>
            </Link>
          </li>
        </ul>
        <div className="logout-section py-1">
          <button
            className="nav-link text-white w-100 text-start"
            onClick={handleLogout}
          >
            <i className="fas fa-sign-out-alt me-2 text-danger"></i>
            <span className="text-danger">Logout</span>
          </button>
        </div>
      </div>

      {showUploadModal && <Upload onClose={() => setShowUploadModal(false)} />}
    </>
  );
}
