import React, { useState, useEffect, useCallback } from 'react';
import CollectionDate from './dashboard/CollectionDate';
import AvailableTrucks from './dashboard/AvailableTrucks';
import MaintenanceRequests from './dashboard/MaintenanceRequests.jsx';
import TotalBins from './dashboard/Totalbins.jsx';
import History from './dashboard/History';
import BinLevelChart from './dashboard/BinLevelChart';
import 'leaflet/dist/leaflet.css';
import TruckStatusChart from './dashboard/TruckStatusChart'; // <-- Add this
import { AlertTriangle, BarChart, PieChart, CheckCircle, Clock, Info } from 'lucide-react';

const Dashboard = ({ activeTab, refreshKey, onLogout }) => {

  const [dashboardData, setDashboardData] = useState({
    totalBins: 0,
    binsData: [],
    availableTrucks: 0,
    inServiceTrucks: 0,
    maintenanceCount: 0,
  });

  // --- NEW STATE FOR ALERTS ---
  const [alerts, setAlerts] = useState([]);
  // ----------------------------

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const jwtToken = localStorage.getItem('token');

  const fetchDashboardData = useCallback(async () => {
    setLoading(true);
    setError(null);

    const API_CALLS = [
      { key: 'allBins', url: '/api/bins' },
      { key: 'availableTrucks', url: '/api/admin/trucks?status=AVAILABLE' },
      { key: 'inServiceTrucks', url: '/api/admin/trucks?status=IN_SERVICE' },
      { key: 'maintenance', url: '/api/maintenance-requests' },

      // --- 1. ADD NOTIFICATIONS API CALL ---
      { key: 'notifications', url: '/api/notifications' }
      // -------------------------------------
    ];

    try {
        const promises = API_CALLS.map(call =>
            fetch(call.url, { headers: { 'Authorization': `Bearer ${jwtToken}` } })
                .then(res => {
                    if (res.status === 401) {
                        if (onLogout) onLogout();
                        throw new Error('Session expired. Please log in.');
                    }
                    if (!res.ok) throw new Error(`API failed for ${call.key}`);
                    return res.json();
                })
        );

        const results = await Promise.all(promises);

        setDashboardData({
            totalBins: results[0].data ? results[0].data.length : 0,
            binsData: results[0].data || [],
            availableTrucks: results[1].data ? results[1].data.length : 0,
            inServiceTrucks: results[2].data ? results[2].data.length : 0,
            maintenanceCount: results[3].data?.content ? results[3].data.content.length : 0,
        });

        // --- 2. SET ALERTS STATE ---
        setAlerts(Array.isArray(results[4].data) ? results[4].data : []);
        // ---------------------------

    } catch (err) {
        setError(err.message);
        console.error("Dashboard Fetch Error:", err);
    } finally {
        setLoading(false);
    }
  }, [jwtToken, onLogout]);

  useEffect(() => {
    fetchDashboardData();
  }, [fetchDashboardData, refreshKey]);


  // --- TAB 1: OVERVIEW ---
  const renderOverviewTab = () => {
    if (loading) return <p className="text-center" style={{padding: '3rem', color: '#9ca3af'}}>Loading dashboard...</p>;
    if (error) return <p className="text-center error-message" style={{padding: '3rem'}}>Error: {error}</p>;

    const { totalBins, maintenanceCount, availableTrucks, inServiceTrucks } = dashboardData;

    return (
      <div className="dashboard__grid">
        <CollectionDate />
        <AvailableTrucks available={availableTrucks} inService={inServiceTrucks} />
        <MaintenanceRequests count={maintenanceCount} />
        <TotalBins total={totalBins} />
        <History />
      </div>
    );
  };

  // --- TAB 2: STATISTICS ---
  // --- TAB 2: STATISTICS (COMPLETED) ---
    const renderStatisticsTab = () => (
      <div className="dashboard__grid" style={{ gridTemplateColumns: '1fr 1fr' }}>

        {/* Chart 1: Bin Levels (Bar Chart) */}
        <div className="card" style={{ minHeight: '400px' }}>
          <h3 className="card__title" style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <BarChart size={20} className="text-blue-500" />
            Bin Fill Level Trends
          </h3>
          <div className="card-content">
            <BinLevelChart bins={dashboardData.binsData} />
          </div>
        </div>

        {/* Chart 2: Truck Fleet Status (Pie Chart) - FIXED */}
        <div className="card" style={{ minHeight: '400px' }}>
          <h3 className="card__title" style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <PieChart size={20} className="text-blue-500" />
            Fleet Status
          </h3>
          <div className="card-content">
            {/* Pass the real data from dashboardData state */}
            <TruckStatusChart
               available={dashboardData.availableTrucks}
               inService={dashboardData.inServiceTrucks}
            />
          </div>
        </div>
      </div>
    );

  // --- TAB 3: ALERTS (FULLY IMPLEMENTED) ---
  const renderAlertsTab = () => {

    // Helper to style alerts based on priority
    const getAlertStyle = (priority) => {
        switch(priority) {
            case 'HIGH': return { borderLeft: '4px solid #ef4444', bg: '#2a3439' }; // Red
            case 'MEDIUM': return { borderLeft: '4px solid #f59e0b', bg: '#2a3439' }; // Orange
            case 'LOW': return { borderLeft: '4px solid #10b981', bg: '#2a3439' }; // Green
            default: return { borderLeft: '4px solid #3b82f6', bg: '#2a3439' }; // Blue
        }
    };

    return (
        <div className="card" style={{ gridColumn: '1 / -1', minHeight: '60vh' }}>
            <h3 className="card__title" style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <AlertTriangle size={20} color="#f44336" />
                System Alerts & Notifications
            </h3>

            <div className="card-content">
                {alerts.length === 0 ? (
                    <div style={{ textAlign: 'center', padding: '3rem', color: '#9ca3af' }}>
                        <CheckCircle size={48} style={{ marginBottom: '1rem', opacity: 0.5 }} />
                        <p>No active alerts. System is running smoothly.</p>
                    </div>
                ) : (
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                        {alerts.map((alert) => {
                            const style = getAlertStyle(alert.priority);
                            return (
                                <div key={alert.id} style={{
                                    backgroundColor: style.bg,
                                    borderLeft: style.borderLeft,
                                    padding: '1rem',
                                    borderRadius: '4px',
                                    display: 'flex',
                                    justifyContent: 'space-between',
                                    alignItems: 'flex-start',
                                    boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
                                }}>
                                    <div>
                                        <h4 style={{ margin: '0 0 0.5rem 0', color: '#f3f4f6', display: 'flex', alignItems: 'center', gap: '8px' }}>
                                            {alert.priority === 'HIGH' && <AlertTriangle size={16} color="#ef4444" />}
                                            {alert.title}
                                        </h4>
                                        <p style={{ margin: 0, color: '#9ca3af', fontSize: '0.95rem' }}>
                                            {alert.message}
                                        </p>
                                    </div>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: '#6b7280', fontSize: '0.8rem', whiteSpace: 'nowrap' }}>
                                        <Clock size={14} />
                                        <span>{new Date(alert.createdAt).toLocaleString()}</span>
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                )}
            </div>
        </div>
    );
  };

  const renderTabContent = () => {
    switch (activeTab) {
      case 'tab1': return renderOverviewTab();
      case 'tab2': return renderStatisticsTab();
      case 'tab3': return renderAlertsTab();
      default: return renderOverviewTab();
    }
  };

  return (
    <main className="dashboard">
      {renderTabContent()}
    </main>
  );
};

export default Dashboard;