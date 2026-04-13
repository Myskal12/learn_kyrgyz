import { useNavigate } from "react-router";
import { Button } from "../components/ui/button";
import { Home } from "lucide-react";

export function NotFound() {
  const navigate = useNavigate();

  return (
    <div 
      className="min-h-screen flex items-center justify-center px-6"
      style={{ backgroundColor: 'var(--background)' }}
    >
      <div className="text-center">
        <h1 className="text-6xl mb-4 text-[var(--primary-blue)]">404</h1>
        <h2 className="text-2xl mb-2 text-[var(--text-primary)]">Page not found</h2>
        <p className="text-[var(--text-secondary)] mb-8">
          The page you're looking for doesn't exist
        </p>
        <Button
          onClick={() => navigate("/app")}
          className="rounded-2xl px-6 h-12"
          style={{ backgroundColor: 'var(--primary-blue)' }}
        >
          <Home className="mr-2 h-5 w-5" />
          Go Home
        </Button>
      </div>
    </div>
  );
}
