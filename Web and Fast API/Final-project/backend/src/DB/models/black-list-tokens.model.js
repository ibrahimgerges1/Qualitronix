import mongoose from "mongoose";




const blackListToken_Schema = new mongoose.Schema({
    tokenId: {
        type: String,
        required: true,
        unique: true
    },
    expiryDate: {
        type: String,
        require: true
    }
}, {timestamps: true})


const BlackListTokens = mongoose.models.BlackListTokens || mongoose.model('BlackListTokens', blackListToken_Schema)

export default BlackListTokens