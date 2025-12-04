import React from 'react';

const MaintenanceRequests = ({ count, emergency }) => {
    return (
        <section className="card maintenance-requests">
            <h3 className="card__title">Maintenance</h3>
            <div className="maintenance-requests__stats">
                <div className="maintenance-requests__stat">
                    <span className="maintenance-requests__label">Emergency</span>
                    <span className="maintenance-requests__value maintenance-requests__value--emergency">{emergency}</span>
                </div>
                <div className="maintenance-requests__stat">
                    <span className="maintenance-requests__label">Total Open</span>
                    <span className="maintenance-requests__value available-trucks__value--route">{count}</span>
                </div>
            </div>
        </section>
    );
};

export default MaintenanceRequests;