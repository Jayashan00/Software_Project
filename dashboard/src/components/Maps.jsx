import React, { useState, useEffect, useMemo } from "react";
import {
  APIProvider,
  Map,
  AdvancedMarker,
  Pin,
  useMap,
  useMapsLibrary,
} from "@vis.gl/react-google-maps";
import "../styles/Maps.css";

// Default fallback location (Colombo, Sri Lanka) if no data is passed
const DEFAULT_CENTER = { lat: 6.9271, lng: 79.8612 };

const Maps = ({ stops = [] }) => {
  const apiKey = import.meta.env.VITE_Maps_API_KEY;
  const mapId = import.meta.env.VITE_Maps_ID;

  if (!apiKey) {
    return <div className="map-error">Error: Missing VITE_Maps_API_KEY in .env file.</div>;
  }
  if (!mapId) {
    return <div className="map-error">Error: Missing VITE_Maps_ID in .env file.</div>;
  }

  // 1. Normalize the data: Backend uses 'latitude/longitude', Google Maps uses 'lat/lng'
  const normalizedStops = useMemo(() => {
    if (!stops || stops.length === 0) return [];

    return stops.map((stop, index) => ({
      lat: stop.latitude || stop.lat,
      lng: stop.longitude || stop.lng,
      label: stop.binId || stop.label || `${index + 1}`,
      id: stop.id || index
    })).filter(pos => pos.lat && pos.lng); // Filter out invalid coordinates
  }, [stops]);

  return (
    <APIProvider apiKey={apiKey} libraries={["geometry", "places"]}>
      <MapWithRoute stops={normalizedStops} mapId={mapId} />
    </APIProvider>
  );
};

// Internal component to handle Map logic and Route API
const MapWithRoute = ({ stops, mapId }) => {
  const [routePath, setRoutePath] = useState([]);
  const [info, setInfo] = useState({ distance: "0 km", duration: "0 mins" });

  const geometry = useMapsLibrary("geometry");
  const apiKey = import.meta.env.VITE_Maps_API_KEY;

  // 2. Fetch Route Logic
  useEffect(() => {
    // We need at least 2 stops to calculate a route
    if (!geometry || stops.length < 2 || !apiKey) {
      setRoutePath([]);
      setInfo({ distance: "0 km", duration: "0 mins" });
      return;
    }

    const fetchRoute = async () => {
      const formatWaypoint = (stop) => ({
        location: { latLng: { latitude: stop.lat, longitude: stop.lng } },
      });

      const originWaypoint = formatWaypoint(stops[0]);
      const destinationWaypoint = formatWaypoint(stops[stops.length - 1]);
      // Google Routes API limits intermediates (max 25 for basic tier), slicing if necessary
      const intermediateWaypoints = stops.slice(1, -1).map(formatWaypoint);

      try {
        const res = await fetch("https://routes.googleapis.com/directions/v2:computeRoutes", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-Goog-Api-Key": apiKey,
            "X-Goog-FieldMask": "routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline",
          },
          body: JSON.stringify({
            origin: originWaypoint,
            destination: destinationWaypoint,
            intermediates: intermediateWaypoints,
            travelMode: "DRIVE",
            routingPreference: "TRAFFIC_AWARE",
            // optimizeWaypointOrder: true, // Optional: Let Google reorder stops for efficiency
          }),
        });

        if (!res.ok) {
          const errorBody = await res.json();
          console.error("Route API Error:", errorBody);
          return;
        }

        const data = await res.json();
        const route = data.routes?.[0];

        if (route) {
          const decodedPath = google.maps.geometry.encoding.decodePath(route.polyline.encodedPolyline);
          setRoutePath(decodedPath);
          setInfo({
            distance: `${(route.distanceMeters / 1000).toFixed(1)} km`,
            duration: `${Math.round(parseInt(route.duration, 10) / 60)} mins`,
          });
        }
      } catch (error) {
        console.error("Failed to fetch route:", error);
      }
    };

    fetchRoute();
  }, [geometry, stops, apiKey]);

  return (
    <div className="map-container-wrapper">
      {/* Sidebar for Route Info */}
      <div className="map-sidebar">
        <h3>Current Route</h3>

        <div className="route-summary">
          <p><strong>Total Distance:</strong> {info.distance}</p>
          <p><strong>Est. Time:</strong> {info.duration}</p>
        </div>

        <hr />

        <h4>Stops Sequence:</h4>
        {stops.length === 0 ? (
          <p style={{fontStyle: 'italic'}}>No stops selected.</p>
        ) : (
          <ol className="stops-list">
            {stops.map((s, i) => (
              <li key={`${s.id}-${i}`}>
                <span className="stop-label">{s.label}</span>
                <span className="stop-coords">{s.lat.toFixed(4)}, {s.lng.toFixed(4)}</span>
              </li>
            ))}
          </ol>
        )}
      </div>

      {/* Actual Map */}
      <div style={{ flexGrow: 1, position: 'relative' }}>
        <Map
          defaultZoom={13}
          defaultCenter={DEFAULT_CENTER}
          mapId={mapId}
          style={{ width: '100%', height: '100%' }}
          gestureHandling={'greedy'}
          disableDefaultUI={false}
        >
          {/* Helper to auto-zoom to fit markers */}
          <MapUpdater stops={stops} />

          {/* Render Markers */}
          {stops.map((s, i) => (
            <AdvancedMarker
              key={`${s.label}-${i}`}
              position={{ lat: s.lat, lng: s.lng }}
            >
              <Pin
                background={i === 0 ? "#16a34a" : i === stops.length - 1 ? "#dc2626" : "#4285F4"}
                borderColor={"white"}
                glyphColor={"white"}
              >
                {/* Display index+1 or label */}
                <span style={{fontSize: '10px', fontWeight: 'bold'}}>{i + 1}</span>
              </Pin>
            </AdvancedMarker>
          ))}

          {/* Render Route Polyline */}
          <DirectionsPolyline path={routePath} />
        </Map>
      </div>
    </div>
  );
};

// Component to draw the line on the map
const DirectionsPolyline = ({ path }) => {
  const map = useMap();

  useEffect(() => {
    if (!map || !path || path.length === 0) return;

    const polyline = new google.maps.Polyline({
      path: path,
      map: map,
      strokeColor: "#3b82f6", // Blue color matching your theme
      strokeOpacity: 0.8,
      strokeWeight: 6,
    });

    return () => {
      polyline.setMap(null);
    };
  }, [map, path]);

  return null;
};

// Component to Auto-Fit the map bounds based on markers
const MapUpdater = ({ stops }) => {
  const map = useMap();

  useEffect(() => {
    if (!map || stops.length === 0) return;

    const bounds = new google.maps.LatLngBounds();
    stops.forEach((stop) => {
      bounds.extend({ lat: stop.lat, lng: stop.lng });
    });

    // If only 1 stop, zoom in close. If multiple, fit bounds.
    if (stops.length === 1) {
      map.setCenter({ lat: stops[0].lat, lng: stops[0].lng });
      map.setZoom(15);
    } else {
      map.fitBounds(bounds);

      // Optional: Adjust zoom slightly if it gets too close
      const listener = google.maps.event.addListenerOnce(map, "idle", () => {
        if (map.getZoom() > 16) map.setZoom(16);
      });
      return () => google.maps.event.removeListener(listener);
    }
  }, [map, stops]);

  return null;
};

export default Maps;