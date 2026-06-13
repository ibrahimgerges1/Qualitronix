import React, { useState } from "react";
import { Navigate } from "react-router-dom";

export default function ProtectedRoute(props) {
  if (localStorage.getItem("accessToken")) {
    return props.children;
  } else {
    return <Navigate to={"/Login"} />;
  }
}
