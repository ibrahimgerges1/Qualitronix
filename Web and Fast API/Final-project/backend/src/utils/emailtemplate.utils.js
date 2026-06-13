export const emailTemplate = ({ username, message, subject, confirmEmailLink }) => {
    return `<!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>${subject || "Qualitronix - Email Verification"}</title>
      <style>
          @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap');
  
          body {
              font-family: 'Poppins', sans-serif;
              margin: 0;
              padding: 0;
              background: #f9f9f9;
              color: #2c3e50;
              text-align: center;
          }
  
          .container {
              background: #ffffff;
              padding: 50px;
              border-radius: 20px;
              box-shadow: 0 8px 30px rgba(0, 0, 0, 0.1);
              max-width: 480px;
              margin: 60px auto;
              border: 1px solid #27ae60;
          }
  
          .logo img {
              width: 90px;
              height: 90px;
              border-radius: 50%;
              margin-bottom: 8px;
          }
  
          .logo-name img {
              width: 180px;
              margin-bottom: 8px;
          }
  
          h1 {
              font-size: 24px;
              margin-bottom: 20px;
              color: #229954;
              font-weight: 600;
          }
  
          p {
              font-size: 14px;
              color: #2c3e50;
              margin-bottom: 20px;
              line-height: 1.6;
          }
  
          .cta-button {
              background: #27ae60;
              color: #ffffff;
              padding: 14px 28px;
              text-decoration: none;
              font-size: 16px;
              font-weight: bold;
              border-radius: 30px;
              display: inline-block;
              width: 100%;
              max-width: 240px;
              transition: 0.3s ease-in-out;
              box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
          }
  
          .cta-button:hover {
              background: #229954;
              transform: scale(1.05);
              box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
          }
  
          .footer {
              font-size: 12px;
              color: #7f8c8d;
              margin-top: 20px;
          }
  
          .social-icons a {
              margin: 0 10px;
              color: #27ae60;
              text-decoration: none;
              font-size: 18px;
              display: inline-block;
          }
  
          .social-icons a:hover {
              color: #229954;
          }
      </style>
  </head>
  <body>
      <div class="container">
          <div class="logo">
              <img src="https://i.postimg.cc/zLfTjZ4p/VSE-icons-03-10004.png" alt="Qualitronix logo"/>
          </div>
          <div class="logo-name">
              <img src="https://i.postimg.cc/2LNqgP9s/Comp-1-10000.png" alt="Qualitronix Name"/>
          </div>
          <h1>Email Verification</h1>
          <p>Hello ${username || "User"}, please click the button below to verify your email address and activate your account with Qualitronix.</p>
          <a href="${confirmEmailLink}" class="cta-button">Verify Email</a>
          <p>${message || "If you didn't request this, please ignore this email."}</p>
          <div class="footer">
              <p>&copy; ${new Date().getFullYear()} Qualitronix. All rights reserved.</p>
              <div class="social-icons">
                  <a href="#" aria-label="Follow us on Twitter">🔗 Twitter</a>
                  <a href="#" aria-label="Follow us on LinkedIn">🔗 LinkedIn</a>
                  <a href="#" aria-label="Visit our website">🌐 Website</a>
              </div>
              <p>Need help? <a href="mailto:support@qualitronix.com" style="color: #27ae60;">Contact Support</a></p>
              <p><a href="#" style="color: #27ae60;">Privacy Policy</a> | <a href="#" style="color: #27ae60;">Terms of Service</a></p>
          </div>
      </div>
  </body>
  </html>`;
  };
  