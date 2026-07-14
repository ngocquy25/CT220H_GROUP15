import { useState } from "react";
import { MapPin, Navigation, Check, ChevronRight, Building2 } from "lucide-react";

const COLORS = {
  primary: "#0046FF",
  orange: "#FF8040",
  darkBlue: "#001BB7",
  beige: "#F5F1DC",
};

const hubs = [
  {
    id: 1,
    name: "Sảnh Tòa Nhà A",
    address: "12 Nguyễn Trãi, Ninh Kiều, Cần Thơ",
    distance: "120m",
    slots: "3 tuyến hoạt động",
    active: true,
  },
  {
    id: 2,
    name: "Công ty X – Sảnh 1",
    address: "45 Mậu Thân, Ninh Kiều, Cần Thơ",
    distance: "280m",
    slots: "2 tuyến hoạt động",
    active: true,
  },
  {
    id: 3,
    name: "Tòa CT2 – Cổng Chính",
    address: "88 Trần Hưng Đạo, Ninh Kiều, Cần Thơ",
    distance: "460m",
    slots: "1 tuyến hoạt động",
    active: false,
  },
];

interface HubSelectionScreenProps {
  onConfirm: (hub: (typeof hubs)[0]) => void;
}

export function HubSelectionScreen({ onConfirm }: HubSelectionScreenProps) {
  const [selected, setSelected] = useState<number | null>(1);

  const selectedHub = hubs.find((h) => h.id === selected);

  return (
    <div className="flex flex-col h-full bg-white">
      {/* Header */}
      <div
        className="px-5 pt-12 pb-4"
        style={{ background: `linear-gradient(135deg, ${COLORS.primary} 0%, ${COLORS.darkBlue} 100%)` }}
      >
        <div className="flex items-center gap-2 mb-1">
          <Navigation size={16} color="rgba(255,255,255,0.8)" />
          <span className="text-xs" style={{ color: "rgba(255,255,255,0.8)" }}>
            GPS đã xác định vị trí của bạn
          </span>
        </div>
        <h1 className="text-white text-xl font-semibold">Chọn Hub của bạn</h1>
        <p className="text-xs mt-0.5" style={{ color: "rgba(255,255,255,0.7)" }}>
          Các Hub trong bán kính 500m
        </p>
      </div>

      {/* Mini Map */}
      <div className="mx-4 mt-4 rounded-2xl overflow-hidden relative" style={{ height: 160 }}>
        <div
          className="w-full h-full relative"
          style={{
            background: `linear-gradient(160deg, #e8f4f8 0%, #d4eaf5 40%, #c8e0ef 100%)`,
          }}
        >
          {/* Grid lines */}
          {[...Array(6)].map((_, i) => (
            <div
              key={`h-${i}`}
              className="absolute w-full"
              style={{ top: `${i * 20}%`, borderTop: "1px solid rgba(0,70,255,0.08)" }}
            />
          ))}
          {[...Array(8)].map((_, i) => (
            <div
              key={`v-${i}`}
              className="absolute h-full"
              style={{ left: `${i * 14}%`, borderLeft: "1px solid rgba(0,70,255,0.08)" }}
            />
          ))}

          {/* Roads */}
          <div
            className="absolute"
            style={{
              top: "50%",
              left: 0,
              right: 0,
              height: 8,
              background: "rgba(255,255,255,0.7)",
              borderRadius: 4,
              transform: "translateY(-50%)",
            }}
          />
          <div
            className="absolute"
            style={{
              left: "38%",
              top: 0,
              bottom: 0,
              width: 8,
              background: "rgba(255,255,255,0.7)",
              borderRadius: 4,
            }}
          />

          {/* Hub pins */}
          <div className="absolute" style={{ top: "44%", left: "32%" }}>
            <div
              className="w-6 h-6 rounded-full flex items-center justify-center shadow-lg border-2 border-white"
              style={{ background: COLORS.primary }}
            >
              <MapPin size={10} color="white" />
            </div>
            <div
              className="text-white text-xs px-1.5 py-0.5 rounded-md mt-0.5 whitespace-nowrap font-medium"
              style={{ background: COLORS.primary, fontSize: 9 }}
            >
              Sảnh A
            </div>
          </div>

          <div className="absolute" style={{ top: "32%", left: "58%" }}>
            <div
              className="w-5 h-5 rounded-full flex items-center justify-center shadow border-2 border-white"
              style={{ background: COLORS.orange }}
            >
              <MapPin size={8} color="white" />
            </div>
          </div>

          <div className="absolute" style={{ top: "62%", left: "68%" }}>
            <div
              className="w-5 h-5 rounded-full flex items-center justify-center shadow border-2 border-white"
              style={{ background: "#aaa" }}
            >
              <MapPin size={8} color="white" />
            </div>
          </div>

          {/* User location */}
          <div className="absolute" style={{ top: "48%", left: "44%" }}>
            <div
              className="w-4 h-4 rounded-full border-3 border-white shadow-lg"
              style={{ background: "#22d3ee" }}
            />
            <div
              className="absolute inset-0 rounded-full animate-ping"
              style={{ background: "rgba(34,211,238,0.3)" }}
            />
          </div>

          {/* Range circle */}
          <div
            className="absolute rounded-full"
            style={{
              top: "48%",
              left: "44%",
              width: 80,
              height: 80,
              transform: "translate(-50%, -50%)",
              border: `1.5px dashed ${COLORS.primary}`,
              background: "rgba(0,70,255,0.05)",
            }}
          />

          <div className="absolute bottom-2 right-3 text-xs" style={{ color: COLORS.darkBlue, opacity: 0.6 }}>
            ~500m
          </div>
        </div>
      </div>

      {/* Hub list */}
      <div className="px-4 mt-4 flex-1 overflow-auto">
        <p className="text-xs font-semibold mb-2" style={{ color: COLORS.darkBlue }}>
          3 Hub gần bạn nhất
        </p>
        <div className="flex flex-col gap-3">
          {hubs.map((hub) => {
            const isSelected = selected === hub.id;
            return (
              <button
                key={hub.id}
                onClick={() => setSelected(hub.id)}
                className="w-full text-left rounded-2xl p-3.5 border-2 transition-all duration-200"
                style={{
                  background: isSelected ? COLORS.beige : "white",
                  borderColor: isSelected ? COLORS.primary : "rgba(0,27,183,0.12)",
                }}
              >
                <div className="flex items-start gap-3">
                  <div
                    className="rounded-xl p-2 shrink-0"
                    style={{ background: isSelected ? COLORS.primary : "rgba(0,70,255,0.08)" }}
                  >
                    <Building2 size={18} color={isSelected ? "white" : COLORS.primary} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span
                        className="font-semibold text-sm truncate"
                        style={{ color: COLORS.darkBlue }}
                      >
                        {hub.name}
                      </span>
                      {hub.active && (
                        <span
                          className="text-xs px-2 py-0.5 rounded-full shrink-0 font-medium"
                          style={{
                            background: isSelected ? COLORS.orange : "rgba(255,128,64,0.12)",
                            color: COLORS.orange,
                          }}
                        >
                          Hoạt động
                        </span>
                      )}
                    </div>
                    <p className="text-xs mt-0.5 truncate" style={{ color: "rgba(0,27,183,0.6)" }}>
                      {hub.address}
                    </p>
                    <div className="flex items-center gap-3 mt-1.5">
                      <span
                        className="flex items-center gap-1 text-xs font-medium"
                        style={{ color: COLORS.primary }}
                      >
                        <Navigation size={10} />
                        {hub.distance}
                      </span>
                      <span className="text-xs" style={{ color: "rgba(0,27,183,0.5)" }}>
                        {hub.slots}
                      </span>
                    </div>
                  </div>
                  <div
                    className="shrink-0 w-5 h-5 rounded-full border-2 flex items-center justify-center"
                    style={{
                      borderColor: isSelected ? COLORS.primary : "rgba(0,70,255,0.2)",
                      background: isSelected ? COLORS.primary : "transparent",
                    }}
                  >
                    {isSelected && <Check size={10} color="white" strokeWidth={3} />}
                  </div>
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {/* CTA */}
      <div className="px-4 pb-10 pt-4">
        <button
          onClick={() => selectedHub && onConfirm(selectedHub)}
          disabled={!selected}
          className="w-full rounded-2xl py-4 font-semibold text-white flex items-center justify-center gap-2 transition-opacity"
          style={{
            background: selected
              ? `linear-gradient(90deg, ${COLORS.primary} 0%, #1a5fff 100%)`
              : "#ccc",
          }}
        >
          <MapPin size={18} />
          Xác nhận Hub
          <ChevronRight size={18} />
        </button>
        <p className="text-center text-xs mt-2" style={{ color: "rgba(0,27,183,0.5)" }}>
          {selectedHub ? `Hub: ${selectedHub.name}` : "Vui lòng chọn Hub"}
        </p>
      </div>
    </div>
  );
}
