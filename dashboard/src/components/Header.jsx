import React from 'react';
import { Bell } from 'lucide-react';
import SearchBar from './SearchBar';

// Destructure the props we pass from App.jsx
const Header = ({ onToggleNotifications, notificationCount, user }) => {
  return (
    <header className="header">
      <div className="header__welcome">
        <h1 className="header__title">Welcome,</h1>
        <h2 className="header__user">{user?.name || 'Admin'}</h2>
      </div>

      <SearchBar />

      {/* 1. Added onClick handler to trigger the sidebar
         2. Added dynamic count check
      */}
      <div className="header__notifications" onClick={onToggleNotifications} style={{ cursor: 'pointer' }}>
        <div className="header__notification-icon">
          <Bell size={20} />
          {notificationCount > 0 && (
            <span className="header__notification-badge">{notificationCount}</span>
          )}
        </div>
      </div>
    </header>
  );
};

export default Header;