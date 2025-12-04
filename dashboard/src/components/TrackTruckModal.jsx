import React from 'react';
import { Truck } from 'lucide-react';
import {
  APIProvider,
  Map,
  AdvancedMarker,
  Pin
} from '@vis.gl/react-google-maps';

const TrackTruckModal = ({ truckData, onCancel, onSave }) => {
    const { id: truckId, registrationNumber } = truckData;
    const apiKey = import.meta.env.VITE_Maps_API_KEY;
    const mapId = import.meta.env.VITE_Maps_ID;

    // --- MOCK LOCATION (Colombo) ---
    // NOTE: Your backend Truck entity does not yet have 'latitude' and 'longitude' fields.
    // Once you add those to the backend, you can pass them in truckData.
    const truckLocation = { lat: 6.9271, lng: 79.8612 };
    const lastUpdateTime = new Date().toLocaleTimeString();

    return (
        // Wrapper div with specific styling for the modal content
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', height: '100%' }}>

            <div>
                <h3 style={{ margin: 0, display: 'flex', alignItems: 'center', gap: '10px', color: '#e5e7eb' }}>
                    <Truck size={24} color="#60a5fa" />
                    Tracking: {registrationNumber}
                </h3>
                <p style={{ color: '#9ca3af', fontSize: '0.9rem', marginTop: '4px' }}>
                    Truck ID: {truckId}
                </p>
            </div>

            {/* MAP CONTAINER */}
            <div style={{
                width: '100%',
                height: '350px',
                borderRadius: '12px',
                overflow: 'hidden',
                border: '2px solid #374151'
            }}>
                <APIProvider apiKey={apiKey}>
                    <Map
                        defaultCenter={truckLocation}
                        defaultZoom={15}
                        mapId={mapId}
                        style={{ width: '100%', height: '100%' }}
                        disableDefaultUI={false}
                        gestureHandling={'greedy'}
                    >
                        {/* Truck Marker */}
                        <AdvancedMarker position={truckLocation}>
                            <Pin
                                background={"#ef4444"} // Red color for truck
                                borderColor={"#b91c1c"}
                                glyphColor={"white"}
                            />
                        </AdvancedMarker>
                    </Map>
                </APIProvider>
            </div>

            {/* Footer Info */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', color: '#9ca3af', fontSize: '0.85rem' }}>
                <span>Status: <strong>In Transit</strong></span>
                <span>Last Updated: {lastUpdateTime}</span>
            </div>

            {/* Action Buttons */}
            <div className="app__modal-footer">
                <button className="btn btn--secondary" onClick={onCancel} type="button">
                    Close
                </button>
            </div>
        </div>
    );
};

export default TrackTruckModal;