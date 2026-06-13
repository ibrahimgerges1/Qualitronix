import axios from "axios";
import dotenv from "dotenv";

dotenv.config();

const API_URL = process.env.API_URL;

export const detectDefects = async (imageUrls) => {
  try {
    if (!API_URL) {
      throw new Error("❌ API_URL is not defined in environment variables.");
    }

    if (!Array.isArray(imageUrls) || imageUrls.length === 0) {
      throw new Error("❌ No valid image URLs provided.");
    }

    console.log("🔹 Preparing JSON payload with image URLs...");
    const payload = { images: imageUrls };

    console.log("🔹 Payload:", JSON.stringify(payload, null, 2));

    const response = await axios.post(API_URL, payload, {
      headers: {
        "Content-Type": "application/json",
      },
    });

    if (!response || !response.data) {
      throw new Error("❌ No response data received from API.");
    }

    console.log("✅ Detection API Response:", response.data);
    return response.data;
  } catch (error) {
    if (error.response) {
      console.error("❌ API Error:", error.response.data);
    } else if (error.request) {
      console.error("❌ Network Error: No response received from API.");
    } else {
      console.error("❌ Unexpected Error:", error.message);
    }
    throw new Error("Detection API request failed.");
  }
};