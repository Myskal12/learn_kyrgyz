import { Trophy, Coins, Flame } from "lucide-react";

const leaderboardData = [
  { rank: 1, name: "Aibek", avatar: "A", xp: 2450, streak: 21 },
  { rank: 2, name: "Nurzhan", avatar: "N", xp: 2380, streak: 18 },
  { rank: 3, name: "Cholpon", avatar: "C", xp: 2150, streak: 15 },
  { rank: 4, name: "Jibek", avatar: "J", xp: 1980, streak: 12 },
  { rank: 5, name: "Kamil", avatar: "K", xp: 1850, streak: 14 },
  { rank: 6, name: "Ainura", avatar: "AI", xp: 1720, streak: 9 },
  { rank: 7, name: "You", avatar: "Y", xp: 1250, streak: 7, isCurrentUser: true },
  { rank: 8, name: "Eldiyar", avatar: "E", xp: 1180, streak: 8 },
  { rank: 9, name: "Gulmira", avatar: "G", xp: 1050, streak: 6 },
  { rank: 10, name: "Bektur", avatar: "B", xp: 920, streak: 5 },
];

function MedalIcon({ rank }: { rank: number }) {
  const colors = {
    1: "#F2C94C",
    2: "#9CA3AF",
    3: "#CD7F32",
  };

  if (rank > 3) return null;

  return (
    <div
      className="w-8 h-8 rounded-full flex items-center justify-center"
      style={{ backgroundColor: colors[rank as keyof typeof colors] + "20" }}
    >
      <Trophy
        className="h-5 w-5"
        style={{ color: colors[rank as keyof typeof colors] }}
      />
    </div>
  );
}

export function Leaderboard() {
  return (
    <div className="min-h-screen" style={{ backgroundColor: "var(--background)" }}>
      {/* Header */}
      <div className="px-6 pt-12 pb-6">
        <h1 className="text-3xl mb-2 text-[var(--text-primary)]">Leaderboard</h1>
        <p className="text-[var(--text-secondary)]">See how you rank among learners</p>
      </div>

      {/* Top 3 Podium */}
      <div className="px-6 mb-8">
        <div className="flex items-end justify-center gap-4 mb-8">
          {/* Second place */}
          <div className="flex flex-col items-center">
            <div
              className="w-16 h-16 rounded-full flex items-center justify-center text-white mb-2"
              style={{ backgroundColor: "var(--primary-blue)" }}
            >
              <span className="text-xl">{leaderboardData[1].avatar}</span>
            </div>
            <p className="text-sm font-medium text-[var(--text-primary)] mb-1">
              {leaderboardData[1].name}
            </p>
            <div
              className="w-20 h-16 rounded-t-2xl flex items-center justify-center"
              style={{ backgroundColor: "#9CA3AF30" }}
            >
              <span className="font-bold text-2xl" style={{ color: "#9CA3AF" }}>
                2
              </span>
            </div>
          </div>

          {/* First place */}
          <div className="flex flex-col items-center">
            <Trophy className="h-6 w-6 mb-2" style={{ color: "#F2C94C" }} />
            <div
              className="w-20 h-20 rounded-full flex items-center justify-center text-white mb-2 border-4"
              style={{
                backgroundColor: "var(--primary-blue)",
                borderColor: "#F2C94C",
              }}
            >
              <span className="text-2xl">{leaderboardData[0].avatar}</span>
            </div>
            <p className="font-medium text-[var(--text-primary)] mb-1">
              {leaderboardData[0].name}
            </p>
            <div
              className="w-24 h-24 rounded-t-2xl flex items-center justify-center"
              style={{ backgroundColor: "#F2C94C30" }}
            >
              <span className="font-bold text-3xl" style={{ color: "#F2C94C" }}>
                1
              </span>
            </div>
          </div>

          {/* Third place */}
          <div className="flex flex-col items-center">
            <div
              className="w-16 h-16 rounded-full flex items-center justify-center text-white mb-2"
              style={{ backgroundColor: "var(--primary-blue)" }}
            >
              <span className="text-xl">{leaderboardData[2].avatar}</span>
            </div>
            <p className="text-sm font-medium text-[var(--text-primary)] mb-1">
              {leaderboardData[2].name}
            </p>
            <div
              className="w-20 h-12 rounded-t-2xl flex items-center justify-center"
              style={{ backgroundColor: "#CD7F3230" }}
            >
              <span className="font-bold text-xl" style={{ color: "#CD7F32" }}>
                3
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Full list */}
      <div className="px-6 pb-8">
        <div className="bg-white rounded-3xl overflow-hidden" style={{ boxShadow: "0 2px 12px rgba(0, 0, 0, 0.06)" }}>
          {leaderboardData.map((user, index) => (
            <div
              key={index}
              className={`flex items-center gap-4 p-4 border-b border-gray-100 last:border-b-0 ${
                user.isCurrentUser ? "bg-blue-50" : ""
              }`}
            >
              {/* Rank or Medal */}
              <div className="w-8 flex justify-center">
                {user.rank <= 3 ? (
                  <MedalIcon rank={user.rank} />
                ) : (
                  <span className="font-medium text-[var(--text-secondary)]">
                    {user.rank}
                  </span>
                )}
              </div>

              {/* Avatar */}
              <div
                className="w-12 h-12 rounded-full flex items-center justify-center text-white flex-shrink-0"
                style={{
                  backgroundColor: user.isCurrentUser
                    ? "var(--accent-yellow)"
                    : "var(--primary-blue)",
                }}
              >
                <span>{user.avatar}</span>
              </div>

              {/* Name */}
              <div className="flex-1">
                <p
                  className={`font-medium ${
                    user.isCurrentUser ? "text-[var(--primary-blue)]" : "text-[var(--text-primary)]"
                  }`}
                >
                  {user.name}
                  {user.isCurrentUser && (
                    <span className="ml-2 text-xs px-2 py-1 rounded-full bg-[var(--primary-blue)] text-white">
                      You
                    </span>
                  )}
                </p>
              </div>

              {/* Stats */}
              <div className="flex items-center gap-4">
                <div className="flex items-center gap-1">
                  <Flame className="h-4 w-4" style={{ color: "var(--accent-yellow)" }} />
                  <span className="text-sm font-medium text-[var(--text-primary)]">
                    {user.streak}
                  </span>
                </div>
                <div className="flex items-center gap-1">
                  <Coins className="h-4 w-4" style={{ color: "var(--accent-yellow)" }} />
                  <span className="font-medium text-[var(--text-primary)]">{user.xp}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
