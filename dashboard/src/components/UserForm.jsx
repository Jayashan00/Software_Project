import React, { useState } from 'react';

// Make sure your CSS file is imported in a parent component (like App.jsx or main.jsx)
// or add: import '../styles/styles.css';

const UserForm = ({ role, onSave, onCancel, token }) => {
  // Common fields
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');

  // Bin Owner specific fields
  const [address, setAddress] = useState('');
  const [mobileNumber, setMobileNumber] = useState('');

  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    let endpoint = '';
    let body = {};

    // Determine the API endpoint and body based on the role
    if (role === 'ROLE_BIN_OWNER') {
      endpoint = '/api/auth/register'; // Uses the public registration endpoint
      body = { username, password, name, address, mobileNumber };
    } else if (role === 'ROLE_COLLECTOR') {
      endpoint = '/api/admin/collectors'; // Uses the admin collector endpoint
      body = { username, password, name };
    } else {
      setError('Cannot add Admin users from this form yet.');
      setIsLoading(false);
      return;
    }

    try {
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(body)
      });

      if (!response.ok) {
        const errData = await response.json();
        throw new Error(errData.message || 'Failed to create user');
      }

      onSave(); // This will call saveModalData in App.jsx

    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    // Note: This form assumes you have CSS for "form-group" and "form-input"
    // (which I am providing in the third code block)
    <form className="app__modal-form" onSubmit={handleSubmit}>
      <div className="form-group">
        <label htmlFor="username">Username (Email)</label>
        <input
          id="username"
          type="email"
          className="form-input"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          required
        />
      </div>

      <div className="form-group">
        <label htmlFor="password">Password</label>
        <input
          id="password"
          type="password"
          className="form-input"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          minLength={6}
        />
      </div>

      <div className="form-group">
        <label htmlFor="name">Full Name</label>
        <input
          id="name"
          type="text"
          className="form-input"
          value={name}
          onChange={(e) => setName(e.target.value)}
          required
        />
      </div>

      {/* Show these fields ONLY if creating a Bin Owner */}
      {role === 'ROLE_BIN_OWNER' && (
        <>
          <div className="form-group">
            <label htmlFor="address">Address</label>
            <input
              id="address"
              type="text"
              className="form-input"
              value={address}
              onChange={(e) => setAddress(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label htmlFor="mobileNumber">Mobile Number</label>
            <input
              id="mobileNumber"
              type="tel"
              className="form-input"
              value={mobileNumber}
              onChange={(e) => setMobileNumber(e.target.value)}
              required
            />
          </div>
        </>
      )}

      {error && <p className="error-message">{error}</p>}

      {/* This div is styled by your existing .app__modal-footer class.
        The buttons are styled by .btn classes.
      */}
      <div className="app__modal-footer">
        <button
          className="btn btn--secondary"
          type="button"
          onClick={onCancel}
          disabled={isLoading}
        >
          Cancel
        </button>
        <button
          className="btn btn--primary"
          type="submit"
          disabled={isLoading}
        >
          {isLoading ? 'Saving...' : 'Save'}
        </button>
      </div>
    </form>
  );
};

export default UserForm;