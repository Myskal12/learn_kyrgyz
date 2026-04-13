import { useState } from "react";
import { useParams, useNavigate } from "react-router";
import { X, Volume2 } from "lucide-react";
import { Button } from "../components/ui/button";
import { Progress } from "../components/ui/progress";

const lessonData = {
  1: {
    title: "Family & Relationships",
    sentences: [
      {
        kyrgyz: "Менин атым Айгүл",
        english: "My name is Aigul",
        breakdown: [
          { word: "Менин", meaning: "My", type: "possessive" },
          { word: "атым", meaning: "name", type: "noun" },
          { word: "Айгүл", meaning: "Aigul", type: "proper noun" },
        ],
        practice: {
          question: "How do you say 'My name is'?",
          options: ["Менин атым", "Сенин атың", "Анын аты", "Биздин атыбыз"],
          correct: 0,
        },
      },
      {
        kyrgyz: "Менде эки бала бар",
        english: "I have two children",
        breakdown: [
          { word: "Менде", meaning: "I have", type: "possessive" },
          { word: "эки", meaning: "two", type: "number" },
          { word: "бала", meaning: "children", type: "noun" },
          { word: "бар", meaning: "exist/there is", type: "verb" },
        ],
        practice: {
          question: "Select 'two children'",
          options: ["эки бала", "үч бала", "бир бала", "төрт бала"],
          correct: 0,
        },
      },
    ],
  },
};

export function Lesson() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [currentStep, setCurrentStep] = useState(0);
  const [stage, setStage] = useState<"sentence" | "breakdown" | "practice">("sentence");
  const [selectedAnswer, setSelectedAnswer] = useState<number | null>(null);
  const [showResult, setShowResult] = useState(false);

  const lesson = lessonData[id as keyof typeof lessonData];
  if (!lesson) return null;

  const currentSentence = lesson.sentences[0];
  const progress = ((currentStep + 1) / (lesson.sentences.length * 3)) * 100;

  const handleNext = () => {
    if (stage === "sentence") {
      setStage("breakdown");
    } else if (stage === "breakdown") {
      setStage("practice");
    } else {
      // Move to next sentence or go to sentence builder
      if (currentStep < lesson.sentences.length - 1) {
        setCurrentStep(currentStep + 1);
        setStage("sentence");
        setSelectedAnswer(null);
        setShowResult(false);
      } else {
        // Navigate to level complete screen
        navigate("/app/level-complete");
      }
    }
  };

  const handleCheck = () => {
    if (selectedAnswer !== null) {
      setShowResult(true);
      if (selectedAnswer === currentSentence.practice.correct) {
        setTimeout(() => handleNext(), 1500);
      }
    }
  };

  return (
    <div className="min-h-screen flex flex-col" style={{ backgroundColor: "var(--background)" }}>
      {/* Header */}
      <div className="px-6 pt-6 pb-4">
        <div className="flex items-center justify-between mb-4">
          <button onClick={() => navigate("/app")} className="p-2">
            <X className="h-6 w-6 text-[var(--text-secondary)]" />
          </button>
          <div className="flex-1 mx-4">
            <Progress value={progress} className="h-2" />
          </div>
          <span className="text-sm text-[var(--text-secondary)]">{Math.round(progress)}%</span>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 px-6 flex flex-col">
        {stage === "sentence" && (
          <div className="flex-1 flex flex-col justify-center">
            <div className="text-center mb-8">
              <p className="text-sm text-[var(--text-secondary)] mb-4">Learn this sentence</p>
              <div className="mb-6">
                <h2 className="text-3xl mb-4 text-[var(--text-primary)]">{currentSentence.kyrgyz}</h2>
                <button className="mb-4">
                  <Volume2 className="h-8 w-8 mx-auto" style={{ color: "var(--primary-blue)" }} />
                </button>
                <p className="text-xl text-[var(--text-secondary)]">{currentSentence.english}</p>
              </div>
            </div>
          </div>
        )}

        {stage === "breakdown" && (
          <div className="flex-1 flex flex-col justify-center">
            <div className="text-center mb-8">
              <p className="text-sm text-[var(--text-secondary)] mb-6">Word breakdown</p>
              <h3 className="text-2xl mb-8 text-[var(--text-primary)]">{currentSentence.kyrgyz}</h3>

              <div className="space-y-3">
                {currentSentence.breakdown.map((item, index) => (
                  <div
                    key={index}
                    className="rounded-2xl p-4"
                    style={{ 
                      backgroundColor: "var(--surface)",
                      boxShadow: "0 2px 8px rgba(0, 0, 0, 0.06)" 
                    }}
                  >
                    <div className="flex items-center justify-between">
                      <div className="text-left">
                        <p className="text-lg font-medium text-[var(--text-primary)] mb-1">
                          {item.word}
                        </p>
                        <p className="text-[var(--text-secondary)]">{item.meaning}</p>
                      </div>
                      <span
                        className="text-xs px-3 py-1 rounded-full"
                        style={{
                          backgroundColor: "var(--warm-beige)",
                          color: "var(--text-primary)",
                        }}
                      >
                        {item.type}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {stage === "practice" && (
          <div className="flex-1 flex flex-col justify-center">
            <div className="mb-8">
              <p className="text-sm text-[var(--text-secondary)] mb-4 text-center">Practice</p>
              <h3 className="text-xl mb-8 text-center text-[var(--text-primary)]">
                {currentSentence.practice.question}
              </h3>

              <div className="space-y-3">
                {currentSentence.practice.options.map((option, index) => {
                  const isSelected = selectedAnswer === index;
                  const isCorrect = index === currentSentence.practice.correct;
                  const showFeedback = showResult && isSelected;

                  return (
                    <button
                      key={index}
                      onClick={() => !showResult && setSelectedAnswer(index)}
                      disabled={showResult}
                      className="w-full bg-white rounded-2xl p-4 text-left transition-all"
                      style={{
                        boxShadow: "0 2px 8px rgba(0, 0, 0, 0.06)",
                        border: `2px solid ${
                          showFeedback
                            ? isCorrect
                              ? "#10B981"
                              : "#EF4444"
                            : isSelected
                            ? "var(--primary-blue)"
                            : "transparent"
                        }`,
                        backgroundColor: showFeedback
                          ? isCorrect
                            ? "#D1FAE5"
                            : "#FEE2E2"
                          : "white",
                      }}
                    >
                      <p className="text-lg text-[var(--text-primary)]">{option}</p>
                    </button>
                  );
                })}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Bottom button */}
      <div className="px-6 pb-8">
        {stage === "practice" ? (
          <Button
            onClick={handleCheck}
            disabled={selectedAnswer === null || showResult}
            className="w-full h-14 rounded-2xl text-base"
            style={{
              backgroundColor:
                selectedAnswer === null || showResult ? "#E5E7EB" : "var(--primary-blue)",
            }}
          >
            {showResult
              ? selectedAnswer === currentSentence.practice.correct
                ? "Correct!"
                : "Try again"
              : "Check"}
          </Button>
        ) : (
          <Button
            onClick={handleNext}
            className="w-full h-14 rounded-2xl text-base"
            style={{ backgroundColor: "var(--primary-blue)" }}
          >
            Continue
          </Button>
        )}
      </div>
    </div>
  );
}