import { useNavigate, useParams } from "react-router";
import { Clock, Zap, Target, CheckCircle2 } from "lucide-react";

interface LevelStats {
  lessonName: string;
  timeMinutes: number;
  timeSeconds: number;
  xpEarned: number;
  accuracy: number;
}

// Mock data - would come from props or route state
const mockStats: LevelStats = {
  lessonName: "Nature & Mountains",
  timeMinutes: 8,
  timeSeconds: 42,
  xpEarned: 250,
  accuracy: 92,
};

function StatCard({ 
  icon, 
  label, 
  value, 
  color,
  accentColor 
}: { 
  icon: React.ReactNode; 
  label: string; 
  value: string; 
  color: string;
  accentColor?: string;
}) {
  return (
    <div
      className="rounded-[20px] p-5 flex items-center gap-4 transition-all"
      style={{
        backgroundColor: "var(--surface)",
        border: "1px solid var(--border)",
        boxShadow: "0 2px 8px rgba(0, 0, 0, 0.04)",
      }}
    >
      {/* Icon */}
      <div
        className="w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0"
        style={{
          backgroundColor: accentColor || `${color}15`,
          color: color,
        }}
      >
        {icon}
      </div>

      {/* Content */}
      <div className="flex-1">
        <div className="text-caption mb-1">{label}</div>
        <div className="text-h3" style={{ color: "var(--text-primary)" }}>
          {value}
        </div>
      </div>
    </div>
  );
}

export function LevelComplete() {
  const navigate = useNavigate();
  const params = useParams();

  // Get accuracy color based on percentage
  const getAccuracyColor = (accuracy: number) => {
    if (accuracy >= 90) return "#10B981"; // Green
    if (accuracy >= 70) return "#F2C94C"; // Yellow
    return "#EF4444"; // Red
  };

  const getAccuracyLabel = (accuracy: number) => {
    if (accuracy >= 90) return "Excellent!";
    if (accuracy >= 70) return "Good job!";
    return "Keep practicing!";
  };

  const accuracyColor = getAccuracyColor(mockStats.accuracy);
  const accuracyLabel = getAccuracyLabel(mockStats.accuracy);

  const handleContinue = () => {
    navigate("/app/roadmap");
  };

  const handleRetry = () => {
    navigate(`/app/lesson/${params.id || 3}`);
  };

  return (
    <div
      className="min-h-screen flex flex-col"
      style={{ backgroundColor: "var(--background)" }}
    >
      {/* Success Icon & Header */}
      <div className="px-6 pt-16 pb-8 text-center">
        {/* Large Success Icon */}
        <div className="flex justify-center mb-6">
          <div
            className="w-20 h-20 rounded-full flex items-center justify-center relative"
            style={{
              backgroundColor: "#10B98115",
            }}
          >
            {/* Outer glow ring */}
            <div
              className="absolute inset-0 rounded-full animate-pulse"
              style={{
                backgroundColor: "#10B981",
                opacity: 0.1,
                transform: "scale(1.3)",
              }}
            />
            
            {/* Icon */}
            <CheckCircle2 
              className="w-12 h-12 relative z-10" 
              style={{ color: "#10B981" }}
              strokeWidth={2}
            />
          </div>
        </div>

        {/* Title */}
        <h1 className="mb-2">Level Complete</h1>
        
        {/* Lesson Name */}
        <h2 
          className="text-h3 font-medium" 
          style={{ color: "var(--text-secondary)" }}
        >
          {mockStats.lessonName}
        </h2>
      </div>

      {/* Stats Section */}
      <div className="px-6 flex-1">
        <div className="space-y-4 mb-8">
          {/* Time Taken */}
          <StatCard
            icon={<Clock className="w-6 h-6" strokeWidth={2} />}
            label="Time Taken"
            value={`${mockStats.timeMinutes}m ${mockStats.timeSeconds}s`}
            color="var(--primary)"
          />

          {/* XP Earned */}
          <StatCard
            icon={<Zap className="w-6 h-6" strokeWidth={2} fill="currentColor" />}
            label="XP Earned"
            value={`+${mockStats.xpEarned} XP`}
            color="#F2C94C"
            accentColor="#FEF3C7"
          />

          {/* Accuracy */}
          <StatCard
            icon={<Target className="w-6 h-6" strokeWidth={2} />}
            label={accuracyLabel}
            value={`${mockStats.accuracy}%`}
            color={accuracyColor}
          />
        </div>

        {/* Motivational Message */}
        <div
          className="rounded-[16px] p-4 text-center mb-6"
          style={{
            backgroundColor: "var(--muted)",
            border: "1px solid var(--border)",
          }}
        >
          <p className="text-body-sm" style={{ color: "var(--text-secondary)" }}>
            {mockStats.accuracy >= 90 
              ? "Outstanding work! You're mastering the language." 
              : mockStats.accuracy >= 70
              ? "Great progress! Keep up the good work."
              : "Every practice makes you better. Keep going!"}
          </p>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="px-6 pb-8 space-y-3">
        {/* Primary Button - Continue */}
        <button
          onClick={handleContinue}
          className="w-full rounded-[16px] py-4 text-h3 font-medium transition-all active:scale-[0.98]"
          style={{
            backgroundColor: "var(--primary)",
            color: "#FFFFFF",
            boxShadow: "0 4px 12px rgba(47, 128, 237, 0.2)",
          }}
        >
          Continue Journey
        </button>

        {/* Secondary Button - Retry */}
        <button
          onClick={handleRetry}
          className="w-full rounded-[16px] py-4 text-h3 font-medium transition-all active:scale-[0.98]"
          style={{
            backgroundColor: "var(--surface)",
            color: "var(--text-primary)",
            border: "2px solid var(--border)",
            boxShadow: "0 2px 6px rgba(0, 0, 0, 0.04)",
          }}
        >
          Retry Level
        </button>
      </div>
    </div>
  );
}
