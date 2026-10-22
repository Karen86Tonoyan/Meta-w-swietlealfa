# Windows — uwagi platformowe

Meta Wearables SDK **nie wspiera Windows** — okularów nie sparujesz
bezpośrednio z desktopu. Aplikacja Flutter na Windowsie działa jako
**klient ALFA Bridge**:

1. Telefon (Android/iOS) z aplikacją ALFA × Meta jest sparowany z okularami.
2. Na telefonie (lub w LAN) działa ALFA Bridge (`ws://<host>:8080/bridge`).
3. Aplikacja Windows łączy się z Bridge przez WebSocket i dostaje:
   transkrypcję, klatki z kamery, odpowiedzi botów, pamięć Brain.

Build: `flutter build windows` (wymaga Visual Studio z C++ desktop tools).
Ustaw endpoint Bridge w ustawieniach aplikacji (domyślnie 127.0.0.1:8080).
