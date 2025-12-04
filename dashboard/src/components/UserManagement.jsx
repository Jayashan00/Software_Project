import React, { useState, useEffect } from 'react';
import { Users, Trash2, Plus, Pencil } from 'lucide-react';

const UserTable = ({ title, users, roleFilter, onAction, addUserType, token }) => {
  const filteredUsers = users.filter(user => user.role === roleFilter);

  const handleDelete = async (userId) => {
    if (roleFilter !== 'ROLE_COLLECTOR') {
        alert("Delete functionality is only available for Collectors.");
        throw new Error("Delete not permitted for this role.");
    }

    try {
      const response = await fetch(`/api/admin/collectors/${userId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      if (!response.ok) {
        const errData = await response.json();
        throw new Error(errData.message || 'Failed to delete user');
      }

      console.log(`User ${userId} deleted`);
    } catch (err) {
      alert(`Error deleting user: ${err.message}`);
      throw err;
    }
  };

  return (
    <section>
      {/* Page Header sits outside the card */}
      <div className="page-header">
        <Users size={24} />
        <h1 className="page-title">{title}</h1>
      </div>

      {/* --- FIX: Added 'card' wrapper here to make it full width & styled --- */}
      <div className="card">

        <div className="card-header">
          <div></div> {/* Spacer to push button to right */}
          <button
            className="btn btn--primary"
            onClick={() => onAction('add', { type: addUserType })}
          >
            <Plus size={16} />
            Add {addUserType}
          </button>
        </div>

        <div className="table-wrapper">
          <table className="data-table">
            <thead>
              <tr>
                <th>Username</th>
                <th>Role</th>
                <th>Join Date</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredUsers.length > 0 ? (
                filteredUsers.map(user => (
                  <tr key={user.id}>
                    <td>{user.username}</td>
                    <td>{user.role.replace('ROLE_', '').replace('_', ' ')}</td>
                    <td>{user.createdAt ? new Date(user.createdAt).toLocaleDateString() : 'N/A'}</td>
                    <td>
                      <div className="action-buttons">
                        <button
                          className="btn-icon btn-icon--primary"
                          onClick={() => onAction('edit', user)}
                          title="Edit User"
                        >
                          <Pencil size={16} />
                        </button>

                        {/* Only show delete for Collectors to prevent Admin lockout errors */}
                        {roleFilter === 'ROLE_COLLECTOR' && (
                          <button
                            className="btn-icon btn-icon--danger"
                            onClick={() => onAction('delete', {
                                name: user.username,
                                deleteCallback: () => handleDelete(user.id)
                              })}
                            title="Delete User"
                          >
                            <Trash2 size={16} />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="4" style={{ textAlign: 'center', padding: '2rem', color: '#9ca3af' }}>
                    No {addUserType.toLowerCase()}s found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
      {/* --- End of card wrapper --- */}
    </section>
  );
};


const UserManagement = ({ activeTab, onAction = () => {}, refreshKey }) => {
  const [users, setUsers] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const token = localStorage.getItem('token');

  useEffect(() => {
    const fetchUsers = async () => {
      setIsLoading(true);
      setError(null);
      try {
        const response = await fetch('/api/admin/users', {
          headers: { 'Authorization': `Bearer ${token}` },
        });
        if (!response.ok) {
          throw new Error(`Failed to fetch users: ${response.statusText}`);
        }
        const data = await response.json();
        setUsers(Array.isArray(data.data) ? data.data : []);
      } catch (err) {
        setError(err.message);
        setUsers([]);
      } finally {
        setIsLoading(false);
      }
    };
    fetchUsers();
  }, [token, refreshKey]);

  if (isLoading) {
    return <main className="page-content" style={{textAlign:'center', marginTop:'2rem'}}>Loading users...</main>;
  }

  if (error) {
    return <main className="page-content" style={{color: '#f43f5e'}}>Error: {error}</main>;
  }

  const renderTabContent = () => {
    const tableProps = { users, onAction, token };

    switch (activeTab) {
      case 'tab1':
        return <UserTable {...tableProps} title="All Collectors" roleFilter="ROLE_COLLECTOR" addUserType="Collector" />;
      case 'tab2':
        return <UserTable {...tableProps} title="All Bin Users" roleFilter="ROLE_BIN_OWNER" addUserType="Bin User" />;
      case 'tab3':
        return <UserTable {...tableProps} title="All Admin Users" roleFilter="ROLE_ADMIN" addUserType="Admin" />;
      default:
        return <UserTable {...tableProps} title="All Collectors" roleFilter="ROLE_COLLECTOR" addUserType="Collector" />;
    }
  };

  return (
    <div className="user-management">
      <main className="page-content">
        <div className="page-grid">{renderTabContent()}</div>
      </main>
    </div>
  );
};

export default UserManagement;