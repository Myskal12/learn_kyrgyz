import { useNavigate } from "react-router";
import { Flame, Coins, ChevronRight, Map, Repeat, Trophy } from "lucide-react";
import { useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "../components/ui/dialog";

export function Home() {
  const navigate = useNavigate();
  const [showStreakModal, setShowStreakModal] = useState(false);

  // Mock data
  const streak = 7;
  const xp = 1250;
  const currentLesson = {
    id: 1,
    title: "Family & Relationships",
    progress: 65,
    nextSentence: "Менин атым Айгүл",
    translation: "My name is Aigul",
  };

  const topUsers = [
    { name: "Aibek", xp: 2450, avatar: "A", color: "#2F80ED" },
    { name: "Nurzhan", xp: 2380, avatar: "N", color: "#10B981" },
    { name: "Cholpon", xp: 2150, avatar: "C", color: "#8B5CF6" },
  ];

  return (
    <div className="min-h-screen pb-24" style={{ backgroundColor: 'var(--background)' }}>
      {/* Top Bar */}
      <div className="px-6 pt-12 pb-6">
        <div className="flex items-center justify-between">
          {/* Avatar */}
          <button 
            onClick={() => navigate("/app/profile")}
            className="w-12 h-12 rounded-full flex items-center justify-center text-white transition-transform hover:scale-105"
            style={{ backgroundColor: 'var(--primary-blue)' }}
          >
            Y
          </button>

          {/* Streak and XP */}
          <div className="flex items-center gap-3">
            {/* Streak */}
            <button
              onClick={() => setShowStreakModal(true)}
              className="flex items-center gap-1.5 px-3 py-2 rounded-xl transition-transform hover:scale-105"
              style={{ 
                backgroundColor: 'var(--surface)',
                boxShadow: '0 2px 8px rgba(0, 0, 0, 0.06)' 
              }}
            >
              <Flame className="h-4 w-4" style={{ color: 'var(--accent-yellow)' }} />
              <span className="font-medium text-[var(--text-primary)]">{streak}</span>
            </button>

            {/* XP */}
            <div 
              className="flex items-center gap-1.5 px-3 py-2 rounded-xl"
              style={{ 
                backgroundColor: 'var(--surface)',
                boxShadow: '0 2px 8px rgba(0, 0, 0, 0.06)' 
              }}
            >
              <Coins className="h-4 w-4" style={{ color: 'var(--accent-yellow)' }} />
              <span className="font-medium text-[var(--text-primary)]">{xp}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Main content */}
      <div className="px-6 space-y-6">
        {/* PRIMARY: Continue Learning Card */}
        <button
          className="w-full rounded-3xl p-8 text-left transition-transform hover:scale-[1.02] active:scale-[0.98]"
          style={{
            background: 'linear-gradient(135deg, var(--primary-blue), #5B9FED)',
            boxShadow: '0 8px 24px rgba(47, 128, 237, 0.3)',
          }}
          onClick={() => navigate(`/app/lesson/${currentLesson.id}`)}
        >
          <div className="flex items-start justify-between mb-6">
            <div className="flex-1">
              <p className="text-white/70 text-sm mb-2">Continue Learning</p>
              <h2 className="text-white text-2xl font-medium mb-3">{currentLesson.title}</h2>
              
              {/* Current sentence preview */}
              <div className="bg-white/10 rounded-2xl p-4 mb-4 backdrop-blur-sm">
                <p className="text-white text-lg mb-1">"{currentLesson.nextSentence}"</p>
                <p className="text-white/60 text-sm">{currentLesson.translation}</p>
              </div>
            </div>

            <div className="bg-white/20 rounded-full p-3 ml-4">
              <ChevronRight className="h-6 w-6 text-white" />
            </div>
          </div>

          {/* Progress bar */}
          <div>
            <div className="bg-white/20 rounded-full h-3 overflow-hidden mb-2">
              <div
                className="bg-white h-full rounded-full transition-all"
                style={{ width: `${currentLesson.progress}%` }}
              />
            </div>
            <p className="text-white/80 text-sm">{currentLesson.progress}% complete</p>
          </div>
        </button>

        {/* SECONDARY: Quick Actions */}
        <div className="grid grid-cols-2 gap-4">
          {/* Roadmap */}
          <button
            onClick={() => navigate("/app/roadmap")}
            className="rounded-2xl p-5 text-left transition-transform hover:scale-[1.02] active:scale-[0.98]"
            style={{ 
              backgroundColor: "var(--surface)",
              boxShadow: '0 2px 12px rgba(0, 0, 0, 0.06)' 
            }}
          >
            <div 
              className="w-12 h-12 rounded-2xl flex items-center justify-center mb-3"
              style={{ backgroundColor: 'var(--warm-beige)' }}
            >
              <Map className="h-6 w-6" style={{ color: 'var(--primary-blue)' }} />
            </div>
            <h4 className="font-medium text-[var(--text-primary)] mb-1">Roadmap</h4>
            <p className="text-xs text-[var(--text-secondary)]">Your journey</p>
          </button>

          {/* Practice */}
          <button
            onClick={() => navigate("/app/practice")}
            className="rounded-2xl p-5 text-left transition-transform hover:scale-[1.02] active:scale-[0.98]"
            style={{ 
              backgroundColor: "var(--surface)",
              boxShadow: '0 2px 12px rgba(0, 0, 0, 0.06)' 
            }}
          >
            <div 
              className="w-12 h-12 rounded-2xl flex items-center justify-center mb-3"
              style={{ backgroundColor: 'var(--warm-beige)' }}
            >
              <Repeat className="h-6 w-6" style={{ color: 'var(--primary-blue)' }} />
            </div>
            <h4 className="font-medium text-[var(--text-primary)] mb-1">Practice</h4>
            <p className="text-xs text-[var(--text-secondary)]">Review & build</p>
          </button>
        </div>

        {/* PASSIVE: Leaderboard Preview */}
        <div 
          className="rounded-2xl p-5" 
          style={{ 
            backgroundColor: "var(--surface)",
            boxShadow: '0 2px 12px rgba(0, 0, 0, 0.06)' 
          }}
        >
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <Trophy className="h-5 w-5" style={{ color: 'var(--text-secondary)' }} />
              <h3 className="font-medium text-[var(--text-primary)]">Top Learners</h3>
            </div>
            <button
              onClick={() => navigate("/app/leaderboard")}
              className="text-sm font-medium"
              style={{ color: 'var(--primary-blue)' }}
            >
              View all
            </button>
          </div>

          <div className="space-y-3">
            {topUsers.map((user, index) => (
              <div key={index} className="flex items-center gap-3">
                <span 
                  className="w-6 text-center font-bold text-lg"
                  style={{ 
                    color: index === 0 ? 'var(--accent-yellow)' : 'var(--text-secondary)' 
                  }}
                >
                  {index + 1}
                </span>
                <div
                  className="w-9 h-9 rounded-full flex items-center justify-center text-white text-sm"
                  style={{ backgroundColor: user.color }}
                >
                  {user.avatar}
                </div>
                <span className="text-[var(--text-primary)] flex-1">{user.name}</span>
                <div className="flex items-center gap-1">
                  <Coins className="h-4 w-4" style={{ color: 'var(--accent-yellow)' }} />
                  <span className="font-medium text-sm text-[var(--text-primary)]">{user.xp}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Streak Modal */}
      <Dialog open={showStreakModal} onOpenChange={setShowStreakModal}>
        <DialogContent className="max-w-sm mx-auto rounded-3xl p-8">
          <DialogHeader className="sr-only">
            <DialogTitle>Streak Information</DialogTitle>
            <DialogDescription>
              View your current learning streak and progress
            </DialogDescription>
          </DialogHeader>
          <StreakModal streak={streak} />
        </DialogContent>
      </Dialog>
    </div>
  );
}

function StreakModal({ streak }: { streak: number }) {
  const days = [
    { label: "M", completed: true },
    { label: "T", completed: true },
    { label: "W", completed: true },
    { label: "T", completed: true },
    { label: "F", completed: true },
    { label: "S", completed: true },
    { label: "S", completed: true },
  ];

  return (
    <div className="text-center">
      <div className="mb-6">
        <Flame className="h-16 w-16 mx-auto mb-4" style={{ color: 'var(--accent-yellow)' }} />
        <h2 className="text-2xl mb-2 text-[var(--text-primary)]">{streak} Day Streak!</h2>
        <p className="text-[var(--text-secondary)]">Keep up the amazing work</p>
      </div>

      {/* Weekly calendar */}
      <div className="flex justify-center gap-2 mb-6">
        {days.map((day, index) => (
          <div key={index} className="flex flex-col items-center gap-2">
            <div
              className="w-10 h-10 rounded-xl flex items-center justify-center transition-all"
              style={{
                backgroundColor: day.completed ? 'var(--primary-blue)' : 'var(--surface)',
              }}
            >
              {day.completed ? (
                <Flame className="h-5 w-5 text-white" />
              ) : (
                <span className="text-[var(--text-secondary)] text-sm">{day.label}</span>
              )}
            </div>
            <span className="text-xs text-[var(--text-secondary)]">{day.label}</span>
          </div>
        ))}
      </div>

      <p className="text-sm text-[var(--text-secondary)]">
        Complete a lesson today to continue your streak
      </p>
    </div>
  );
}