import express from "express";
import { createCheckoutSession, checkSessionStatus, upgradeSubscription, cancelSubscription } from "./services/subscription.service.js";

const router = express.Router();

router.post("/checkout", createCheckoutSession);
router.get("/session-status", checkSessionStatus);
router.post("/upgrade", upgradeSubscription);
router.post("/cancel", cancelSubscription);

export default router;