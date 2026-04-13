import { useState } from "react";
import { useParams, useNavigate } from "react-router";
import { X, Volume2, ChevronLeft, ChevronRight } from "lucide-react";
import { Button } from "../components/ui/button";

const flashcardsData = {
  family: [
    { kyrgyz: "ата", english: "father", pronunciation: "ata" },
    { kyrgyz: "эне", english: "mother", pronunciation: "ene" },
    { kyrgyz: "бала", english: "child", pronunciation: "bala" },
    { kyrgyz: "агай", english: "older brother", pronunciation: "agay" },
    { kyrgyz: "эже", english: "older sister", pronunciation: "ezhe" },
  ],
  nature: [
    { kyrgyz: "тоо", english: "mountain", pronunciation: "too" },
    { kyrgyz: "дарыя", english: "river", pronunciation: "darya" },
    { kyrgyz: "көл", english: "lake", pronunciation: "köl" },
    { kyrgyz: "асман", english: "sky", pronunciation: "asman" },
    { kyrgyz: "жылдыз", english: "star", pronunciation: "zhyldyz" },
  ],
  emotions: [
    { kyrgyz: "кубанычтуу", english: "happy", pronunciation: "kubanychtu" },
    { kyrgyz: "кайгылуу", english: "sad", pronunciation: "kaygylu" },
    { kyrgyz: "ачуулуу", english: "angry", pronunciation: "achuulu" },
    { kyrgyz: "коркок", english: "scared", pronunciation: "korkok" },
    { kyrgyz: "таң калуу", english: "surprised", pronunciation: "tang kaluu" },
  ],
};

export function Flashcards() {
  const { category } = useParams();
  const navigate = useNavigate();
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isFlipped, setIsFlipped] = useState(false);

  const cards = flashcardsData[category as keyof typeof flashcardsData] || flashcardsData.family;
  const currentCard = cards[currentIndex];

  const handleNext = () => {
    if (currentIndex < cards.length - 1) {
      setCurrentIndex(currentIndex + 1);
      setIsFlipped(false);
    }
  };

  const handlePrev = () => {
    if (currentIndex > 0) {
      setCurrentIndex(currentIndex - 1);
      setIsFlipped(false);
    }
  };

  const handleFlip = () => {
    setIsFlipped(!isFlipped);
  };

  return (
    <div className="min-h-screen flex flex-col" style={{ backgroundColor: "var(--background)" }}>
      {/* Header */}
      <div className="px-6 pt-6 pb-4">
        <div className="flex items-center justify-between">
          <button onClick={() => navigate("/app/practice")} className="p-2">
            <X className="h-6 w-6 text-[var(--text-secondary)]" />
          </button>
          <span className="text-sm text-[var(--text-secondary)]">
            {currentIndex + 1} / {cards.length}
          </span>
        </div>
      </div>

      {/* Flashcard */}
      <div className="flex-1 flex items-center justify-center px-6">
        <div className="w-full max-w-sm">
          <button
            onClick={handleFlip}
            className="w-full aspect-[3/4] rounded-3xl p-8 transition-all duration-300 relative"
            style={{
              backgroundColor: isFlipped ? "var(--primary-blue)" : "white",
              boxShadow: "0 8px 24px rgba(0, 0, 0, 0.12)",
              transform: isFlipped ? "rotateY(180deg)" : "rotateY(0deg)",
              transformStyle: "preserve-3d",
            }}
          >
            <div
              className="h-full flex flex-col items-center justify-center"
              style={{
                transform: isFlipped ? "rotateY(180deg)" : "rotateY(0deg)",
              }}
            >
              {!isFlipped ? (
                <>
                  <h2 className="text-5xl mb-6 text-[var(--text-primary)]">{currentCard.kyrgyz}</h2>
                  <button className="mb-4">
                    <Volume2 className="h-10 w-10" style={{ color: "var(--primary-blue)" }} />
                  </button>
                  <p className="text-[var(--text-secondary)] italic">/{currentCard.pronunciation}/</p>
                  <p className="text-sm text-[var(--text-secondary)] mt-8">Tap to reveal</p>
                </>
              ) : (
                <>
                  <p className="text-sm text-white/80 mb-4">Translation</p>
                  <h2 className="text-4xl text-white mb-8">{currentCard.english}</h2>
                  <p className="text-white/60 text-lg">{currentCard.kyrgyz}</p>
                </>
              )}
            </div>
          </button>

          {/* Navigation */}
          <div className="flex items-center justify-between mt-8">
            <Button
              onClick={handlePrev}
              disabled={currentIndex === 0}
              variant="outline"
              className="rounded-full w-12 h-12 p-0"
              style={{
                borderColor: currentIndex === 0 ? "#E5E7EB" : "var(--primary-blue)",
                color: currentIndex === 0 ? "#E5E7EB" : "var(--primary-blue)",
              }}
            >
              <ChevronLeft className="h-6 w-6" />
            </Button>

            <div className="flex gap-2">
              {cards.map((_, index) => (
                <div
                  key={index}
                  className={`h-2 rounded-full transition-all ${
                    index === currentIndex ? "w-8" : "w-2"
                  }`}
                  style={{
                    backgroundColor:
                      index === currentIndex ? "var(--primary-blue)" : "#E5E7EB",
                  }}
                />
              ))}
            </div>

            <Button
              onClick={handleNext}
              disabled={currentIndex === cards.length - 1}
              variant="outline"
              className="rounded-full w-12 h-12 p-0"
              style={{
                borderColor: currentIndex === cards.length - 1 ? "#E5E7EB" : "var(--primary-blue)",
                color: currentIndex === cards.length - 1 ? "#E5E7EB" : "var(--primary-blue)",
              }}
            >
              <ChevronRight className="h-6 w-6" />
            </Button>
          </div>
        </div>
      </div>

      {/* Bottom hint */}
      <div className="px-6 pb-8 text-center">
        <p className="text-sm text-[var(--text-secondary)]">Swipe or use arrows to navigate</p>
      </div>
    </div>
  );
}
