# ALFA × Meta — okulary Ray-Ban Meta w świetle ALFA

Aplikacja Flutter (Android / iOS / Windows) łącząca okulary Ray-Ban Meta
z Meta Model API (Muse) i ekosystemem ALFA: Bridge, Brain, Guardian/CERBER, boty rytualne.

## Architektura

```
Ray-Ban Meta ──BLE──> Android/iOS (Meta Wearables SDK)
                           │ MethodChannel: alfa/meta_wearables (audio PCM16)
                           ▼
                    Aplikacja Flutter
                     ┌─────┴──────────────────┐
                     ▼                        ▼
        Muse Voice Transcribe         ALFA Bridge (ws://:8080/bridge)
        (wss://api.meta.ai/v1/         Guardian/CERBER + Brain
         asr/realtime)                      │
                     │                        ▼
                     ▼                   Boty ALFA (6 rytuałów)
        Transkrypcja PL live            │
                     │                  ▼
                     └────► Muse Spark 1.3 (lub lokalny Glimmer fallback)
                                        ▲
                     Windows (klient Bridge — bez parowania)
```

## Modele Meta w użyciu

| Zadanie | Model | Dostęp |
|---|---|---|
| STT live z okularów | `muse-voice-transcribe-1.0` | WebSocket realtime + pliki |
| Boty ALFA (szybkie) | `muse-spark-1.3` | Chat Completions |
| Długie zadania agentowe | `muse-wonder-1.0` | `heavy: true` w `askLocal` |
| Lokalny fallback | Muse Glimmer (self-host, vLLM/llama.cpp) | OpenAI-compatible `:8000` |

## Funkcje STT

- Streaming realtime z **diaryzacją** (kto mówi) i natywnym endpointingiem (VAD)
- **Keyword biasing**: ALFA, Guardian, CERBER, nazwy botów → lepsze rozpoznawanie rytuałów
- PL/EN code-switching
- Znaczniki czasu na poziomie zdań

## Status warstw

| Warstwa | Status |
|---|---|
| UI Flutter (Głos, Wzrok, Boty) | ✅ |
| Muse Voice Transcribe (realtime STT) | ✅ klient gotowy — wymaga `MODEL_API_KEY` |
| Muse API (Spark 1.3 / Wonder) | ✅ z retry-hint i fallbackiem lokalnym |
| ALFA Bridge (WebSocket client) | ✅ |
| Guardian pre-filter (klient) | ✅ |
| Boty ALFA (6 rytuałów, tryb Bridge lub lokalny) | ✅ |
| Meta Wearables SDK (Android/iOS) | ⚠️ stub — czeka na zatwierdzenie konta Meta Developer |
| Windows | ✅ klient Bridge |

## Uruchomienie

```bash
flutter pub get
# klucz tylko do devu; produkcyjnie klucz żyje w Bridge po stronie serwera
flutter run --dart-define=MODEL_API_KEY=mk_...        # Android / iOS
flutter run -d windows --dart-define=MODEL_API_KEY=mk_...
```

Lokalny fallback (self-hosted Glimmer):
```bash
vllm serve muse-glimmer --port 8000
# w aplikacji: preferLocal = true (core/config.dart)
```

## Roadmap

1. Zatwierdzenie Meta Wearables Developer → podmiana stubów na realne SDK
2. Endpoint `/bridge` w ALFA Brain (protokół: transcription / frame / bot_request / bot_response)
3. CERBER server-side w Bridge
4. Ensemble botów (mixture of experts) po stronie Bridge
5. SAM 3.1 — segmentacja obiektów w klatkach z okularów ("co widzę")
