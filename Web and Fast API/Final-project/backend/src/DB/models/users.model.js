import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: [true, "Username is required"],
      lowercase: true,
      trim: true,
      unique: [true, "Username already taken"],
      minLength: [3, "Username must be at least 3 characters long"],
      maxLength: [20, "Username must be at most 20 characters long"],
    },
    email: {
      type: String,
      required: [true, "Email is required"],
      unique: [true, "Email is already taken"],
    },
    password: {
      type: String,
      required: [true, "Password is required"],
    },
    phone: {
      type: String,
      required: [true, "Phone number is required"],
    },
    age: {
      type: Number,
      min: [18, "Age must be at least 18 years old to register"],
      max: [100, "Age must be at most 100 years old to register"],
    },
    dateOfBirth: {
      type: Date,
      required: false,
    },
    permanentAddress: {
      type: String,
      required: false,
    },
    postalCode: {
      type: String,
      required: false,
    },
    presentAddress: {
      type: String,
      required: false,
    },
    city: {
      type: String,
      required: false,
    },
    country: {
      type: String,
      required: false,
    },
    profileImage: {
      type: String,
      required: false,
    },
    isDeleted: {
      type: Boolean,
      default: false,
    },
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    stripeCustomerId: { type: String },
    stripeSubscriptionId: { type: String },
    otp: String,
    isPremium: { type: Boolean, default: false },
    subscriptionDate: Date,
    subscriptionStatus: {
      type: String,
      enum: ["subscribed", "canceled"],
      default: "canceled",
    },
    plan: {
      type: String,
      enum: ["basic", "silver", "gold", "diamond"],
      default: "basic",
    },
    photosPerDay: { type: Number, default: 10 }, // Default is basic plan
  },
  {
    timestamps: true,
  }
);

const User = mongoose.models.User || mongoose.model("User", userSchema);

export default User;