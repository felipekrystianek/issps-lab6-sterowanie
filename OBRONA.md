# Obrona LAB6 - sterowanie czterowirnikowym BSP

Ściąga: jak pokazać model `src/quad_control.slx` na zajęciach i co odpowiedzieć na typowe pytania.

## 1. Pokaz modelu krok po kroku

1. W MATLAB-ie przejdź do `LAB6_Sterowanie/src` i otwórz `quad_control.slx`. Model sam uruchamia `parametry.m`, więc w oknie **Workspace** są wszystkie parametry.
2. Wartości zmieniasz w Command Window (np. `z_cel = 12`) albo dwuklikiem w oknie Workspace, potem klikasz **Run**. Wpisanie `parametry` przywraca wartości domyślne.
3. Czas symulacji ustawiasz w polu **Stop Time**.
4. Przebiegi pokazują Scope'y: z, phi, theta, r, psi, XY (zawsze wartość zadana i rzeczywista). Pozostałe sygnały (oznaczone anteną) są w **Data Inspector**: `Xe`, `Ve`, `eul`, `wb`, `Omega`.
5. Model jest sparametryzowany: w blokach są nazwy zmiennych (np. dwuklik na 6DOF: *Initial mass* = `m`, *Inertia* = `I`; na DJIF450Rotors: `d`, `H`, `CT`, `CQ`, `R`), a liczby są w workspace.

### Jak czytać schemat (od lewej)

1. **Wartości zadane**: skoki (Step), suwaki (Slider Gain) albo regulator położenia. Wybór zmienną `tryb` w blokach Multiport Switch (z_ref, phi_ref, theta_ref, r_ref).
2. **Uchyby i PID-y**: PID1 wysokości (+ limit dT + m·g), PID2 roll i PID3 pitch (+ bloki -1), PID4 prędkości yaw.
3. **Mikser**: Mux U → A⁻¹ → pierwiastek ze znakiem → Saturation (0-1000 rad/s) → kierunki obrotu [1 -1 1 -1].
4. **Model BSP z LAB5**: DJIF450Rotors (Quadcopter +) i 6DOF (Quaternion), ciężar, bodyDrag, wiatr z podmuchem.
5. **Pomiary**: Demux XYZ (x, y, wysokość h = -Z_e), Demux katy (φ, θ, ψ), Demux w_b (prędkość yaw r).
6. **Na dole**: regulator położenia (rampa x/y → PID X/Y → XY na katy) i regulator kąta yaw (e_psi → K psi → limit r).

### Scenariusze

| Test | Ustaw | Stop Time | Scope |
|---|---|---|---|
| skok wysokości 10 → 15 m | nic (domyślne: `tryb = 1`, `z_cel = 15`) | 20 | z |
| skok roll π/8 | `z_cel = 10`, `phi_cel = pi/8` | 20 | phi |
| skok pitch π/8 | `z_cel = 10`, `theta_cel = pi/8` | 20 | theta |
| skok prędkości yaw π/12 rad/s | `z_cel = 10`, `r_cel = pi/12` | 20 | r, psi |
| lot do punktu (5, 5, 15), ψ = 45° | `tryb = 3`, `x_cel = 5`, `y_cel = 5`, `z_cel = 15`, `psi_cel = pi/4` | 50 | XY, z, psi |
| to samo z wiatrem | jak wyżej + `Wind = [5 0 0]`, `Gust = [3 0 0]`, `t_gust = 30` | 50 | XY |
| suwaki jak na wykładzie | `tryb = 2`, Stop Time `inf`, w trakcie lotu przesuwaj bloki „suwak z / phi / theta / r” | inf | wszystkie |

Po każdym teście wpisz `parametry`, żeby wrócić do ustawień domyślnych. Wszystkie symulacje do sprawozdania naraz: w `src` wpisz `run_lab6`.

## 2. Najważniejsze wyniki

### Zadanie 1 (warunki idealne, skok w chwili 1 s)

| Kanał | Przeregulowanie | t_ust (5 %) | t_ust (2 %) | Uwagi |
|---|---|---|---|---|
| wysokość 10 → 15 m | 0 % | 4,9 s | 6,4 s | wznoszenie ogranicza limit dT |
| roll π/8 | 3,3 % | 2,4 s | > 19 s | bardzo wolny powrót z przeregulowania (mały człon I) |
| pitch π/8 | 5,0 % | 0,5 s | 5,9 s | najszybszy kanał |
| prędkość yaw π/12 | 10,3 % | 3,8 s | 5,3 s | słabe tłumienie (K_d = 0,0014) |

Przy przechyleniu wysokość spada najwyżej do 9,94 m. Uchyb ustalony jest wszędzie bliski zera.

