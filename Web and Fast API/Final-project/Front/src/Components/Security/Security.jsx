import axios from "axios";
import React, { useState } from "react";
import { useNavigate } from "react-router-dom";

export default function Security() {
  const navigate = useNavigate();
  const accessToken = localStorage.getItem("accessToken");
  const refreshToken = localStorage.getItem("refreshToken");

  const [formData, setFormData] = useState({
    oldPassword: "",
    newPassword: "",
    confirmNewPassword: "",
  });

  const [error, setError] = useState("");

  const profileData = [
    ["Old Password", "password", "oldPassword"],
    ["New Password", "password", "newPassword"],
    ["Confirm New Password", "password", "confirmNewPassword"],
  ];

  // Handle form input changes
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };

  // Handle form submission
  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    // Check if new password and confirmation match
    if (formData.newPassword !== formData.confirmNewPassword) {
      setError("New password does not match.");
      return;
    }

    // Filter out empty fields
    const filteredData = Object.fromEntries(
      Object.entries(formData).filter(([_, value]) => value.trim() !== "")
    );

    try {
      const response = await axios.patch(
        "http://13.48.37.38:3000/user/updatePassword",
        filteredData,
        {
          headers: {
            Authorization: `Bearer ${accessToken}`, // Corrected header
            refreshToken: `${refreshToken}`, // Ensure this header is required by the backend
            "Content-Type": "application/json", // Explicitly define content type
          },
        }
      );

      console.log("Password changed successfully:", response.data);
      navigate("/Dashboard");
    } catch (error) {
      if (error.response) {
        // Backend responded with an error status
        setError(
          error.response.data.message || "Update failed. Please try again."
        );
        console.error("Server error:", error.response);
      } else if (error.request) {
        // No response received
        setError("No response from server. Check your connection.");
        console.error("Network error:", error.request);
      } else {
        // Other errors
        setError("An unexpected error occurred.");
        console.error("Error:", error.message);
      }
    }
  };

  return (
    <div className="container-fluid">
      <div className="row">
        <div className="col-1"></div>
        <div className="col-10 offset-1">
          <form onSubmit={handleSubmit}>
            <ul className="col-6 list-unstyled">
              {profileData.map(([label, type, name], index) => (
                <div key={index} className="px-0 row">
                  <div className="mx-2 my-2">
                    <label className="text-white mb-1" htmlFor={name}>
                      {label}
                    </label>
                    <li className="m-0 bg-white rounded-xl py-1 px-2 text-black border-black border-1">
                      <input
                        id={name}
                        type={type}
                        name={name}
                        value={formData[name]}
                        onChange={handleInputChange}
                        autoComplete="off"
                        aria-autocomplete="none"
                        readOnly={false}
                        onFocus={(e) => e.target.removeAttribute("readonly")}
                        className="w-100"
                      />
                    </li>
                  </div>
                </div>
              ))}
              <button
                type="submit"
                className="bg-white text-black w-100 font-medium rounded-pill p-1 mx-2 my-3 border-1 border-white"
              >
                Submit
              </button>
            </ul>
          </form>
          {error && <p className="text-red-500">{error}</p>}
        </div>
      </div>
    </div>
  );
}
