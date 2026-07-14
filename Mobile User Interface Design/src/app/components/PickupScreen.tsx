import { useState } from "react";
import { ArrowLeft, MapPin, Clock, User, Package, CheckCircle2, QrCode, Hash, ChevronRight, RefreshCw } from "lucide-react";

const COLORS = {
  primary: "#0046FF",
  orange: "#FF8040",
  darkBlue: "#001BB7",
  beige: "#F5F1DC",
};

type CodeMode = "pin" | "qr";

interface PickupScreenProps {
  onBack: () => void;
}

const PIN = "7429";

function QRPattern() {
  const size = 140;
  const cells = 21;
  const cell = size / cells;

  const pattern = [
    [0,0],[0,1],[0,2],[0,3],[0,4],[0,5],[0,6],
    [0,8],[0,11],[0,12],[0,13],[0,14],[0,15],[0,16],[0,17],[0,18],[0,19],[0,20],
    [1,0],[1,6],[1,8],[1,9],[1,11],[1,14],[1,20],
    [2,0],[2,2],[2,3],[2,4],[2,6],[2,8],[2,10],[2,12],[2,14],[2,16],[2,17],[2,18],[2,20],
    [3,0],[3,2],[3,3],[3,4],[3,6],[3,9],[3,11],[3,14],[3,16],[3,17],[3,18],[3,20],
    [4,0],[4,2],[4,3],[4,4],[4,6],[4,8],[4,10],[4,11],[4,14],[4,16],[4,17],[4,18],[4,20],
    [5,0],[5,6],[5,8],[5,9],[5,11],[5,12],[5,14],[5,20],
    [6,0],[6,1],[6,2],[6,3],[6,4],[6,5],[6,6],[6,8],[6,10],[6,12],[6,14],[6,15],[6,16],[6,17],[6,18],[6,19],[6,20],
    [7,8],[7,10],[7,12],
    [8,0],[8,1],[8,3],[8,5],[8,6],[8,7],[8,8],[8,10],[8,12],[8,13],[8,15],[8,17],[8,18],[8,20],
    [9,1],[9,3],[9,5],[9,8],[9,10],[9,11],[9,14],[9,15],[9,17],[9,19],[9,20],
    [10,0],[10,2],[10,4],[10,6],[10,8],[10,9],[10,11],[10,13],[10,15],[10,17],[10,19],
    [11,0],[11,2],[11,4],[11,5],[11,7],[11,9],[11,11],[11,12],[11,14],[11,16],[11,18],[11,20],
    [12,1],[12,3],[12,6],[12,8],[12,10],[12,13],[12,15],[12,17],[12,19],
    [13,8],[13,10],[13,12],
    [14,0],[14,1],[14,2],[14,3],[14,4],[14,5],[14,6],[14,8],[14,10],[14,12],[14,14],[14,16],[14,17],[14,19],[14,20],
    [15,0],[15,6],[15,9],[15,10],[15,12],[15,13],[15,15],[15,17],[15,19],
    [16,0],[16,2],[16,3],[16,4],[16,6],[16,8],[16,9],[16,11],[16,14],[16,16],[16,18],[16,19],[16,20],
    [17,0],[17,2],[17,3],[17,4],[17,6],[17,8],[17,10],[17,12],[17,13],[17,15],[17,17],[17,20],
    [18,0],[18,2],[18,3],[18,4],[18,6],[18,9],[18,11],[18,13],[18,15],[18,16],[18,18],[18,20],
    [19,0],[19,6],[19,8],[19,10],[19,12],[19,14],[19,16],[19,18],[19,20],
    [20,0],[20,1],[20,2],[20,3],[20,4],[20,5],[20,6],[20,8],[20,10],[20,12],[20,14],[20,16],[20,18],[20,20],
  ];

  const set = new Set(pattern.map(([r, c]) => `${r}-${c}`));

  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
      <rect width={size} height={size} fill="white" />
      {Array.from({ length: cells }).map((_, row) =>
        Array.from({ length: cells }).map((_, col) =>
          set.has(`${row}-${col}`) ? (
            <rect
              key={`${row}-${col}`}
              x={col * cell}
              y={row * cell}
              width={cell}
              height={cell}
              fill={COLORS.darkBlue}
              rx={1}
            />
          ) : null
        )
      )}
    </svg>
  );
}

