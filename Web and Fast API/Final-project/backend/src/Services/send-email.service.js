import nodemailer from 'nodemailer'
import { EventEmitter } from 'node:events'
import { emailTemplate } from '../utils/emailtemplate.utils.js'

export const sendEmailService = async ({ to, subject, message, confirmEmailLink, html , attachments = [] } = {}) => {
    try {
        const transporter = nodemailer.createTransport({
            host: 'smtp.gmail.com',  // smtp.gmail.com || localhost
            port: 465,
            secure: true,
            auth: {
                user: process.env.EMAIL_USER,  // account credentials that the email will be sent from
                pass: process.env.PASSWORD_USER
            },
            tls:{
                rejectUnauthorized: false  // Ignore SSL errors (for testing)
            }   
        })

        // If `html` is not provided, generate email content using `emailTemplate`
        const emailContent = html || emailTemplate({ message, subject, confirmEmailLink });

        const info = await transporter.sendMail({
            from: `"Qualitronix - No Reply" <${process.env.EMAIL_USER}>`, // sender email
            to,
            subject,
            html: emailContent,
            attachments
        })

        return info;

    } catch (error) {
        console.error("Error sending email:", error);
        return error;
    }
}

// Event emitter for sending non-critical emails in the background
export const emitter = new EventEmitter();

emitter.on('sendEmail', ({ to, subject, message, confirmEmailLink, html, attachments }) => {
    sendEmailService({
        to,
        subject,
        message,
        confirmEmailLink,
        html,
        attachments
    });
});
