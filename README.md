# ISSPS - ćwiczenie 6: sterowanie czterowirnikowym BSP

Sprawozdanie i model Simulink do ćwiczenia 6 „Podstawy sterowania wielowirnikowych bezzałogowych statków powietrznych” (Inżynieria systemów statków powietrznych - systemy sterowania, Politechnika Śląska).

Model BSP jest ten sam co w ćwiczeniu 5 (Aerospace Blockset: Multirotor + 6DOF Quaternion, ciężar, opór, wiatr), a układ sterowania jest zbudowany jak na wykładzie 6 (slajd 32): PID wysokości, roll, pitch i prędkości yaw, mikser A⁻¹, pierwiastek, nasycenie. Do zadania 2 dochodzą pętle położenia X, Y i kąta yaw.

## Co tu jest

```
docs/
  ISSPS_LAB6_sekcja2_...pdf   <- gotowe sprawozdanie
  ISSPS_LAB6_sekcja2_...docx    to samo sprawozdanie w wersji Word
  make_docx.py                tworzy wersję Word: python3 make_docx.py <plik.typ> <wynik.docx>
  sprawozdanie_lab6.typ       źródło sprawozdania (Typst)
  wyniki.json                 wskaźniki z symulacji, które wczytuje sprawozdanie
  img/                        wykresy i zrzut modelu
src/
  quad_control.slx            model Simulink (przy otwarciu sam wczytuje parametry.m)
  parametry.m                 parametry modelu i wartości zadane (workspace)
  build_control.m             skrypt, który od zera buduje quad_control.slx
  run_lab6.m                  symulacje zadań 1 i 2, wykresy i wyniki.json
  bodyDrag.m, xy_na_katy.m    kod bloków MATLAB Function
```

## Jak używać modelu

Model jest sparametryzowany: w blokach są nazwy zmiennych, a wartości ustawia plik `src/parametry.m` w workspace MATLAB-a (wczytuje się sam przy otwarciu modelu). Zmienne zmieniasz w Command Window, np. `z_cel = 12`, i klikasz Run; `parametry` przywraca wartości domyślne. Najważniejsza jest `tryb`:

- `tryb = 1` - skoki: ustaw `z_cel`, `phi_cel`, `theta_cel` [rad], `r_cel` [rad/s] (skok w chwili `t_skok`),
- `tryb = 2` - suwaki jak na wykładzie (suwak z, suwak phi, suwak theta, suwak r),
- `tryb = 3` - punkt docelowy: `x_cel`, `y_cel`, `z_cel` [m] i `psi_cel` [rad].

Wiatr: `Wind` (stały, [m/s]), podmuch `Gust` w chwili `t_gust` przez 2 s. Przebiegi są w Scope z, phi, theta, r, psi i XY.

Wszystko naraz: w folderze `src` wpisz `run_lab6`.

## Wymagania

- MATLAB + Simulink + Aerospace Blockset (robione na R2026a)
