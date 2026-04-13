import { useNavigate } from "react-router";
import { Check, Lock, Circle } from "lucide-react";

const lessons = [
  { id: 1, title: "Family & Relationships", status: "completed", progress: 100, sentences: 24 },
  { id: 2, title: "Daily Greetings", status: "completed", progress: 100, sentences: 18 },
  { id: 3, title: "Nature & Mountains", status: "active", progress: 45, sentences: 32 },
  { id: 4, title: "Food & Meals", status: "locked", progress: 0, sentences: 28 },
  { id: 5, title: "Emotions & Feelings", status: "locked", progress: 0, sentences: 22 },
  { id: 6, title: "Travel & Directions", status: "locked", progress: 0, sentences: 30 },
  { id: 7, title: "Time & Seasons", status: "locked", progress: 0, sentences: 26 },
  { id: 8, title: "Traditional Culture", status: "locked", progress: 0, sentences: 35 },
];

function StepCard({ 
  lesson, 
  index,
  isLast,
  isCompleted,
  isBeforeActive
}: { 
  lesson: typeof lessons[0]; 
  index: number;
  isLast: boolean;
  isCompleted: boolean;
  isBeforeActive: boolean;
}) {
  const navigate = useNavigate();

  const handleClick = () => {
    if (lesson.status !== "locked") {
      navigate(`/app/lesson/${lesson.id}`);
    }
  };

  // Status styling
  const getStatusConfig = () => {
    switch (lesson.status) {
      case "completed":
        return {
          icon: <Check className="w-5 h-5" strokeWidth={3} />,
          iconBg: "#10B981",
          iconColor: "#FFFFFF",
          cardBorder: "rgba(16, 185, 129, 0.15)",
          cardShadow: "0 2px 8px rgba(0, 0, 0, 0.04)",
          statusText: "Completed",
          statusColor: "#10B981",
        };
      case "active":
        return {
          icon: <div className="w-3 h-3 rounded-full bg-white" />,
          iconBg: "var(--primary)",
          iconColor: "#FFFFFF",
          cardBorder: "var(--primary)",
          cardShadow: "0 4px 16px rgba(47, 128, 237, 0.12)",
          statusText: "Current",
          statusColor: "var(--primary)",
        };
      case "locked":
      default:
        return {
          icon: <Lock className="w-4 h-4" strokeWidth={2} />,
          iconBg: "#E2E8F0",
          iconColor: "#94A3B8",
          cardBorder: "rgba(0, 0, 0, 0.06)",
          cardShadow: "0 1px 3px rgba(0, 0, 0, 0.04)",
          statusText: "Locked",
          statusColor: "#94A3B8",
        };
    }
  };

  const config = getStatusConfig();

  // Slight horizontal offset for natural flow - alternating pattern
  const getOffset = () => {
    if (index % 3 === 0) return "0px";
    if (index % 3 === 1) return "8px";
    return "-8px";
  };

  return (
    <div className="relative flex items-start gap-4" style={{ marginLeft: getOffset() }}>
      {/* Status Indicator Circle */}
      <div className="relative flex-shrink-0 pt-1">
        <div
          className="w-12 h-12 rounded-full flex items-center justify-center transition-all duration-300 relative z-10"
          style={{
            backgroundColor: config.iconBg,
            color: config.iconColor,
            boxShadow: lesson.status === "active" 
              ? "0 0 0 4px rgba(47, 128, 237, 0.1), 0 4px 12px rgba(47, 128, 237, 0.2)" 
              : "0 2px 8px rgba(0, 0, 0, 0.06)",
            transform: lesson.status === "active" ? "scale(1.1)" : "scale(1)",
          }}
        >
          {config.icon}
        </div>
        
        {/* Active pulse effect */}
        {lesson.status === "active" && (
          <div 
            className="absolute inset-0 rounded-full animate-pulse"
            style={{
              backgroundColor: "var(--primary)",
              opacity: 0.2,
              transform: "scale(1.3)",
            }}
          />
        )}
      </div>

      {/* Card Content */}
      <button
        onClick={handleClick}
        disabled={lesson.status === "locked"}
        className="flex-1 text-left transition-all duration-200 hover:scale-[1.01] active:scale-[0.99] disabled:cursor-not-allowed disabled:hover:scale-100"
        style={{ paddingBottom: isLast ? "0" : "32px" }}
      >
        <div
          className="rounded-[20px] p-5 transition-all"
          style={{
            backgroundColor: "var(--surface)",
            border: `2px solid ${config.cardBorder}`,
            boxShadow: config.cardShadow,
            opacity: lesson.status === "locked" ? 0.7 : 1,
          }}
        >
          {/* Header */}
          <div className="flex items-start justify-between mb-3">
            <div className="flex-1">
              <h3 className="text-h3 mb-1" style={{ 
                color: lesson.status === "locked" ? "var(--text-secondary)" : "var(--text-primary)" 
              }}>
                {lesson.title}
              </h3>
              
              <div className="flex items-center gap-3">
                <span className="text-caption">
                  {lesson.sentences} sentences
                </span>
                <span 
                  className="text-caption font-medium" 
                  style={{ color: config.statusColor }}
                >
                  • {config.statusText}
                </span>
              </div>
            </div>

            {/* Step Number Badge */}
            <div 
              className="text-caption font-bold px-2 py-1 rounded-lg"
              style={{ 
                backgroundColor: lesson.status === "locked" ? "#F1F5F9" : "var(--muted)",
                color: lesson.status === "locked" ? "var(--text-secondary)" : "var(--text-secondary)",
              }}
            >
              {index + 1}
            </div>
          </div>

          {/* Progress Bar */}
          {lesson.status !== "locked" && (
            <div className="w-full h-2 rounded-full overflow-hidden" style={{ backgroundColor: "#F1F5F9" }}>
              <div
                className="h-full rounded-full transition-all duration-300"
                style={{
                  width: `${lesson.progress}%`,
                  backgroundColor: lesson.status === "completed" ? "#10B981" : "var(--primary)",
                }}
              />
            </div>
          )}
        </div>
      </button>
    </div>
  );
}

