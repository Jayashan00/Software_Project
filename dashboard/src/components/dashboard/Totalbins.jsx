import React from 'react';

const TotalBins = ({ total, active, full, empty }) => {
    return (
        <section className="card total-bins">
            <h3 className="card__title">Total Bins</h3>
            <div className="total-bins__total">{total}</div>

            <div className="total-bins__stats">
                <div className="total-bins__stat">
                    <span className="total-bins__label">Active</span>
                    <div className="total-bins__value-container">
                        <span className="total-bins__value">{active}</span>
                        <span className="total-bins__fraction">/{total}</span>
                    </div>
                </div>

                <div className="total-bins__stat">
                    <span className="total-bins__label">Full</span>
                    <div className="total-bins__value-container">
                        <span className="total-bins__value">{full}</span>
                        <span className="total-bins__fraction">/{total}</span>
                    </div>
                </div>

                <div className="total-bins__stat">
                    <span className="total-bins__label">Empty</span>
                    <div className="total-bins__value-container">
                        <span className="total-bins__value">{empty}</span>
                        <span className="total-bins__fraction">/{total}</span>
                    </div>
                </div>
            </div>
        </section>
    );
};

export default TotalBins;