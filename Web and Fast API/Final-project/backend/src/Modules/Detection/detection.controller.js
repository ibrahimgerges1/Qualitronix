import { Router } from "express";
import multer from "multer";
import { detectDefects } from "./services/detection.service.js";
import DetectionResult from "../../DB/models/detectionResult.model.js";
import { authenticationMiddleware } from "../../Middleware/authentication.middleware.js";
import { errorHandler } from "../../Middleware/error-handler.middleware.js";
import cloudinary from "cloudinary";
import { CloudinaryStorage } from "multer-storage-cloudinary";
import dotenv from "dotenv";
import DailySummary from "../../DB/models/DailySummery.model.js";

dotenv.config();

const detectionController = Router();

// 🔹 Derive a stable base‑URL for annotated images served by YOLO API
const API_URL = process.env.API_URL || "";
const API_BASE_URL = API_URL.includes("/batch-predict")
  ? API_URL.split("/batch-predict")[0]
  : API_URL;

// 🔹 Cloudinary configuration
cloudinary.v2.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// 🔹 Multer ⇢ Cloudinary storage
const storage = new CloudinaryStorage({
  cloudinary: cloudinary.v2,
  params: {
    folder: "pcb-defects",
    format: async () => "png",
    public_id: (req, file) => file.originalname.split(".")[0],
  },
});

const upload = multer({ storage });

// Apply authentication & wrap each handler with a top‑level errorHandler
// so that all async errors propagate nicely to the Express error pipeline.
detectionController.use(errorHandler(authenticationMiddleware()));

/* -------------------------------------------------------------------------
 * GET /remaining-uploads  – daily quota checker
 * ---------------------------------------------------------------------- */
detectionController.get(
  "/remaining-uploads",
  errorHandler(async (req, res) => {
    const user = req.authUser;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const uploadsToday = await DetectionResult.countDocuments({
      userId: user._id,
      createdAt: { $gte: today, $lt: tomorrow },
    });

    return res.status(200).json({
      remainingUploads: Math.max(user.photosPerDay - uploadsToday, 0),
    });
  })
);

/* -------------------------------------------------------------------------
 * POST /upload  – Bulk image upload & defect detection
 * ---------------------------------------------------------------------- */
detectionController.post(
  "/upload",
  upload.array("images"),
  errorHandler(async (req, res) => {
    try {
      const user = req.authUser;

      if (!req.files || req.files.length === 0) {
        return res.status(400).json({ message: "No images uploaded" });
      }

      /* ------------------------------ Daily quota enforcement */
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);

      const uploadsToday = await DetectionResult.countDocuments({
        userId: user._id,
        createdAt: { $gte: today, $lt: tomorrow },
      });

      const remainingUploads = user.photosPerDay - uploadsToday;
      const numImages = req.files.length;

      if (numImages > remainingUploads) {
        // Delete the just‑uploaded Cloudinary resources to avoid orphans
        const publicIds = req.files.map((f) => f.public_id);
        await cloudinary.v2.api.delete_resources(publicIds, {
          type: "upload",
          resource_type: "image",
        });

        return res.status(403).json({
          message: `You have only ${remainingUploads} uploads remaining today. Tried to upload ${numImages} images.`,
        });
      }

      /* ------------------------------ Detect defects */
      const imageUrls = req.files.map((f) => f.path);
      const detectionResults = await detectDefects(imageUrls);

      if (!detectionResults?.batch_results) {
        return res.status(500).json({
          message: "Detection API returned an invalid response",
        });
      }

      /* ------------------------------ Persist results */
      const savedResults = await Promise.all(
        detectionResults.batch_results.map(async (result) => {
          if (result.error) return undefined;
          return DetectionResult.create({
            userId: user._id,
            ...result,
            heatmap_url: result.heatmap_url
              ? `${API_BASE_URL}${result.heatmap_url}`
              : undefined,
            annotated_image_url: result.annotated_image_url
              ? `${API_BASE_URL}${result.annotated_image_url}`
              : undefined,
          });
        })
      );

      return res.status(200).json({
        message: "Detection completed and results stored.",
        results: savedResults.filter(Boolean),
      });
    } catch (error) {
      return res.status(500).json({
        message: "Error processing images",
        error: error.message,
      });
    }
  })
);

