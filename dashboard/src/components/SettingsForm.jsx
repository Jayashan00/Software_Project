import React, { useState } from 'react';

const SettingsForm = ({ userProfile, onSave, onCancel, token }) => {
  const [name, setName] = useState(userProfile?.fullName || '');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!name.trim()) return;

    setIsLoading(true);
    setError('');

    try {
      const res = await fetch('/api/admin/users/profile', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ name: name.trim() }),
      });

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data.message || 'Failed to update');
      }

      const json = await res.json();
      onSave(json.data.fullName);
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form className="app__modal-form" onSubmit={handleSubmit}>
      <p style={{ color: '#9ca3af', fontSize: '0.9rem', marginBottom: '1.5rem' }}>
        You are editing your public display name. Email and role cannot be changed here.
      </p>

      <div className="form-group">
        <label htmlFor="fullName">Display Name</label>
        <input
          id="fullName"
          type="text"
          className="form-input"
          value={name}
          onChange={(e) => setName(e.target.value)}
          required
          disabled={isLoading}
        />
      </div>

      {error && <p className="error-message">{error}</p>}

      <div className="app__modal-footer">
        <button
          type="button"
          className="btn btn--secondary"
          onClick={onCancel}
          disabled={isLoading}
        >
          Cancel
        </button>
        <button
          type="submit"
          className="btn btn--primary"
          disabled={isLoading || !name.trim()}
        >
          {isLoading ? 'Updating…' : 'Update Name'}
        </button>
      </div>
    </form>
  );
};

export default SettingsForm;