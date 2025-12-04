import React from 'react';

const AvailableTrucks = ({ available, inService, repair }) => {
    return (
        <section className="card available-trucks">
            <h3 className="card__title">Trucks Overview</h3>
            <div className="available-trucks__stats">

                <div className="available-trucks__stat">
                    <span className="available-trucks__label">Available</span>
                    <span className="available-trucks__value available-trucks__value--idle">{available}</span>
                </div>

                <div className="available-trucks__stat">
                    <span className="available-trucks__label">On Route</span>
                    <span className="available-trucks__value available-trucks__value--route">{inService}</span>
                </div>

                <div className="available-trucks__stat">
                    <span className="available-trucks__label">Repair</span>
                    <span className="available-trucks__value available-trucks__value--repair">{repair}</span>
                </div>
            </div>
        </section>
    );
};

export default AvailableTrucks;