/* -------------------------------------------------------------------------
 * GET /results  – fetch a user's detection history
 * ---------------------------------------------------------------------- */
detectionController.get(
  "/results",
  errorHandler(async (req, res) => {
    try {
      const userId = req.authUser._id;
      const results = await DetectionResult.find({ userId }).sort({ createdAt: -1 });

      const updatedResults = results.map((r) => ({
        ...r.toObject(),
        heatmap_url: r.heatmap_url?.startsWith("http")
          ? r.heatmap_url
          : r.heatmap_url
          ? `${API_BASE_URL}${r.heatmap_url}`
          : undefined,
        annotated_image_url: r.annotated_image_url?.startsWith("http")
          ? r.annotated_image_url
          : r.annotated_image_url
          ? `${API_BASE_URL}${r.annotated_image_url}`
          : undefined,
      }));

      return res.status(200).json({
        message: "User-specific detection results retrieved",
        results: updatedResults,
      });
    } catch (error) {
      return res.status(500).json({
        message: "Error fetching results",
        error: error.message,
      });
    }
  })
);

/* -------------------------------------------------------------------------
 * GET /dashboard  – consolidated analytics (includes summary)
 * ---------------------------------------------------------------------- */
detectionController.get(
  "/dashboard",
  errorHandler(async (req, res) => {
    try {
      const userId = req.authUser._id;
      const results = await DetectionResult.find({ userId });

      /* ------------------------------ Aggregate stats */
      const defectCounts = {};
      let defectivePCBs = 0;
      let goodPCBs = 0;
      let totalDefects = 0;

      results.forEach((r) => {
        if (r.predictions.length) {
          defectivePCBs++;
          r.predictions.forEach(({ class_name }) => {
            defectCounts[class_name] = (defectCounts[class_name] || 0) + 1;
            totalDefects++;
          });
        } else {
          goodPCBs++;
        }
      });

      const defectPercentages = Object.entries(defectCounts).map(([name, count]) => ({
        name,
        percentage: ((count / (totalDefects || 1)) * 100).toFixed(2),
      }));

      const recentDefects = results
        .slice(-3)
        .reverse()
        .map((r, i) => ({
          pcb_id: `PCB #${i + 1}`,
          defects: r.predictions.map((p) => p.class_name),
          image_url: r.image_url,
          heatmap_url: r.heatmap_url?.startsWith("http") ? r.heatmap_url : `${API_BASE_URL}${r.heatmap_url}`,
          annotated_image_url: r.annotated_image_url?.startsWith("http")
            ? r.annotated_image_url
            : `${API_BASE_URL}${r.annotated_image_url}`,
        }));

      /* ------------------------------ 7‑day trend */
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      const rawWeekly = await DailySummary.find({
        userId,
        date: { $gte: sevenDaysAgo.toISOString().split("T")[0] },
      }).sort({ date: 1 });

      const weeklySummary = rawWeekly.map((d) => ({
        name: new Date(d.date).toLocaleDateString("en-US", { weekday: "short" }),
        faultRate: parseFloat(d.defective_percentage) || 0,
      }));

      /* ------------------------------ Persist today's summary for chart */
      const defectivePercentage = ((defectivePCBs / (goodPCBs + defectivePCBs || 1)) * 100).toFixed(2);
      await DailySummary.findOneAndUpdate(
        { userId, date: new Date().toISOString().split("T")[0] },
        { $set: { defective_percentage: defectivePercentage } },
        { upsert: true }
      );

      return res.status(200).json({
        summary: {
          defect_percentages: defectPercentages,
          defective_chart: [
            { name: "Good PCBs", value: goodPCBs },
            { name: "Defective PCBs", value: defectivePCBs },
          ],
          total_defects: totalDefects,
          recent_defects: recentDefects,
          weekly_summary: weeklySummary,
        },
      });
    } catch (error) {
      return res.status(500).json({
        message: "Error processing dashboard",
        error: error.message,
      });
    }
  })
);

export default detectionController;