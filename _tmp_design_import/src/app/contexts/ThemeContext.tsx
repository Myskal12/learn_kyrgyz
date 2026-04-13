import { createContext, useContext, useEffect, useState, ReactNode } from "react";

export type ColorTheme = "sky-sun" | "sunset-nomad" | "earth-nature" | "night-gold";

interface ThemeContextType {
  theme: ColorTheme;
  setTheme: (theme: ColorTheme) => void;
  toggleTheme: () => void; // Keep for backward compatibility
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setThemeState] = useState<ColorTheme>(() => {
    const stored = localStorage.getItem("kyrgyz-app-theme");
    return (stored as ColorTheme) || "sky-sun";
  });

  useEffect(() => {
    const root = document.documentElement;
    
    // Remove all theme classes
    root.classList.remove("sky-sun", "sunset-nomad", "earth-nature", "night-gold");
    
    // Add current theme class
    root.classList.add(theme);
    
    localStorage.setItem("kyrgyz-app-theme", theme);
  }, [theme]);

  const setTheme = (newTheme: ColorTheme) => {
    setThemeState(newTheme);
  };

  // Keep toggleTheme for backward compatibility (toggles between sky-sun and night-gold)
  const toggleTheme = () => {
    setThemeState((prev) => (prev === "night-gold" ? "sky-sun" : "night-gold"));
  };

  return (
    <ThemeContext.Provider value={{ theme, setTheme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error("useTheme must be used within a ThemeProvider");
  }
  return context;
}
