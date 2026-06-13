import { compareSync, hashSync } from "bcrypt"
import BlackListTokens from "../../../DB/models/black-list-tokens.model.js"
import User from "../../../DB/models/users.model.js"
import { decryption, encryption } from "../../../utils/encryption.utils.js"
import jwt from 'jsonwebtoken'
import { emitter } from "../../../Services/send-email.service.js"




export const profileService = async (req, res) => {

    // get user data from the authentication middleware to verify that he is authenticated
    const {_id} = req.authUser
    const user = await User.findById(_id)
    if(!user)  return res.status(404).json({message: `User not found`})
    
    user.phone = await decryption({cipher: user.phone, secretKey: process.env.ENCRYPTED_KEY})
    return res.status(200).json({message: 'User found successfully', user})
}


export const updatePasswordService = async (req, res, next) => {
    
    const {_id} = req.authUser                                          // check that the user is loggedIn
    const {oldPassword, newPassword, confirmNewPassword} = req.body

    if(newPassword !== confirmNewPassword){
        return res.status(409).json({message: 'New password and confirm new password does not match'})
    }

    const user = await User.findById(_id)
    if(!user){
        return res.status(404).json({message: 'User not found'})
    }

    const isPasswordMatch = compareSync(oldPassword, user.password)
    if(!isPasswordMatch){
        return res.status(400).json({message: 'Invalid password'})
    }


    const hashedPassword = hashSync(newPassword, +process.env.SALT)
    user.password = hashedPassword
    await user.save()

    // revok user tokens by using blacklist
    await BlackListTokens.insertMany([req.authUser.token, req.refreshtoken])
    return res.status(200).json({message: 'Password updated successfully'})

}


export const updateProfileService = async (req, res) => {
    const { _id } = req.authUser;
    const { email, phone, username, age } = req.body;

    const user = await User.findById(_id);
    if (!user) {
        return res.status(404).json({ message: "User not found" });
    }

    if (age) user.age = age;
    if (phone) user.phone = await encryption({ value: phone, secretKey: process.env.ENCRYPTED_KEY });

    if (username) {
        const isUsernameExist = await User.findOne({ username });
        if (isUsernameExist && isUsernameExist._id.toString() !== _id) {
            return res.status(409).json({ message: "Username already taken" });
        }
        user.username = username;
    }

    if (email) {
        const isEmailExists = await User.findOne({ email });
        if (isEmailExists && isEmailExists._id.toString() !== _id) {
            return res.status(409).json({ message: "Email already exists" });
        }

        const token = jwt.sign({ email, userId: _id }, process.env.JWT_SECRET, { expiresIn: "1h" });
        const confirmationLink = `${req.protocol}://${req.headers.host}/auth/verify/${token}`;

        emitter.emit("sendEmail", {
            to: email,
            subject: "Verify your email",
            html: `<a href="${confirmationLink}">Click here to verify your email</a>`,
        });

        // Store the new email temporarily instead of overwriting the old one
        user.tempEmail = email; // Add this field to the user model
        user.isEmailVerified = false;
    }

    await user.save();
    return res.status(200).json({ message: "User Profile updated successfully" });
};



export const listUsersService = async (req, res) => {
    
    const users = await User.find()
    if(!users){
        return res.status(404).json({message: 'No users found'})
    }
    return res.status(200).json({message: 'Users found', users})

}