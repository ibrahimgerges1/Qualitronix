import CryptoJS from "crypto-js"


// {value, secretKey} = {}  named parameters better for many attributes functions, and empty object as default value if no object was sent to the function as parameter when calling it to prevent server error.
export const encryption = async ({value, secretKey} = {}) => {
    return CryptoJS.AES.encrypt(value, secretKey).toString()
}

export const decryption = async ({cipher, secretKey} = {}) => {
    return CryptoJS.AES.decrypt(cipher, secretKey).toString(CryptoJS.enc.Utf8)
}