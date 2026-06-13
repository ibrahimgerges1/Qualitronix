import mongoose from "mongoose";

const dailySummarySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  date: { type: String, required: true },
  defective_percentage: { type: Number, required: true },
});

const DailySummary = mongoose.model("DailySummary", dailySummarySchema);

export default DailySummary;
