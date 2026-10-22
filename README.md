# ALFA × Meta — okulary Ray-Ban Meta w świetle ALFA

Aplikacja Flutter (Android / iOS / Windows) łącząca okulary Ray-Ban Meta
z ekosystemem ALFA: Bridge, Brain, Guardian/CERBER i boty rytualne.

## Architektura

```
Ray-Ban Meta ──BLE──> Android/iOS (Meta Wearables SDK)
                           │ MethodChannel: alfa/meta_wearables
                           ▼
                    Aplikacja Flutter (UI: Głos / Wzrok / Boty)
                           │ WebSocket
                           ▼
                    ALFA Bridge (hub lokalny, ws://:8080/bridge)
                     ┌─────┴─────┐
                     ▼           ▼
              Guardian/CERBER   ALFA Brain (pamięć)
                     │           │
                     ▼           ▼
              Boty ALFA (CODER / ARCHITECT / DEBUGGER / ...)
                     ▲
                     │ WebSocket
              Windows (klient desktop — bez parowania z okularami)
```

## Status warstw

| Warstwa | Status |
|---|---|
| UI Flutter (Głos, Wzrok, Boty) | ✅ działa |
| ALFA Bridge (WebSocket client) | ✅ działa |
| Guardian pre-filter (klient) | ✅ działa |
| Boty ALFA (6 botów rytualnych) | ✅ routing gotowy |
| Meta Wearables SDK (Android/iOS) | ⚠️ stub — czeka na zatwierdzenie konta Meta Developer |
| Windows | ✅ jako klient Bridge (brak bezpośredniego parowania — limitacja Meta) |

## Uruchomienie

```bash
flutter pub get
flutter run                # Android / iOS
flutter run -d windows     # Windows (klient Bridge)
```

## Roadmap

1. Zatwierdzenie Meta Wearables Developer → podmiana stubów na realne SDK
2. Bridge: endpoint `/bridge` w ALFA Brain (protokół: transcription / frame / bot_request / bot_response)
3. CERBER server-side w Bridge (pełne filtrowanie, nie tylko pre-filter)
4. Ensemble botów (mixture of experts) po stronie Bridge
