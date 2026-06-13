import { Router } from "express";
import { listUsersService, profileService, updatePasswordService, updateProfileService } from "./services/profile.service.js";
import { authenticationMiddleware, checkRefreshToken } from "../../Middleware/authentication.middleware.js";
import { errorHandler } from "../../Middleware/error-handler.middleware.js";
import { validationMiddleware } from "../../Middleware/validation.middleware.js";
import { updatePasswordSchema, updateProfileSchema } from "../../Validators/profile.schema.js";

const userController = Router();

userController.use(errorHandler(authenticationMiddleware()));

userController.get('/profile', errorHandler(profileService));

userController.patch('/updatePassword', errorHandler(validationMiddleware(updatePasswordSchema)), errorHandler(checkRefreshToken()), errorHandler(updatePasswordService));

userController.put('/updateProfile', errorHandler(validationMiddleware(updateProfileSchema)), errorHandler(updateProfileService));

userController.get('/listUsers', errorHandler(listUsersService));

export default userController;