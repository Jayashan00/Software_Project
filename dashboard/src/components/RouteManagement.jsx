import React, { useEffect, useState } from 'react';
import { Route, Plus, Pencil, Trash2, MapPin, Users, Truck, Clock, Navigation, CheckCircle, XCircle, X } from 'lucide-react';
import "../styles/RouteManagement.css";
import Maps from './Maps';

// --- MODAL for Assignment ---
const AssignmentModal = ({ route, trucks, routes, onConfirm, onClose }) => {
    if (!route) return null;

    const [selectedTruckId, setSelectedTruckId] = useState(null);

    // Find collector IDs already assigned
    const assignedCollectorIds = routes
        .filter(r => r.status === 'ASSIGNED' || r.status === 'IN_PROGRESS')
        .map(r => r.assignedToId);

    // Show trucks where collector is NOT assigned
    const availableTrucks = trucks.filter(truckItem =>
        !assignedCollectorIds.includes(truckItem.collector.id)
    );

    const handleConfirm = () => {
        if (!selectedTruckId) {
            alert("Please select a truck to assign.");
            return;
        }
        const truckItem = trucks.find(t => t.truck.id === selectedTruckId);
        if (!truckItem) {
             alert("Selected truck data not found.");
             return;
        }
        onConfirm(route.id, truckItem.collector.id);
    };

    return (
        <div className="modal-overlay">
            <div className="modal-window">
                <div className="modal-header">
                    <h4>Assign Truck to: <span className="modal-route-name">{route.name}</span></h4>
                    <button onClick={onClose} className="btn-icon">
                        <X size={20} />
                    </button>
                </div>
                <div className="modal-body">
                    <p className="modal-subtitle">Select an available truck from the list below. Only 'AVAILABLE' and unassigned trucks are shown.</p>
                    <div className="modal-options-list">
                        {availableTrucks.length > 0 ? availableTrucks.map(truckItem => (
                            <div
                                key={truckItem.truck.id}
                                className={`modal-option ${selectedTruckId === truckItem.truck.id ? 'modal-option--selected' : ''}`}
                                onClick={() => setSelectedTruckId(truckItem.truck.id)}
                            >
                                <div className="assignment-option-info">
                                    <strong>{truckItem.truck.registrationNumber}</strong> - {truckItem.collector.name}
                                    <br />
                                    <small>{truckItem.truck.capacityKg}Kg Capacity</small>
                                </div>
                                {selectedTruckId === truckItem.truck.id && <CheckCircle size={20} className="selection-checkmark" />}
                            </div>
                        )) : (
                           <p className="modal-empty-state">No available trucks to assign.</p>
                        )}
                    </div>
                </div>
                <div className="modal-footer">
                    <button className="btn btn--secondary" onClick={onClose}>
                        Cancel
                    </button>
                    <button
                        className="btn btn--success"
                        onClick={handleConfirm}
                        disabled={!selectedTruckId}
                    >
                        <CheckCircle size={16} />
                        Confirm Assignment
                    </button>
                </div>
            </div>
        </div>
    );
};
// --- END MODAL ---


