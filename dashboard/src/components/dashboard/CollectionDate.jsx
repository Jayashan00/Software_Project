import React from 'react';

const CollectionDate = () => {
  // Logic: Get tomorrow's date dynamically
  const today = new Date();
  const tomorrow = new Date(today);
  tomorrow.setDate(today.getDate() + 1);

  const day = tomorrow.getDate();
  const monthYear = tomorrow.toLocaleString('default', { month: 'long', year: 'numeric' });

  // Logic for suffix (st, nd, rd, th)
  const getSuffix = (d) => {
    if (d > 3 && d < 21) return 'th';
    switch (d % 10) {
      case 1:  return "st";
      case 2:  return "nd";
      case 3:  return "rd";
      default: return "th";
    }
  };

  return (
    <section className="card collection-date">
      <h3 className="card__title">Next Collection Date</h3>
      <div className="collection-date__content">
        <div className="collection-date__main">
          <span className="collection-date__day">{day}</span>
          <span className="collection-date__superscript">{getSuffix(day)}</span>
          <span className="collection-date__month-year"> {monthYear}</span>
        </div>
        <div className="collection-date__label">Tomorrow</div>
      </div>
    </section>
  );
};

export default CollectionDate;