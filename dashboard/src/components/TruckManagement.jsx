import React, { useEffect, useState } from 'react';
import { Truck, Pencil, Trash2, Plus, MapPin, Users } from 'lucide-react';
import "../styles/TruckManagement.css";

const TruckManagement = ({ activeTab, onAction, refreshKey }) => {
  const [tab1Data, setTab1Data] = useState([]); // Available trucks
  const [tab1Loading, setTab1Loading] = useState(true);
  const [tab1Error, setTab1Error] = useState(null);

  const [tab2Data, setTab2Data] = useState([]); // On-route/assigned trucks
  const [tab2Loading, setTab2Loading] = useState(true);
  const [tab2Error, setTab2Error] = useState(null);

  const [availableCollectors, setAvailableCollectors] = useState([]);

  const token = localStorage.getItem('token');

  const handleDeleteTruck = async (truckId) => {
    try {
      const response = await fetch(`/api/admin/trucks/${truckId}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (!response.ok) {
        const errData = await response.json();
        throw new Error(errData.message || 'Failed to delete truck');
      }
      onAction('refresh'); // Refresh on success
    } catch (err) {
      alert(`Error deleting truck: ${err.message}`);
      throw err;
    }
  };

  // Fetch available trucks (omitted for brevity, keep existing useEffect)
  useEffect(() => {
    const fetchTrucks = async () => {
        setTab1Loading(true);
        try {
            const response = await fetch('/api/admin/trucks?status=AVAILABLE', {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            if (!response.ok) throw new Error('Failed to fetch trucks');
            const data = await response.json();
            setTab1Data(Array.isArray(data.data) ? data.data : []);
        } catch (error) {
            setTab1Error(error.message);
            setTab1Data([]);
        } finally {
            setTab1Loading(false);
        }
    };
    fetchTrucks();
  }, [token, refreshKey]);

  // Fetch in-service trucks
  useEffect(() => {
    const fetchInServiceTrucks = async () => {
        setTab2Loading(true);
        try {
            const response = await fetch('/api/collector/trucks', {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            if (!response.ok) throw new Error('Failed to fetch in-service trucks');
            const data = await response.json();
            setTab2Data(Array.isArray(data.data) ? data.data : []);
        } catch (error) {
            setTab2Error(error.message);
            setTab2Data([]);
        } finally {
            setTab2Loading(false);
        }
    };
    fetchInServiceTrucks();
  }, [token, refreshKey]);

  // Fetch available collectors (omitted for brevity, keep existing useEffect)
  useEffect(() => {
    const fetchAvailableCollectors = async () => {
        try {
            const response = await fetch('/api/collector/trucks/available-collectors', {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            if (!response.ok) throw new Error('Failed to fetch available collectors');
            const data = await response.json();
            setAvailableCollectors(Array.isArray(data.data) ? data.data : []);
        } catch (error) {
            console.error("Error fetching collectors:", error);
            setAvailableCollectors([]);
        }
    };
    fetchAvailableCollectors();
  }, [token, refreshKey]);

  const getStatusColor = (status) => {
    if (!status) return 'status-badge--default';
    switch (status.toLowerCase()) {
      case 'available': return 'status-badge--success';
      case 'in_service': return 'status-badge--primary';
      case 'maintenance': return 'status-badge--warning';
      case 'inactive': return 'status-badge--danger';
      default: return 'status-badge--default';
    }
  };

  const renderTruckInventoryTab = () => (
    <section>
      <div className="page-header">
        <Truck size={24} />
        <h1 className="page-title">Truck Inventory</h1>
      </div>
      <div className="card-header">
        <h3 className="card__title">Available Trucks</h3>
        <button className="btn btn--primary" onClick={() => onAction('add')}>
          <Plus size={18} /> Add Truck
        </button>
      </div>
      <div className="card-content">
        <table className="data-table">
          <thead>
            <tr>
              <th>Truck ID</th>
              <th>Plate Number</th>
              <th>Status</th>
              <th>Capacity(kg)</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {tab1Loading ? (
              <tr><td colSpan="5" style={{ textAlign: 'center', padding: '1rem' }}>Loading...</td></tr>
            ) : tab1Error ? (
              <tr><td colSpan="5" style={{ textAlign: 'center', padding: '1rem', color: '#f43f5e' }}>{tab1Error}</td></tr>
            ) : tab1Data.length === 0 ? (
              <tr><td colSpan="5" style={{ textAlign: 'center', padding: '1rem' }}>No available trucks found.</td></tr>
            ) : (
              tab1Data.map(truck => (
                <tr key={truck.id}>
                  <td className="font-medium">{truck.id}</td>
                  <td className="font-medium">{truck.registrationNumber}</td>
                  <td>
                    <span className={`status-badge ${getStatusColor(truck.status)}`}>
                      {truck.status.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase())}
                    </span>
                  </td>
                  <td>{truck.capacityKg}</td>
                  <td>
                    <div className="action-buttons">
                      <button
                        className="btn-icon btn-icon--primary"
                        onClick={() => onAction('edit', truck)}
                        title="Edit Truck"
                      >
                        <Pencil size={16} />
                      </button>
                      <button
                        className="btn-icon btn-icon--info"
                        onClick={() => onAction('assign', {
                           truck: truck,
                           collectors: availableCollectors
                        })}
                        title="Assign Collector"
                      >
                        <Users size={16} />
                      </button>
                      <button
                        className="btn-icon btn-icon--danger"
                        onClick={() => onAction('delete', {
                          name: truck.registrationNumber,
                          deleteCallback: () => handleDeleteTruck(truck.id)
                        })}
                        title="Delete Truck"
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

  const renderOnRouteTab = () => (
    <section>
      <div className="page-header">
        <Truck size={24} />
        <h1 className="page-title">On Route / Assigned Trucks</h1>
      </div>
      <div className="card-header">
        <h3 className="card__title"></h3>
      </div>
      <div className="card-content">
        <table className="data-table">
          <thead>
            <tr>
              <th>Truck ID</th>
              <th>Plate Number</th>
              <th>Driver</th>
              <th>Capacity</th>
              <th>Status</th>
              <th>Assigned Date</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {tab2Loading ? (
              <tr><td colSpan="7" style={{ textAlign: 'center', padding: '1rem' }}>Loading...</td></tr>
            ) : tab2Error ? (
              <tr><td colSpan="7" style={{ textAlign: 'center', padding: '1rem', color: '#f43f5e' }}>{tab2Error}</td></tr>
            ) : tab2Data.length === 0 ? (
              <tr><td colSpan="7" style={{ textAlign: 'center', padding: '1rem' }}>No trucks on route.</td></tr>
            ) : (
              tab2Data.map((assignment) => (
                <tr key={assignment.truck.id}>
                  <td className="font-medium">{assignment.truck.id}</td>
                  <td className="font-medium">{assignment.truck.registrationNumber}</td>
                  <td>{assignment.collector.name}</td>
                  <td>{assignment.truck.capacityKg}</td>
                  <td>
                    <span className={`status-badge ${getStatusColor(assignment.truck.status)}`}>
                      {assignment.truck.status.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase())}
                    </span>
                  </td>
                  <td>{new Date(assignment.assignedDate).toLocaleDateString()}</td>
                  <td>
                    <div className="action-buttons">
                      {/* --- FIX: Pass truck details directly for tracking --- */}
                      <button
                        className="btn-icon btn-icon--info"
                        onClick={() => onAction('track', {
                            id: assignment.truck.id,
                            registrationNumber: assignment.truck.registrationNumber
                        })}
                        title="Track Truck"
                      >
                        <MapPin size={16} />
                      </button>
                      {/* --- End Fix --- */}
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

  const renderTabContent = () => {
    switch (activeTab) {
      case 'tab1':
        return renderTruckInventoryTab();
      case 'tab2':
        return renderOnRouteTab();
      default:
        return renderTruckInventoryTab();
    }
  };

  return (
    <div className="truck-management">
      <main className="page-content">
        <div className="page-grid">
          {renderTabContent()}
        </div>
      </main>
    </div>
  );
};

export default TruckManagement;