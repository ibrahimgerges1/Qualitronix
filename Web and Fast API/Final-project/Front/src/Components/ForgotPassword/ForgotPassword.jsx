import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import axios from "axios";

export default function ForgotPassword() {
  const [email, setEmail] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState("");
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccess("");

    if (!email.trim()) {
      setError("Please enter your email address.");
      return;
    }

    setLoading(true);

    try {
      const response = await axios.patch(
        "http://13.48.37.38:3000/auth/forgetPassword",
        { email }
      );
      setSuccess("Reset link sent! Check your email.");
      setTimeout(() => {
        navigate("/ResetPassword");
      }, 2000);
    } catch (err) {
      setError(err.response?.data?.message || "Email not found");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col md:flex-row bg-cover bg-center" style={{ backgroundImage: "url('https://imgur.com/XJUGC3H.png')" }}>
      {/* Left Panel */}
      <div className="w-full md:w-1/2 flex flex-col justify-center items-center p-6 bg-gradient-to-t from-[#003021f0] to-[#009669d0]">
        <div className="w-full max-w-md bg-white/5 backdrop-blur-md rounded-2xl shadow-lg p-10 space-y-6">
          <div className="text-center">
            <img src="https://imgur.com/4YwzsaW.jpg" alt="Logo" className="w-20 mx-auto rounded-full shadow-md" />
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <input
                type="email"
                placeholder="Email Address"
                className="w-full p-3 rounded-md border border-white bg-transparent text-white placeholder-white/70 focus:outline-none focus:ring-2 focus:ring-amber-400"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              {error && (
                <p className="text-red-400 text-sm mt-2">{error}</p>
              )}
              {success && (
                <p className="text-green-500 text-sm mt-2">{success}</p>
              )}
            </div>

            <button
              type="submit"
              disabled={loading}
              className={`w-full py-3 rounded-full font-semibold transition text-white ${
                loading
                  ? "bg-blue-400 cursor-not-allowed"
                  : "bg-blue-600 hover:bg-blue-700"
              }`}
            >
              {loading ? "Sending..." : "Submit"}
            </button>

            <div className="text-center text-sm mt-4">
              <Link to="/Login" className="text-white underline">
                Remembered your Password? Click Here
              </Link>
            </div>
          </form>

          <div className="flex items-center my-6 text-white">
            <hr className="flex-grow border-white/50" />
            <span className="mx-2 text-sm">Or continue with</span>
            <hr className="flex-grow border-white/50" />
          </div>

          <div className="w-3/5 mx-auto flex items-center justify-center bg-gradient-to-br from-emerald-600 via-emerald-600 to-amber-400 text-white py-2 rounded-full cursor-pointer hover:opacity-90">
            <img
              src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Gmail_icon_%282020%29.svg/512px-Gmail_icon_%282020%29.svg.png"
              alt="Gmail"
              className="w-5 h-5 mr-2"
            />
            Gmail
          </div>

          <div className="text-center mt-6 text-sm text-white">
            Don’t have an account?
            <Link to="/Register" className="text-amber-300 ml-1 font-semibold hover:underline">
              Register here
            </Link>
          </div>
        </div>

        <div className="mt-12 text-center text-white">
          <p className="mb-3 text-lg font-medium">Get the Application</p>
          <div className="flex justify-center gap-6">
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
