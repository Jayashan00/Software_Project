import React, { useState } from 'react';

const TruckAssignCollectorForm = ({ truck, collectors, onSave, onCancel, token }) => {
  const [selectedCollectorId, setSelectedCollectorId] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    if (!selectedCollectorId) {
      setError('Please select a collector to assign.');
      setIsLoading(false);
      return;
    }

    // --- THIS IS THE FIX ---
    // We are now calling the correct Admin endpoint
    const endpoint = '/api/admin/trucks/assign-collector';
    const body = {
      truckId: truck.id,
      collectorId: selectedCollectorId
    };
    // --- END OF FIX ---

    try {
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(body)
      });

      if (!response.ok) {
        const errData = await response.json();
        throw new Error(errData.message || 'Failed to assign truck');
      }

      onSave(); // This will close the modal and refresh the data

    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form className="app__modal-form" onSubmit={handleSubmit}>
      <p style={{fontSize: '0.9rem', color: '#cbd5e1'}}>
        Assigning Truck: <strong>{truck.registrationNumber}</strong> (ID: {truck.id})
      </p>

      <div className="form-group">
        <label htmlFor="collector">Select an Available Collector</label>
        <select
          id="collector"
          className="form-input"
          value={selectedCollectorId}
          onChange={(e) => setSelectedCollectorId(e.target.value)}
          required
        >
          <option value="" disabled>-- Select a collector --</option>
          {collectors.length > 0 ? (
            collectors.map(collector => (
              <option key={collector.id} value={collector.id}>
                {collector.name}
              </option>
            ))
          ) : (
            <option disabled>No available collectors found</option>
          )}
        </select>
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
          disabled={isLoading || collectors.length === 0}
        >
          {isLoading ? 'Assigning...' : 'Assign'}
        </button>
      </div>
    </form>
  );
};

export default TruckAssignCollectorForm;