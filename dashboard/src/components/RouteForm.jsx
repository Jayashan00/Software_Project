import React, { useState, useEffect } from 'react';

const RouteForm = ({ existingRoute, onSave, onCancel, token }) => {
  const isEditMode = !!existingRoute;

  const [name, setName] = useState(existingRoute?.name || '');
  // Store bin IDs as a comma-separated string for the textarea
  const [binIds, setBinIds] = useState(
    existingRoute?.stops?.map(stop => stop.binId).join(', ') || ''
  );

  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    // Convert the comma-separated string into an array of strings
    const binIdArray = binIds.split(',')
                             .map(id => id.trim())
                             .filter(id => id.length > 0);

    if (binIdArray.length === 0) {
      setError('You must add at least one Bin ID.');
      setIsLoading(false);
      return;
    }

    const endpoint = isEditMode
      ? `/api/routes/${existingRoute.id}`
      : '/api/routes';

    const method = isEditMode ? 'PUT' : 'POST';

    const body = {
      name: name,
      binIds: binIdArray
    };

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
        throw new Error(errData.message || `Failed to ${isEditMode ? 'update' : 'create'} route`);
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
        <label htmlFor="routeName">Route Name</label>
        <input
          id="routeName"
          type="text"
          className="form-input"
          value={name}
          onChange={(e) => setName(e.target.value)}
          required
          placeholder="e.g., Downtown Morning Route"
        />
      </div>

      <div className="form-group">
        <label htmlFor="binIds">Bin IDs (comma-separated)</label>
        <textarea
          id="binIds"
          className="form-input"
          value={binIds}
          onChange={(e) => setBinIds(e.target.value)}
          required
          rows={3}
          placeholder="e.g., BIN-001, BIN-002, 34"
        />
        <small style={{ color: '#9ca3af', marginTop: '4px', display: 'block' }}>
          Enter the Bin IDs in the order you want them collected.
        </small>
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
          {isLoading ? 'Saving...' : (isEditMode ? 'Update' : 'Save')}
        </button>
      </div>
    </form>
  );
};

export default RouteForm;