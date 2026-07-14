import { useState } from "react";
import { ArrowLeft, Users, Clock, Shield, Info, Plus, Minus, ChevronRight, CheckCircle2, AlertCircle } from "lucide-react";

const COLORS = {
  primary: "#0046FF",
  orange: "#FF8040",
  darkBlue: "#001BB7",
  beige: "#F5F1DC",
};

const menuItems = [
  { id: 1, name: "Cơm Gà Xối Mỡ", price: 45000, emoji: "🍗" },
  { id: 2, name: "Cơm Gà Luộc", price: 42000, emoji: "🍚" },
  { id: 3, name: "Cơm Gà + Canh", price: 52000, emoji: "🍱" },
];

interface RoomDetailScreenProps {
  onBack: () => void;
  onConfirmPayment: () => void;
}

export function RoomDetailScreen({ onBack, onConfirmPayment }: RoomDetailScreenProps) {
  const [selected, setSelected] = useState<number | null>(1);
  const [qty, setQty] = useState(1);
  const [mode, setMode] = useState<"sure" | "cheap">("sure");
  const [showPaymentInfo, setShowPaymentInfo] = useState(false);

  const current = 8;
  const target = 10;
  const pct = (current / target) * 100;
  const remaining = target - current;

  const item = menuItems.find((m) => m.id === selected);
  const basePrice = (item?.price ?? 45000) * qty;
  const shipFee = 35000;
  const total = basePrice + shipFee;
  const estimatedRefund = 12000;

  return (
    <div className="flex flex-col h-full bg-gray-50">
      {/* Header */}
      <div
        className="px-4 pt-11 pb-4 flex items-center gap-3"
        style={{ background: `linear-gradient(135deg, ${COLORS.primary} 0%, #1a3aff 100%)` }}
      >
        <button
          onClick={onBack}
          className="p-2 rounded-xl"
          style={{ background: "rgba(255,255,255,0.2)" }}
        >
          <ArrowLeft size={18} color="white" />
        </button>
        <div>
          <h1 className="text-white font-bold text-base">Phòng Gom: Bữa Trưa Lầu 5</h1>
          <p className="text-xs" style={{ color: "rgba(255,255,255,0.75)" }}>
            Cơm Gà Bà Tuyến · Toà Nhà A
          </p>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto pb-32">
        {/* Progress card */}
        <div className="mx-4 mt-4 rounded-2xl p-4" style={{ background: COLORS.beige, border: `1.5px solid rgba(255,128,64,0.25)` }}>
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-2">
              <span
                className="text-xs px-2.5 py-1 rounded-full font-semibold"
                style={{ background: COLORS.orange, color: "white" }}
              >
                🔥 Đang gom
              </span>
              <div className="flex items-center gap-1">
                <Clock size={12} color={COLORS.darkBlue} />
                <span className="text-xs font-medium" style={{ color: COLORS.darkBlue }}>
                  Chốt lúc 10h00
                </span>
              </div>
            </div>
            <span className="text-xs" style={{ color: "rgba(0,27,183,0.5)" }}>
              Còn ~15 phút
            </span>
          </div>

          <div className="flex items-center justify-between mb-1.5">
            <div className="flex items-center gap-1.5">
              <Users size={14} color={COLORS.orange} />
              <span className="font-bold text-sm" style={{ color: COLORS.darkBlue }}>
                {current}/{target} món
              </span>
            </div>
            {remaining > 0 && (
              <span className="text-xs font-semibold" style={{ color: COLORS.orange }}>
                Cần thêm {remaining} món để Freeship!
              </span>
            )}
          </div>

          <div className="w-full h-3 rounded-full relative overflow-hidden" style={{ background: "rgba(255,128,64,0.15)" }}>
            <div
              className="h-3 rounded-full transition-all duration-500"
              style={{ width: `${pct}%`, background: `linear-gradient(90deg, ${COLORS.orange} 0%, #ff5500 100%)` }}
            />
            <div
              className="absolute top-0 h-full w-px"
              style={{ left: "100%", background: "transparent" }}
            />
          </div>

          <div className="flex justify-between mt-1.5">
            <span className="text-xs" style={{ color: "rgba(0,27,183,0.5)" }}>0 món</span>
            <span className="text-xs font-medium" style={{ color: COLORS.orange }}>
              🎉 {target} món = Freeship
            </span>
          </div>
        </div>

        {/* Mode selection */}
        <div className="mx-4 mt-4">
          <p className="text-xs font-semibold mb-2" style={{ color: COLORS.darkBlue }}>
            Cài đặt đơn của bạn
          </p>
          <div className="grid grid-cols-2 gap-2">
            {[
              {
                key: "sure",
                label: "Chắc chắn ăn",
                desc: "Giữ nguyên món dù thiếu người",
                icon: "✅",
              },
              {
                key: "cheap",
                label: "Đảm bảo rẻ",
                desc: "Chỉ đặt khi đủ người Freeship",
                icon: "💰",
              },
            ].map((opt) => (
              <button
                key={opt.key}
                onClick={() => setMode(opt.key as "sure" | "cheap")}
                className="rounded-xl p-3 text-left border-2 transition-all"
                style={{
                  background: mode === opt.key ? COLORS.beige : "white",
                  borderColor: mode === opt.key ? COLORS.primary : "rgba(0,27,183,0.12)",
                }}
              >
                <div className="text-xl mb-1">{opt.icon}</div>
                <p className="text-xs font-semibold" style={{ color: COLORS.darkBlue }}>
                  {opt.label}
                </p>
                <p className="text-xs mt-0.5" style={{ color: "rgba(0,27,183,0.55)" }}>
                  {opt.desc}
                </p>
                {mode === opt.key && (
                  <div className="mt-1.5 flex items-center gap-1">
                    <CheckCircle2 size={12} color={COLORS.primary} />
                    <span className="text-xs font-medium" style={{ color: COLORS.primary }}>
                      Đang chọn
                    </span>
                  </div>
                )}
              </button>
            ))}
          </div>
        </div>

        {/* Menu selection */}
        <div className="mx-4 mt-4">
          <p className="text-xs font-semibold mb-2" style={{ color: COLORS.darkBlue }}>
            Chọn món
          </p>
          <div className="flex flex-col gap-2">
            {menuItems.map((menuItem) => {
              const isSel = selected === menuItem.id;
              return (
                <button
                  key={menuItem.id}
                  onClick={() => setSelected(menuItem.id)}
                  className="w-full flex items-center gap-3 rounded-xl p-3 border-2 transition-all"
                  style={{
                    background: isSel ? COLORS.beige : "white",
                    borderColor: isSel ? COLORS.primary : "rgba(0,27,183,0.1)",
                  }}
                >
                  <span className="text-2xl">{menuItem.emoji}</span>
                  <div className="flex-1 text-left">
                    <p className="text-sm font-medium" style={{ color: COLORS.darkBlue }}>
                      {menuItem.name}
                    </p>
                  </div>
                  <span className="font-semibold text-sm" style={{ color: COLORS.orange }}>
                    {(menuItem.price / 1000).toFixed(0)}.000đ
                  </span>
                  <div
                    className="w-5 h-5 rounded-full border-2 flex items-center justify-center shrink-0"
                    style={{
                      borderColor: isSel ? COLORS.primary : "rgba(0,70,255,0.2)",
                      background: isSel ? COLORS.primary : "transparent",
                    }}
                  >
                    {isSel && (
                      <div className="w-2 h-2 rounded-full bg-white" />
                    )}
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Quantity */}
        <div className="mx-4 mt-3 flex items-center justify-between bg-white rounded-xl px-4 py-3" style={{ border: "1px solid rgba(0,27,183,0.1)" }}>
          <p className="text-sm font-medium" style={{ color: COLORS.darkBlue }}>Số lượng</p>
          <div className="flex items-center gap-3">
            <button
              onClick={() => setQty(Math.max(1, qty - 1))}
              className="w-8 h-8 rounded-full flex items-center justify-center"
              style={{ background: "rgba(0,70,255,0.08)" }}
            >
              <Minus size={14} color={COLORS.primary} />
            </button>
            <span className="text-base font-bold w-6 text-center" style={{ color: COLORS.darkBlue }}>
              {qty}
            </span>
            <button
              onClick={() => setQty(qty + 1)}
              className="w-8 h-8 rounded-full flex items-center justify-center"
              style={{ background: COLORS.primary }}
            >
              <Plus size={14} color="white" />
            </button>
          </div>
        </div>

        {/* Payment estimate */}
        <div
          className="mx-4 mt-4 rounded-2xl overflow-hidden"
          style={{ border: `1.5px solid rgba(0,70,255,0.15)` }}
        >
          <button
            className="w-full flex items-center justify-between px-4 py-3 bg-white"
            onClick={() => setShowPaymentInfo(!showPaymentInfo)}
          >
            <div className="flex items-center gap-2">
              <Shield size={16} color={COLORS.primary} />
              <span className="text-sm font-semibold" style={{ color: COLORS.darkBlue }}>
                Thanh toán Giữ Tiền
              </span>
            </div>
            <ChevronRight
              size={16}
              color={COLORS.primary}
              style={{ transform: showPaymentInfo ? "rotate(90deg)" : "none", transition: "transform 0.2s" }}
            />
          </button>

          {showPaymentInfo && (
            <div className="px-4 pb-3 bg-white">
              <div
                className="rounded-xl p-3 mb-3"
                style={{ background: "rgba(0,70,255,0.04)", border: "1px dashed rgba(0,70,255,0.2)" }}
              >
                <div className="flex items-start gap-2">
                  <Info size={13} color={COLORS.primary} className="shrink-0 mt-0.5" />
                  <p className="text-xs leading-relaxed" style={{ color: "rgba(0,27,183,0.7)" }}>
                    Hệ thống sẽ <strong>tạm giữ tiền tối đa</strong> (tiền món + phí ship gốc) cho đến khi đơn được chốt.
                    Phần tiền thừa sẽ được <strong>hoàn trả ngay</strong> sau khi chốt đơn.
                  </p>
                </div>
              </div>
            </div>
          )}

          <div className="bg-white px-4 pb-4">
            <div className="space-y-2">
              {[
                { label: "Tiền món × " + qty, value: `${basePrice.toLocaleString("vi")}đ` },
                { label: "Phí ship (tạm tính)", value: `${shipFee.toLocaleString("vi")}đ` },
              ].map((row) => (
                <div key={row.label} className="flex justify-between">
                  <span className="text-xs" style={{ color: "rgba(0,27,183,0.6)" }}>{row.label}</span>
                  <span className="text-xs font-medium" style={{ color: COLORS.darkBlue }}>{row.value}</span>
                </div>
              ))}
              <div className="h-px" style={{ background: "rgba(0,27,183,0.08)" }} />
              <div className="flex justify-between">
                <span className="text-sm font-semibold" style={{ color: COLORS.darkBlue }}>Tổng giữ tiền</span>
                <span className="text-sm font-bold" style={{ color: COLORS.primary }}>
                  {total.toLocaleString("vi")}đ
                </span>
              </div>
              <div className="flex items-center gap-1.5 rounded-lg px-2 py-1.5" style={{ background: "rgba(255,128,64,0.08)" }}>
                <AlertCircle size={12} color={COLORS.orange} />
                <p className="text-xs" style={{ color: COLORS.orange }}>
                  Ước tính hoàn ~{estimatedRefund.toLocaleString("vi")}đ nếu Freeship
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom CTA */}
      <div
        className="absolute bottom-0 left-0 right-0 px-4 pb-8 pt-3"
        style={{ background: "rgba(249,250,251,0.98)", borderTop: "1px solid rgba(0,27,183,0.08)" }}
      >
        <button
          onClick={onConfirmPayment}
          className="w-full rounded-2xl py-4 font-bold text-white text-sm flex items-center justify-center gap-2"
          style={{ background: `linear-gradient(90deg, ${COLORS.primary} 0%, #1a5fff 100%)` }}
        >
          <Shield size={18} />
          Giữ tiền để đặt hàng
          <ChevronRight size={18} />
        </button>
        <p className="text-center text-xs mt-1.5" style={{ color: "rgba(0,27,183,0.45)" }}>
          Giữ tối đa {total.toLocaleString("vi")}đ · Hoàn tiền ngay khi chốt
        </p>
      </div>
    </div>
  );
}
