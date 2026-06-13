import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import axios from "axios";

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [touched, setTouched] = useState({ email: false, password: false });
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const isValid = email.trim() && password.trim();

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!isValid) {
      setTouched({ email: true, password: true });
      return;
    }

    setError("");
    try {
      const response = await axios.post("http://13.48.37.38:3000/auth/signin", {
        email,
        password,
      });

      localStorage.setItem("accessToken", response.data.accessToken);
      localStorage.setItem("refreshToken", response.data.refreshToken);

      navigate("/");
    } catch (err) {
      setError(err.response?.data?.message || "Login failed.");
    }
  };

  return (
    <div className="min-h-screen flex flex-col md:flex-row bg-cover bg-center" style={{ backgroundImage: "url('https://imgur.com/XJUGC3H.png')" }}>
      {/* Left Panel */}
      <div className="w-full md:w-1/2 flex flex-col justify-center items-center p-6 bg-gradient-to-t from-[#003021f0] to-[#009669d0]">
        <div className="w-full max-w-md bg-white/5 backdrop-blur-md rounded-2xl shadow-lg p-8">
          <div className="text-center mb-6">
            <img src="https://imgur.com/4YwzsaW.jpg" alt="Logo" className="w-20 mx-auto rounded-full shadow-md" />
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <input
                type="email"
                placeholder="Email Address"
                className="w-full p-2 rounded-md border border-white bg-transparent text-white placeholder-white/70 focus:outline-none focus:ring-2 focus:ring-amber-400"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                onBlur={() => setTouched((prev) => ({ ...prev, email: true }))}
              />
              {touched.email && !email && (
                <p className="text-grey-400 text-xl mt-1">Please enter your email</p>
              )}
            </div>
            <div>
              <input
                type="password"
                placeholder="Password"
                className="w-full p-2 rounded-md border border-white bg-transparent text-white placeholder-white/70 focus:outline-none focus:ring-2 focus:ring-amber-400"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                onBlur={() => setTouched((prev) => ({ ...prev, password: true }))}
              />
              {touched.password && !password && (
                <p className="text-grey-400 text-xl mt-1">Please enter your password</p>
              )}
            </div>

            {error && (
              <div className="text-grey-400 bg-red-100/10 border border-red-300/30 p-2 rounded-md text-xl">
                {error}
              </div>
            )}

            <button
              type="submit"
              className={`w-full py-2 rounded-full font-semibold transition text-white ${
                isValid
                  ? "bg-blue-600 hover:bg-blue-700"
                  : "bg-blue-400 cursor-not-allowed"
              }`}
              disabled={!isValid}
            >
              Login
            </button>

            <div className="text-center text-xl mt-2">
              <Link to="/ForgotPassword" className="text-white underline">
                Forgot Password?
              </Link>
            </div>
          </form>

          <div className="text-center mt-5 text-xl text-white">
            Don’t have an account?
            <Link to="/Register" className="text-amber-300 ml-1 font-semibold hover:underline">
              Register here
            </Link>
          </div>
        </div>

        <div className="mt-10 text-center text-white">
          <p className="mb-2">Get the Application</p>
          <div className="flex justify-center gap-4">
            <button>
              <img src="https://imgur.com/uPXtOKg.png" alt="Google Play" className="h-12" />
            </button>
            <button>
              <img src="https://imgur.com/vVOobox.png" alt="App Store" className="h-12" />
            </button>
          </div>
        </div>
      </div>

      {/* Right Panel */}
      <div className="hidden md:flex w-1/2 flex-col justify-center items-center bg-gradient-to-br from-amber-400 to-emerald-600 text-white text-center px-10">
        <img src="https://imgur.com/4YwzsaW.jpg" alt="Logo" className="w-20 mb-4" />
        <img src="https://imgur.com/aM95Zwr.png" alt="Qualitronix" className="w-2/3 mb-8" />

        <div className="mb-10">
          <h2 className="text-2xl font-semibold">Defect Zero, Quality Hero</h2>
          <hr className="my-2 border-white w-2/3 mx-auto" />
        </div>

        <div className="mb-10">
          <h2 className="text-2xl font-semibold">PCB Defect Detection</h2>
          <hr className="my-2 border-white w-2/3 mx-auto" />
        </div>
      </div>
    </div>
  );
}
