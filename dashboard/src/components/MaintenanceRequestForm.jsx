import React, { useState } from 'react';

const MaintenanceRequestForm = ({ existingRequest, bins, onSave, onCancel, token }) => {
  const isEditMode = !!existingRequest;

  // Initialize state
  const [binId, setBinId] = useState(existingRequest?.binId || '');
  const [requestType, setRequestType] = useState(existingRequest?.requestType || 'Repair');
  const [description, setDescription] = useState(existingRequest?.description || '');
  const [priority, setPriority] = useState(existingRequest?.priority || 'MEDIUM');

  // --- NEW: Status State ---
  const [status, setStatus] = useState(existingRequest?.status || 'PENDING');

  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const requestTypes = ['Repair', 'Sensor Malfunction', 'Physical Damage', 'Lid Issue', 'Other'];
  const priorityOptions = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];
  // --- NEW: Status Options ---
  const statusOptions = ['PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'];

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      // 1. Update Basic Details (Description, Priority, Type)
      const endpoint = isEditMode
          ? `/api/maintenance-requests/${existingRequest.id}`
          : '/api/maintenance-requests';

      const method = isEditMode ? 'PUT' : 'POST';

      const body = {
        binId: binId,
        requestType: requestType,
        description: description,
        priority: priority,
      };

      const response = await fetch(endpoint, {
        method: method,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(body)
      });

      if (!response.ok) {
        const errData = await response.json();
        throw new Error(errData.message || `Failed to save request details`);
      }

      // 2. Update Status (Only in Edit Mode and if status changed)
      // The backend has a separate endpoint for status: PUT /api/maintenance-requests/{id}/status?status=...
      if (isEditMode && status !== existingRequest.status) {
        const statusResponse = await fetch(
          `/api/maintenance-requests/${existingRequest.id}/status?status=${status}`,
          {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json', // Content-Type isn't strictly needed for query params but good practice
              'Authorization': `Bearer ${token}`
            }
          }
        );

        if (!statusResponse.ok) {
           console.warn("Details saved, but status update failed.");
           // We won't throw here to avoid blocking the UI, but you could
        }
      }

      onSave(); // Close modal & refresh

    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form className="app__modal-form" onSubmit={handleSubmit}>

      {/* Bin ID Selection/Display */}
      <div className="form-group">
        <label htmlFor="binId">Bin ID</label>
        {isEditMode ? (
            <input className="form-input" value={binId} disabled />
        ) : (
            <select
                id="binId"
                className="form-input"
                value={binId}
                onChange={(e) => setBinId(e.target.value)}
                required
            >
                <option value="" disabled>-- Select Bin --</option>
                {bins.length > 0 ? (
                    bins.map(bin => (
                        <option key={bin.binId} value={bin.binId}>
                            {bin.binId}
                        </option>
                    ))
                ) : (
                    <option disabled>No bins available.</option>
                )}
            </select>
        )}
      </div>

      {/* Request Type */}
      <div className="form-group">
        <label htmlFor="requestType">Request Type</label>
        <select
          id="requestType"
          className="form-input"
          value={requestType}
          onChange={(e) => setRequestType(e.target.value)}
          required
        >
          {requestTypes.map(type => (
              <option key={type} value={type}>{type}</option>
          ))}
        </select>
      </div>

      {/* Priority */}
      <div className="form-group">
        <label htmlFor="priority">Priority</label>
        <select
          id="priority"
          className="form-input"
          value={priority}
          onChange={(e) => setPriority(e.target.value)}
          required
        >
          {priorityOptions.map(opt => (
              <option key={opt} value={opt}>{opt}</option>
          ))}
        </select>
      </div>

      {/* --- NEW: Status Dropdown (Edit Mode Only) --- */}
      {isEditMode && (
        <div className="form-group">
          <label htmlFor="status">Status</label>
          <select
            id="status"
            className="form-input"
            value={status}
            onChange={(e) => setStatus(e.target.value)}
            required
            style={{ borderColor: status === 'COMPLETED' ? '#4ade80' : '' }}
          >
            {statusOptions.map(opt => (
              <option key={opt} value={opt}>
                {opt.replace('_', ' ')}
              </option>
            ))}
          </select>
        </div>
      )}

      {/* Description */}
      <div className="form-group">
        <label htmlFor="description">Description</label>
        <textarea
          id="description"
          className="form-input"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          required
          rows={3}
        />
      </div>

      {error && <p className="error-message">{error}</p>}

      <div className="app__modal-footer">
        <button
          className="btn btn--secondary"
          type="button"
          onClick={onCancel}
          disabled={isLoading}
        >
          Cancel
        </button>
        <button
          className="btn btn--primary"
          type="submit"
          disabled={isLoading}
        >
          {isLoading ? 'Saving...' : (isEditMode ? 'Update' : 'Submit')}
        </button>
      </div>
    </form>
  );
};

export default MaintenanceRequestForm;