const RouteManagement = ({ activeTab, onAction, refreshKey }) => {
    const [truckData, setTruckData] = useState([]);
    const [trucksError, setTrucksError] = useState(null);
    const [trucksLoading, setTrucksLoading] = useState(true);

    const [routeData, setRouteData] = useState([]);
    const [routesError, setRoutesError] = useState(null);
    const [routesLoading, setRoutesLoading] = useState(true);

    const [selectedRouteForModal, setSelectedRouteForModal] = useState(null);
    const token = localStorage.getItem('token');

    // Fetch Truck + Collector Data
    useEffect(() => {
        setTrucksLoading(true);
        fetch('/api/collector/trucks', {
            method: 'GET',
            headers: { 'Authorization': `Bearer ${token}` }
        })
        .then(response => {
            if (!response.ok) throw new Error('Failed to fetch truck data');
            return response.json();
        })
        .then(data => {
            setTruckData(Array.isArray(data.data) ? data.data : []);
        })
        .catch(error => {
            setTrucksError(error.message);
            setTruckData([]);
        })
        .finally(() => setTrucksLoading(false));
    }, [token, refreshKey]);

    // Fetch Routes
    useEffect(() => {
        setRoutesLoading(true);
        fetch('/api/routes', {
            method: 'GET',
            headers: { 'Authorization': `Bearer ${token}` }
        })
        .then(response => {
            if (!response.ok) throw new Error('Failed to fetch route data');
            return response.json();
        })
        .then(data => {
            setRouteData(Array.isArray(data.data) ? data.data : []);
        })
        .catch(error => {
            setRoutesError(error.message);
            setRouteData([]);
        })
        .finally(() => setRoutesLoading(false));
    }, [token, refreshKey]);

    // Delete Route
    const handleDeleteRoute = async (routeId) => {
        try {
            const response = await fetch(`/api/routes/${routeId}`, {
                method: 'DELETE',
                headers: { 'Authorization': `Bearer ${token}` }
            });
            if (!response.ok) {
                const errData = await response.json();
                throw new Error(errData.message || 'Failed to delete route');
            }
            onAction('refresh');
        } catch (err) {
            alert(`Error: ${err.message}`);
            throw err;
        }
    };

    // Assign Route
    const handleAssignRoute = async (routeId, collectorId) => {
        try {
            const response = await fetch('/api/routes/assign', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({ routeId, collectorId })
            });

            if (!response.ok) {
                const errData = await response.json();
                throw new Error(errData.message || 'Failed to assign route');
            }

            setSelectedRouteForModal(null);
            onAction('refresh');

        } catch (err) {
            alert(`Error assigning route: ${err.message}`);
        }
    };

    const getStatusColor = (status) => {
        if (!status) return 'status-badge--default';
        switch (status.toLowerCase()) {
            case 'active':
            case 'created':
            case 'available':
                return 'status-badge--success';
            case 'assigned':
            case 'in_service':
                return 'status-badge--primary';
            case 'inactive': return 'status-badge--warning';
            case 'maintenance': return 'status-badge--danger';
            case 'completed': return 'status-badge--default';
            default: return 'status-badge--default';
        }
    };

    // ----------------------------
    // ROUTES TAB
    // ----------------------------
    const renderRoutesTab = () => (
     <section className="">
           <div className="page-header">
             <Route size={24} />
             <h1 className="page-title">Routes Management</h1>
           </div>
           <div className="card-header">
             <h3 className="card__title">All Routes</h3>
             <button
               className="btn btn--primary"
               onClick={() => onAction && onAction('add')}
             >
               <Plus size={18} />
               Add Route
             </button>
           </div>
           <div className="card-content">
             <table className="data-table">
               <thead>
                 <tr>
                   <th>Route Name</th>
                   <th>Stops</th>
                   <th>Status</th>
                   <th>Assigned To</th>
                   <th>Actions</th>
                 </tr>
               </thead>
               <tbody>
                {routesLoading ? (
                    <tr><td colSpan="5" style={{ textAlign: 'center', padding: '1rem' }}>Loading...</td></tr>
                ) : routesError ? (
                    <tr><td colSpan="5" style={{ textAlign: 'center', padding: '1rem', color: '#f43f5e' }}>{routesError}</td></tr>
                ) : routeData.length === 0 ? (
                    <tr><td colSpan="5" style={{ textAlign: 'center', padding: '1rem' }}>No routes found.</td></tr>
                ) : (
                 routeData.map(route => {
                    const assignedTruck = truckData.find(t => t.collector.id === route.assignedToId);
                    const driverName = assignedTruck ? assignedTruck.collector.name : "Unassigned";

                    return (
                       <tr key={route.id}>
                         <td className="font-medium">{route.name}</td>
                         <td>{route.stops ? route.stops.length : 0}</td>
                         <td>
                           <span className={`status-badge ${getStatusColor(route.status)}`}>
                             {route.status.replace('_', ' ')}
                           </span>
                         </td>
                         <td>
                            <span className={`assignment-text ${route.assignedToId ? 'assignment-text--assigned' : 'assignment-text--unassigned'}`}>
                                {route.assignedToId ? driverName : 'Unassigned'}
                            </span>
                         </td>
                         <td>
                           <div className="action-buttons">
                             <button
                               className="btn-icon btn-icon--primary"
                               onClick={() => onAction && onAction('edit', route)}
                               title="Edit Route"
                             >
                               <Pencil size={16} />
                             </button>
                             <button
                               className="btn-icon btn-icon--danger"
                               onClick={() => onAction && onAction('delete', {
                                 name: route.name,
                                 deleteCallback: () => handleDeleteRoute(route.id)
                               })}
                               title="Delete Route"
                             >
                               <Trash2 size={16} />
                             </button>
                           </div>
                         </td>
                       </tr>
                    );
                 })
                )}
               </tbody>
             </table>
           </div>
         </section>
    );

    // ----------------------------
    // ASSIGNMENT TAB
    // ----------------------------
    const renderAssignmentTab = () => {

      const assignedCollectorIds = routeData
        .filter(r => r.status === 'ASSIGNED' || r.status === 'IN_PROGRESS')
        .map(r => r.assignedToId);

      const trucksWithAssignment = truckData.map(t => ({
        ...t,
        isAssigned: assignedCollectorIds.includes(t.collector.id)
      }));

      return (
        <section className="">
            <div className="page-header">
                <Users size={24} />
                <h1 className="page-title">Route Assignment</h1>
            </div>
            <div className="card-content">
                <div className="assignment-container">

                    <div className="assignment-section">
                        <h4 className="section-title"><Truck size={20} /> Drivers & Trucks Status</h4>
                        <div className="driver-truck-grid">
                            {trucksLoading ? <p>Loading trucks...</p> :
                             trucksError ? <p className="error-message">Error: {trucksError}</p> :
                             trucksWithAssignment.length === 0 ? <p>No trucks found.</p> :
                             trucksWithAssignment.map(truckItem => (
                                <div key={truckItem.truck.id} className={`driver-truck-card ${truckItem.isAssigned ? 'driver-truck-card--assigned' : ''}`}>
                                    <div className="driver-truck-header">
                                        <div className="truck-info">
                                            <h5 className="truck-plate">{truckItem.truck.registrationNumber}</h5>
                                            <span className="truck-id">{truckItem.truck.id}</span>
                                        </div>
                                        <span className={`status-badge ${getStatusColor(truckItem.truck.status)}`}>
                                            {truckItem.truck.status.replace('_', ' ')}
                                        </span>
                                    </div>
                                    <div className="driver-details">
                                        <div className="driver-info">
                                            <Users size={16} />
                                            <span>{truckItem.collector.name}</span>
                                        </div>
                                        <div className="truck-details">
                                            <Truck size={16} />
                                            <span>{truckItem.truck.capacityKg} Kg</span>
                                        </div>
                                    </div>
                                    {truckItem.isAssigned && (
                                        <div className="assignment-badge">
                                            <CheckCircle size={14} />
                                            <span>Assigned to Route</span>
                                        </div>
                                    )}
                                </div>
                            ))}
                        </div>
                    </div>

                    <div className="assignment-section">
                        <h4 className="section-title"><Route size={20} /> Available Routes to Assign</h4>
                        <div className="available-routes">
                            {routesLoading ? <p>Loading routes...</p> :
                             routesError ? <p className="error-message">{routesError}</p> :
                             routeData.filter(route => route.status === 'CREATED').length === 0 ? <p>No routes available to assign.</p> :
                             routeData.filter(route => route.status === 'CREATED').map(route => (
                                <div
                                    key={route.id}
                                    className="route-assignment-card"
                                    onClick={() => setSelectedRouteForModal(route)}
                                >
                                    <div className="route-header">
                                        <h5 className="route-name">{route.name}</h5>
                                    </div>
                                    <div className="route-details">
                                        <div className="route-stat"><MapPin size={14} /><span>{route.stops ? route.stops.length : 0} stops</span></div>
                                    </div>
                                    <div className="card-footer-action">
                                        <button className="btn btn--primary btn--small">Assign Truck</button>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>
        </section>
      );
    };

    // ----------------------------
    // ** UPDATED MAP TAB ** (Requested)
    // ----------------------------
    const renderMapTab = () => {

        // Flatten ALL stops from ALL routes
        const allRouteStops = routeData.flatMap(route =>
            route.stops
                ? route.stops.map(stop => ({
                    ...stop,
                    label: `${route.name} - ${stop.binId}`
                }))
                : []
        );

        return (
            <section style={{ height: "100%" }}>
                <div className="page-header">
                    <Route size={24} />
                    <h1 className="page-title">Route Map</h1>
                </div>

                <div
                    className="card"
                    style={{
                        height: "calc(100vh - 150px)",
                        padding: 0,
                        overflow: "hidden"
                    }}
                >
                    {/* PASS ALL STOPS TO MAP */}
                    <Maps stops={allRouteStops} />
                </div>
            </section>
        );
    };

    const renderTabContent = () => {
        switch (activeTab) {
            case 'tab1': return renderRoutesTab();
            case 'tab2': return renderAssignmentTab();
            case 'tab3': return renderMapTab();
            default: return renderRoutesTab();
        }
    };

    return (
        <div className="route-management">
            <main className="page-content">
                <div>
                    {renderTabContent()}
                </div>
            </main>
            <AssignmentModal
                route={selectedRouteForModal}
                trucks={truckData}
                routes={routeData}
                onClose={() => setSelectedRouteForModal(null)}
                onConfirm={handleAssignRoute}
            />
        </div>
    );
};

export default RouteManagement;
