import React, { useEffect, useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import axios from 'axios';
import './PaymentSuccess.css';

export default function PaymentSuccess() {
  const [seconds, setSeconds] = useState(5);
  const [error, setError] = useState(null);
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    const checkSessionStatus = async () => {
      // Extract session_id from URL query
      const params = new URLSearchParams(location.search);
      const sessionId = params.get('session_id');

      if (!sessionId) {
        setError('Session ID not found in URL.');
        return;
      }

      try {
        const response = await axios.get(
          `http://13.48.37.38:3000/subscription/session-status?sessionId=${sessionId}`
        );
        console.log('Session status response:', response.data);
        if (!response.data.success) {
          setError('Failed to verify payment. Please contact support.');
        }
      } catch (err) {
        console.error('Error checking session status:', err);
        setError('Error verifying payment. Please try again or contact support.');
      }
    };

    checkSessionStatus();

    // Redirect timer
    if (seconds <= 0) {
      navigate('/Dashboard');
      return;
    }

    const timer = setInterval(() => {
      setSeconds((prev) => {
        if (prev <= 1) {
          clearInterval(timer);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [seconds, navigate, location]);

  return (
    <div className="flex flex-col items-center justify-center h-screen bg-all">
      <div className="bgc p-8 rounded-lg shadow-md text-center">
        {error ? (
          <>
            <h1 className="text-2xl font-bold text-red-600 mb-4 drop-shadow">
              Payment Verification Failed
            </h1>
            <p className="text-red-600 mb-6">{error}</p>
          </>
        ) : (
          <>
            <h1 className="text-2xl font-bold text-gold mb-4 drop-shadow">
              Payment Successful!
            </h1>
            <p className="text-gold mb-2">
              Thank you for your purchase. Your transaction has been completed successfully.
            </p>
            <p className="text-gold mb-6">
              Redirecting to dashboard in{' '}
              <span className="font-semibold">{seconds}</span> seconds...
            </p>
          </>
        )}

        {seconds <= 0 && (
          <div className="1">
            <p className="text-gold mb-4">
              If you are not redirected, click the button below:
            </p>
            <Link to="/Dashboard" className="text-center bg-green p-3 py-2 rounded">
              <button className="slogan font-bold text-lg">
                Go to Dashboard
              </button>
            </Link>
          </div>
        )}
      </div>
    </div>
  );
}