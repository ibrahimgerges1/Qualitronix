import Stripe from "stripe";
import mongoose from "mongoose";
import User from "../../../DB/models/users.model.js";
import dotenv from "dotenv";
dotenv.config();

/* ----------  Stripe ---------- */
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: "2024-04-10",
});

/* ----------  Plans ---------- */
export const PLANS = {
  basic:   { priceId: "price_1QvNboJraeAEtfLfmlXv17lR", photosPerDay: 10 },
  silver:  { priceId: "price_1QvNcxJraeAEtfLftl5v8QJU", photosPerDay: 75 },
  gold:    { priceId: "price_1QvNBSJraeAEtfLfxlms1j5j", photosPerDay: 200 },
  diamond: { priceId: "price_1QvNdpJraeAEtfLfhpUuBK6A", photosPerDay: 500 },
};

/* ===================================================================== */
/* 1. createCheckoutSession                                              */
/* ===================================================================== */
export const createCheckoutSession = async (req, res) => {
  const { userId, plan } = req.body;

  /* Validate input ---------------------------------------------------- */
  if (!PLANS[plan]) {
    console.error("Invalid plan selected:", plan);
    return res.status(400).json({ error: "Invalid plan selected" });
  }
  if (!mongoose.Types.ObjectId.isValid(userId)) {
    console.error("Invalid user ID:", userId);
    return res.status(400).json({ error: "Invalid user ID" });
  }

  const user = await User.findById(userId);
  if (!user) {
    console.error("User not found for ID:", userId);
    return res.status(404).json({ error: "User not found" });
  }

  /* Build absolute URLs without double slashes ----------------------- */
  const FRONTEND = (process.env.FRONTEND_URL || "").replace(/\/+$/, "");

  try {
    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      payment_method_types: ["card"],
      customer_email: user.email,
      client_reference_id: userId.toString(),
      metadata: { plan },
      line_items: [{ price: PLANS[plan].priceId, quantity: 1 }],
      success_url: `${FRONTEND}/payment-success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${FRONTEND}/payment-failed`,
    });

    return res.json({ success: true, sessionId: session.id, url: session.url });
  } catch (error) {
    console.error("Stripe session creation failed:", error.message);
    return res.status(500).json({ error: "Failed to create checkout session" });
  }
};

/* ===================================================================== */
/* 2. checkSessionStatus                                                 */
/* ===================================================================== */
export const checkSessionStatus = async (req, res) => {
  const { sessionId } = req.query;


  if (!sessionId) {
    console.error("Session ID is missing");
    return res.status(400).json({ error: "Session ID is required" });
  }

  try {
    const session = await stripe.checkout.sessions.retrieve(sessionId);

    if (session.payment_status === "paid" && session.status === "complete") {
      const userId = session.client_reference_id;
      const plan = session.metadata?.plan;

      if (!userId || !plan || !PLANS[plan]) {
        console.error("Invalid session data:", { userId, plan });
        return res.status(400).json({ error: "Invalid session data" });
      }

      const user = await User.findByIdAndUpdate(
        userId,
        {
          isPremium: true,
          subscriptionStatus: "subscribed",
          subscriptionDate: new Date(),
          plan,
          photosPerDay: PLANS[plan].photosPerDay,
          stripeCustomerId: session.customer,
          stripeSubscriptionId: session.subscription,
        },
        { new: true, runValidators: true }
      );

      if (!user) {
        console.error("User not found for ID:", userId);
        return res.status(404).json({ error: "User not found" });
      }

      return res.json({ success: true, message: "Subscription updated", user });
    } else {
      console.error("Session not completed:", {
        payment_status: session.payment_status,
        status: session.status
      });
      return res.status(400).json({ error: "Payment not completed or session expired" });
    }
  } catch (error) {
    console.error("Failed to check session status:", error.message);
    return res.status(500).json({ error: "Failed to verify session status" });
  }
};

