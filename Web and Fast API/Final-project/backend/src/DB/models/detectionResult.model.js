import mongoose from "mongoose";

const detectionResultSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true, // Ensure every detection is linked to a user
    },
    filename: String,
    predictions: [
      {
        class_id: Number,
        class_name: String,
        confidence: Number,
        x_min: Number,
        y_min: Number,
        x_max: Number,
        y_max: Number,
      },
    ],
    image_url: String,
    heatmap_url: String,
    annotated_image_url: String,
  },
  { timestamps: true }
);

const DetectionResult = mongoose.model(
  "DetectionResult",
  detectionResultSchema
);
export default DetectionResult;
