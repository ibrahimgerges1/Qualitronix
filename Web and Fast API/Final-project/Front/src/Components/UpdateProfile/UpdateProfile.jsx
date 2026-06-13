import React, { useState } from "react";
import "./UpdateProfile.css";
import axios from "axios";
import { useNavigate } from "react-router-dom";

export default function UpdateProfile() {
  const navigate = useNavigate();
  const accessToken = localStorage.getItem("accessToken");

  const [formData, setFormData] = useState({
    username: "",
    phone: "",
    email: "",
    confirmEmail: "",
    age: "",
  });

  const [error, setError] = useState("");

  const profileData = [
    ["Username", "text", "username"],
    ["Phone", "number", "phone"],
    ["Email", "email", "email"],
    ["Confirm Email", "email", "confirmEmail"],
    ["Age", "number", "age"],
  ];

  // Handle Input Change
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };

  // Handle Form Submission
  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    if (formData.email !== formData.confirmEmail) {
      setError("Emails do not match.");
      return;
    }

    // Filter out empty fields
    const filteredData = Object.fromEntries(
      Object.entries(formData).filter(([_, value]) => value.trim() !== "")
    );

    try {
      const response = await axios.put(
        "http://13.48.37.38:3000/user/updateProfile",
        filteredData,
        {
          headers: {
            Authorization: `${accessToken}`,
          },
        }
      );

      console.log("Data updated successfully:", response.data);
      navigate("/Settings/Update-Profile");
    } catch (error) {
      setError("An error occurred. Please try again later.");
      console.error("Error during update:", error);
    }
  };

  return (
    <div className="container-fluid">
      <div className="row">
        <div className="col-1"></div>
        <div className="col-10 offset-1">
          <form onSubmit={handleSubmit}>
            <ul className="row list-unstyled">
              {profileData.map(([label, type, name], index) => (
                <div key={index} className="px-0 col-6">
                  <div className="mx-2 my-2">
                    <label className="text-white text-shadow-lg/30 mb-1" htmlFor={name}>
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
              <div className="">
                <button
                type="submit"
                className="bg-white text-black font-medium rounded-pill p-1 me-2 my-3 border-1 border-white w-100"
              >
                Submit
              </button>
              </div>
            </ul>
          </form>
          {error && <p className="text-red-500">{error}</p>}
        </div>
      </div>
    </div>
  );
}
