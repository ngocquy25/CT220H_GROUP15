import { useState } from "react";
import { Search, Bell, MapPin, Users, Clock, ChevronRight, Star, Flame, Zap, ShoppingBag } from "lucide-react";

const COLORS = {
  primary: "#0046FF",
  orange: "#FF8040",
  darkBlue: "#001BB7",
  beige: "#F5F1DC",
};

const rooms = [
  {
    id: 1,
    name: "Phòng Gom Lầu 5 – Toà A",
    restaurant: "Cơm Gà Bà Tuyến",
    current: 8,
    target: 10,
    freeAt: 10,
    timeLeft: "12 phút",
    tag: "Đang gom",
    emoji: "🍚",
  },
  {
    id: 2,
    name: "Phòng Gom Lầu 12 – CT2",
    restaurant: "Bún Bò Huế Ngon",
    current: 13,
    target: 15,
    freeAt: 15,
    timeLeft: "8 phút",
    tag: "Đang gom",
    emoji: "🍜",
  },
];

const foods = [
  {
    id: 1,
    name: "Cơm Gà Xối Mỡ",
    restaurant: "Cơm Gà Bà Tuyến",
    price: "45.000đ",
    originalPrice: "52.000đ",
    rating: 4.8,
    orders: 120,
    tag: "Freeship",
    emoji: "🍗",
    category: "Cơm",
  },
  {
    id: 2,
    name: "Bún Bò Huế Đặc Biệt",
    restaurant: "Quán Bún Bò Ngon",
    price: "55.000đ",
    originalPrice: null,
    rating: 4.7,
    orders: 88,
    tag: "Hot",
    emoji: "🍜",
    category: "Bún",
  },
  {
    id: 3,
    name: "Cơm Sườn Bì Chả",
    restaurant: "Quán Cơm 3 Miền",
    price: "50.000đ",
    originalPrice: "58.000đ",
    rating: 4.9,
    orders: 205,
    tag: "Bán chạy",
    emoji: "🍖",
    category: "Cơm",
  },
  {
    id: 4,
    name: "Bánh Mì Đặc Biệt",
    restaurant: "Bánh Mì Sài Gòn",
    price: "25.000đ",
    originalPrice: null,
    rating: 4.6,
    orders: 340,
    tag: "Freeship",
    emoji: "🥖",
    category: "Bánh Mì",
  },
];

const categories = ["Tất cả", "Cơm", "Bún", "Bánh Mì", "Nước uống"];

interface HomeScreenProps {
  hubName: string;
  onOpenRoom: (roomId: number) => void;
}

