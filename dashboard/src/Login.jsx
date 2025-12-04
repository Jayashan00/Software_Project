import React, { useState } from 'react';
import './Login.css';
// useNavigate is removed as main.jsx will handle navigation after login
// import { useNavigate } from 'react-router-dom';

const Login = ({ onLoginSuccess }) => { // Accept onLoginSuccess prop
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [passwordVisible, setPasswordVisible] = useState(false);
  const [error, setError] = useState('');
  // const navigate = useNavigate(); // No longer needed here

  const handleLogin = async (e) => {
    e.preventDefault();
    setError(''); // Clear previous errors

    try {
      const response = await fetch('http://localhost:8080/api/auth/authenticate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password })
      });

      const data = await response.json(); // Always parse JSON first

      if (!response.ok) { // Check HTTP status code for errors
        // Prefer data.message if available, otherwise a generic message
        setError(data.message || `Error: ${response.status} ${response.statusText}`);
        if (response.status === 401) {
          setError('Invalid username or password');
        }
        return;
      }

      // Assuming successful response structure is like: { success: true, data: { token: "..." } }
      // or just { token: "..." }
      // Adjust based on your actual API response
      const token = data.token || (data.data && data.data.token);

      if (token) {
        onLoginSuccess(token); // Call the callback from main.jsx
        // localStorage.setItem('token', token); // No longer needed here
        // navigate('/app'); // No longer needed here
      } else {
        setError(data.message || 'Login failed: No token received.');
      }

    } catch (err) {
      console.error('Login error:', err);
      // Differentiate network errors from API errors
      if (err instanceof TypeError && err.message === "Failed to fetch") {
          setError('Network error: Could not connect to the server.');
      } else {
          setError('An unexpected error occurred during login.');
      }
    }
  };

  return (
    <div className="login-container">
      <div className="login-logo">
        <img src="/Logo.png" alt="EcoRoute Logo" />
      </div>
      <div className="login-card">
        <h2>Welcome Back!</h2>
        <p>Login to your account to continue</p>
        <form onSubmit={handleLogin}>
          <label htmlFor="username">Username</label>
          <input
            id="username"
            type="text"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            required
            autoComplete="username"
          />
          <label htmlFor="password">Password</label>
          <div className="password-wrapper">
            <input
              id="password"
              type={passwordVisible ? 'text' : 'password'}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              autoComplete="current-password"
            />
            <span
              className="toggle-visibility"
              onClick={() => setPasswordVisible(!passwordVisible)}
              role="button" // for accessibility
              tabIndex={0} // for accessibility
              onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') setPasswordVisible(!passwordVisible);}} // for accessibility
            >
              {passwordVisible ? '🙈' : '👁️'}
            </span>
          </div>
          {error && <p className="error-message">{error}</p>}
          <button type="submit">LOGIN</button>
        </form>
      </div>
    </div>
  );
};

export default Login;