/* ===================================================================== */
/* 3. upgradeSubscription                                                */
/* ===================================================================== */
export const upgradeSubscription = async (req, res) => {
  const { userId, plan } = req.body;


  /* Validate input ---------------------------------------------------- */
  if (!PLANS[plan]) {
    console.error("Invalid plan selected:", plan);
    return res.status(400).json({ error: "Invalid plan selected" });
  }
  if (!mongoose.Types.ObjectId.isValid(userId)) {
    console.error("Invalid user ID:", userId);
    return res.status(400).json({ error: "Invalid user ID" });
  }

  const user = await User.findById(userId);
  if (!user) {
    console.error("User not found for ID:", userId);
    return res.status(404).json({ error: "User not found" });
  }

  /* Cancel existing subscription if it exists ------------------------- */
  if (user.stripeSubscriptionId) {
    try {
      // Verify subscription exists
      await stripe.subscriptions.retrieve(user.stripeSubscriptionId);
      await stripe.subscriptions.cancel(user.stripeSubscriptionId);
    } catch (error) {
      console.error("Subscription check/cancel failed:", error.message);
      if (error.code === "resource_missing" || error.message.includes("No such subscription")) {
        // Clear invalid subscription ID
        await User.findByIdAndUpdate(userId, { stripeSubscriptionId: null });
      } else {
        return res.status(500).json({ error: "Failed to cancel existing subscription" });
      }
    }
  }

  /* Build absolute URLs without double slashes ----------------------- */
  const FRONTEND = (process.env.FRONTEND_URL || "").replace(/\/+$/, "");

  /* Create new checkout session --------------------------------------- */
  try {
    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      payment_method_types: ["card"],
      customer_email: user.email,
      client_reference_id: userId.toString(),
      metadata: { plan },
      line_items: [{ price: PLANS[plan].priceId, quantity: 1 }],
      success_url: `${FRONTEND}/payment-success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${FRONTEND}/payment-failed`,
    });

    return res.json({ success: true, sessionId: session.id, url: session.url });
  } catch (error) {
    console.error("Stripe session creation failed for upgrade:", error.message);
    return res.status(500).json({ error: "Failed to create upgrade checkout session" });
  }
};

/* ===================================================================== */
/* 4. cancelSubscription                                                 */
/* ===================================================================== */
export const cancelSubscription = async (req, res) => {
  const { userId } = req.body;


  if (!mongoose.Types.ObjectId.isValid(userId)) {
    console.error("Invalid user ID:", userId);
    return res.status(400).json({ error: "Invalid user ID" });
  }

  const user = await User.findById(userId);
  if (!user || !user.stripeSubscriptionId) {
    console.error("User or subscription not found:", userId);
    return res.status(404).json({ error: "User or subscription not found" });
  }

  try {
    // Verify subscription exists
    await stripe.subscriptions.retrieve(user.stripeSubscriptionId);
    await stripe.subscriptions.cancel(user.stripeSubscriptionId);

    const updatedUser = await User.findByIdAndUpdate(
      userId,
      {
        isPremium: false,
        subscriptionStatus: "canceled",
        plan: "basic",
        photosPerDay: PLANS.basic.photosPerDay,
        stripeSubscriptionId: null,
      },
      { new: true, runValidators: true }
    );

    return res.json({ success: true, message: "Subscription canceled", user: updatedUser });
  } catch (error) {
    console.error("Subscription check/cancel failed:", error.message);
    if (error.code === "resource_missing" || error.message.includes("No such subscription")) {
      // Clear invalid subscription ID
      const updatedUser = await User.findByIdAndUpdate(
        userId,
        {
          isPremium: false,
          subscriptionStatus: "canceled",
          plan: "basic",
          photosPerDay: PLANS.basic.photosPerDay,
          stripeSubscriptionId: null,
        },
        { new: true, runValidators: true }
      );
      return res.json({ success: true, message: "Subscription canceled", user: updatedUser });
    }
    return res.status(500).json({ error: "Failed to cancel subscription" });
  }
};