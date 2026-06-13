import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import axios from "axios";

export default function ResetPassword() {
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [touched, setTouched] = useState({});
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const isValid =
    email.trim() &&
    otp.trim() &&
    password.trim() &&
    confirmPassword.trim() &&
    password === confirmPassword;

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!isValid) {
      setTouched({ email: true, otp: true, password: true, confirmPassword: true });
      return;
    }

    setError("");
    setSuccess("");
    setLoading(true);

    try {
      const response = await axios.put("http://13.48.37.38:3000/auth/resetPassword", {
        email,
        otp,
        password,
        confirmPassword,
      });

      setSuccess("Password successfully reset!");
      setTimeout(() => navigate("/Login"), 2000);
    } catch (err) {
      setError(err.response?.data?.message || "Something went wrong");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
      className="min-h-screen flex flex-col md:flex-row bg-cover bg-center"
      style={{ backgroundImage: "url('https://imgur.com/XJUGC3H.png')" }}
    >
      {/* Left Panel */}
      <div className="w-full md:w-1/2 flex flex-col justify-center items-center p-6 bg-gradient-to-t from-[#003021f0] to-[#009669d0]">
        <div className="w-full max-w-md bg-white/5 backdrop-blur-md rounded-2xl shadow-lg p-8">
          <div className="text-center mb-6">
            <img src="https://imgur.com/4YwzsaW.jpg" alt="Logo" className="w-20 mx-auto rounded-full shadow-md" />
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <input
              type="email"
              placeholder="Email Address"
              className="w-full p-2 rounded-md border border-white bg-transparent text-white placeholder-white/70 focus:outline-none focus:ring-2 focus:ring-amber-400"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              onBlur={() => setTouched((prev) => ({ ...prev, email: true }))}
            />
            {touched.email && !email && (
              <p className="text-red-400 text-sm mt-1">Email is required</p>
            )}

            <input
              type="number"
              placeholder="One Time Pin"
              className="w-full p-2 rounded-md border border-white bg-transparent text-white placeholder-white/70 focus:outline-none focus:ring-2 focus:ring-amber-400"
              value={otp}
              onChange={(e) => setOtp(e.target.value)}
              onBlur={() => setTouched((prev) => ({ ...prev, otp: true }))}
            />
            {touched.otp && !otp && (
              <p className="text-red-400 text-sm mt-1">OTP is required</p>
            )}

            <input
              type="password"
              placeholder="New Password"
              className="w-full p-2 rounded-md border border-white bg-transparent text-white placeholder-white/70 focus:outline-none focus:ring-2 focus:ring-amber-400"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              onBlur={() => setTouched((prev) => ({ ...prev, password: true }))}
            />
            {touched.password && !password && (
              <p className="text-red-400 text-sm mt-1">Password is required</p>
            )}

            <input
              type="password"
              placeholder="Confirm Password"
              className="w-full p-2 rounded-md border border-white bg-transparent text-white placeholder-white/70 focus:outline-none focus:ring-2 focus:ring-amber-400"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              onBlur={() => setTouched((prev) => ({ ...prev, confirmPassword: true }))}
            />
            {touched.confirmPassword && confirmPassword !== password && (
              <p className="text-red-400 text-sm mt-1">Passwords do not match</p>
            )}

            {error && (
              <div className="text-red-400 bg-red-100/10 border border-red-300/30 p-2 rounded-md text-sm">
                {error}
              </div>
            )}

            {success && (
              <div className="text-green-400 bg-green-100/10 border border-green-300/30 p-2 rounded-md text-sm">
                {success}
              </div>
            )}

            <button
              type="submit"
              className={`w-full py-2 rounded-full font-semibold transition text-white ${
                isValid
                  ? "bg-blue-600 hover:bg-blue-700"
                  : "bg-blue-400 cursor-not-allowed"
              }`}
              disabled={!isValid || loading}
            >
              {loading ? "Submitting..." : "Reset Password"}
            </button>

            <div className="text-center text-sm mt-2">
              <Link to="/Login" className="text-white underline">
                Remembered your password? Click here
              </Link>
            </div>
          </form>

          <div className="flex items-center my-5 text-white">
            <hr className="flex-grow border-white/50" />
            <span className="mx-2 text-sm">Or continue with</span>
            <hr className="flex-grow border-white/50" />
          </div>

          <div className="w-3/5 mx-auto flex items-center justify-center bg-red-600 text-white py-2 rounded-full cursor-pointer hover:bg-red-700">
            <img
              src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Gmail_icon_%282020%29.svg/512px-Gmail_icon_%282020%29.svg.png"
              alt="Gmail"
              className="w-5 h-5 mr-2"
            />
            Gmail
          </div>

          <div className="text-center mt-5 text-sm text-white">
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

        <Link
          to="/About"
          className="mt-4 px-6 py-2 rounded-lg text-lg font-medium shadow-md bg-black hover:bg-white hover:text-black transition"
        >
          About
        </Link>
      </div>
    </div>
  );
}
