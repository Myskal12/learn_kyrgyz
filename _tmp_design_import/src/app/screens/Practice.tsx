import { useNavigate } from "react-router";
import { Users, Mountain, Heart, Coffee, Home as HomeIcon, Sun, Repeat, Languages } from "lucide-react";

const practiceCategories = [
  {
    id: "family",
    title: "Family",
    icon: Users,
    color: "#2F80ED",
    bgColor: "#EBF4FF",
    count: 24,
  },
  {
    id: "nature",
    title: "Nature",
    icon: Mountain,
    color: "#10B981",
    bgColor: "#D1FAE5",
    count: 32,
  },
  {
    id: "emotions",
    title: "Emotions",
    icon: Heart,
    color: "#F2C94C",
    bgColor: "#FEF9E7",
    count: 18,
  },
  {
    id: "daily-life",
    title: "Daily Life",
    icon: HomeIcon,
    color: "#8B5CF6",
    bgColor: "#EDE9FE",
    count: 28,
  },
  {
    id: "food",
    title: "Food & Meals",
    icon: Coffee,
    color: "#F59E0B",
    bgColor: "#FEF3C7",
    count: 20,
  },
  {
    id: "weather",
    title: "Weather",
    icon: Sun,
    color: "#06B6D4",
    bgColor: "#CFFAFE",
    count: 15,
  },
];

export function Practice() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen pb-24" style={{ backgroundColor: "var(--background)" }}>
      {/* Header */}
      <div className="px-6 pt-12 pb-6">
        <h1 className="text-3xl mb-2 text-[var(--text-primary)]">Practice</h1>
        <p className="text-[var(--text-secondary)]">Review and improve your skills</p>
      </div>

      <div className="px-6 space-y-6">
        {/* Practice Modes */}
        <div>
          <h2 className="text-lg font-medium text-[var(--text-primary)] mb-4">Practice Modes</h2>
          
          <div className="space-y-3">
            {/* Flashcards */}
            <button
              onClick={() => navigate("/app/flashcards")}
              className="w-full rounded-2xl p-5 text-left transition-transform hover:scale-[1.02] active:scale-[0.98]"
              style={{ 
                backgroundColor: "var(--surface)",
                boxShadow: '0 2px 12px rgba(0, 0, 0, 0.06)' 
              }}
            >
              <div className="flex items-center gap-4">
                <div 
                  className="w-14 h-14 rounded-2xl flex items-center justify-center shrink-0"
                  style={{ backgroundColor: 'var(--warm-beige)' }}
                >
                  <Repeat className="h-7 w-7" style={{ color: 'var(--primary-blue)' }} />
                </div>
                <div className="flex-1">
                  <h3 className="font-medium text-[var(--text-primary)] mb-1">Flashcards</h3>
                  <p className="text-sm text-[var(--text-secondary)]">Review vocabulary by category</p>
                </div>
              </div>
            </button>

            {/* Sentence Builder */}
            <button
              onClick={() => navigate("/app/sentence-builder/1")}
              className="w-full rounded-2xl p-5 text-left transition-transform hover:scale-[1.02] active:scale-[0.98]"
              style={{ 
                backgroundColor: "var(--surface)",
                boxShadow: '0 2px 12px rgba(0, 0, 0, 0.06)' 
              }}
            >
              <div className="flex items-center gap-4">
                <div 
                  className="w-14 h-14 rounded-2xl flex items-center justify-center shrink-0"
                  style={{ backgroundColor: 'var(--warm-beige)' }}
                >
                  <Languages className="h-7 w-7" style={{ color: 'var(--primary-blue)' }} />
                </div>
                <div className="flex-1">
                  <h3 className="font-medium text-[var(--text-primary)] mb-1">Sentence Builder</h3>
                  <p className="text-sm text-[var(--text-secondary)]">Practice translating sentences</p>
                </div>
              </div>
            </button>
          </div>
        </div>

        {/* Quick Practice by Category */}
        <div>
          <h2 className="text-lg font-medium text-[var(--text-primary)] mb-4">Quick Practice</h2>
          
          <div className="grid grid-cols-2 gap-3">
            {practiceCategories.map((category) => {
              const Icon = category.icon;
              
              return (
                <button
                  key={category.id}
                  onClick={() => navigate(`/app/flashcards?category=${category.id}`)}
                  className="rounded-2xl p-4 text-left transition-transform hover:scale-[1.02] active:scale-[0.98]"
                  style={{ 
                    backgroundColor: "var(--surface)",
                    boxShadow: "0 2px 12px rgba(0, 0, 0, 0.06)" 
                  }}
                >
                  <div
                    className="w-12 h-12 rounded-xl flex items-center justify-center mb-3"
                    style={{ backgroundColor: category.bgColor }}
                  >
                    <Icon className="h-6 w-6" style={{ color: category.color }} />
                  </div>
                  
                  <h3 className="font-medium text-[var(--text-primary)] mb-0.5 text-sm">{category.title}</h3>
                  <p className="text-xs text-[var(--text-secondary)]">{category.count} words</p>
                </button>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}
