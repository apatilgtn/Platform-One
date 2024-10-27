// apps/frontend/src/features/settings/AuditLog/AuditLogViewer.tsx
import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { auditApi } from '@/services/api';
import { AuditLogFilters } from './AuditLogFilters';
import { AuditLogTable } from './AuditLogTable';

export const AuditLogViewer: React.FC = () => {
  const [filters, setFilters] = useState({
    startDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
    endDate: new Date(),
    type: 'all',
    user: '',
  });

  const { data, isLoading } = useQuery(
    ['audit-logs', filters],
    () => auditApi.getLogs(filters)
  );

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-semibold">Audit Log</h2>
        <AuditLogExport filters={filters} />
      </div>

      <AuditLogFilters filters={filters} onChange={setFilters} />
      <AuditLogTable logs={data?.logs ?? []} isLoading={isLoading} />
    </div>
  );
};
