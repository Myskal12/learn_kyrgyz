import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import { ArrowLeft, Check, X } from "lucide-react";

interface SentenceExercise {
  id: number;
  kyrgyzSentence: string;
  englishWords: string[];
  correctOrder: number[];
  breakdown: {
    word: string;
    translation: string;
    explanation?: string;
  }[];
}

const exercises: SentenceExercise[] = [
  {
    id: 1,
    kyrgyzSentence: "Менин атым Айнура",
    englishWords: ["My", "name", "is", "Ainura"],
    correctOrder: [0, 1, 2, 3],
    breakdown: [
      { word: "Менин", translation: "My", explanation: "possessive pronoun" },
      { word: "атым", translation: "name", explanation: "noun with possessive suffix" },
      { word: "Айнура", translation: "is Ainura", explanation: "name (no 'is' needed in Kyrgyz)" },
    ],
  },
  {
    id: 2,
    kyrgyzSentence: "Апам үйдө",
    englishWords: ["is", "at home", "Mother"],
    correctOrder: [2, 0, 1],
    breakdown: [
      { word: "Апам", translation: "Mother / My mother", explanation: "with possessive suffix" },
      { word: "үйдө", translation: "at home", explanation: "locative case" },
    ],
  },
  {
    id: 3,
    kyrgyzSentence: "Мен китеп окуйм",
    englishWords: ["I", "a book", "read"],
    correctOrder: [0, 1, 2],
    breakdown: [
      { word: "Мен", translation: "I", explanation: "first person pronoun" },
      { word: "китеп", translation: "a book", explanation: "noun" },
      { word: "окуйм", translation: "read", explanation: "verb with first person suffix" },
    ],
  },
];

