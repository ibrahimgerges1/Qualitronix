import { useEffect } from "react";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import axios from "axios";

import Layout from "./Components/Layout/Layout";
import Login from "./Components/Login/Login";
import Register from "./Components/Register/Register";
import ProtectedRoute from "./Components/ProtectedRoute/ProtectedRoute";
import Dashboard from "./Components/Dashboard/Dashboard";
import Subscription from "./Components/Subscription/Subscription";
import History from "./Components/History/History";
import Settings from "./Components/Settings/Settings";
import ForgotPassword from "./Components/ForgotPassword/ForgotPassword";
import ResetPassword from "./Components/ResetPassword/ResetPassword";
import Error404 from "./Components/Error404/Error404";
import UpdateProfile from "./Components/UpdateProfile/UpdateProfile";
import Security from "./Components/Security/Security";
import PaymentSuccess from "./Components/PaymentSuccess/PaymentSuccess";

import {
  storeAccessToken,
  getLastTokenUpdateTime,
  getAccessToken,
} from "./utils/authUtils";

let isLoggingOut = false;

async function refreshAccessToken(refreshToken) {
  if (isLoggingOut) return null;

  try {
    const response = await axios.get("http://localhost:3000/auth/refreshToken", {
      headers: {
        refreshtoken: `${refreshToken}`,
      },
    });

    const newToken = response.data?.accessToken;
    return newToken;
  } catch (error) {
    console.error("Error refreshing access token:", error);
    return null;
  }
}

function App() {
  useEffect(() => {
    const refreshInterval = 60 * 60 * 1000; // 1 hour
    const logoutTimeout = 60 * 60 * 1000;   // 1 hour
    const staleThreshold = 60 * 60 * 1000;  // 1 hour

    const refreshToken = localStorage.getItem("refreshToken");

    // Check if last token update is too old
    const lastUpdateStr = localStorage.getItem("lastTokenUpdateTime");
    if (lastUpdateStr) {
      const lastUpdate = parseInt(lastUpdateStr);
      const timeDiff = Date.now() - lastUpdate;

      if (timeDiff > staleThreshold) {
        isLoggingOut = true;
        localStorage.clear();
        window.location.href = "/Login";
        return;
      }
    }

    const refreshTimer = setInterval(async () => {
      if (!refreshToken || isLoggingOut) return;

      const newToken = await refreshAccessToken(refreshToken);
      if (newToken && newToken !== getAccessToken()) {
        storeAccessToken(newToken);
      }
    }, refreshInterval);

    const checkTimer = setInterval(() => {
      const last = getLastTokenUpdateTime();
      if (last && Date.now() - last > logoutTimeout) {
        isLoggingOut = true;
        localStorage.clear();
        window.location.href = "/Login";
      }
    }, 60 * 1000);

    return () => {
      clearInterval(refreshTimer);
      clearInterval(checkTimer);
    };
  }, []);

  const router = createBrowserRouter([
    { path: "/ForgotPassword", element: <ForgotPassword /> },
    { path: "/ResetPassword", element: <ResetPassword /> },
    { path: "/Login", element: <Login /> },
    { path: "/Register", element: <Register /> },
    { path: "/payment-success", element: <PaymentSuccess /> },
    { path: "*", element: <Error404 /> },
    {
      path: "/",
      element: <Layout />,
      children: [
        {
          path: "/",
          element: (
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          ),
        },
        {
          path: "/Dashboard",
          element: (
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          ),
        },
        {
          path: "/Subscription",
          element: (
            <ProtectedRoute>
              <Subscription />
            </ProtectedRoute>
          ),
        },
        {
          path: "/History",
          element: (
            <ProtectedRoute>
              <History />
            </ProtectedRoute>
          ),
        },
        {
          path: "/Settings/",
          element: (
            <ProtectedRoute>
              <Settings />
            </ProtectedRoute>
          ),
          children: [
            { path: "Update-Profile", element: <UpdateProfile /> },
            { path: "Security", element: <Security /> },
          ],
        },
      ],
    },
  ]);

  return <RouterProvider router={router} />;
}

export default App;
