import { useState } from "react";
import { useNavigate } from "react-router";
import { Settings, ChevronRight, Camera, Mail, Lock, Bell, LogOut, Flame, Coins, BookOpen, Trophy, Moon, Sun, Edit2, Palette, Check } from "lucide-react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "../components/ui/dialog";
import { Input } from "../components/ui/input";
import { Button } from "../components/ui/button";
import { Switch } from "../components/ui/switch";
import { useTheme, type ColorTheme } from "../contexts/ThemeContext";

const avatarOptions = [
  { id: 1, initial: "Y", color: "#2F80ED", label: "Blue" },
  { id: 2, initial: "Y", color: "#10B981", label: "Green" },
  { id: 3, initial: "Y", color: "#8B5CF6", label: "Purple" },
  { id: 4, initial: "Y", color: "#F59E0B", label: "Orange" },
  { id: 5, initial: "Y", color: "#EF4444", label: "Red" },
  { id: 6, initial: "Y", color: "#EC4899", label: "Pink" },
  { id: 7, initial: "Y", color: "#14B8A6", label: "Teal" },
  { id: 8, initial: "Y", color: "#6366F1", label: "Indigo" },
];

const themeOptions = [
  { 
    id: "sky-sun" as ColorTheme, 
    name: "Sky + Sun", 
    description: "Light & airy",
    colors: { primary: "#2F80ED", accent: "#F2C94C", bg: "#FAF8F4" }
  },
  { 
    id: "sunset-nomad" as ColorTheme, 
    name: "Sunset Nomad", 
    description: "Warm & mystical",
    colors: { primary: "#7C3AED", accent: "#F97316", bg: "#FFF7ED" }
  },
  { 
    id: "earth-nature" as ColorTheme, 
    name: "Earth + Nature", 
    description: "Calm & organic",
    colors: { primary: "#059669", accent: "#D97706", bg: "#F9F7F4" }
  },
  { 
    id: "night-gold" as ColorTheme, 
    name: "Night + Gold", 
    description: "Dark & elegant",
    colors: { primary: "#3B82F6", accent: "#FBBF24", bg: "#0F172A" }
  },
];

