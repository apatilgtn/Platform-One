// apps/frontend/src/components/layout/Header.tsx
import { useAuth } from '@/hooks/useAuth';
import { Logo } from '@/components/common/Logo';

export const Header = () => {
  const { user, logout } = useAuth();

  return (
    <header className="bg-white shadow-sm">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex">
            <Logo />
            <nav className="ml-6 flex space-x-8">
              <NavLink to="/dashboard">Dashboard</NavLink>
              <NavLink to="/services">Services</NavLink>
              <NavLink to="/monitoring">Monitoring</NavLink>
            </nav>
          </div>
          <div className="flex items-center">
            <span className="text-sm text-gray-700 mr-4">{user?.name}</span>
            <button
              onClick={logout}
              className="text-sm text-gray-700 hover:text-gray-900"
            >
              Logout
            </button>
          </div>
        </div>
      </div>
    </header>
  );
};