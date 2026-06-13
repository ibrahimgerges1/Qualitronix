import { Router } from "express";
import {  forgetPasswordService, refreshTokenService, resetPasswordService, signInService, signOutService, signUpService, verifyEmailService } from "./Services/auth.service.js";
import { errorHandler } from "../../Middleware/error-handler.middleware.js";
import { validationMiddleware } from "../../Middleware/validation.middleware.js";
import { forgetPasswordSchema, resetPasswordSchema, signInSchema, signUpSchema } from "../../Validators/auth.schema.js";

const authController = Router()


authController.post('/signUp', errorHandler( validationMiddleware(signUpSchema) ), errorHandler( signUpService ))

authController.post('/signIn', errorHandler( validationMiddleware(signInSchema) ), errorHandler( signInService ))

authController.get('/verify/:emailToken', errorHandler( verifyEmailService ))

authController.get('/refreshToken', errorHandler( refreshTokenService ))

authController.get('/signOut', errorHandler( signOutService ))

authController.patch('/forgetPassword', errorHandler( validationMiddleware(forgetPasswordSchema) ), errorHandler( forgetPasswordService ))

authController.put('/resetPassword', errorHandler( validationMiddleware(resetPasswordSchema) ), errorHandler( resetPasswordService ))


export default authController