### Zadanie 2 (lot do punktu (5, 5, 15) m, ψ = 45°)

| Warunki | x | y | z | ψ |
|---|---|---|---|---|
| bez wiatru: przeregulowanie / t_ust (2 %) | 4,4 % / 13,6 s | 7,0 % / 15,2 s | 0 % / 6,4 s | 0,2 % / 3,6 s |
| wiatr 5 m/s: przeregulowanie / t_ust (2 %) | 8,1 % / 17,2 s | 5,2 % / 14,9 s | 0 % / 6,4 s | 0,2 % / 3,6 s |

Podmuch 3 m/s odsuwa BSP od celu najwyżej o 0,34 m. Na końcu (50 s) odległość od celu wynosi 0,04 m.

### Nastawy

| Regulator | P | I | D | N | Skąd |
|---|---|---|---|---|---|
| PID1 wysokość | 20 | 0,001 | 30 | 10 | wykład, slajd 26 |
| PID2 roll | 0,00042 | 2,87·10⁻⁶ | 0,011 | 10 | wykład, slajd 38 |
| PID3 pitch | 0,0038 | 9,97·10⁻⁵ | 0,026 | 10 | wykład, slajd 39 |
| PID4 prędkość yaw | 0,020 | 0,0093 | 0,0014 | 10 | wykład, slajd 40 |
| PID X, PID Y | 0,06 | 0,01 | 0,3 | 10 | zad. 2 |
| K_psi (kąt yaw) | 1 | - | - | - | zad. 2 |

## 3. Pytania i odpowiedzi

### Model i parametry

**Z czego zbudowany jest model?**
Z modelu BSP z LAB5 (Multirotor DJIF450Rotors w układzie „+”, 6DOF Quaternion, ciężar, opór bodyDrag, wiatr), w którym stałe RotorSpeed zastąpiono układem sterowania z wykładu 6 (slajd 32).

**Co znaczy, że model jest sparametryzowany?**
W parametrach bloków zamiast liczb są nazwy zmiennych, a wartości przypisuje plik `parametry.m` w workspace. Zmianę parametru robi się w jednym miejscu, bez wchodzenia w bloki.

**Jaki układ współrzędnych?**
NED: x do przodu, y w prawo, z w dół. Dlatego wysokość to h = -Z_e (blok [1;1;-1]), a start z 10 m to `InitialPosition = [0 0 -10]`.

**Dlaczego wirniki mają znaki [1 -1 1 -1]?**
Sąsiednie wirniki kręcą się w przeciwne strony, więc ich momenty reakcyjne się znoszą. Różnicując obroty par wirników, steruje się obrotem yaw.

### Układ sterowania

**Jak działa regulator wysokości?**
Uchyb e_z = z_ref - z trafia do PID1, który daje dodatkowy ciąg ΔT. Całkowity ciąg to ΣT = m·g + ΔT, więc w zawisie (e = 0) wirniki dają dokładnie ciężar.

**Co robi macierz A⁻¹ (mikser)?**
Macierz A wiąże kwadraty prędkości wirników z ciągiem i momentami roll, pitch, yaw dla układu „+” (slajd 13). Odwrotność rozdziela żądany ciąg i momenty na cztery wirniki: Ω² = A⁻¹·[ΣT, τφ, τθ, τψ]. Potem pierwiastek ze znakiem i nasycenie.

**Po co bloki -1 przy roll i pitch?**
Macierz A z wykładu zakłada oś z w górę, a model ma oś z w dół (NED), więc momenty roll i pitch mają przeciwny znak. Bez -1 sprzężenie byłoby dodatnie i pętle byłyby niestabilne. Sprawdziliśmy to w LAB5: wirnik przedni szybszy o 5 % dał dodatni moment pitch, a macierz A przewiduje ujemny.

**Dlaczego PID4 reguluje prędkość yaw, a nie kąt?**
Tak jest na wykładzie: na slajdzie 32 sprzężenie idzie z ω_b, a wykres na slajdzie 40 jest podpisany „psi′”. Tak działa też drążek yaw w aparaturze RC. Z tymi nastawami pętla kąta byłaby niestabilna: dla obiektu I_zz·s² z PID warunek Routha to K_d·K_p > I_zz·K_i, a tu 0,0014·0,02 = 2,8·10⁻⁵ < 0,008·0,0093 = 7,4·10⁻⁵.

**Po co ograniczenie ΔT (limit dT)?**
Przy skoku wysokości o 5 m PID1 (P = 20) żądał ok. 100 N ciągu. Wszystkie wirniki wchodziły w nasycenie i znikała różnica obrotów potrzebna do sterowania kątami, więc BSP tracił stabilność podczas wznoszenia. Ograniczenie do ±0,5·m·g jest też na slajdzie 25.

