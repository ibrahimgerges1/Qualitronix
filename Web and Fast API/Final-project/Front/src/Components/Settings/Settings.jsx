import React, { useState, useEffect } from "react";
import {
  Link,
  Route,
  Routes,
  useLocation,
  useNavigate,
} from "react-router-dom";
import "./Settings.css";
import UpdateProfile from "../UpdateProfile/UpdateProfile";
import Security from "../Security/Security";

export default function Settings() {
  const [activeButton, setActiveButton] = useState("UpdateProfile");
  const location = useLocation();
  const navigate = useNavigate();

  useEffect(() => {
    const path = location.pathname.split("/").pop();

    // Redirect to Update-Profile if only /Settings is visited
    if (path === "Settings") {
      navigate("Update-Profile");
    }

    if (path === "Security") {
      setActiveButton("Security");
    } else {
      setActiveButton("UpdateProfile");
    }
  }, [location, navigate]);

  return (
    <div className="bg-gray-950 rounded-2xl bgf mt-2 flex-col ">
      <ul className="flex flex-wrap mt-2 pt-1 text-sm font-medium text-center text-gray-500 border-b border-yellow-600 ">
          <li className="me-2">
              <Link
                to="Update-Profile"
                className={`inline-block p-4 rounded-t-lg hover:text-yellow-600 text-white w-100 text-start ${
                  activeButton === "UpdateProfile" ? "active-button" : ""
                }`}
              >
                {"Update Profile"}
              </Link>
          </li>
          <li className="me-2">
              <Link
                to="Security"
                className={`inline-block p-4 rounded-t-lg hover:text-yellow-600 text-white w-100 text-start ${
                  activeButton === "Security" ? "active-button" : ""
                }`}
              >
                {"Security"}
              </Link>
          </li>
      </ul>
      <Routes>
        <Route path="Update-Profile" element={<UpdateProfile />} />
        <Route path="Security" element={<Security />} />
      </Routes>
    </div>
  );
}
