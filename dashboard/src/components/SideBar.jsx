import React from 'react';
import { 
  LayoutDashboard, 
  Trash2, 
  Truck, 
  LineChart, 
  Users,
  Settings,
  HelpCircle
} from 'lucide-react';

//
// THE FIX: It now receives "onMenuChange" instead of "setActiveMenu"
//
const Sidebar = ({ activeMenu, onMenuChange }) => {
  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: <LayoutDashboard size={20} /> },
    { id: 'bin-management', label: 'Bin Management', icon: <Trash2 size={20} /> },
    { id: 'truck-management', label: 'Truck Management', icon: <Truck size={20} /> },
    { id: 'route-management', label: 'Route Management', icon: <LineChart size={20} /> },
    { id: 'user-management', label: 'User Management', icon: <Users size={20} /> },
  ];

  //
  // THE FIX: It now calls the correct function "onMenuChange"
  //
  const handleTabChange = (tabId) => {
    onMenuChange(tabId);
  };

  return (
    <aside className="sidebar">
      <div className="sidebar__logo">
        <img src="/Logo.png" alt="EcoRoute Logo" className="sidebar__logo-img" />
      </div>

      <nav className="sidebar__menu">
        <ul className="sidebar__menu-list">
          {menuItems.map((item) => (
            <li
              key={item.id}
              className={`sidebar__menu-item ${activeMenu === item.id ? 'sidebar__menu-item--active' : ''}`}
              onClick={() => handleTabChange(item.id)} // This line calls the fixed function
            >
              {item.icon}
              <span>{item.label}</span>
            </li>
          ))}
        </ul>
      </nav>

      <div className="sidebar__footer">
        <div
          className={`sidebar__footer-item ${activeMenu === 'settings' ? 'sidebar__footer-item--active' : ''}`}
          onClick={() => handleTabChange('settings')} // This also calls the fixed function
        >
          <Settings size={20} />
          <span>Settings</span>
        </div>
        <div
          className={`sidebar__footer-item ${activeMenu === 'support' ? 'sidebar__footer-item--active' : ''}`}
          onClick={() => handleTabChange('support')} // This also calls the fixed function
        >
          <HelpCircle size={20} />
          <span>Support</span>
        </div>
      </div>
      
      <div className="sidebar__user">
        <div className="sidebar__user-avatar">A</div>
        <span className="sidebar__user-name">Admin User</span>
      </div>
    </aside>
  );
};

export default Sidebar;