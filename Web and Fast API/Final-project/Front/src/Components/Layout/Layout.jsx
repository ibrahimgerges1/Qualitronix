import React, { useEffect, useState } from "react";
import Navbar from "../Navbar/Navbar.jsx";
import "./Layout.css";
import { Outlet } from "react-router-dom";
import Sidemenu from "../Sidemenu/Sidemenu.jsx";
import axios from "axios";

export default function Layout() {
  const accessToken = localStorage.getItem("accessToken");

  useEffect(() => {
    const fetchUserProfile = async () => {
      try {
        const response = await axios.get(
          "http://13.48.37.38:3000/user/profile",
          {
            headers: {
              Authorization: `Bearer ${accessToken}`,
            },
          }
        );

        const { username } = response.data.user;

        localStorage.setItem("username", username);
      } catch (error) {
        console.error("Error fetching user profile:", error);
      }
    };

    fetchUserProfile();
  });
  return (
    <div className="flex flex-col h-screen">
      <Navbar />
      <div className="flex flex-row flex-grow">
        {/* Side menu hidden on small screens */}
        <div className="hidden md:block basis-2/12 menu pe-2">
          <Sidemenu />
        </div>

        {/* Main content */}
        <div className="basis-10/12 flex-grow px-2 bg23 border-t-2 border-dark">
          <Outlet />
        </div>
      </div>
    </div>
  );

}