export function PickupScreen({ onBack }: PickupScreenProps) {
  const [codeMode, setCodeMode] = useState<CodeMode>("pin");

  const steps = [
    { label: "Đặt hàng thành công", done: true, time: "09:32" },
    { label: "Đang gom đơn", done: true, time: "09:32 – 10:00" },
    { label: "Đơn đã chốt & đang chuẩn bị", done: true, time: "10:05" },
    { label: "Tài xế đang giao", done: false, time: "Dự kiến 11:30" },
    { label: "Nhận hàng tại sảnh", done: false, time: "11:30 – 12:00" },
  ];

  return (
    <div className="flex flex-col h-full bg-gray-50">
      {/* Header */}
      <div
        className="px-4 pt-11 pb-5"
        style={{ background: `linear-gradient(135deg, ${COLORS.darkBlue} 0%, ${COLORS.primary} 100%)` }}
      >
        <div className="flex items-center gap-3 mb-4">
          <button
            onClick={onBack}
            className="p-2 rounded-xl"
            style={{ background: "rgba(255,255,255,0.2)" }}
          >
            <ArrowLeft size={18} color="white" />
          </button>
          <div>
            <h1 className="text-white font-bold text-base">Đơn Hàng Đã Chốt</h1>
            <p className="text-xs" style={{ color: "rgba(255,255,255,0.75)" }}>
              Cơm Gà Bà Tuyến · Toà Nhà A – Lầu 5
            </p>
          </div>
        </div>

        {/* Status tags */}
        <div className="flex gap-2 flex-wrap">
          <span
            className="text-xs px-3 py-1.5 rounded-full font-semibold"
            style={{ background: COLORS.orange, color: "white" }}
          >
            ✅ Thành công – Freeship
          </span>
          <span
            className="text-xs px-3 py-1.5 rounded-full font-semibold"
            style={{ background: "rgba(255,255,255,0.2)", color: "white" }}
          >
            🚚 Đang giao hàng
          </span>
          <span
            className="text-xs px-3 py-1.5 rounded-full font-medium"
            style={{
              background: COLORS.beige,
              color: COLORS.darkBlue,
              border: `1px solid rgba(0,27,183,0.15)`,
            }}
          >
            💰 Đã hoàn tiền thừa
          </span>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto pb-8">
        {/* Code card */}
        <div className="mx-4 mt-4 rounded-2xl overflow-hidden" style={{ border: `2px solid ${COLORS.primary}` }}>
          <div
            className="px-4 py-3 flex items-center justify-between"
            style={{ background: COLORS.primary }}
          >
            <div>
              <p className="text-white font-semibold text-sm">Mã nhận hàng</p>
              <p className="text-xs" style={{ color: "rgba(255,255,255,0.75)" }}>
                Xuất trình cho tài xế lúc nhận
              </p>
            </div>
            <div className="flex gap-1">
              {(["pin", "qr"] as CodeMode[]).map((m) => (
                <button
                  key={m}
                  onClick={() => setCodeMode(m)}
                  className="flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-xs font-medium transition-all"
                  style={
                    codeMode === m
                      ? { background: "white", color: COLORS.primary }
                      : { background: "rgba(255,255,255,0.2)", color: "white" }
                  }
                >
                  {m === "pin" ? <Hash size={12} /> : <QrCode size={12} />}
                  {m === "pin" ? "PIN" : "QR"}
                </button>
              ))}
            </div>
          </div>

          <div className="bg-white flex flex-col items-center py-6">
            {codeMode === "pin" ? (
              <>
                <div className="flex gap-3 mb-2">
                  {PIN.split("").map((digit, i) => (
                    <div
                      key={i}
                      className="w-14 h-16 rounded-xl flex items-center justify-center shadow-sm"
                      style={{
                        background: COLORS.beige,
                        border: `2px solid ${COLORS.primary}`,
                      }}
                    >
                      <span
                        className="text-3xl font-black"
                        style={{ color: COLORS.darkBlue }}
                      >
                        {digit}
                      </span>
                    </div>
                  ))}
                </div>
                <p className="text-xs mt-1" style={{ color: "rgba(0,27,183,0.5)" }}>
                  Mã PIN · Sử dụng một lần
                </p>
              </>
            ) : (
              <>
                <div
                  className="p-3 rounded-2xl"
                  style={{ background: COLORS.beige, border: `2px solid ${COLORS.primary}` }}
                >
                  <QRPattern />
                </div>
                <p className="text-xs mt-2" style={{ color: "rgba(0,27,183,0.5)" }}>
                  Quét mã QR · Sử dụng một lần
                </p>
              </>
            )}

            <div
              className="mt-3 mx-4 rounded-xl px-4 py-2.5 flex items-center gap-2"
              style={{ background: "rgba(255,128,64,0.08)", border: `1px solid rgba(255,128,64,0.2)` }}
            >
              <Clock size={13} color={COLORS.orange} />
              <p className="text-xs font-medium" style={{ color: COLORS.orange }}>
                Nhận hàng tại sảnh lúc <strong>11:30 – 12:00</strong> hôm nay
              </p>
            </div>
          </div>
        </div>

        {/* Order summary */}
        <div className="mx-4 mt-4 bg-white rounded-2xl p-4" style={{ border: "1px solid rgba(0,27,183,0.08)" }}>
          <p className="text-sm font-semibold mb-3" style={{ color: COLORS.darkBlue }}>
            Tóm tắt đơn hàng
          </p>
          <div className="space-y-2">
            {[
              { label: "Cơm Gà Xối Mỡ × 1", value: "45.000đ" },
              { label: "Phí ship (gốc)", value: "35.000đ" },
              { label: "Giảm Freeship", value: "–35.000đ", highlight: true },
            ].map((row) => (
              <div key={row.label} className="flex justify-between">
                <span className="text-xs" style={{ color: "rgba(0,27,183,0.6)" }}>{row.label}</span>
                <span
                  className="text-xs font-medium"
                  style={{ color: row.highlight ? COLORS.orange : COLORS.darkBlue }}
                >
                  {row.value}
                </span>
              </div>
            ))}
            <div className="h-px" style={{ background: "rgba(0,27,183,0.08)" }} />
            <div className="flex justify-between">
              <span className="text-sm font-bold" style={{ color: COLORS.darkBlue }}>Thực trả</span>
              <span className="text-sm font-bold" style={{ color: COLORS.primary }}>45.000đ</span>
            </div>
            <div
              className="flex items-center gap-2 rounded-lg px-3 py-2"
              style={{ background: "rgba(34,197,94,0.08)", border: "1px solid rgba(34,197,94,0.2)" }}
            >
              <RefreshCw size={12} color="#16a34a" />
              <p className="text-xs font-medium" style={{ color: "#16a34a" }}>
                Đã hoàn 12.000đ về ví của bạn
              </p>
            </div>
          </div>
        </div>

        {/* Driver info */}
        <div className="mx-4 mt-3 bg-white rounded-2xl p-4" style={{ border: "1px solid rgba(0,27,183,0.08)" }}>
          <p className="text-sm font-semibold mb-3" style={{ color: COLORS.darkBlue }}>
            Thông tin giao hàng
          </p>
          <div className="flex items-center gap-3">
            <div
              className="w-12 h-12 rounded-2xl flex items-center justify-center shrink-0"
              style={{ background: COLORS.beige }}
            >
              <User size={22} color={COLORS.primary} />
            </div>
            <div className="flex-1">
              <p className="text-sm font-semibold" style={{ color: COLORS.darkBlue }}>
                Anh Minh Tài xế
              </p>
              <p className="text-xs" style={{ color: "rgba(0,27,183,0.55)" }}>
                Tuyến Ninh Kiều – Tòa A
              </p>
              <div className="flex items-center gap-2 mt-1">
                <span
                  className="text-xs px-2 py-0.5 rounded-full font-medium"
                  style={{ background: "rgba(0,70,255,0.08)", color: COLORS.primary }}
                >
                  ⭐ 4.9 · 320 chuyến
                </span>
              </div>
            </div>
          </div>

          <div className="mt-3 flex items-center gap-2 rounded-xl px-3 py-2.5" style={{ background: COLORS.beige }}>
            <Clock size={14} color={COLORS.orange} />
            <div>
              <p className="text-xs font-medium" style={{ color: COLORS.darkBlue }}>
                Dự kiến giao: <span style={{ color: COLORS.orange }}>11:30 – 12:00</span>
              </p>
              <p className="text-xs" style={{ color: "rgba(0,27,183,0.5)" }}>
                Địa điểm: Sảnh Toà Nhà A, 12 Nguyễn Trãi
              </p>
            </div>
          </div>

          <button
            className="mt-3 w-full flex items-center justify-center gap-2 rounded-xl py-2.5 font-medium text-sm"
            style={{
              border: `1.5px solid ${COLORS.primary}`,
              color: COLORS.primary,
              background: "white",
            }}
          >
            <MapPin size={15} />
            Xem lộ trình giao
            <ChevronRight size={15} />
          </button>
        </div>

        {/* Timeline */}
        <div className="mx-4 mt-3 bg-white rounded-2xl p-4" style={{ border: "1px solid rgba(0,27,183,0.08)" }}>
          <p className="text-sm font-semibold mb-3" style={{ color: COLORS.darkBlue }}>
            Trạng thái đơn hàng
          </p>
          <div className="flex flex-col gap-0">
            {steps.map((step, i) => (
              <div key={i} className="flex gap-3">
                <div className="flex flex-col items-center">
                  <div
                    className="w-6 h-6 rounded-full flex items-center justify-center shrink-0"
                    style={{
                      background: step.done ? COLORS.primary : "rgba(0,27,183,0.1)",
                      border: step.done ? "none" : `2px dashed rgba(0,27,183,0.2)`,
                    }}
                  >
                    {step.done ? (
                      <CheckCircle2 size={14} color="white" />
                    ) : (
                      <Package size={11} color="rgba(0,27,183,0.3)" />
                    )}
                  </div>
                  {i < steps.length - 1 && (
                    <div
                      className="w-px flex-1 min-h-6"
                      style={{ background: step.done ? COLORS.primary : "rgba(0,27,183,0.1)" }}
                    />
                  )}
                </div>
                <div className="pb-3">
                  <p
                    className="text-xs font-medium"
                    style={{ color: step.done ? COLORS.darkBlue : "rgba(0,27,183,0.4)" }}
                  >
                    {step.label}
                  </p>
                  <p className="text-xs" style={{ color: "rgba(0,27,183,0.4)" }}>
                    {step.time}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
