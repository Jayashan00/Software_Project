import { Pencil, Trash2, Plus, MapPin, Wrench, Truck } from 'lucide-react';
import React, { useState, useEffect } from 'react';
import Maps from './Maps';
const BinManagement = ({ activeTab, onAction, refreshKey, currentUser }) => {

  const [tab1Data, setTab1Data] = useState([]); // Available Bins
  const [tab1Loading, setTab1Loading] = useState(true);
  const [tab1Error, setTab1Error] = useState(null);

  const [tab2Data, setTab2Data] = useState([]); // Assigned Bins
  const [tab2Loading, setTab2Loading] = useState(true);
  const [tab2Error, setTab2Error] = useState(null);

  const [tab3Data, setTab3Data] = useState([]); // Maintenance Requests
  const [tab3Loading, setTab3Loading] = useState(true);
  const [tab3Error, setTab3Error] = useState(null);

  // --- NEW STATE for All Bins (for Maintenance Request Form) ---
  const [allBins, setAllBins] = useState([]);
  // --- END ---

  const token = localStorage.getItem('token');

  // Delete bin function
  const handleDeleteBin = async (binId) => {
    try {
      const response = await fetch(`/api/bins/${binId}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (!response.ok) {
        const errData = await response.json();
        throw new Error(errData.message || 'Failed to delete bin');
      }

      console.log(`Bin ${binId} deleted`);
      onAction('refresh'); // Refresh data on success
    } catch (err) {
      alert(`Error deleting bin: ${err.message}`);
      throw err;
    }
  };

  // --- Fetch ALL bins (Used for Maintenance Form dropdown) ---
  useEffect(() => {
    fetch('/api/bins', {
      method: 'GET',
      headers: { 'Authorization': `Bearer ${token}` }
    })
      .then(response => {
        if (!response.ok) throw new Error('Failed to fetch all bins');
        return response.json();
      })
      .then(data => {
        setAllBins(Array.isArray(data.data) ? data.data : []);
      })
      .catch(error => {
        console.error("Error fetching all bins for form:", error.message);
      });
  }, [token, refreshKey]);

  // Fetch available bins (tab1)
  useEffect(() => {
    if (activeTab === 'tab1') {
      setTab1Loading(true);
      fetch('/api/bins?status=AVAILABLE', {
        method: 'GET',
        headers: { 'Authorization': `Bearer ${token}` }
      })
        .then(response => {
          if (!response.ok) throw new Error('Failed to fetch available bins');
          return response.json();
        })
        .then(data => {
          setTab1Data(Array.isArray(data.data) ? data.data : []);
        })
        .catch(error => {
          setTab1Error(error.message);
        })
        .finally(() => setTab1Loading(false));
    }
  }, [token, refreshKey, activeTab]);

  // ✅ UPDATED: Fetch assigned bins (tab2)
  // Try /fetch for BIN_OWNER, fallback to ?status=ASSIGNED for ADMIN
  useEffect(() => {
    if (activeTab === 'tab2') {
      setTab2Loading(true);
      const tryFetch = async () => {
        try {
          // First try /fetch endpoint (for BIN_OWNER)
          const res = await fetch('/api/bins/fetch', {
            headers: { 'Authorization': `Bearer ${token}` }
          });

          if (res.ok) {
            const data = await res.json();
            setTab2Data(Array.isArray(data.data) ? data.data : []);
          } else {
            // Fallback for ADMIN
            const fallback = await fetch('/api/bins?status=ASSIGNED', {
              headers: { 'Authorization': `Bearer ${token}` }
            });
            const fallbackData = await fallback.json();
            setTab2Data(Array.isArray(fallbackData.data) ? fallbackData.data : []);
          }
        } catch (err) {
          setTab2Error('Failed to load assigned bins');
        } finally {
          setTab2Loading(false);
        }
      };
      tryFetch();
    }
  }, [token, refreshKey, activeTab]);

  // Fetch maintenance requests (tab3)
  useEffect(() => {
    if (activeTab === 'tab3') {
      setTab3Loading(true);
      fetch('/api/maintenance-requests', {
        method: 'GET',
        headers: { 'Authorization': `Bearer ${token}` }
      })
        .then(response => {
          if (!response.ok) throw new Error('Failed to fetch maintenance requests');
          return response.json();
        })
        .then(data => {
          setTab3Data(Array.isArray(data.data?.content) ? data.data.content : []);
        })
        .catch(error => {
          setTab3Error(error.message);
        })
        .finally(() => setTab3Loading(false));
    }
  }, [token, refreshKey, activeTab]);

  const getStatusColor = (status) => {
    if (!status) return 'status-badge--default';
    switch (status) {
      case 'active': return 'status-badge--success';
      case 'maintenance': return 'status-badge--warning';
      case 'inactive': return 'status-badge--danger';
      case 'AVAILABLE': return 'status-badge--success';
      case 'ASSIGNED': return 'status-badge--primary';
      case 'PENDING':
      case 'IN_PROGRESS':
        return 'status-badge--warning';
      case 'COMPLETED': return 'status-badge--success';
      default: return 'status-badge--default';
    }
  };

  const getPriorityColor = (priority) => {
    if (!priority) return 'priority--default';
    switch (priority.toLowerCase()) {
      case 'high': return 'priority--high';
      case 'medium': return 'priority--medium';
      case 'low': return 'priority--low';
      default: return 'priority--default';
    }
  };

  const renderAllBinsTab = () => (
      <section>
        <div className="page-header">
          <Truck size={24} />
          <h1 className="page-title">All Bins</h1>
        </div>
        <div className="card-header">
          <h3 className="card__title">Available Bins</h3>
          <button className="btn btn--primary" onClick={() => onAction('add')}>
            <Plus size={18} /> Add Bin
          </button>
        </div>
        <div className="card-content">
          <table className="data-table">
            <thead>
              <tr>
                <th>Bin ID</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {tab1Loading ? (
                <tr><td colSpan="3" style={{ textAlign: 'center', padding: '1rem' }}>Loading...</td></tr>
              ) : tab1Error ? (
                <tr><td colSpan="3" style={{ textAlign: 'center', padding: '1rem', color: '#f43f5e' }}>{tab1Error}</td></tr>
              ) : tab1Data.length === 0 ? (
                <tr><td colSpan="3" style={{ textAlign: 'center', padding: '1rem' }}>No available bins found.</td></tr>
              ) : (
                tab1Data.filter(bin => bin !== null && bin !== undefined).map(bin => (
                  <tr key={bin.binId}>
                    <td className="font-medium">{bin.binId}</td>
                    <td>
                      <span className={`status-badge ${getStatusColor(bin.status)}`}>
                        {bin.status ? bin.status.charAt(0).toUpperCase() + bin.status.slice(1).toLowerCase() : 'Unknown'}
                      </span>
                    </td>
                    <td>
                      <div className="action-buttons">
                        {/* ✅ FIX: Added Edit Button Here */}
                        <button
                          className="btn-icon btn-icon--primary"
                          onClick={() => onAction('edit', bin)}
                          title="Edit Bin Location"
                        >
                          <Pencil size={16} />
                        </button>

                        {/* Assign button (Only for Bin Owners) */}
                        {bin.status === 'AVAILABLE' && currentUser?.role === 'ROLE_BIN_OWNER' && (
                          <button
                            className="btn-icon btn-icon--success"
                            title="Assign to Me"
                            onClick={async () => {
                              if (confirm(`Assign bin ${bin.binId} to yourself?`)) {
                                try {
                                  const res = await fetch(`/api/bins/${bin.binId}/assign`, {
                                    method: 'PUT',
                                    headers: { 'Authorization': `Bearer ${token}` }
                                  });
                                  if (!res.ok) throw new Error('Failed to assign bin');
                                  onAction('refresh');
                                } catch (err) {
                                  alert(err.message);
                                }
                              }
                            }}
                          >
                            <Plus size={16} />
                          </button>
                        )}

                        {/* Delete bin (Admin) */}
                        <button
                          className="btn-icon btn-icon--danger"
                          onClick={() => {
                            onAction('delete', {
                              name: bin.binId,
                              deleteCallback: () => handleDeleteBin(bin.binId)
                            });
                          }}
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>
    );

  const renderAllActiveBinsTab = () => (
      <section>
        <div className="page-header">
          <Truck size={24} />
          <h1 className="page-title">All Active Bins</h1>
        </div>
        <div className="card-header">
          <h3 className="card__title">Assigned Bins</h3>
        </div>
        <div className="card-content">
          <table className="data-table">
            <thead>
              <tr>
                <th>Bin ID</th>
                <th>Status</th>
                <th>Assigned Date</th>
                <th>Location</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {tab2Loading ? (
                <tr><td colSpan="5" style={{ textAlign: 'center', padding: '1rem' }}>Loading...</td></tr>
              ) : tab2Error ? (
                <tr><td colSpan="5" style={{ textAlign: 'center', padding: '1rem', color: '#f43f5e' }}>{tab2Error}</td></tr>
              ) : tab2Data.length === 0 ? (
                <tr><td colSpan="5" style={{ textAlign: 'center', padding: '1rem' }}>No assigned bins found.</td></tr>
              ) : (
                tab2Data.map(bin => (
                  <tr key={bin.binId}>
                    <td className="font-medium">{bin.binId}</td>
                    <td>
                      <span className={`status-badge ${getStatusColor(bin.status)}`}>
                        {bin.status ? bin.status.charAt(0).toUpperCase() + bin.status.slice(1).toLowerCase() : 'Unknown'}
                      </span>
                    </td>
                    <td>{bin.assignedDate ? new Date(bin.assignedDate).toLocaleDateString() : 'N/A'}</td>
                    <td>{bin.latitude && bin.longitude ? `${bin.latitude.toFixed(4)}, ${bin.longitude.toFixed(4)}` : 'N/A'}</td>
                    <td>
                      <div className="action-buttons">
                        <button
                          className="btn-icon btn-icon--primary"
                          onClick={() => onAction('edit', bin)}
                          title="Edit Bin Location"
                        >
                          <Pencil size={16} />
                        </button>
                        <button
                          className="btn-icon btn-icon--danger"
                          onClick={() => {
                            onAction('delete', {
                              name: bin.binId,
                              deleteCallback: () => handleDeleteBin(bin.binId)
                            });
                          }}
                          title="Delete Bin"
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>
    );

  const renderMaintenanceTab = () => (
      <section>
        <div className="page-header">
          <Wrench size={24} />
          <h1 className="page-title">Maintenance Requests</h1>
        </div>
        <div className="card-header">
          <button
            className="btn btn--primary"
            onClick={() => onAction('add-maintenance', { bins: allBins })}
          >
            <Wrench size={18} /> New Request
          </button>
        </div>
        <div className="card-content">
          <table className="data-table">
            <thead>
              <tr>
                <th>Bin ID</th>
                <th>Issue</th>
                <th>Priority</th>
                <th>Reported Date</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {tab3Loading ? (
                <tr><td colSpan="6" style={{ textAlign: 'center', padding: '1rem' }}>Loading...</td></tr>
              ) : tab3Error ? (
                <tr><td colSpan="6" style={{ textAlign: 'center', padding: '1rem', color: '#f43f5e' }}>{tab3Error}</td></tr>
              ) : tab3Data.length === 0 ? (
                <tr><td colSpan="6" style={{ textAlign: 'center', padding: '1rem' }}>No maintenance requests found.</td></tr>
              ) : (
                tab3Data.map(request => (
                  <tr key={request.id}>
                    <td className="font-medium">{request.binId}</td>
                    <td>{request.description}</td>
                    <td>
                      <span className={`priority-badge ${getPriorityColor(request.priority)}`}>
                        {request.priority.charAt(0).toUpperCase() + request.priority.slice(1).toLowerCase()}
                      </span>
                    </td>
                    <td>{new Date(request.createdAt).toLocaleDateString()}</td>
                    <td>
                      <span className={`status-badge ${getStatusColor(request.status)}`}>
                        {request.status.replace('_', ' ')}
                      </span>
                    </td>
                    <td>
                      <div className="action-buttons">

                        {/* EDIT BUTTON */}
                        <button
                          className="btn-icon btn-icon--primary"
                          onClick={() => onAction('edit-maintenance', request)}
                          title="Edit Request"
                        >
                          <Pencil size={16} />
                        </button>

                        {/* DELETE BUTTON (Added for CRUD) */}
                        <button
                          className="btn-icon btn-icon--danger"
                          onClick={async () => {
                            if (confirm('Delete this maintenance request?')) {
                              try {
                                const res = await fetch(`/api/maintenance-requests/${request.id}`, {
                                  method: 'DELETE',
                                  headers: { 'Authorization': `Bearer ${token}` }
                                });
                                if (!res.ok) throw new Error('Failed to delete request');
                                onAction('refresh');
                              } catch (err) {
                                alert(err.message);
                              }
                            }
                          }}
                          title="Delete Request"
                        >
                          <Trash2 size={16} />
                        </button>

                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>
    );

  const renderBinMapTab = () => {
      // We use 'allBins' which is already fetched in your component for the dropdowns.
      // We map it to the format Maps.jsx expects if needed, though Maps.jsx handles normalization too.
      const mapStops = allBins.map(bin => ({
        ...bin,
        label: bin.binId, // Use Bin ID as the label on the map
        lat: bin.latitude,
        lng: bin.longitude
      }));

      return (
        <section style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
          <div className="page-header">
            <MapPin size={24} />
            <h1 className="page-title">Bin Locations</h1>
          </div>

          {/* Container for the map */}
          <div className="card" style={{ flexGrow: 1, padding: 0, overflow: 'hidden', minHeight: '600px' }}>
            {mapStops.length > 0 ? (
              <Maps stops={mapStops} />
            ) : (
               <div style={{
                   height: '100%',
                   display: 'flex',
                   alignItems: 'center',
                   justifyContent: 'center',
                   color: '#9ca3af',
                   flexDirection: 'column',
                   gap: '1rem'
               }}>
                   <MapPin size={48} />
                   <p>No bins found or loaded yet.</p>
               </div>
            )}
          </div>
        </section>
      );
    };

  const renderTabContent = () => {
    switch (activeTab) {
      case 'tab1':
        return renderAllBinsTab();
      case 'tab2':
        return renderAllActiveBinsTab();
      case 'tab3':
        return renderMaintenanceTab();
      case 'tab4':
        return renderBinMapTab();
      default:
        return renderAllBinsTab();
    }
  };

  return (
    <div className="bin-management">
      <main className="page-content">
        <div className="page-grid">{renderTabContent()}</div>
      </main>
    </div>
  );
};

export default BinManagement;