export function SentenceBuilder() {
  const navigate = useNavigate();
  const { exerciseId } = useParams();
  const currentExercise = exercises.find((ex) => ex.id === Number(exerciseId)) || exercises[0];

  const [selectedWords, setSelectedWords] = useState<number[]>([]);
  const [availableWords, setAvailableWords] = useState<number[]>(
    currentExercise.englishWords.map((_, i) => i)
  );
  const [showFeedback, setShowFeedback] = useState(false);
  const [isCorrect, setIsCorrect] = useState(false);

  const handleWordClick = (wordIndex: number) => {
    if (showFeedback) return;

    if (selectedWords.includes(wordIndex)) {
      // Remove word from selected and return to available
      setSelectedWords(selectedWords.filter((i) => i !== wordIndex));
      setAvailableWords([...availableWords, wordIndex].sort((a, b) => a - b));
    } else {
      // Add word to selected
      setSelectedWords([...selectedWords, wordIndex]);
      setAvailableWords(availableWords.filter((i) => i !== wordIndex));
    }
  };

  const handleCheck = () => {
    const correct =
      selectedWords.length === currentExercise.correctOrder.length &&
      selectedWords.every((word, index) => word === currentExercise.correctOrder[index]);

    setIsCorrect(correct);
    setShowFeedback(true);
  };

  const handleSkip = () => {
    // Navigate to next exercise or back to lesson
    const nextExerciseId = currentExercise.id + 1;
    if (nextExerciseId <= exercises.length) {
      navigate(`/app/sentence-builder/${nextExerciseId}`);
      resetExercise();
    } else {
      navigate("/app/lesson/1");
    }
  };

  const handleContinue = () => {
    const nextExerciseId = currentExercise.id + 1;
    if (nextExerciseId <= exercises.length) {
      navigate(`/app/sentence-builder/${nextExerciseId}`);
      resetExercise();
    } else {
      navigate("/app/lesson/1");
    }
  };

  const resetExercise = () => {
    setSelectedWords([]);
    setAvailableWords(currentExercise.englishWords.map((_, i) => i));
    setShowFeedback(false);
    setIsCorrect(false);
  };

  return (
    <div
      className="min-h-screen flex flex-col"
      style={{ backgroundColor: "var(--background)" }}
    >
      {/* Header */}
      <div className="px-6 pt-12 pb-6 flex items-center gap-4">
        <button
          onClick={() => navigate(-1)}
          className="w-10 h-10 rounded-full flex items-center justify-center"
          style={{ backgroundColor: "var(--surface)" }}
        >
          <ArrowLeft className="h-5 w-5" style={{ color: "var(--text-primary)" }} />
        </button>
        <div className="flex-1">
          <div
            className="h-2 rounded-full overflow-hidden"
            style={{ backgroundColor: "var(--surface)" }}
          >
            <div
              className="h-full transition-all duration-300"
              style={{
                width: `${(currentExercise.id / exercises.length) * 100}%`,
                backgroundColor: "var(--primary-blue)",
              }}
            />
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 px-6 pb-6 flex flex-col">
        {!showFeedback ? (
          <>
            {/* Instruction */}
            <div className="mb-8">
              <h3 className="text-lg font-medium text-[var(--text-primary)] mb-2">
                Translate this sentence
              </h3>
              <p className="text-sm text-[var(--text-secondary)]">
                Tap the words in the correct order
              </p>
            </div>

            {/* Kyrgyz Sentence */}
            <div
              className="rounded-3xl p-6 mb-8 text-center"
              style={{
                backgroundColor: "var(--surface)",
                boxShadow: "0 2px 12px rgba(0, 0, 0, 0.06)",
              }}
            >
              <p className="text-2xl font-medium text-[var(--text-primary)]">
                {currentExercise.kyrgyzSentence}
              </p>
            </div>

            {/* Selected Words Area */}
            <div
              className="rounded-3xl p-6 mb-6 min-h-[100px] flex flex-wrap gap-2 items-start"
              style={{
                backgroundColor: "var(--surface)",
                border: "2px dashed var(--border)",
              }}
            >
              {selectedWords.length === 0 ? (
                <p className="text-[var(--text-secondary)] text-center w-full mt-6">
                  Select words below
                </p>
              ) : (
                selectedWords.map((wordIndex, position) => (
                  <button
                    key={position}
                    onClick={() => handleWordClick(wordIndex)}
                    className="px-4 py-3 rounded-2xl font-medium transition-all"
                    style={{
                      backgroundColor: "var(--primary-blue)",
                      color: "white",
                    }}
                  >
                    {currentExercise.englishWords[wordIndex]}
                  </button>
                ))
              )}
            </div>

            {/* Available Words */}
            <div className="flex flex-wrap gap-2 mb-6">
              {availableWords.map((wordIndex) => (
                <button
                  key={wordIndex}
                  onClick={() => handleWordClick(wordIndex)}
                  className="px-4 py-3 rounded-2xl font-medium transition-all"
                  style={{
                    backgroundColor: "var(--surface)",
                    color: "var(--text-primary)",
                    border: "2px solid var(--border)",
                  }}
                >
                  {currentExercise.englishWords[wordIndex]}
                </button>
              ))}
            </div>

            {/* Actions */}
            <div className="mt-auto space-y-3">
              <button
                onClick={handleCheck}
                disabled={selectedWords.length === 0}
                className="w-full h-14 rounded-2xl font-medium transition-all"
                style={{
                  backgroundColor:
                    selectedWords.length === 0
                      ? "var(--muted)"
                      : "var(--primary-blue)",
                  color: "white",
                  opacity: selectedWords.length === 0 ? 0.5 : 1,
                }}
              >
                Check
              </button>
              <button
                onClick={handleSkip}
                className="w-full h-14 rounded-2xl font-medium transition-all"
                style={{
                  backgroundColor: "var(--surface)",
                  color: "var(--text-secondary)",
                  border: "2px solid var(--border)",
                }}
              >
                Skip
              </button>
            </div>
          </>
        ) : (
          <>
            {/* Feedback */}
            <div
              className="rounded-3xl p-6 mb-6"
              style={{
                backgroundColor: isCorrect
                  ? "rgba(16, 185, 129, 0.1)"
                  : "rgba(239, 68, 68, 0.1)",
              }}
            >
              <div className="flex items-center gap-3 mb-4">
                <div
                  className="w-12 h-12 rounded-full flex items-center justify-center"
                  style={{
                    backgroundColor: isCorrect ? "#10B981" : "#EF4444",
                  }}
                >
                  {isCorrect ? (
                    <Check className="h-6 w-6 text-white" />
                  ) : (
                    <X className="h-6 w-6 text-white" />
                  )}
                </div>
                <div>
                  <h3
                    className="text-xl font-medium"
                    style={{ color: isCorrect ? "#10B981" : "#EF4444" }}
                  >
                    {isCorrect ? "Excellent!" : "Not quite right"}
                  </h3>
                  <p className="text-[var(--text-secondary)]">
                    {isCorrect
                      ? "Perfect translation"
                      : "Review the correct translation below"}
                  </p>
                </div>
              </div>

              {/* Correct Answer */}
              {!isCorrect && (
                <div
                  className="rounded-2xl p-4 mb-4"
                  style={{ backgroundColor: "var(--surface)" }}
                >
                  <p className="text-sm text-[var(--text-secondary)] mb-2">
                    Correct translation:
                  </p>
                  <p className="text-lg font-medium text-[var(--text-primary)]">
                    {currentExercise.correctOrder
                      .map((i) => currentExercise.englishWords[i])
                      .join(" ")}
                  </p>
                </div>
              )}
            </div>

            {/* Word-by-word Breakdown */}
            <div
              className="rounded-3xl p-6 mb-6"
              style={{
                backgroundColor: "var(--surface)",
                boxShadow: "0 2px 12px rgba(0, 0, 0, 0.06)",
              }}
            >
              <h4 className="text-lg font-medium text-[var(--text-primary)] mb-4">
                Sentence Breakdown
              </h4>
              <div className="space-y-4">
                {currentExercise.breakdown.map((item, index) => (
                  <div
                    key={index}
                    className="pb-4"
                    style={{
                      borderBottom:
                        index < currentExercise.breakdown.length - 1
                          ? "1px solid var(--border)"
                          : "none",
                    }}
                  >
                    <div className="flex items-baseline gap-2 mb-1">
                      <span className="text-lg font-medium text-[var(--text-primary)]">
                        {item.word}
                      </span>
                      <span className="text-[var(--text-secondary)]">→</span>
                      <span className="text-lg text-[var(--primary-blue)]">
                        {item.translation}
                      </span>
                    </div>
                    {item.explanation && (
                      <p className="text-sm text-[var(--text-secondary)] mt-1">
                        {item.explanation}
                      </p>
                    )}
                  </div>
                ))}
              </div>
            </div>

            {/* Continue Button */}
            <div className="mt-auto">
              <button
                onClick={handleContinue}
                className="w-full h-14 rounded-2xl font-medium transition-all"
                style={{
                  backgroundColor: "var(--primary-blue)",
                  color: "white",
                }}
              >
                Continue
              </button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
