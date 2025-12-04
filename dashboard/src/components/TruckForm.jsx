import React, { useState, useEffect } from 'react';

// This component can now be used for ADDING or EDITING
const TruckForm = ({ existingTruck, onSave, onCancel, token }) => {

  // If 'existingTruck' is provided, fill the form for editing.
  const [registrationNumber, setRegistrationNumber] = useState(existingTruck?.registrationNumber || '');
  const [capacity, setCapacity] = useState(existingTruck?.capacityKg || '');

  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  // --- THIS IS THE FIX ---
  // Define isEditMode here so it's available for both handleSubmit and the render
  const isEditMode = !!existingTruck;
  // --- END OF FIX ---

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    // Determine the endpoint and method
    const endpoint = isEditMode
      ? `/api/admin/trucks/${existingTruck.id}`
      : '/api/admin/trucks/add';

    const method = isEditMode ? 'PUT' : 'POST';

    const body = {
      registrationNumber: registrationNumber,
      capacity: parseInt(capacity, 10)
    };

    if (isNaN(body.capacity) || body.capacity <= 0) {
        setError('Capacity must be a valid positive number.');
        setIsLoading(false);
        return;
    }

    try {
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
        throw new Error(errData.message || `Failed to ${isEditMode ? 'update' : 'create'} truck`);
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
      <div className="form-group">
        <label htmlFor="registrationNumber">Registration Number</label>
        <input
          id="registrationNumber"
          type="text"
          className="form-input"
          value={registrationNumber}
          onChange={(e) => setRegistrationNumber(e.target.value)}
          required
        />
      </div>

      <div className="form-group">
        <label htmlFor="capacity">Capacity (in kg)</label>
        <input
          id="capacity"
          type="number"
          className="form-input"
          value={capacity}
          onChange={(e) => setCapacity(e.target.value)}
          required
          min="1"
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
          {/* This line is now fixed */}
          {isLoading ? 'Saving...' : (isEditMode ? 'Update' : 'Save')}
        </button>
      </div>
    </form>
  );
};

export default TruckForm;