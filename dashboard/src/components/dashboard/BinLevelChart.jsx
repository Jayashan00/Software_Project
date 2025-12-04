import React from 'react';
import { Bar } from 'react-chartjs-2';
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend } from 'chart.js';

// Register Chart.js components
ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

const BinLevelChart = ({ bins }) => {
  // Safety check: if bins is null or undefined, render nothing or a loader
  if (!bins || !Array.isArray(bins)) {
    return <p style={{color: '#9ca3af', textAlign: 'center'}}>No bin data available for analysis.</p>;
  }

  // Calculate stats based on your backend fields (plasticLevel, paperLevel, glassLevel)
  const full = bins.filter(b =>
    (b.plasticLevel || 0) >= 90 ||
    (b.paperLevel || 0) >= 90 ||
    (b.glassLevel || 0) >= 90
  ).length;

  const empty = bins.length - full;

  const data = {
    labels: ['Critical (>=90%)', 'Normal (<90%)'],
    datasets: [
      {
        label: 'Number of Bins',
        data: [full, empty],
        backgroundColor: [
          'rgba(239, 68, 68, 0.8)', // Red for full
          'rgba(34, 197, 94, 0.8)'  // Green for empty
        ],
        borderColor: [
          'rgba(239, 68, 68, 1)',
          'rgba(34, 197, 94, 1)'
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
        position: 'top',
        labels: { color: '#e5e7eb' } // Light text for dark mode
      },
      title: {
        display: true,
        text: 'Bin Fill Level Status',
        color: '#e5e7eb'
      },
    },
    scales: {
      y: {
        beginAtZero: true,
        ticks: { color: '#9ca3af', stepSize: 1 },
        grid: { color: '#374151' }
      },
      x: {
        ticks: { color: '#9ca3af' },
        grid: { display: false }
      }
    }
  };

  return (
    <div style={{ height: '300px', width: '100%' }}>
      <Bar data={data} options={options} />
    </div>
  );
};

export default BinLevelChart;