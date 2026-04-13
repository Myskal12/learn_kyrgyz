import { Outlet, useNavigate, useLocation } from "react-router";
import { Home, BookOpen, Repeat, Trophy, User } from "lucide-react";

export function MainLayout() {
  const navigate = useNavigate();
  const location = useLocation();

  const navItems = [
    { icon: Home, label: "Home", path: "/app" },
    { icon: BookOpen, label: "Learn", path: "/app/roadmap" },
    { icon: Repeat, label: "Practice", path: "/app/practice" },
    { icon: Trophy, label: "Leaderboard", path: "/app/leaderboard" },
    { icon: User, label: "Profile", path: "/app/profile" },
  ];

  const isActive = (path: string) => {
    if (path === "/app") {
      return location.pathname === "/app";
    }
    return location.pathname.startsWith(path);
  };

  return (
    <div className="min-h-screen flex flex-col max-w-[390px] mx-auto" style={{ backgroundColor: 'var(--background)' }}>
      {/* Main content */}
      <div className="flex-1 pb-20 overflow-auto">
        <Outlet />
      </div>

      {/* Bottom navigation */}
      <nav 
        className="fixed bottom-0 left-0 right-0 max-w-[390px] mx-auto bg-white border-t border-[var(--border)] px-4 py-2"
        style={{ boxShadow: '0 -2px 10px rgba(0, 0, 0, 0.05)' }}
      >
        <div className="flex items-center justify-around">
          {navItems.map((item) => {
            const Icon = item.icon;
            const active = isActive(item.path);
            
            return (
              <button
                key={item.path}
                onClick={() => navigate(item.path)}
                className="flex flex-col items-center gap-1 py-2 px-3 rounded-xl transition-colors min-w-[60px]"
                style={{
                  color: active ? 'var(--primary-blue)' : 'var(--text-secondary)',
                }}
              >
                <Icon className="h-5 w-5" strokeWidth={active ? 2.5 : 2} />
                <span className="text-xs">{item.label}</span>
              </button>
            );
          })}
        </div>
      </nav>
    </div>
  );
}
