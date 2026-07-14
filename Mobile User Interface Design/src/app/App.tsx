import { useState } from "react";
import { HubSelectionScreen } from "./components/HubSelectionScreen";
import { HomeScreen } from "./components/HomeScreen";
import { RoomDetailScreen } from "./components/RoomDetailScreen";
import { PickupScreen } from "./components/PickupScreen";
import { Home, Search, ShoppingBag, User, UtensilsCrossed } from "lucide-react";

const COLORS = {
  primary: "#0046FF",
  orange: "#FF8040",
  darkBlue: "#001BB7",
  beige: "#F5F1DC",
};

type Screen = "hub" | "home" | "room" | "pickup";

interface Hub {
  id: number;
  name: string;
  address: string;
  distance: string;
  slots: string;
  active: boolean;
}

const NAV_ITEMS = [
  { screen: "home" as Screen, label: "Trang chủ", icon: Home },
  { screen: "home" as Screen, label: "Tìm kiếm", icon: Search },
  { screen: "room" as Screen, label: "Gom Đơn", icon: UtensilsCrossed, primary: true },
  { screen: "pickup" as Screen, label: "Đơn hàng", icon: ShoppingBag },
  { screen: "home" as Screen, label: "Cá nhân", icon: User },
];

export default function App() {
  const [screen, setScreen] = useState<Screen>("hub");
  const [selectedHub, setSelectedHub] = useState<Hub | null>(null);
  const [activeNav, setActiveNav] = useState<Screen>("home");

  const handleHubConfirm = (hub: Hub) => {
    setSelectedHub(hub);
    setScreen("home");
    setActiveNav("home");
  };

  const handleNavPress = (item: (typeof NAV_ITEMS)[0]) => {
    if (screen !== "hub") {
      setScreen(item.screen);
      setActiveNav(item.screen);
    }
  };

  const showBottomNav = screen !== "hub";

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-200">
      {/* Mobile frame */}
      <div
        className="relative flex flex-col overflow-hidden shadow-2xl"
        style={{
          width: 390,
          height: 844,
          borderRadius: 44,
          background: "white",
          border: "8px solid #1a1a1a",
          boxShadow: "0 0 0 2px #333, 0 30px 80px rgba(0,0,0,0.35)",
        }}
      >
        {/* Status bar */}
        <div
          className="flex items-center justify-between px-7 shrink-0"
          style={{
            height: 44,
            background:
              screen === "hub"
                ? COLORS.primary
                : screen === "pickup"
                ? COLORS.darkBlue
                : COLORS.primary,
          }}
        >
          <span className="text-white text-xs font-semibold">9:41</span>
          <div
            className="rounded-full"
            style={{ width: 120, height: 32, background: "#1a1a1a", marginTop: -44 }}
          />
          <div className="flex items-center gap-1.5">
            <div className="flex gap-0.5">
              {[3, 4, 4, 4].map((h, i) => (
                <div key={i} className="w-1 rounded-sm bg-white opacity-90" style={{ height: h }} />
              ))}
            </div>
            <span className="text-white text-xs">100%</span>
          </div>
        </div>

        {/* Screen content */}
        <div className="flex-1 overflow-hidden flex flex-col" style={{ marginBottom: showBottomNav ? 0 : 0 }}>
          <div className="flex-1 overflow-hidden relative">
            {screen === "hub" && (
              <div className="absolute inset-0 overflow-y-auto">
                <HubSelectionScreen onConfirm={handleHubConfirm} />
              </div>
            )}
            {screen === "home" && selectedHub && (
              <div className="absolute inset-0 overflow-hidden flex flex-col">
                <HomeScreen
                  hubName={selectedHub.name}
                  onOpenRoom={() => {
                    setScreen("room");
                    setActiveNav("room");
                  }}
                />
              </div>
            )}
            {screen === "room" && (
              <div className="absolute inset-0 overflow-hidden flex flex-col">
                <RoomDetailScreen
                  onBack={() => {
                    setScreen("home");
                    setActiveNav("home");
                  }}
                  onConfirmPayment={() => {
                    setScreen("pickup");
                    setActiveNav("pickup");
                  }}
                />
              </div>
            )}
            {screen === "pickup" && (
              <div className="absolute inset-0 overflow-hidden flex flex-col">
                <PickupScreen
                  onBack={() => {
                    setScreen("home");
                    setActiveNav("home");
                  }}
                />
              </div>
            )}
          </div>

          {/* Bottom navigation */}
          {showBottomNav && (
            <div
              className="shrink-0 flex items-center px-2 pb-5 pt-2"
              style={{
                background: "rgba(255,255,255,0.98)",
                borderTop: "1px solid rgba(0,27,183,0.08)",
                backdropFilter: "blur(12px)",
              }}
            >
              {NAV_ITEMS.map((item, i) => {
                const Icon = item.icon;
                const isActive = activeNav === item.screen && i !== 4 && i !== 1;
                const isPrimary = item.primary;

                if (isPrimary) {
                  return (
                    <button
                      key={i}
                      onClick={() => handleNavPress(item)}
                      className="flex-1 flex flex-col items-center gap-0.5"
                    >
                      <div
                        className="w-12 h-12 rounded-2xl flex items-center justify-center -mt-5 shadow-lg"
                        style={{
                          background: `linear-gradient(135deg, ${COLORS.primary} 0%, ${COLORS.orange} 100%)`,
                          boxShadow: `0 4px 16px rgba(0,70,255,0.4)`,
                        }}
                      >
                        <Icon size={22} color="white" />
                      </div>
                      <span className="text-xs font-semibold" style={{ color: COLORS.primary }}>
                        {item.label}
                      </span>
                    </button>
                  );
                }

                return (
                  <button
                    key={i}
                    onClick={() => handleNavPress(item)}
                    className="flex-1 flex flex-col items-center gap-1 py-1"
                  >
                    <Icon
                      size={20}
                      color={isActive ? COLORS.primary : "rgba(0,27,183,0.35)"}
                      strokeWidth={isActive ? 2.5 : 1.8}
                    />
                    <span
                      className="text-xs"
                      style={{
                        color: isActive ? COLORS.primary : "rgba(0,27,183,0.4)",
                        fontWeight: isActive ? 600 : 400,
                      }}
                    >
                      {item.label}
                    </span>
                    {isActive && (
                      <div
                        className="w-1 h-1 rounded-full"
                        style={{ background: COLORS.primary }}
                      />
                    )}
                  </button>
                );
              })}
            </div>
          )}
        </div>

        {/* Home indicator */}
        <div className="flex justify-center pb-2 shrink-0">
          <div
            className="rounded-full"
            style={{ width: 134, height: 5, background: "#1a1a1a", opacity: 0.2 }}
          />
        </div>
      </div>

      {/* Screen selector pills */}
      <div className="fixed bottom-6 flex gap-2 flex-wrap justify-center px-4">
        {(["hub", "home", "room", "pickup"] as Screen[]).map((s) => (
          <button
            key={s}
            onClick={() => {
              if (s !== "hub" || !selectedHub) {
                if (s !== "hub") {
                  if (!selectedHub) {
                    setSelectedHub({
                      id: 1,
                      name: "Sảnh Toà Nhà A",
                      address: "12 Nguyễn Trãi, Ninh Kiều",
                      distance: "120m",
                      slots: "3 tuyến",
                      active: true,
                    });
                  }
                }
              }
              setScreen(s);
              if (s !== "hub") setActiveNav(s);
            }}
            className="px-3 py-1.5 rounded-full text-xs font-medium shadow-sm transition-all"
            style={
              screen === s
                ? { background: COLORS.primary, color: "white" }
                : { background: "white", color: COLORS.darkBlue, border: `1px solid rgba(0,27,183,0.2)` }
            }
          >
            {s === "hub" ? "1. Chọn Hub" : s === "home" ? "2. Trang chủ" : s === "room" ? "3. Chi tiết phòng" : "4. Nhận hàng"}
          </button>
        ))}
      </div>
    </div>
  );
}
