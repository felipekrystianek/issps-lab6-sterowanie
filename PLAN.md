# Plan: ISSPS LAB6 (sterowanie BSP) + projekt (sekcja P2)

Ustalone 18.11.2026. Kolejność: LAB6 (termin sekcja lab. 2: 30.11) → projekt (Moodle: 25.11 albo 03.12, do sprawdzenia).

## Wspólne
- Baza: `../LAB5_Quadrocopter/src/quad_model.slx` (Multirotor DJIF450Rotors „+” + 6DOF Quaternion + grawitacja + bodyDrag + Wind). LAB5 zostaje bez zmian i służy jako REF dynamiki.
- Parametry jako zmienne w workspace MATLAB-a, wartości w plikach .m (LAB6: `parametry.m`, projekt: `parametry_REF.m`, `parametry_P2.m`); model wczytuje je sam przy otwarciu (uwaga profesora 19.11).
- Struktura sterowania jak na slajdzie 32: PID z (+ m·g), PID roll, pitch i yaw → Mux → A^-1 (slajd 36) → ±sqrt(|u|) → Saturation → Gain [1 -1 1 -1] → Ω.
- Wartości zadane: przełącznik między suwakami (jak na wykładzie: z przez Slider Gain → 1/s, kąty pi/8, pi/8, pi/12 × Slider) a skokami (Step) do sprawozdania.
- Nastawy PID (wykład 6, slajdy 26 i 38–40), N = 10:

  | Pętla | P | I | D |
  |---|---|---|---|
  | z | 20 | 0.001 | 30 |
  | roll | 0.00042 | 2.87e-6 | 0.011 |
  | pitch | 0.0038 | 9.97e-5 | 0.026 |
  | yaw | 0.020 | 0.0093 | 0.0014 |

- Pętle położenia X i Y (LAB6 zad. 2) dają zadany pitch i roll (z obrotem o yaw).

## LAB6_Sterowanie/: `src/quad_control.slx`, parametry REF
- Zad. 1: skoki z 10 → 15 m, roll pi/8, pitch pi/8, yaw pi/12 (warunki idealne).
- Zad. 2: start (0, 0, 10) → cel (5, 5, 15) m, yaw pi/4. Raz bez wiatru, raz z wiatrem stałym 5 m/s i podmuchem +3 m/s przez 2 s.
- Wykresy: wartość zadana i rzeczywista, opisy osi, jednostki, legenda. Wskaźniki: uchyb ustalony, czas ustalania, przeregulowanie.
- Sprawozdanie w Typst (szablon jak LAB5), PDF: `ISSPS_LAB6_sekcja2_Filipek_Michalik_Kozlowski_Augustowski.pdf`.

## Projekt_BSP/: `src/quad_P2.slx` (jeden model z przełącznikiem: stałe RotorSpeed albo PID)
- P2: m = 1.65 kg, J = diag(0.0114, 0.0073, 0.0083), CDxS = [0.0390 0.0455 0.0900].
- Zad. 1: podzadania 1–7 jak w LAB5 (masy 1.65 i 2.15 kg).
- Zad. 2: scenariusze jak w LAB6, zawsze z nastawami z LAB6 (bez dostrajania).
- Porównanie z REF (LAB5 i LAB6) na wspólnych wykresach, wnioski.

## GitHub
Publiczne repo `issps-lab6-sterowanie` i `issps-projekt-bsp`, push po każdym skończonym etapie. Backup LAB5: `issps-lab5-quadrocopter` (folder `LAB5_Quadrocopter_github`).