export function Profile() {
  const navigate = useNavigate();
  const { theme, setTheme } = useTheme();
  const [showSettings, setShowSettings] = useState(false);
  const [activeSettingModal, setActiveSettingModal] = useState<string | null>(null);
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [showAvatarModal, setShowAvatarModal] = useState(false);
  const [showThemeModal, setShowThemeModal] = useState(false);
  const [currentAvatar, setCurrentAvatar] = useState(avatarOptions[0]);
  const [selectedAvatar, setSelectedAvatar] = useState(avatarOptions[0]);

  const stats = {
    streak: 7,
    totalXP: 1250,
    lessonsCompleted: 12,
    rank: 7,
  };

  const handleLogout = () => {
    navigate("/auth");
  };

  const handleAvatarClick = () => {
    setSelectedAvatar(currentAvatar);
    setShowAvatarModal(true);
  };

  const handleSaveAvatar = () => {
    setCurrentAvatar(selectedAvatar);
    setShowAvatarModal(false);
  };

  const handleCancelAvatar = () => {
    setSelectedAvatar(currentAvatar);
    setShowAvatarModal(false);
  };

  const handleThemeClick = () => {
    setShowThemeModal(true);
  };

  const handleSaveTheme = (selectedTheme: ColorTheme) => {
    setTheme(selectedTheme);
    setShowThemeModal(false);
  };

  const handleCancelTheme = () => {
    setShowThemeModal(false);
  };

  return (
    <div className="min-h-screen" style={{ backgroundColor: "var(--background)" }}>
      {/* Header with Profile */}
      <div
        className="px-6 pt-12 pb-8 rounded-b-3xl"
        style={{
          background: "linear-gradient(135deg, var(--primary-blue), #5B9FED)",
        }}
      >
        <div className="flex flex-col items-center">
          <div className="relative mb-4">
            <button
              onClick={handleAvatarClick}
              className="w-24 h-24 rounded-full flex items-center justify-center text-white text-3xl relative group transition-transform hover:scale-105"
              style={{ backgroundColor: currentAvatar.color }}
            >
              {currentAvatar.initial}
              
              {/* Edit icon overlay */}
              <div
                className="absolute inset-0 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
                style={{ backgroundColor: "rgba(0, 0, 0, 0.5)" }}
              >
                <Edit2 className="h-8 w-8 text-white" />
              </div>
            </button>
          </div>
          <h2 className="text-2xl text-white mb-1">Your Name</h2>
          <p className="text-white/80">Joined January 2026</p>
        </div>
      </div>

      {/* Stats */}
      <div className="px-6 -mt-8 mb-6">
        <div
          className="rounded-3xl p-6 grid grid-cols-2 gap-4"
          style={{ 
            backgroundColor: "var(--surface)",
            boxShadow: "0 4px 16px rgba(0, 0, 0, 0.08)" 
          }}
        >
          <div className="flex items-center gap-3">
            <div
              className="w-12 h-12 rounded-2xl flex items-center justify-center"
              style={{ backgroundColor: "var(--warm-beige)" }}
            >
              <Flame className="h-6 w-6" style={{ color: "var(--accent-yellow)" }} />
            </div>
            <div>
              <p className="text-2xl font-medium text-[var(--text-primary)]">{stats.streak}</p>
              <p className="text-sm text-[var(--text-secondary)]">Day streak</p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div
              className="w-12 h-12 rounded-2xl flex items-center justify-center"
              style={{ backgroundColor: "var(--warm-beige)" }}
            >
              <Coins className="h-6 w-6" style={{ color: "var(--accent-yellow)" }} />
            </div>
            <div>
              <p className="text-2xl font-medium text-[var(--text-primary)]">{stats.totalXP}</p>
              <p className="text-sm text-[var(--text-secondary)]">Total XP</p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div
              className="w-12 h-12 rounded-2xl flex items-center justify-center"
              style={{ backgroundColor: "var(--warm-beige)" }}
            >
              <BookOpen className="h-6 w-6" style={{ color: "var(--primary-blue)" }} />
            </div>
            <div>
              <p className="text-2xl font-medium text-[var(--text-primary)]">{stats.lessonsCompleted}</p>
              <p className="text-sm text-[var(--text-secondary)]">Lessons</p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div
              className="w-12 h-12 rounded-2xl flex items-center justify-center"
              style={{ backgroundColor: "var(--warm-beige)" }}
            >
              <Trophy className="h-6 w-6" style={{ color: "var(--primary-blue)" }} />
            </div>
            <div>
              <p className="text-2xl font-medium text-[var(--text-primary)]">#{stats.rank}</p>
              <p className="text-sm text-[var(--text-secondary)]">Rank</p>
            </div>
          </div>
        </div>
      </div>

      {/* Settings */}
      <div className="px-6 pb-8">
        <h3 className="text-lg font-medium text-[var(--text-primary)] mb-4">Settings</h3>
        <div
          className="rounded-3xl overflow-hidden"
          style={{ 
            backgroundColor: "var(--surface)",
            boxShadow: "0 2px 12px rgba(0, 0, 0, 0.06)" 
          }}
        >
          {/* Theme Selector */}
          <button
            onClick={handleThemeClick}
            className="w-full flex items-center justify-between p-4"
            style={{ borderBottom: "1px solid var(--border)" }}
          >
            <div className="flex items-center gap-3">
              <Palette className="h-5 w-5 text-[var(--text-secondary)]" />
              <span className="text-[var(--text-primary)]">Color Theme</span>
            </div>
            <ChevronRight className="h-5 w-5 text-[var(--text-secondary)]" />
          </button>

          <button
            onClick={() => setActiveSettingModal("email")}
            className="w-full flex items-center justify-between p-4"
            style={{ borderBottom: "1px solid var(--border)" }}
          >
            <div className="flex items-center gap-3">
              <Mail className="h-5 w-5 text-[var(--text-secondary)]" />
              <span className="text-[var(--text-primary)]">Change Email</span>
            </div>
            <ChevronRight className="h-5 w-5 text-[var(--text-secondary)]" />
          </button>

          <button
            onClick={() => setActiveSettingModal("password")}
            className="w-full flex items-center justify-between p-4"
            style={{ borderBottom: "1px solid var(--border)" }}
          >
            <div className="flex items-center gap-3">
              <Lock className="h-5 w-5 text-[var(--text-secondary)]" />
              <span className="text-[var(--text-primary)]">Change Password</span>
            </div>
            <ChevronRight className="h-5 w-5 text-[var(--text-secondary)]" />
          </button>

          <div 
            className="flex items-center justify-between p-4"
            style={{ borderBottom: "1px solid var(--border)" }}
          >
            <div className="flex items-center gap-3">
              <Bell className="h-5 w-5 text-[var(--text-secondary)]" />
              <span className="text-[var(--text-primary)]">Notifications</span>
            </div>
            <Switch
              checked={notificationsEnabled}
              onCheckedChange={setNotificationsEnabled}
            />
          </div>

          <button
            onClick={handleLogout}
            className="w-full flex items-center justify-between p-4"
          >
            <div className="flex items-center gap-3">
              <LogOut className="h-5 w-5 text-red-500" />
              <span className="text-red-500">Log Out</span>
            </div>
          </button>
        </div>
      </div>

      {/* Change Email Modal */}
      <Dialog open={activeSettingModal === "email"} onOpenChange={() => setActiveSettingModal(null)}>
        <DialogContent className="max-w-sm mx-auto rounded-3xl">
          <DialogHeader>
            <DialogTitle>Change Email</DialogTitle>
            <DialogDescription>
              Update your email address for your account
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 pt-4">
            <div>
              <label className="block mb-2 text-sm text-[var(--text-primary)]">New Email</label>
              <Input
                type="email"
                placeholder="Enter new email"
                className="h-12 rounded-2xl"
              />
            </div>
            <Button
              className="w-full h-12 rounded-2xl"
              style={{ backgroundColor: "var(--primary-blue)" }}
            >
              Update Email
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Change Password Modal */}
      <Dialog open={activeSettingModal === "password"} onOpenChange={() => setActiveSettingModal(null)}>
        <DialogContent className="max-w-sm mx-auto rounded-3xl">
          <DialogHeader>
            <DialogTitle>Change Password</DialogTitle>
            <DialogDescription>
              Update your password to keep your account secure
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 pt-4">
            <div>
              <label className="block mb-2 text-sm text-[var(--text-primary)]">Current Password</label>
              <Input
                type="password"
                placeholder="Enter current password"
                className="h-12 rounded-2xl"
              />
            </div>
            <div>
              <label className="block mb-2 text-sm text-[var(--text-primary)]">New Password</label>
              <Input
                type="password"
                placeholder="Enter new password"
                className="h-12 rounded-2xl"
              />
            </div>
            <Button
              className="w-full h-12 rounded-2xl"
              style={{ backgroundColor: "var(--primary-blue)" }}
            >
              Update Password
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Avatar Modal */}
      <Dialog open={showAvatarModal} onOpenChange={handleCancelAvatar}>
        <DialogContent className="max-w-sm mx-auto rounded-3xl">
          <DialogHeader>
            <DialogTitle className="text-[var(--text-primary)]">Choose Avatar</DialogTitle>
            <DialogDescription>
              Select a color for your profile avatar
            </DialogDescription>
          </DialogHeader>
          <div className="pt-4">
            {/* Avatar Grid */}
            <div className="grid grid-cols-4 gap-4 mb-6">
              {avatarOptions.map((avatar) => (
                <button
                  key={avatar.id}
                  onClick={() => setSelectedAvatar(avatar)}
                  className="relative transition-all duration-200"
                  style={{
                    transform: selectedAvatar.id === avatar.id ? "scale(1.1)" : "scale(1)",
                  }}
                >
                  <div
                    className="w-16 h-16 rounded-full flex items-center justify-center text-white text-2xl cursor-pointer transition-all"
                    style={{
                      backgroundColor: avatar.color,
                      border:
                        selectedAvatar.id === avatar.id
                          ? "3px solid var(--primary-blue)"
                          : "3px solid transparent",
                      boxShadow:
                        selectedAvatar.id === avatar.id
                          ? "0 4px 16px rgba(47, 128, 237, 0.3)"
                          : "0 2px 8px rgba(0, 0, 0, 0.1)",
                    }}
                  >
                    {avatar.initial}
                  </div>
                </button>
              ))}
            </div>

            {/* Buttons */}
            <div className="flex gap-3">
              <Button
                onClick={handleCancelAvatar}
                className="flex-1 h-12 rounded-2xl"
                style={{
                  backgroundColor: "var(--surface)",
                  color: "var(--text-primary)",
                  border: "2px solid var(--border)",
                }}
              >
                Cancel
              </Button>
              <Button
                onClick={handleSaveAvatar}
                className="flex-1 h-12 rounded-2xl text-white"
                style={{
                  backgroundColor: "var(--primary-blue)",
                }}
              >
                Save
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* Theme Modal */}
      <Dialog open={showThemeModal} onOpenChange={handleCancelTheme}>
        <DialogContent className="max-w-sm mx-auto rounded-3xl">
          <DialogHeader>
            <DialogTitle className="text-[var(--text-primary)]">Choose Theme</DialogTitle>
            <DialogDescription>
              Select a color theme for your learning experience
            </DialogDescription>
          </DialogHeader>
          <div className="pt-4">
            {/* Theme Options */}
            <div className="space-y-3 mb-6">
              {themeOptions.map((themeOption) => (
                <button
                  key={themeOption.id}
                  onClick={() => handleSaveTheme(themeOption.id)}
                  className="w-full rounded-2xl p-4 text-left transition-all duration-200"
                  style={{
                    backgroundColor: "var(--surface)",
                    border: themeOption.id === theme 
                      ? "2px solid var(--primary-blue)" 
                      : "2px solid var(--border)",
                    boxShadow: themeOption.id === theme
                      ? "0 4px 16px rgba(47, 128, 237, 0.2)"
                      : "0 2px 8px rgba(0, 0, 0, 0.04)",
                  }}
                >
                  <div className="flex items-center gap-4">
                    {/* Color Preview */}
                    <div className="flex gap-2 shrink-0">
                      <div
                        className="w-10 h-10 rounded-xl"
                        style={{ backgroundColor: themeOption.colors.primary }}
                      />
                      <div
                        className="w-10 h-10 rounded-xl"
                        style={{ backgroundColor: themeOption.colors.accent }}
                      />
                      <div
                        className="w-10 h-10 rounded-xl border"
                        style={{ 
                          backgroundColor: themeOption.colors.bg,
                          borderColor: "var(--border)"
                        }}
                      />
                    </div>

                    {/* Theme Info */}
                    <div className="flex-1">
                      <h4 className="font-medium text-[var(--text-primary)] mb-0.5">
                        {themeOption.name}
                      </h4>
                      <p className="text-sm text-[var(--text-secondary)]">
                        {themeOption.description}
                      </p>
                    </div>

                    {/* Checkmark */}
                    {themeOption.id === theme && (
                      <Check 
                        className="h-5 w-5 shrink-0" 
                        style={{ color: "var(--primary-blue)" }} 
                      />
                    )}
                  </div>
                </button>
              ))}
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}