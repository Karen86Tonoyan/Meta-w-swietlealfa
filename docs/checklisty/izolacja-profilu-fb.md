# Checklista: „Nowe życie" — izolacja profilu Facebook/Instagram

Cel: odseparować stary profil od nowego, bez przenoszenia starych
powiązań, i z minimalną powierzchnią ataku. Kroki do kliknięcia.

## Faza 0 — przygotowanie (przed zmianami)

- [ ] Zapisz z starych kont to, co chcesz zachować (zdjęcia, kontakty):
      Facebook → Ustawienia → Twoje informacje → Pobierz swoje informacje
- [ ] Zapisz listę znajomych/grup, do których chcesz wrócić ręcznie
- [ ] Przygotuj NOWY e-mail (nieużywany nigdy z kontami Meta)

## Faza 1 — nowe konto

- [ ] Załóż nowe konto Facebook na nowy e-mail (nie przez „zaloguj przez Google"
      powiązane ze starą tożsamością)
- [ ] Nowa nazwa profilu NIE powinna kopiować starej 1:1 (unikniesz
      automatycznych sugestii „osoby, które możesz znać")
- [ ] Nie podawaj starego numeru telefonu — jeśli 2FA, użyj aplikacji
      uwierzytelniającej zamiast SMS

## Faza 2 — uszczelnienie prywatności (nowe konto)

- [ ] Ustawienia → Prywatność → „Kto może widzieć Twoje posty" → Tylko znajomi
- [ ] „Kto może wyszukać Cię po e-mailu/telefonie" → Tylko ja
- [ ] „Czy chcesz, by wyszukiwarki linkowały do profilu" → NIE
- [ ] Oznaczenia i wzmianki → wymagaj zatwierdzenia
- [ ] Ogranicz przeszłe posty (jeśli coś przeniosłeś)
- [ ] Wyłącz rozpoznawanie twarzy (jeśli dostępne w regionie)
- [ ] Aktywność poza Facebookiem → wyczyść historię i odłącz przyszłą

## Faza 3 — stary profil

- [ ] Dezaktywacja (odwracalna) albo usunięcie:
      Ustawienia → Twoje informacje → Dezaktywacja i usunięcie
- [ ] UWAGA: jeśli stary FB jest kluczem do innych usług (logowanie „przez
      Facebook"), przełącz je najpierw na e-mail
- [ ] Messenger starego konta dezaktywuje się razem z FB

## Faza 4 — izolacja techniczna (powiązanie z apką ALFA × Meta)

- [ ] Nowe konto Meta → nowy profil w aplikacji = nowy baseline CERBER-a
      (IP + fingerprint + token zapisywane od zera)
- [ ] `SecureStore.wipeProfile()` na urządzeniach, gdzie był stary profil
- [ ] Nowy klucz MODEL_API_KEY w Bridge (stary unieważnij w Meta for Developers)
- [ ] Graf wiedzy: nowy węzeł profilu, stary oznacz jako zamknięty

## Czego NIE robić

- Nie loguj nowego konta w tej samej przeglądarce/profilu bez wyczyszczenia
  cookies — Meta łączy konta po śladach przeglądarki
- Nie przenoś masowo tych samych znajomych pierwszego dnia
- Nie używaj tego samego zdjęcia profilowego (odwrócone wyszukiwanie obrazem)