export function HomeScreen({ hubName, onOpenRoom }: HomeScreenProps) {
  const [search, setSearch] = useState("");
  const [activeCategory, setActiveCategory] = useState("Tất cả");

  const filtered = foods.filter(
    (f) =>
      (activeCategory === "Tất cả" || f.category === activeCategory) &&
      (f.name.toLowerCase().includes(search.toLowerCase()) ||
        f.restaurant.toLowerCase().includes(search.toLowerCase()))
  );

  return (
    <div className="flex flex-col h-full bg-gray-50">
      {/* Top bar */}
      <div
        className="px-4 pt-11 pb-4"
        style={{ background: `linear-gradient(135deg, ${COLORS.primary} 0%, #1a3aff 100%)` }}
      >
        <div className="flex items-center justify-between mb-3">
          <div>
            <div className="flex items-center gap-1.5">
              <MapPin size={12} color="rgba(255,255,255,0.8)" />
              <span className="text-xs" style={{ color: "rgba(255,255,255,0.8)" }}>
                Hub của bạn
              </span>
            </div>
            <p className="text-white font-semibold text-sm mt-0.5 truncate max-w-[200px]">{hubName}</p>
          </div>
          <button className="relative p-2 rounded-full" style={{ background: "rgba(255,255,255,0.15)" }}>
            <Bell size={18} color="white" />
            <span
              className="absolute top-1 right-1 w-2 h-2 rounded-full"
              style={{ background: COLORS.orange }}
            />
          </button>
        </div>

        {/* Search */}
        <div className="flex items-center gap-2 bg-white rounded-2xl px-3.5 py-2.5">
          <Search size={16} color={COLORS.primary} />
          <input
            type="text"
            placeholder="Tìm món, tìm quán..."
            className="flex-1 text-sm bg-transparent outline-none"
            style={{ color: COLORS.darkBlue }}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
          {search && (
            <button onClick={() => setSearch("")} className="text-xs px-2 py-0.5 rounded-full"
              style={{ background: "rgba(0,70,255,0.1)", color: COLORS.primary }}>
              Xóa
            </button>
          )}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto">
        {/* Banner */}
        <div className="mx-4 mt-4 rounded-2xl overflow-hidden relative">
          <div
            className="p-4 relative overflow-hidden"
            style={{
              background: `linear-gradient(120deg, ${COLORS.darkBlue} 0%, ${COLORS.primary} 50%, ${COLORS.orange} 100%)`,
            }}
          >
            {/* Decorative circles */}
            <div
              className="absolute -top-6 -right-6 rounded-full opacity-20"
              style={{ width: 100, height: 100, background: COLORS.beige }}
            />
            <div
              className="absolute -bottom-8 -right-2 rounded-full opacity-15"
              style={{ width: 80, height: 80, background: "white" }}
            />
            <div className="flex items-center gap-2 mb-1">
              <Zap size={14} color={COLORS.beige} />
              <span className="text-xs font-medium" style={{ color: COLORS.beige }}>
                Ưu đãi hôm nay
              </span>
            </div>
            <h2 className="text-white font-bold text-base leading-tight">
              Gom Đơn – Freeship{"\n"}
              <span style={{ color: COLORS.beige }}>Sảnh Văn Phòng</span>
            </h2>
            <p className="text-xs mt-1" style={{ color: "rgba(255,255,255,0.8)" }}>
              Gom đủ người → Ship miễn phí tận sảnh 🎉
            </p>
            <div className="mt-2 flex items-center gap-2">
              <span
                className="text-xs px-2.5 py-1 rounded-full font-semibold"
                style={{ background: COLORS.orange, color: "white" }}
              >
                ☀️ Gom đơn ngay
              </span>
              <span
                className="text-xs px-2.5 py-1 rounded-full font-medium"
                style={{ background: "rgba(255,255,255,0.2)", color: "white" }}
              >
                Chốt lúc 10h00
              </span>
            </div>
          </div>
        </div>

        {/* Active Rooms */}
        <div className="px-4 mt-5">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <Flame size={16} color={COLORS.orange} />
              <span className="font-semibold text-sm" style={{ color: COLORS.darkBlue }}>
                Phòng gom đang hoạt động
              </span>
            </div>
            <button className="flex items-center gap-1 text-xs" style={{ color: COLORS.primary }}>
              Xem tất cả <ChevronRight size={12} />
            </button>
          </div>

          <div className="flex flex-col gap-3">
            {rooms.map((room) => {
              const pct = (room.current / room.target) * 100;
              const remaining = room.freeAt - room.current;
              return (
                <button
                  key={room.id}
                  onClick={() => onOpenRoom(room.id)}
                  className="w-full text-left rounded-2xl p-3.5"
                  style={{ background: COLORS.beige, border: `1.5px solid rgba(255,128,64,0.2)` }}
                >
                  <div className="flex items-start gap-3">
                    <div
                      className="rounded-xl p-2 text-xl shrink-0"
                      style={{ background: "white" }}
                    >
                      {room.emoji}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 flex-wrap">
                        <span
                          className="font-semibold text-sm"
                          style={{ color: COLORS.darkBlue }}
                        >
                          {room.name}
                        </span>
                        <span
                          className="text-xs px-2 py-0.5 rounded-full font-medium shrink-0"
                          style={{
                            background: "rgba(255,128,64,0.15)",
                            color: COLORS.orange,
                            border: `1px solid rgba(255,128,64,0.3)`,
                          }}
                        >
                          {room.tag}
                        </span>
                      </div>
                      <p className="text-xs mt-0.5" style={{ color: "rgba(0,27,183,0.6)" }}>
                        {room.restaurant}
                      </p>

                      {/* Progress */}
                      <div className="mt-2">
                        <div className="flex items-center justify-between mb-1">
                          <div className="flex items-center gap-1">
                            <Users size={11} color={COLORS.orange} />
                            <span className="text-xs font-medium" style={{ color: COLORS.orange }}>
                              {room.current}/{room.target} món
                            </span>
                          </div>
                          <div className="flex items-center gap-1">
                            <Clock size={11} color="rgba(0,27,183,0.5)" />
                            <span className="text-xs" style={{ color: "rgba(0,27,183,0.5)" }}>
                              {room.timeLeft}
                            </span>
                          </div>
                        </div>
                        <div className="w-full h-2 rounded-full" style={{ background: "rgba(255,128,64,0.15)" }}>
                          <div
                            className="h-2 rounded-full transition-all"
                            style={{ width: `${pct}%`, background: COLORS.orange }}
                          />
                        </div>
                        {remaining > 0 && (
                          <p className="text-xs mt-1 font-medium" style={{ color: COLORS.orange }}>
                            Còn {remaining} người nữa để Freeship!
                          </p>
                        )}
                      </div>
                    </div>
                    <ChevronRight size={16} color={COLORS.primary} className="shrink-0 mt-1" />
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Category filter */}
        <div className="px-4 mt-5">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <ShoppingBag size={16} color={COLORS.primary} />
              <span className="font-semibold text-sm" style={{ color: COLORS.darkBlue }}>
                Món ngon hôm nay
              </span>
            </div>
          </div>
          <div className="flex gap-2 overflow-x-auto pb-1 scrollbar-none">
            {categories.map((cat) => (
              <button
                key={cat}
                onClick={() => setActiveCategory(cat)}
                className="shrink-0 px-3.5 py-1.5 rounded-full text-xs font-medium transition-all"
                style={
                  activeCategory === cat
                    ? { background: COLORS.primary, color: "white" }
                    : { background: "white", color: COLORS.darkBlue, border: `1px solid rgba(0,27,183,0.15)` }
                }
              >
                {cat}
              </button>
            ))}
          </div>
        </div>

        {/* Food grid */}
        <div className="px-4 mt-3 pb-6 grid grid-cols-2 gap-3">
          {filtered.map((food) => (
            <div
              key={food.id}
              className="rounded-2xl overflow-hidden"
              style={{ background: "white", border: "1px solid rgba(0,27,183,0.07)" }}
            >
              {/* Image placeholder */}
              <div
                className="h-28 flex items-center justify-center relative"
                style={{ background: COLORS.beige }}
              >
                <span className="text-5xl">{food.emoji}</span>
                <span
                  className="absolute top-2 left-2 text-xs px-2 py-0.5 rounded-full font-semibold"
                  style={
                    food.tag === "Freeship"
                      ? { background: COLORS.primary, color: "white" }
                      : food.tag === "Hot"
                      ? { background: COLORS.orange, color: "white" }
                      : { background: COLORS.darkBlue, color: "white" }
                  }
                >
                  {food.tag}
                </span>
              </div>
              <div className="p-2.5">
                <p className="text-xs font-semibold leading-tight" style={{ color: COLORS.darkBlue }}>
                  {food.name}
                </p>
                <p className="text-xs mt-0.5 truncate" style={{ color: "rgba(0,27,183,0.5)" }}>
                  {food.restaurant}
                </p>
                <div className="flex items-center gap-1 mt-1">
                  <Star size={9} color="#fbbf24" fill="#fbbf24" />
                  <span className="text-xs" style={{ color: "rgba(0,27,183,0.6)" }}>
                    {food.rating}
                  </span>
                  <span className="text-xs" style={{ color: "rgba(0,27,183,0.4)" }}>
                    · {food.orders}
                  </span>
                </div>
                <div className="flex items-center justify-between mt-2">
                  <div>
                    <p className="text-sm font-bold" style={{ color: COLORS.orange }}>
                      {food.price}
                    </p>
                    {food.originalPrice && (
                      <p className="text-xs line-through" style={{ color: "rgba(0,27,183,0.35)" }}>
                        {food.originalPrice}
                      </p>
                    )}
                  </div>
                  <button
                    className="text-xs px-2.5 py-1.5 rounded-xl font-semibold text-white"
                    style={{ background: COLORS.primary }}
                  >
                    Đặt chung
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
