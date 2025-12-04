import React, { useState, useEffect } from 'react';
import { Shield, User, LogOut, Edit, Loader2 } from 'lucide-react';
import SettingsForm from './SettingsForm';
import '../styles/Settings.css';

const Settings = ({ onLogout }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showEdit, setShowEdit] = useState(false);
  const token = localStorage.getItem('token');

  // -------------------------------------------------
  // 1. Load the real user profile
  // -------------------------------------------------
  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const res = await fetch('/api/admin/users/profile', {
          headers: { Authorization: `Bearer ${token}` },
        });

        if (!res.ok) throw new Error('Failed to load profile');
        const json = await res.json();
        setUser(json.data);               // <-- real user from DB
      } catch (e) {
        setError(e.message);
      } finally {
        setLoading(false);
      }
    };

    if (token) fetchProfile();
    else setLoading(false);
  }, [token]);

  // -------------------------------------------------
  // 2. Handle successful name update
  // -------------------------------------------------
  const handleNameSaved = (newName) => {
    setUser((u) => ({ ...u, fullName: newName }));
    setShowEdit(false);
  };

  // -------------------------------------------------
  // Render
  // -------------------------------------------------
  if (loading) {
    return (
      <div className="settings-page-dark">
        <Loader2 className="spinner" size={32} />
        <p>Loading profile…</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="settings-page-dark">
        <p className="error-message">{error}</p>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="settings-page-dark">
        <p>No user data available.</p>
      </div>
    );
  }

  return (
    <div className="settings-page-dark">
      <div className="settings-card-dark">

        {/* ---------- USER INFO ---------- */}
        <div className="info-section">
          <div className="info-item">
            <Shield size={20} className="info-icon" />
            <div className="info-text">
              <span className="info-label">Role</span>
              <span className="info-value">
                {user.role.replace('ROLE_', '')}
              </span>
            </div>
          </div>

          <div className="info-item">
            <User size={20} className="info-icon" />
            <div className="info-text">
              <span className="info-label">Member Since</span>
              <span className="info-value">
                {new Date(user.createdAt || user.memberSince).toLocaleDateString()}
              </span>
            </div>
          </div>

          {/* Optional: show username */}
          <div className="info-item">
            <User size={20} className="info-icon" />
            <div className="info-text">
              <span className="info-label">Username</span>
              <span className="info-value">{user.username}</span>
            </div>
          </div>
        </div>

        {/* ---------- ACTION BUTTONS ---------- */}
        <div className="action-section">
          <button className="settings-button" onClick={() => setShowEdit(true)}>
            <Edit size={16} />
            <span>Edit Profile</span>
          </button>

          <button
            className="settings-button settings-button--danger"
            onClick={onLogout}
          >
            <LogOut size={16} />
            <span>Log Out</span>
          </button>
        </div>
      </div>

      {/* ---------- EDIT MODAL ---------- */}
      {showEdit && (
        <div className="app__modal-overlay" onClick={() => setShowEdit(false)}>
          <div className="app__modal" onClick={(e) => e.stopPropagation()}>
            <div className="app__modal-header">
              <h2>Edit Display Name</h2>
              <button
                className="app__modal-close"
                onClick={() => setShowEdit(false)}
                aria-label="Close"
              >
                ×
              </button>
            </div>

            <div className="app__modal-content">
              <SettingsForm
                userProfile={user}
                onSave={handleNameSaved}
                onCancel={() => setShowEdit(false)}
                token={token}
              />
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Settings;