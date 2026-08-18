# Payment Cancel API — `POST /api/v1/integrations/payment/cancel`

Hamkor (partner) o'ziga tegishli bir marotabalik to'lovni bekor qilishi/qaytarishi
uchun API. Faqat **PAYME** va **CLICK** gateway'lari qo'llab-quvvatlanadi.

## Auth

Boshqa `integrations/*` endpointlari kabi — API key + HMAC-SHA256 imzo
(`apps/integration/auth.py`). Headerlar:

| Header | Tavsif |
|---|---|
| `X-API-Key` | Partner API key |
| `X-Timestamp` | so'rov vaqti, ms (±300s tolerantlik) |
| `X-Signature` | `HMAC-SHA256(secret, "POST\n/api/v1/integrations/payment/cancel\n{X-Timestamp}\n{sha256(body)}")` |

Rate limit: `RATE_LIMIT_PARTNER_PAYMENT_CANCEL` (default `30/minute`, partner key bo'yicha).

## So'rov

```json
{
  "payment_id": 4521,
  "reason": 5
}
```

| Maydon | Tur | Majburiy | Tavsif |
|---|---|---|---|
| `payment_id` | int | ha | Bekor qilinadigan `Payment.id` |
| `reason` | int | yo'q (default `5`) | Faqat PAYME uchun — `receipts.cancel` ga yuboriladigan sabab kodi. CLICK uchun e'tiborga olinmaydi |

## Javob

```json
{
  "success": true,
  "payment_id": 4521,
  "status": "cancelled",
  "error_note": null
}
```

| Maydon | Tavsif |
|---|---|
| `success` | provayder tomonida bekor qilish muvaffaqiyatli o'tdimi |
| `status` | to'lovning joriy holati (`Payment.status`) |
| `error_note` | `success: false` bo'lsa provayderdan qaytgan xato matni |

`success: false` bo'lsa ham javob **200** bilan qaytadi — HTTP xato faqat
validatsiya/ruxsat bosqichida (pastga qarang).

## Biznes qoidalari

- **PAYME**: to'lovda `transaction_id` bo'lishi kerak, holat
  `SUCCESSFULLY` / `INITIATING` / `CREATED` bo'lganda bekor qilish mumkin
  (`receipts.cancel`, `reason` shu yerda ishlatiladi). **Diqqat:** bu chaqiruv
  faqat Payme'ga so'rov yuboradi — lokal `Payment` holati shu yerda
  o'zgartirilmaydi, keyinroq Payme webhook orqali yangilanadi.
- **CLICK**: faqat `SUCCESSFULLY` holatidagi to'lov qaytariladi
  (`payment/reversal/{service_id}/{click_paydoc_id}`, DELETE). Muvaffaqiyatli
  bo'lsa (`error_code == 0`) lokal holat **shu yerda darhol** yangilanadi:
  `Payment.status="cancelled"`, `state=CANCELLED`, `cancelled_at` to'ldiriladi,
  barcha `PaymentSplit`lar bekor qilinadi, `Order.canceled=True`/`paid=False`
  bo'ladi; shundan so'ng OFD qaytarish cheki va hamkor webhook relay'i navbatga
  qo'yiladi (`apps/payment/webhooks/click.py: handle_cancel/cancelled_payment`).
- Allaqachon `CANCELLED` / `CANCELLED_DURING_INIT` holatidagi to'lov qayta
  bekor qilinmaydi — `400`.
- UZUM, PAYLOV, karta va boshqa gateway'lar hozircha qo'llab-quvvatlanmaydi.
- Bekor qilish faqat shu `payment.order.partner_id == partner.id` bo'lsa
  amalga oshadi — boshqa hamkorning to'lovi `403`.
- `Settlement` bilan bog'liq emas — bu repoda umuman `Settlement` modeli yo'q,
  faqat `Payment`/`PaymentSplit`/`Order` o'zgaradi.

## Xato kodlari

| Kod | Holat |
|---|---|
| 404 | `payment_id` topilmadi |
| 403 | to'lov boshqa hamkorga tegishli |
| 400 | to'lov allaqachon bekor qilingan / joriy holatda bekor qilib bo'lmaydi / gateway qo'llab-quvvatlanmaydi / `transaction_id` yo'q |

Xatolar `{"detail": "..."}` ko'rinishida qaytadi.

## Manba

- Router: `apps/integration/routers.py` (`cancel_payment`, `/payment/cancel`)
- Sxemalar: `apps/integration/schema.py` (`PaymentCancelRequest`, `PaymentCancelResponse`)
- Provayder cancel logikasi: `apps/payment/providers/payme.py`,
  `apps/payment/providers/click.py`