**Do czego są suwaki?**
Do ręcznego sterowania jak na wykładzie (slajd 28): suwak z zadaje prędkość zmiany wysokości (przez integrator), a suwaki kątów zadają kąt w zakresie ±π/8 (roll, pitch) i prędkość yaw ±π/12 rad/s. Do sprawozdania użyliśmy skoków, bo dają powtarzalne testy.

**Dlaczego przy skoku roll wysokość trochę spada?**
Przechylony BSP ma mniejszą pionową składową ciągu (ΣT·cos φ). Regulator wysokości to wyrównuje, spadek to tylko ok. 6 cm.

**Dlaczego przy skoku roll BSP odlatuje w bok?**
Stały przechył daje stałą poziomą składową ciągu. W zadaniu 1 nie ma pętli położenia, więc nic tego nie hamuje. To jest właśnie sposób, w jaki wielowirnikowiec porusza się w poziomie.

### Zadanie 2

**Jak działa sterowanie położeniem?**
Kaskadowo: uchyby x i y idą do PID X i PID Y, funkcja „XY na katy” obraca ich wyjścia o kąt ψ do układu BSP i zamienia na zadane kąty. Lot do przodu to θ < 0 (nos w dół), w prawo to φ > 0. Kąty są ograniczone do ±π/8, a wewnętrzne pętle roll i pitch je realizują.

**Po co obrót o kąt ψ?**
Regulatory X i Y liczą w układzie ziemskim, a pochylenie działa w układzie BSP. Gdy BSP jest obrócony o 45°, lot na północ wymaga jednocześnie pitch i roll.

**Jak regulowany jest kąt yaw w zadaniu 2?**
Regulator P (K_psi = 1) zamienia uchyb kąta ψ na zadaną prędkość yaw, ograniczoną do ±π/12 rad/s. Dalej działa PID4 prędkości yaw.

**Po co rampa wartości zadanej x, y?**
Przy skoku o 5 m człon I narastał przez cały przelot i dawał przeregulowanie 1-2 m. Z rampą 0,5 m/s uchyb jest cały czas mały, a przeregulowanie spadło do 4-7 %.

**Dlaczego nastawy PID X i PID Y są takie małe?**
Pętla położenia musi być wyraźnie wolniejsza od pętli roll, która ustala się po ok. 2,5 s. Przy większych nastawach regulator położenia zadawałby kąty szybciej, niż pętla roll je realizuje, i pojawiłyby się oscylacje. Człon I (0,01) usuwa uchyb przy wietrze, człon D (0,3) tłumi oscylacje.

**Dlaczego oś y jest wolniejsza od x?**
Y realizuje pętla roll, która z nastawami z wykładu jest wolniejsza od pitch (P = 0,00042 wobec 0,0038, a I_xx > I_yy).

**Jak zamodelowany jest wiatr?**
Stały wiatr `Wind` plus podmuch `Gust` włączany w chwili `t_gust` na 2 s (dwa bloki Step). Prędkość wiatru jest przeliczana do układu BSP (DCM_be) i bodyDrag liczy opór od prędkości względnej.

**Dlaczego przy wietrze nie ma uchybu ustalonego?**
Stały wiatr wymaga stałego pochylenia pod wiatr, czyli stałego sygnału z regulatora przy zerowym uchybie. Daje go człon I. Bez niego zostawał uchyb ok. 0,8 m.

**Jak liczyliście wskaźniki?**
Przeregulowanie to największe przekroczenie wartości zadanej w procentach skoku. Czas ustalania to ostatnia chwila wyjścia poza pasmo ±2 % (lub ±5 %) skoku, liczona od chwili skoku. Uchyb ustalony to różnica na końcu symulacji.

**Dlaczego roll ma czas ustalania „> 19 s”?**
Przeregulowanie 3,3 % jest większe niż pasmo 2 %, a człon I jest bardzo mały (2,87·10⁻⁶), więc kąt wraca do wartości zadanej bardzo powoli. W pasmo 5 % wchodzi po 2,4 s.

### Wnioski

**Czy układ działa poprawnie?**
Tak: wysokość, roll, pitch i prędkość yaw osiągają wartość zadaną bez uchybu ustalonego, a BSP dolatuje do zadanego punktu także przy wietrze 5 m/s i wraca na miejsce po podmuchu.

**Co można poprawić?**
Szybsze nastawy roll (teraz najwolniejsza pętla, ogranicza całą kaskadę) i lepsze tłumienie prędkości yaw. Wtedy można by też przyspieszyć pętlę położenia.
