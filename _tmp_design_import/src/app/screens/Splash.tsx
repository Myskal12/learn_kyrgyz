import { useEffect } from "react";
import { useNavigate } from "react-router";
import { TundukLogo } from "../components/TundukLogo";

export function Splash() {
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setTimeout(() => {
      navigate("/onboarding");
    }, 2000);

    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div 
      className="min-h-screen flex items-center justify-center"
      style={{ background: 'linear-gradient(to bottom, #FAF8F4, #F5E9DA)' }}
    >
      <div className="flex flex-col items-center gap-6 animate-fade-in">
        <TundukLogo size={120} />
        <h1 className="text-3xl text-[var(--text-primary)]">Kyrgyz</h1>
      </div>
    </div>
  );
}
