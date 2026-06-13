import Joi from "joi"


export const signUpSchema = {
  body: Joi.object({
    username: Joi.string().alphanum().messages({
      'string.alphanum': 'Username must be alphanumeric and contain only a-z, A-Z, 0-9',
    }),
    email: Joi.string().email({
      tlds: {
        allow: ['com', 'net'],
      },
      maxDomainSegments: 2,
    }),
    password: Joi.string()
      .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\w\s])[A-Za-z\d\W_]{8,}$/)
      .message(
        'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character.'
      ),
    confirmPassword: Joi.string()
      .valid(Joi.ref('password'))
      .messages({ 'any.only': 'Passwords do not match' }),
    phone: Joi.string(),
  }).options({ presence: 'required' }),
};


export const signInSchema = {
  body: Joi.object({
    email: Joi.string().email({
      tlds: {
        allow: ['com', 'net'],
      },
      maxDomainSegments: 2,
    }),
    password: Joi.string().min(1).messages({
      'string.empty': 'Password cannot be empty',
    }),
  }).options({ presence: 'required' }),
};


export const forgetPasswordSchema = {
    body: Joi.object({
        email: Joi.string().email({
            tlds:{
                allow: ['com', 'net'] ,
            },
            maxDomainSegments: 2        
        })
    })
    .options({presence: 'required'})
}


export const resetPasswordSchema = {
  body: Joi.object({
    email: Joi.string().email({
      tlds: {
        allow: ['com', 'net'],
      },
      maxDomainSegments: 2,
    }),
    password: Joi.string()
      .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\w\s])[A-Za-z\d\W_]{8,}$/)
      .messages({
        'string.pattern.base':
          'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character.',
      }),
    confirmPassword: Joi.string()
      .valid(Joi.ref('password'))
      .messages({ 'any.only': 'Passwords do not match' }),
    otp: Joi.number().messages({
      'number.base': 'OTP must be a number',
    }),
  }).options({ presence: 'required' }),
}
