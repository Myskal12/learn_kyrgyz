import { createBrowserRouter } from "react-router";
import { Splash } from "./screens/Splash";
import { Onboarding } from "./screens/Onboarding";
import { Auth } from "./screens/Auth";
import { Home } from "./screens/Home";
import { Roadmap } from "./screens/Roadmap";
import { Lesson } from "./screens/Lesson";
import { LevelComplete } from "./screens/LevelComplete";
import { Practice } from "./screens/Practice";
import { Flashcards } from "./screens/Flashcards";
import { Leaderboard } from "./screens/Leaderboard";
import { Profile } from "./screens/Profile";
import { SentenceBuilder } from "./screens/SentenceBuilder";
import { NotFound } from "./screens/NotFound";
import { MainLayout } from "./components/MainLayout";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <Splash />,
  },
  {
    path: "/onboarding",
    element: <Onboarding />,
  },
  {
    path: "/auth",
    element: <Auth />,
  },
  {
    path: "/app",
    element: <MainLayout />,
    children: [
      {
        index: true,
        element: <Home />,
      },
      {
        path: "roadmap",
        element: <Roadmap />,
      },
      {
        path: "lesson/:id",
        element: <Lesson />,
      },
      {
        path: "sentence-builder/:exerciseId",
        element: <SentenceBuilder />,
      },
      {
        path: "practice",
        element: <Practice />,
      },
      {
        path: "practice/:category",
        element: <Flashcards />,
      },
      {
        path: "leaderboard",
        element: <Leaderboard />,
      },
      {
        path: "profile",
        element: <Profile />,
      },
      {
        path: "level-complete",
        element: <LevelComplete />,
      },
    ],
  },
  {
    path: "*",
    element: <NotFound />,
  },
]);