export function Roadmap() {
  const completedCount = lessons.filter(l => l.status === "completed").length;
  const totalCount = lessons.length;
  const activeIndex = lessons.findIndex(l => l.status === "active");

  return (
    <div
      className="min-h-screen"
      style={{ backgroundColor: "var(--background)" }}
    >
      {/* Header */}
      <div className="px-6 pt-12 pb-8">
        <h1 className="mb-2">Your Journey</h1>
        <p className="text-body text-secondary mb-4">
          Complete each category to unlock the next
        </p>

        {/* Overall Progress */}
        <div 
          className="rounded-[16px] p-4"
          style={{ 
            backgroundColor: "var(--surface)",
            border: "1px solid var(--border)",
            boxShadow: "0 2px 8px rgba(0, 0, 0, 0.04)"
          }}
        >
          <div className="flex items-center justify-between mb-2">
            <span className="text-label">Overall Progress</span>
            <span className="text-label" style={{ color: "var(--primary)" }}>
              {completedCount}/{totalCount}
            </span>
          </div>
          <div className="w-full h-2 rounded-full overflow-hidden" style={{ backgroundColor: "#F1F5F9" }}>
            <div
              className="h-full rounded-full transition-all duration-500"
              style={{
                width: `${(completedCount / totalCount) * 100}%`,
                backgroundColor: "var(--primary)",
              }}
            />
          </div>
        </div>
      </div>

      {/* Journey Path */}
      <div className="px-6 pb-24 relative">
        {/* Continuous Vertical Line */}
        <div 
          className="absolute left-[48px] top-0 bottom-0 w-[3px]"
          style={{
            background: `linear-gradient(to bottom, 
              #10B981 0%, 
              #10B981 ${activeIndex > 0 ? ((activeIndex) / lessons.length) * 100 : 0}%, 
              var(--primary) ${activeIndex > 0 ? ((activeIndex) / lessons.length) * 100 : 0}%,
              var(--primary) ${((activeIndex + 1) / lessons.length) * 100}%,
              #E2E8F0 ${((activeIndex + 1) / lessons.length) * 100}%, 
              #E2E8F0 100%)`,
          }}
        />

        {/* Step Cards */}
        <div className="space-y-0">
          {lessons.map((lesson, index) => (
            <StepCard
              key={lesson.id}
              lesson={lesson}
              index={index}
              isLast={index === lessons.length - 1}
              isCompleted={lesson.status === "completed"}
              isBeforeActive={index < activeIndex}
            />
          ))}
        </div>
      </div>
    </div>
  );
}