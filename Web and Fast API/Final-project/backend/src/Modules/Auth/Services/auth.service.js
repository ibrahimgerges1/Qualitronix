import User from "../../../DB/models/users.model.js";
import bcrypt, { compare, compareSync, hashSync } from "bcrypt";
import { encryption } from "../../../utils/encryption.utils.js";
import {
  emitter,
  sendEmailService,
} from "../../../Services/send-email.service.js";
import path from "path";
import jwt from "jsonwebtoken";
import { v4 as uuidv4 } from "uuid";
import BlackListTokens from "../../../DB/models/black-list-tokens.model.js";
import { emailTemplate } from "../../../utils/emailtemplate.utils.js";

export const signUpService = async (req, res) => {
    const { email, password, confirmPassword, username, phone, age } = req.body;
  
    if (password !== confirmPassword)
      return res.status(409).json({ message: "Passwords do not match" });
  
    const isEmailExists = await User.findOne({ email });
    if (isEmailExists)
      return res.status(409).json({ message: "Email already exists" });
  
    const hashedPassword = hashSync(password, +process.env.SALT);
    const encryptedPhone = await encryption({
      value: phone,
      secretKey: process.env.ENCRYPTED_KEY,
    });
  
    const emailToken = jwt.sign({ email }, process.env.JWT_SECRET, {
      expiresIn: "40m",
    });
    const confirmEmailLink = `${req.protocol}://${req.headers.host}/auth/verify/${emailToken}`;
  
    // Use emailTemplate for the email body
    const emailBody = emailTemplate({
      subject: "Verify your email",
      confirmEmailLink,
      message: "Please verify your email to activate your account.",
    });
  
    emitter.emit("sendEmail", {
      to: email,
      subject: "Verify your email",
      html: emailBody,
    });
  
    const user = await User.create({
      email,
      password: hashedPassword,
      username,
      phone: encryptedPhone,
      age,
    });
  
    if (!user)
      return res
        .status(500)
        .json({ message: "User creation failed, try again later" });
  
    return res.status(201).json({ message: "User created successfully", user });
  };
  
export const verifyEmailService = async (req, res) => {
  const { emailToken } = req.params;
  const decodedData = jwt.verify(emailToken, process.env.JWT_SECRET); // { email: 'yousefadel.dev@gmail.com', iat: 1737572997 }

  const user = await User.findOneAndUpdate(
    { email: decodedData.email },
    { isEmailVerified: true },
    { new: true }
  ); // new:true >>> return the document after updating
  if (!user)
    return res.status(404).json({ message: "Error verfiying the user" });

  return res.status(200).json({ message: "User verified", user });
};

export const signInService = async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email });
  if (!user)
    return res.status(404).json({ message: "Invalid email or password" });

  // compare hashed passwords, compare the input password after hashing it with the stored hashed password and internally removes the salt rounds to compare correctly
  const isPasswordMatch = compareSync(password, user.password);
  if (!isPasswordMatch)
    return res.status(404).json({ message: "Invalid email or password" });

  // generate access token to verify user authentication
  const accessToken = jwt.sign(
    { _id: user._id, email: user.email },
    process.env.JWT_SECRET_LOGIN,
    { expiresIn: "1h", jwtid: uuidv4() }
  );
  // generate refresh token so we can generate new access tken through it
  const refreshToken = jwt.sign(
    { _id: user._id, email: user.email },
    process.env.JWT_SECRET_REFRESH,
    { expiresIn: "2d", jwtid: uuidv4() }
  );

  return res
    .status(200)
    .json({
      message: "User logged in successfully",
      accessToken,
      refreshToken,
    });
};

export const refreshTokenService = async (req, res) => {
  const { refreshtoken } = req.headers;
  const decodedData = jwt.verify(refreshtoken, process.env.JWT_SECRET_REFRESH);

  const isRefreshTokenBlackListed = await BlackListTokens.findOne({
    tokenId: decodedData.jti,
  });
  if (isRefreshTokenBlackListed)
    return res.status(401).json({ message: "Token is blacklisted" });

  const accessToken = jwt.sign(
    { _id: decodedData._id, email: decodedData.email },
    process.env.JWT_SECRET_LOGIN,
    { expiresIn: "1h", jwtid: uuidv4() }
  );

  res
    .status(200)
    .json({ message: "Token refreshed successfully", accessToken });
};

export const signOutService = async (req, res) => {
  const { accesstoken, refreshtoken } = req.headers;
  const decodedAccessToken = jwt.verify(
    accesstoken,
    process.env.JWT_SECRET_LOGIN
  );
  const decodedRefreshToken = jwt.verify(
    refreshtoken,
    process.env.JWT_SECRET_REFRESH
  );

  await BlackListTokens.insertMany([
    {
      tokenId: decodedAccessToken.jti,
      expiryDate: decodedAccessToken.exp,
    },
    {
      tokenId: decodedRefreshToken.jti,
      expiryDate: decodedRefreshToken.exp,
    },
  ]);
  return res.status(200).json({ message: "User signed out successfully" });
};

export const forgetPasswordService = async (req, res) => {
  const { email } = req.body;

  const user = await User.findOne({ email });
  if (!user) {
    return res.status(404).json({ message: "This email is not registered" });
  }

  const otp = Math.floor(Math.random() * 10000); // generating random otp

  emitter.emit("sendEmail", {
    to: user.email, // single source of truth
    subject: "Reset your password",
    html: `
            <p>Use this OTP ${otp} to reset your password</p>
        `,
  });

  const hashedOtp = hashSync(otp.toString(), +process.env.SALT);
  user.otp = hashedOtp;
  await user.save(); // better case to use save() cause we already have the user

  return res.status(200).json({ message: "OTP sent successfully" });
};

export const resetPasswordService = async (req, res) => {
  const { email, otp, password, confirmPassword } = req.body;

  if (password !== confirmPassword) {
    return res
      .status(409)
      .json({ message: "Password and confirm password does not match" });
  }
  const user = await User.findOne({ email });
  if (!user) {
    return res.status(404).json({ message: "This email is not registered" });
  }

  const isOtpMatch = compareSync(otp, user.otp);
  if (!isOtpMatch) {
    return res.status(401).json({ message: "Invalid OTP" });
  }
  const hashedPassword = hashSync(password, +process.env.SALT);
  await User.updateOne(
    { email },
    { password: hashedPassword, $unset: { otp: "" } }
  ); // deleting otp from the database document, beacuse it is one time use
  return res.status(200).json({ message: "Password reset successfully" });
};
