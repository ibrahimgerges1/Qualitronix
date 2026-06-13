import Joi from "joi";




export const updatePasswordSchema = {
    body: Joi.object({
        oldPassword: Joi.string().regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*])[A-Za-z\d@$!%*]{8,}$/ ),
        newPassword: Joi.string().regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*])[A-Za-z\d@$!%*]{8,}$/ ),
        confirmNewPassword: Joi.string().valid(Joi.ref('newPassword'))
    })
    .options({presence: 'required'})  
}



export const updateProfileSchema = {
    body: Joi.object({
        username: Joi.string().alphanum().messages({
            'string.alphanum': 'Username must be alphanumeric and contain only a-z, A-Z, 0-9'
        }),
        email: Joi.string().email({
            tlds: {
                allow: ['com', 'net'],
            },
            maxDomainSegments: 2        
        }),
        phone: Joi.string(),
        age: Joi.number().max(100),
        profileImage: Joi.string(),
        dateOfBirth: Joi.date(),
        permanentAddress: Joi.string(),
        postalCode: Joi.string(),
        presentAddress: Joi.string(),
        city: Joi.string(),
        country: Joi.string()
    })
    .options({ presence: 'optional' })  
}
