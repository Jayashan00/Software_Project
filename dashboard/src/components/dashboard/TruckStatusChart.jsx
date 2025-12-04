import React from 'react';
import { Pie } from 'react-chartjs-2';
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js';

// Register Pie chart components
ChartJS.register(ArcElement, Tooltip, Legend);

const TruckStatusChart = ({ available, inService }) => {
  // If no data, show a safe default
  const hasData = available > 0 || inService > 0;

  const data = {
    labels: ['Available', 'On Route'],
    datasets: [
      {
        label: '# of Trucks',
        data: hasData ? [available, inService] : [1, 0], // Default to 1 available if empty to show circle
        backgroundColor: [
          'rgba(34, 197, 94, 0.8)', // Green for Available
          'rgba(59, 130, 246, 0.8)', // Blue for On Route
        ],
        borderColor: [
          'rgba(34, 197, 94, 1)',
          'rgba(59, 130, 246, 1)',
        ],
        borderWidth: 1,
      },
    ],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'right',
        labels: { color: '#e5e7eb' } // Light text for dark mode
      },
      title: {
        display: false,
      },
    },
  };

  if (!hasData) {
      return (
          <div style={{height: '300px', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#6b7280'}}>
              <p>No truck data available</p>
          </div>
      )
  }

  return (
    <div style={{ height: '300px', width: '100%', display: 'flex', justifyContent: 'center' }}>
      <Pie data={data} options={options} />
    </div>
  );
};

export default TruckStatusChart;