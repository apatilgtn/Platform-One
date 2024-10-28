// src/pages/Services.tsx
import React from 'react';
import { useQuery } from '@tanstack/react-query';

const Services = () => {
  const { data: services, isLoading } = useQuery(['services'], () =>
    fetch('http://localhost:8000/api/services').then(res => res.json())
  );

  if (isLoading) return <div>Loading...</div>;

  return (
    <div>
      <h2 className="text-2xl font-bold mb-4">Services</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {services?.map((service: any) => (
          <div key={service.id} className="bg-white p-6 rounded-lg shadow-sm">
            <h3 className="text-lg font-semibold">{service.name}</h3>
            <p className="text-gray-600">{service.description}</p>
            <div className="mt-4">
              <span className={`px-2 py-1 rounded-full text-sm ${
                service.status === 'healthy' ? 'bg-green-100 text-green-800' :
                service.status === 'warning' ? 'bg-yellow-100 text-yellow-800' :
                'bg-red-100 text-red-800'
              }`}>
                {service.status}
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Services;