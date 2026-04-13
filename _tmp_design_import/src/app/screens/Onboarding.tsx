import { useState } from "react";
import { useNavigate } from "react-router";
import { Button } from "../components/ui/button";
import { ChevronRight } from "lucide-react";

const slides = [
  {
    title: "Learn Kyrgyz through context",
    description: "Master the language by understanding real sentences, not memorizing isolated words.",
    illustration: "mountains",
  },
  {
    title: "Discover nomadic culture",
    description: "Connect with Kyrgyz heritage while building language skills naturally.",
    illustration: "yurt",
  },
  {
    title: "Practice with purpose",
    description: "Organized learning paths guide you from basics to fluency.",
    illustration: "journey",
  },
];

function MountainIllustration() {
  return (
    <svg width="200" height="120" viewBox="0 0 200 120" fill="none">
      <path d="M0 90 L50 40 L100 70 L150 30 L200 80 L200 120 L0 120 Z" fill="#2F80ED" opacity="0.15" />
      <path d="M20 100 L70 50 L120 80 L170 45 L200 90" stroke="#2F80ED" strokeWidth="2" fill="none" />
      <circle cx="180" cy="25" r="15" fill="#F2C94C" opacity="0.6" />
    </svg>
  );
}

function YurtIllustration() {
  return (
    <svg width="200" height="120" viewBox="0 0 200 120" fill="none">
      <path d="M100 30 L140 60 L140 100 L60 100 L60 60 Z" fill="#F5E9DA" stroke="#2F80ED" strokeWidth="2" />
      <path d="M100 30 L140 60" stroke="#2F80ED" strokeWidth="2" />
      <path d="M100 30 L60 60" stroke="#2F80ED" strokeWidth="2" />
      <circle cx="100" cy="30" r="5" fill="#F2C94C" />
      <rect x="90" y="70" width="20" height="30" fill="#2F80ED" opacity="0.3" />
    </svg>
  );
}

function JourneyIllustration() {
  return (
    <svg width="200" height="120" viewBox="0 0 200 120" fill="none">
      <path d="M20 100 Q60 60 100 80 T180 60" stroke="#2F80ED" strokeWidth="3" strokeDasharray="5 5" fill="none" opacity="0.3" />
      <circle cx="20" cy="100" r="8" fill="#10B981" />
      <circle cx="100" cy="80" r="8" fill="#2F80ED" />
      <circle cx="180" cy="60" r="8" fill="#F2C94C" stroke="#2F80ED" strokeWidth="2" />
    </svg>
  );
}

export function Onboarding() {
  const [currentSlide, setCurrentSlide] = useState(0);
  const navigate = useNavigate();

  const handleNext = () => {
    if (currentSlide < slides.length - 1) {
      setCurrentSlide(currentSlide + 1);
    } else {
      navigate("/auth");
    }
  };

  const handleSkip = () => {
    navigate("/auth");
  };

  const slide = slides[currentSlide];

  return (
    <div className="min-h-screen flex flex-col" style={{ backgroundColor: 'var(--background)' }}>
      {/* Skip button */}
      <div className="p-6 flex justify-end">
        <button 
          onClick={handleSkip}
          className="text-[var(--text-secondary)] px-4 py-2"
        >
          Skip
        </button>
      </div>

      {/* Content */}
      <div className="flex-1 flex flex-col items-center justify-center px-8 pb-20">
        {/* Illustration */}
        <div className="mb-12">
          {slide.illustration === "mountains" && <MountainIllustration />}
          {slide.illustration === "yurt" && <YurtIllustration />}
          {slide.illustration === "journey" && <JourneyIllustration />}
        </div>

        {/* Text */}
        <div className="text-center max-w-sm">
          <h2 className="text-2xl mb-4 text-[var(--text-primary)]">{slide.title}</h2>
          <p className="text-[var(--text-secondary)] leading-relaxed">
            {slide.description}
          </p>
        </div>
      </div>

      {/* Bottom section */}
      <div className="p-8 pb-12">
        {/* Dots */}
        <div className="flex justify-center gap-2 mb-8">
          {slides.map((_, index) => (
            <div
              key={index}
              className={`h-2 rounded-full transition-all ${
                index === currentSlide 
                  ? "w-8 bg-[var(--primary-blue)]" 
                  : "w-2 bg-[var(--text-secondary)] opacity-30"
              }`}
            />
          ))}
        </div>

        {/* Button */}
        <Button
          onClick={handleNext}
          className="w-full h-14 rounded-2xl text-base"
          style={{ backgroundColor: 'var(--primary-blue)' }}
        >
          {currentSlide === slides.length - 1 ? "Get Started" : "Next"}
          <ChevronRight className="ml-2 h-5 w-5" />
        </Button>
      </div>
    </div>
  );
}
