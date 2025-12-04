import React, { useState } from "react";

/**
 * BinForm Component
 * ------------------
 * Allows users to add or edit Smart Waste Bins.
 *
 * Props:
 * - existingBin: Bin object (if editing)
 * - onSave: Callback triggered after successful save
 * - onCancel: Callback triggered when cancel button clicked
 * - token: JWT auth token for API calls
 */
const BinForm = ({ existingBin, onSave, onCancel, token }) => {
  const isEditMode = !!existingBin;

  // Form state
  const [binId, setBinId] = useState(existingBin?.binId || "");
  const [latitude, setLatitude] = useState(existingBin?.latitude || "");
  const [longitude, setLongitude] = useState(existingBin?.longitude || "");

  // UI state
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  // Handle form submission
  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError("");

    const endpoint = isEditMode
      ? `/api/bins/${existingBin.binId}`
      : `/api/bins/add`;

    const method = isEditMode ? "PUT" : "POST";

    let body = {};

    if (isEditMode) {
      // Edit: Update only lat/lon
      const latNum = parseFloat(latitude);
      const lonNum = parseFloat(longitude);

      if (isNaN(latNum) || isNaN(lonNum)) {
        setError("Latitude and Longitude must be valid numbers.");
        setIsLoading(false);
        return;
      }

      body = { latitude: latNum, longitude: lonNum };
    } else {
      // Add: Only Bin ID at first
      if (!binId.trim()) {
        setError("Bin ID cannot be empty.");
        setIsLoading(false);
        return;
      }

      body = { binId: binId.trim() };
    }

    try {
      const response = await fetch(endpoint, {
        method: method,
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(body),
      });

      if (!response.ok) {
        const errData = await response.json().catch(() => ({}));
        throw new Error(
          errData.message ||
            `Failed to ${isEditMode ? "update" : "create"} bin.`
        );
      }

      // Success — refresh data
      onSave();
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form className="app__modal-form" onSubmit={handleSubmit}>
      {/* Bin ID Field */}
      <div className="form-group">
        <label htmlFor="binId">Bin ID</label>
        <input
          id="binId"
          type="text"
          className="form-input"
          value={binId}
          onChange={(e) => setBinId(e.target.value)}
          required
          disabled={isEditMode} // Can't edit ID in edit mode
          placeholder="e.g., BIN-005"
        />
      </div>

      {/* Lat/Lon Fields (only visible in edit mode) */}
      {isEditMode && (
        <>
          <div className="form-group">
            <label htmlFor="latitude">Latitude</label>
            <input
              id="latitude"
              type="number"
              step="any"
              className="form-input"
              value={latitude}
              onChange={(e) => setLatitude(e.target.value)}
              required
              placeholder="e.g., 6.9271"
            />
          </div>

          <div className="form-group">
            <label htmlFor="longitude">Longitude</label>
            <input
              id="longitude"
              type="number"
              step="any"
              className="form-input"
              value={longitude}
              onChange={(e) => setLongitude(e.target.value)}
              required
              placeholder="e.g., 79.8612"
            />
          </div>
        </>
      )}

      {/* Help text when adding a bin */}
      {!isEditMode && (
        <small
          style={{
            color: "#9ca3af",
            marginTop: "4px",
            display: "block",
            fontSize: "0.9rem",
          }}
        >
          Latitude and Longitude can be added later by editing the bin.
        </small>
      )}

      {/* Error message */}
      {error && (
        <p className="error-message" style={{ color: "red", marginTop: "10px" }}>
          {error}
        </p>
      )}

      {/* Buttons */}
      <div className="app__modal-footer" style={{ marginTop: "16px" }}>
        <button
          type="button"
          className="btn btn--secondary"
          onClick={onCancel}
          disabled={isLoading}
        >
          Cancel
        </button>

        <button
          type="submit"
          className="btn btn--primary"
          disabled={isLoading}
        >
          {isLoading
            ? "Saving..."
            : isEditMode
            ? "Update Location"
            : "Save Bin"}
        </button>
      </div>
    </form>
  );
};

export default BinForm;
