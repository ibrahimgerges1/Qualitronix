import React, { useEffect, useState } from "react";
import axios from "axios";
import { ToastContainer, toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

export default function Subscription() {
  const [userID, setUserID] = useState("");
  const [currentPlan, setCurrentPlan] = useState(null);
  const [subscriptionStatus, setSubscriptionStatus] = useState(null);
  const [loading, setLoading] = useState(false);
  const accessToken = localStorage.getItem("accessToken");

  useEffect(() => {
    const fetchUserProfile = async () => {
      if (!accessToken) {
        toast.error("Please log in to view subscription options.");
        return;
      }

      try {
        const response = await axios.get(
          "http://13.48.37.38:3000/user/profile",
          {
            headers: { Authorization: `Bearer ${accessToken}` },
          }
        );

        const { _id, username, plan, subscriptionStatus } = response.data.user;
        setUserID(_id);
        setCurrentPlan(plan || "basic");
        setSubscriptionStatus(subscriptionStatus || "none");
        localStorage.setItem("username", username);
        console.log("User profile:", response.data);
      } catch (error) {
        console.error("Error fetching user profile:", error);
        toast.error("Failed to load user profile. Please try again.");
      }
    };

    fetchUserProfile();
  }, [accessToken]);

  const handleSelect = async (plan) => {
    if (!userID) {
      toast.error("User ID not found. Please log in again.");
      return;
    }

    if (plan === currentPlan && subscriptionStatus === "subscribed") {
      toast.info(`You are already on the ${plan} plan.`);
      return;
    }

    setLoading(true);
    try {
      const endpoint =
        subscriptionStatus === "subscribed"
          ? "http://13.48.37.38:3000/subscription/upgrade"
          : "http://13.48.37.38:3000/subscription/checkout";

      const response = await axios.post(endpoint, { userId: userID, plan });

      const checkoutUrl = response.data.url;
      if (checkoutUrl) {
        window.location.href = checkoutUrl;
      } else {
        toast.error("Checkout URL not found. Please try again.");
      }
    } catch (error) {
      console.error("Error:", error);
      toast.error(
        error.response?.data?.error ||
          "Failed to process subscription. Please try again."
      );
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = async () => {
    if (!userID) {
      toast.error("User ID not found. Please log in again.");
      return;
    }

    if (subscriptionStatus !== "subscribed") {
      toast.info("You have no active subscription to cancel.");
      return;
    }

    if (!window.confirm("Are you sure you want to cancel your subscription?")) {
      return;
    }

    setLoading(true);
    try {
      const response = await axios.post(
        "http://13.48.37.38:3000/subscription/cancel",
        { userId: userID }
      );

      if (response.data.success) {
        setCurrentPlan("basic");
        setSubscriptionStatus("canceled");
        toast.success("Subscription canceled successfully.");
      }
    } catch (error) {
      console.error("Error canceling subscription:", error);
      toast.error(
        error.response?.data?.error ||
          "Failed to cancel subscription. Please try again."
      );
    } finally {
      setLoading(false);
    }
  };

  const planOptions = [
    {
      id: "diamond",
      title: "Diamond",
      description: "Batch(s) of 500 Photos/Day",
      price: "$300.00",
      color: "bg-cyan-200",
      highlight: true,
    },
    {
      id: "gold",
      title: "Gold",
      description: "Batch(s) of 200 Photos/Day",
      price: "$200.00",
      color: "bg-yellow-300",
    },
    {
      id: "silver",
      title: "Silver",
      description: "Batch(s) of 75 Photos/Day",
      price: "$100.00",
      color: "bg-slate-300",
    },
    {
      id: "basic",
      title: "Basic",
      description: "Batch(s) of 10 Photos/Day",
      price: "$10.00",
      color: "bg-gray-400",
    },
  ];

  return (
    <div className="w-full px-4 py-8 max-w-6xl mx-auto">
      <ToastContainer position="top-right" autoClose={3000} />
      <h2 className="text-3xl font-bold text-center text-white mb-8">
        Subscription Plans
      </h2>
      {currentPlan && (
        <p className="text-center  text-gray-200  text-lg mb-6">
          Your current plan:{" "}
          <span className="font-semibold capitalize">{currentPlan}</span> (
          {subscriptionStatus === "subscribed" ? "Active" : "Inactive"})
        </p>
      )}

      {/* Diamond Plan */}
      <div className="bg-black text-white p-6 rounded-2xl mb-10 shadow-lg">
        <div className="flex flex-col gap-4">
          <div className="w-full text-left">
            <div
              className={`py-3 px-4 rounded-2xl bg-cyan-200 text-black font-semibold ${
                currentPlan === "diamond" ? "opacity-50" : ""
              }`}
            >
              <h3 className="text-xl">Diamond</h3>
              <p>Batch(s) of 500 Photos/Day</p>
            </div>
          </div>
          <div className="text-start mb-0">
            <p className="text-sm">Monthly Price</p>
            <h3 className="text-2xl font-bold">$300.00</h3>
          </div>
          <hr className="text-light m-0" />
          <div className="w-full mt-0">
            <button
              onClick={() => handleSelect("diamond")}
              disabled={currentPlan === "diamond" || loading}
              className={`w-full px-6 py-2 button-bg text-black font-medium rounded-lg transition ${
                currentPlan === "diamond" || loading
                  ? "opacity-50 cursor-not-allowed"
                  : "hover:bg-gray-200"
              }`}
            >
              {loading ? "Processing..." : "Select"}
            </button>
          </div>
        </div>
      </div>

      {/* Other Plans */}
      <h3 className="text-2xl text-center text-black mb-6">Other Plans</h3>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {planOptions
          .filter((plan) => plan.id !== "diamond")
          .map((plan) => (
            <div
              key={plan.id}
              className="bg-black text-white p-3 rounded-2xl shadow-md flex flex-col"
            >
              <div
                className={`rounded-2xl p-4 mb-4 ${plan.color} text-black ${
                  currentPlan === plan.id ? "opacity-50" : ""
                }`}
              >
                <h3 className="text-xl font-bold">{plan.title}</h3>
                <p>{plan.description}</p>
              </div>
              <div className="mb-0">
                <p className="text-sm">Monthly Price</p>
                <h3 className="text-xl font-bold">{plan.price}</h3>
              </div>
              <hr className="text-light" />
              <button
                onClick={() => handleSelect(plan.id)}
                disabled={currentPlan === plan.id || loading}
                className={`w-full px-4 py-2 button-bg text-black font-medium rounded-lg transition ${
                  currentPlan === plan.id || loading
                    ? "opacity-50 cursor-not-allowed"
                    : "hover:bg-gray-200"
                }`}
              >
                {loading ? "Processing..." : "Select"}
              </button>
            </div>
          ))}
      </div>

      {/* Cancel Subscription */}
      {subscriptionStatus === "subscribed" && (
        <div className="mt-8 text-center rounded-lg ">
          <button
            onClick={handleCancel}
            disabled={loading}
            className={`px-6 py-2 bg-red-600 text-white font-medium rounded-lg transition border-amber-50 ${
              loading ? "opacity-50 cursor-not-allowed" : "hover:bg-red-700"
            }`}
          >
            {loading ? "Processing..." : "Cancel Subscription"}
          </button>
        </div>
      )}
    </div>
  );
}
