import express from "express";
import { config } from "dotenv";
import cors from "cors";
import path from "path";
import { fileURLToPath } from "url";

import { database_connection } from "./DB/connection.js";
import routerHandler from "./utils/router-handler.utils.js";

import subscriptionRouter from "./Modules/Subscription/subscription.controller.js";

config(); // Load .env

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const bootstrap = async () => {
  await database_connection();

  const app = express();
  app.use(cors({ origin: "*" }));
  app.use(express.json());
  app.use("/subscription", subscriptionRouter);

  /* Static files and fallback handlers */
  app.use(express.static("public"));
  routerHandler(app);

  const port = process.env.PORT || 3000;
  app.listen(port, () => console.log(`🚀 Server is running on port ${port}`));
};

export default bootstrap;