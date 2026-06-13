import jwt from "jsonwebtoken";
import BlackListTokens from "../DB/models/black-list-tokens.model.js";
import User from "../DB/models/users.model.js";

// Middleware to authenticate users
export const authenticationMiddleware = () => {
    return async (req, res, next) => {
        const accessToken = req.headers.authorization?.split(" ")[1] || req.headers.accesstoken;
        
        if (!accessToken) {
            return res.status(400).json({ message: "No access token found, please login" });
        }

        try {
            const decodedData = jwt.verify(accessToken, process.env.JWT_SECRET_LOGIN);

            const isTokenBlackListed = await BlackListTokens.findOne({ tokenId: decodedData.jti });
            if (isTokenBlackListed) {
                return res.status(401).json({ message: "Token is blacklisted, please login" });
            }

            const user = await User.findById(decodedData._id, "-password -__v"); // Ensure photosPerDay is included
            if (!user) {
                return res.status(401).json({ message: "User not found, please sign up" });
            }

            req.authUser = {
                ...user._doc,
                token: {
                    tokenId: decodedData.jti,
                    expiryDate: decodedData.exp,
                },
            };

            next();
        } catch (error) {
            return res.status(401).json({ message: "Invalid or expired access token" });
        }
    };
};

// Middleware to verify refresh token
export const checkRefreshToken = () => {
  return async (req, res, next) => {
    try {
      const { refreshtoken } = req.headers;
      if (!refreshtoken) {
        return res
          .status(401)
          .json({ message: "Refresh token required, please login" });
      }

      // Verify refresh token
      const decodedData = jwt.verify(
        refreshtoken,
        process.env.JWT_SECRET_REFRESH
      );

      // Check if token is blacklisted
      const isTokenBlackListed = await BlackListTokens.findOne({
        tokenId: decodedData.jti,
      });

      if (isTokenBlackListed) {
        return res
          .status(401)
          .json({ message: "Refresh token is blacklisted, please login" });
      }

      // Attach refresh token data to request
      req.refreshtoken = {
        tokenId: decodedData.jti,
        expiryDate: decodedData.exp,
      };

      next();
    } catch (error) {
      return res
        .status(401)
        .json({ message: "Invalid or expired refresh token" });
    }
  };
};
