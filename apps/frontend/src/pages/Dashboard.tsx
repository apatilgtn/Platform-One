// src/pages/Dashboard.tsx
import React from 'react';
import { Link } from 'react-router-dom';

const Dashboard = () => {
  return (
    <div>
      <h2 className="text-2xl font-bold mb-4">Dashboard</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <Link to="/services">
          <div className="bg-white p-6 rounded-lg shadow-sm hover:shadow-md transition-shadow">
            <h3 className="text-lg font-semibold">Services</h3>
            <p className="text-gray-600">Manage your services</p>
          </div>
        </Link>
      </div>
    </div>
  );
};

export default Dashboard;