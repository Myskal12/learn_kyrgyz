import { useState } from "react";
import { useNavigate } from "react-router";
import { Button } from "../components/ui/button";
import { Input } from "../components/ui/input";
import { TundukLogo } from "../components/TundukLogo";

export function Auth() {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const navigate = useNavigate();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Mock auth - just navigate to app
    navigate("/app");
  };

  return (
    <div className="min-h-screen flex flex-col" style={{ backgroundColor: 'var(--background)' }}>
      {/* Header */}
      <div className="flex justify-center pt-16 pb-8">
        <TundukLogo size={80} />
      </div>

      {/* Form */}
      <div className="flex-1 px-8">
        <div className="max-w-sm mx-auto">
          <h1 className="text-3xl mb-2 text-center text-[var(--text-primary)]">
            {isLogin ? "Welcome back" : "Get started"}
          </h1>
          <p className="text-center text-[var(--text-secondary)] mb-10">
            {isLogin ? "Continue your language journey" : "Begin learning Kyrgyz"}
          </p>

          <form onSubmit={handleSubmit} className="space-y-4">
            {!isLogin && (
              <div>
                <label className="block mb-2 text-sm text-[var(--text-primary)]">Name</label>
                <Input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Enter your name"
                  className="h-14 rounded-2xl bg-white border border-[var(--border)] px-4"
                />
              </div>
            )}

            <div>
              <label className="block mb-2 text-sm text-[var(--text-primary)]">Email</label>
              <Input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Enter your email"
                className="h-14 rounded-2xl bg-white border border-[var(--border)] px-4"
              />
            </div>

            <div>
              <label className="block mb-2 text-sm text-[var(--text-primary)]">Password</label>
              <Input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter your password"
                className="h-14 rounded-2xl bg-white border border-[var(--border)] px-4"
              />
            </div>

            <Button
              type="submit"
              className="w-full h-14 rounded-2xl text-base mt-6"
              style={{ backgroundColor: 'var(--primary-blue)' }}
            >
              {isLogin ? "Log In" : "Sign Up"}
            </Button>
          </form>

          {/* Toggle */}
          <div className="text-center mt-6">
            <button
              onClick={() => setIsLogin(!isLogin)}
              className="text-[var(--primary-blue)]"
            >
              {isLogin ? "Don't have an account? Sign up" : "Already have an account? Log in"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
