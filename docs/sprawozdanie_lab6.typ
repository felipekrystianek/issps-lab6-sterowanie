// Sprawozdanie: ISSPS ćw. 6 - podstawy sterowania czterowirnikowego BSP (MATLAB/Simulink, Aerospace Blockset)
// Kompilacja: typst compile sprawozdanie_lab6.typ ISSPS_LAB6_sekcja2_Filipek_Michalik_Kozlowski_Augustowski.pdf
// Wszystkie liczby czytane z wyniki.json (generuje src/run_lab6.m)

#let r = json("wyniki.json")

// liczba z przecinkiem dziesiętnym, d miejsc po przecinku
#let f(x, d) = {
  let s = str(calc.abs(calc.round(x, digits: d)))
  if d > 0 {
    if not s.contains(".") { s += "." }
    let frac = s.split(".").at(1).len()
    s += "0" * (d - frac)
  }
  (if x < 0 and calc.round(x, digits: d) != 0 { "-" } else { "" }) + s.replace(".", ",")
}
#let blad(a, b) = (a - b) / b * 100   // błąd względny [%], b - wartość analityczna
#let bl(a, b) = { let e = calc.abs(blad(a, b)); if e < 0.001 { "< 0,001" } else { f(e, 3) } }

// ---------- Styl (wg SZABLON_SPRAWOZDANIA.doc) ----------
#set document(title: "Sprawozdanie - ćwiczenie 6", author: ("Krystian Filipek", "Paweł Michalik", "Wiktor Kozłowski", "Artur Augustowski"))
#set page(
  paper: "a4",
  margin: (x: 2.5cm, top: 2.5cm, bottom: 2.5cm),
  footer: context align(right, text(font: "Times New Roman", size: 12pt)[#counter(page).display()]),
)
#set text(font: "Times New Roman", size: 12pt, lang: "pl")
#set par(justify: true, leading: 0.65em, spacing: 1.1em)
#show heading: set text(weight: "bold")
#show heading.where(level: 1): it => context if target() == "html" { it } else { block(sticky: true, above: 1.4em, below: 0.8em, text(size: 13pt, it.body)) }
#show heading.where(level: 2): it => context if target() == "html" { it } else { block(sticky: true, above: 1.4em, below: 0.8em, underline(text(size: 12pt, it.body))) }
#show heading.where(level: 3): it => context if target() == "html" { it } else { block(sticky: true, above: 1.2em, below: 0.6em, text(size: 12pt, it.body)) }
#set list(indent: 1.2em, body-indent: 0.5em)
#set enum(indent: 1.2em)
#show figure.caption: set text(size: 10pt)
#show figure.where(kind: table): set figure.caption(position: top)
#show figure: set block(spacing: 1.4em)
#set table(stroke: 0.6pt, inset: (x: 5pt, y: 4pt), align: center + horizon)
#show table.cell.where(y: 0): set text(weight: "bold")
#show table: set par(justify: false)
#show table: set text(size: 11pt)

// ---------- Strona tytułowa ----------
#let tytul-html() = html.elem("div", attrs: ("data-custom-style": "Tytul"))[
  #par[Politechnika Śląska, Wydział Mechaniczny Technologiczny, Katedra Podstaw Konstrukcji Maszyn]
  #par[*Inżynieria systemów statków powietrznych - systemy sterowania*]
  #par[Rok akademicki 2026/27]
  #par[SPRAWOZDANIE]
  #par[Ćwiczenie 6]
  #par[Temat]
  #par[Podstawy sterowania wielowirnikowych bezzałogowych statków powietrznych]
  #par[SEKCJA LAB 2: Krystian Filipek, Paweł Michalik, Wiktor Kozłowski, Artur Augustowski]
  #par[Data wykonania ćwiczenia: 30.11.2026]
  #par[Prowadzący: dr hab. inż. Piotr Przystałka, prof. PŚ]
]
#context if target() == "html" { tytul-html() } else {
page(margin: (left: 2cm, right: 2cm, top: 2.5cm, bottom: 2cm),
  footer: align(right, text(font: "Times New Roman", size: 12pt)[- 1 -]))[
  #set par(justify: false, leading: 0.4em, spacing: 0.5em)
  #set text(font: "Arial")
  #grid(columns: (5cm, 1.6cm, 1fr), rows: 100%,
    // lewa kolumna
    {
      set align(right)
      text(size: 15pt, weight: "bold")[Katedra \ Podstaw \ Konstrukcji \ Maszyn]
      v(1.2em)
      text(size: 15pt, weight: "bold")[Wydział \ Mechaniczny \ Technologiczny]
      v(1.2em)
      text(size: 15pt, weight: "bold")[Politechnika \ Śląska]
      v(0.8em)
      image("img/logo_polsl.png", width: 2.6cm)
      v(1fr)
      text(size: 8.5pt)[ul. Konarskiego 18a \ 44-100 Gliwice]
      v(0.8em)
      text(size: 8.5pt)[tel. 237 1467 \ fax 237 1360]
      v(0.8em)
      text(size: 8.5pt)[http://kpkm.polsl.pl]
    },
    align(center, line(angle: 90deg, length: 100%, stroke: 0.6pt + luma(120))),
    // prawa kolumna
    {
      v(4.6cm)
      text(size: 24pt, weight: "bold")[Inżynieria systemów statków powietrznych - systemy sterowania]
      v(2em)
      text(size: 11pt)[Rok akademicki 2026/27]
      v(3.2cm)
      text(size: 11pt)[SPRAWOZDANIE]
      v(1.2em)
      text(size: 11pt)[Ćwiczenie 6]
      v(1em)
      text(size: 9pt)[Temat]
      v(0.3em)
      text(size: 11pt)[Podstawy sterowania wielowirnikowych bezzałogowych statków powietrznych]
      v(2.4em)
      text(size: 11pt)[SEKCJA LAB 2: Krystian Filipek, Paweł Michalik, Wiktor Kozłowski, Artur Augustowski]
      v(2em)
      text(size: 11pt)[Data wykonania ćwiczenia: 30.11.2026]
      v(0.8em)
      text(size: 11pt)[Prowadzący: dr hab. inż. Piotr Przystałka, prof. PŚ]
    },
  )
]
}

// czas ustalania: 19 s oznacza, że przebieg nie wszedł do pasma do końca symulacji (20 s, skok w 1 s)
#let ts(x) = if x >= 18.99 { "> 19" } else { f(x, 2) }
#let wiersz(n, w, jedn) = ([#n], [#f(w.przeregulowanie, 1)], [#ts(w.t_ust5)], [#ts(w.t_ust)], [#f(w.uchyb, 3) #jedn])

// ---------- Treść ----------
= Cel ćwiczenia

Celem ćwiczenia jest nabycie podstawowych umiejętności w zakresie modelowania systemu sterowania wielowirnikowego bezzałogowego statku powietrznego w środowisku MATLAB/Simulink. Obejmuje to definiowanie pętli regulacji dla poszczególnych osi BSP, strojenie parametrów regulatorów oraz badanie odpowiedzi obiektu regulacji.

== Zadanie nr 1

Do sterowania wykorzystano model BSP z ćwiczenia 5 (bloki Multirotor DJIF450Rotors w konfiguracji _Quadcopter +_ i 6DOF (Quaternion), ciężar, opór bodyDrag i wiatr). Stałą prędkość wirników RotorSpeed zastąpiono układem sterowania jak na wykładzie (rys. 1). Model jest sparametryzowany: w parametrach bloków zamiast liczb wpisano nazwy zmiennych (np. `m`, `I`, `CDxS`, `rho`), a ich wartości (tab. 1) przypisuje plik `parametry.m` w workspace MATLAB-a. Model wczytuje ten plik automatycznie przy otwarciu.

Układ sterowania ma cztery regulatory PID: wysokości (PID1), kąta roll (PID2), kąta pitch (PID3) i prędkości obrotu yaw (PID4). Uchyb wysokości $e_z = z_"ref" - z$ daje dodatkowy ciąg $Delta T$, ograniczony do $plus.minus 0","5 m g$, który dodaje się do ciężaru: $Sigma T = m g + Delta T$. Regulatory kątów dają momenty $tau_phi$, $tau_theta$, $tau_psi$. Mikser wylicza z nich kwadraty prędkości wirników $bold(Omega)^2 = bold(A)^(-1) [Sigma T, tau_phi, tau_theta, tau_psi]^T$ (macierz $bold(A)^(-1)$ jak na wykładzie). Po pierwiastku ze znakiem i ograniczeniu do 0-1000 rad/s nadawane są kierunki obrotu $[1, -1, 1, -1]$.

Wprowadzono trzy uzupełnienia, bez których układ nie działał poprawnie:
- *Znak momentów roll i pitch (bloki -1).* Model 6DOF ma oś $z$ skierowaną w dół (NED), a macierz $bold(A)$ z wykładu zakłada oś $z$ w górę. Bez zmiany znaku sprzężenie zwrotne w pętlach roll i pitch byłoby dodatnie, czyli niestabilne.
- *Prędkość yaw zamiast kąta.* Tak jak na wykładzie, PID4 reguluje prędkość obrotu $r = omega_(b,z)$, czyli zachowuje się jak drążek yaw w aparaturze. Z nastawami z wykładu pętla kąta $psi$ byłaby niestabilna ($I_(z z) K_i > K_d K_p$).
- *Ograniczenie $Delta T$* (blok limit dT, jak na slajdzie 25). Przy skoku wysokości o 5 m PID1 żądał ok. 100 N dodatkowego ciągu, więc wszystkie wirniki wchodziły w nasycenie i regulatory kątów traciły możliwość sterowania.

Wartości zadane wybiera zmienna `tryb`: 1 - skoki (Step), 2 - suwaki (Slider Gain) jak na wykładzie, 3 - punkt docelowy z zadania 2.

#figure(image("img/model.png", width: 100%), caption: [Model BSP z układem sterowania w MATLAB/Simulink (`quad_control.slx`)])

#figure(
  table(columns: (auto, auto, auto, 1fr),
    table.header([Parametr], [Wartość], [Jednostka], [Opis]),
    [AirDensity], [1,225], [kg/m³], [gęstość powietrza],
    [Arm length], [0,225], [m], [długość ramienia do wirnika],
    [Height], [-0,035], [m], [wysokość środka masy względem układu],
    [$C_T$], [0,0142], [-], [współczynnik siły ciągu śmigła],
    [$C_Q$], [0,00206], [-], [współczynnik momentu aerodynamicznego śmigła],
    [Radius], [0,127], [m], [promień wirnika],
    [$m$], [1,5], [kg], [masa BSP],
    [$J$], [$I_(x x)$ = 0,0111, $I_(y y)$ = 0,0070, $I_(z z)$ = 0,0080], [kg·m²], [momenty bezwładności],
    [CDxS], [0,0390; 0,0455; 0,0900], [m²], [opór aerodynamiczny w osiach $x$, $y$, $z$],
  ),
  caption: [Parametry modelu BSP i otoczenia],
)

#figure(
  table(columns: 6,
    table.header([Regulator], [Wielkość], [P], [I], [D], [N]),
    [PID1], [wysokość $z$], [20], [0,001], [30], [10],
    [PID2], [kąt roll $phi$], [0,00042], [2,87·10⁻⁶], [0,011], [10],
    [PID3], [kąt pitch $theta$], [0,0038], [9,97·10⁻⁵], [0,026], [10],
    [PID4], [prędkość yaw $r$], [0,020], [0,0093], [0,0014], [10],
  ),
  caption: [Nastawy regulatorów PID (z wykładu)],
)

Działanie układu sprawdzono w warunkach idealnych (bez wiatru), osobno dla każdego kanału: skok wysokości z 10 do 15 m, skok kąta roll i pitch o $pi \/ 8$ = 22,5° oraz skok prędkości yaw o $pi \/ 12$ rad/s. Skok następuje w chwili 1 s, a w pozostałych kanałach wartości zadane są zerowe, a wysokość wynosi 10 m.

#figure(image("img/z1_wysokosc.png", width: 75%), caption: [Odpowiedź na skok wysokości])

#figure(image("img/z1_roll.png", width: 75%), caption: [Odpowiedź na skok kąta roll])

#figure(image("img/z1_pitch.png", width: 75%), caption: [Odpowiedź na skok kąta pitch])

#figure(image("img/z1_yaw.png", width: 75%), caption: [Odpowiedź na skok prędkości yaw i kąt $psi$])

#figure(
  table(columns: 5,
    table.header([Kanał], [Przeregulowanie [%]], [$t_"ust"$ (5 %) [s]], [$t_"ust"$ (2 %) [s]], [Uchyb ustalony]),
    ..wiersz([wysokość $z$], r.z, "m"),
    ..wiersz([roll $phi$], r.phi, "rad"),
    ..wiersz([pitch $theta$], r.theta, "rad"),
    ..wiersz([prędkość yaw $r$], r.r, "rad/s"),
  ),
  caption: [Wskaźniki jakości regulacji - zadanie 1 (czas ustalania liczony od chwili skoku)],
)

Wszystkie kanały osiągają wartość zadaną z pomijalnym uchybem. Wysokość dochodzi do 15 m bez przeregulowania, a wznoszenie ogranicza blok limit dT. Kąt pitch ustala się najszybciej. Kąt roll ma przeregulowanie ok. #f(r.phi.przeregulowanie, 1) % i bardzo wolno do niego wraca (mały człon I), więc nie wchodzi w pasmo 2 % do końca symulacji. Prędkość yaw ma największe przeregulowanie (#f(r.r.przeregulowanie, 1) %), bo regulator ma małe tłumienie ($K_d$ = 0,0014). Przechylenie BSP zmniejsza pionową składową ciągu, ale regulator wysokości to kompensuje: wysokość spada najwyżej do #f(r.theta.h_min, 2) m.

== Zadanie nr 2

Do układu z zadania 1 dodano zewnętrzne pętle położenia (dolna część rys. 1). Uchyby położenia $x$ i $y$ trafiają do regulatorów PID X i PID Y, a funkcja `xy_na_katy` obraca ich wyjścia o kąt $psi$ do układu BSP i zamienia na zadane kąty: $theta_"ref" = -u_x^b$ (lot do przodu to pochylenie nosa w dół) oraz $phi_"ref" = u_y^b$. Oba kąty są ograniczone do $plus.minus pi \/ 8$. Kąt yaw reguluje człon P ($K_psi$ = 1), który zadaje prędkość $r_"ref"$ ograniczoną do $plus.minus pi \/ 12$ rad/s. Wysokość zadaje się bezpośrednio w pętli PID1. Położenie zadane $x$, $y$ zmienia się rampą 0,5 m/s, a nie skokiem, bo przy skoku człon I regulatorów położenia narastał podczas przelotu i dawał przeregulowanie ok. 1-2 m.

Pętla położenia musi być wolniejsza od pętli roll, która z nastawami z wykładu ustala się dopiero po ok. 2-3 s, dlatego nastawy PID X i PID Y są małe. Człon I usuwa uchyb ustalony przy wietrze, a człon D tłumi oscylacje.

#figure(
  table(columns: 5,
    table.header([Regulator], [P], [I], [D], [N]),
    [PID X, PID Y], [0,06], [0,01], [0,3], [10],
    [$K_psi$], [1], [-], [-], [-],
  ),
  caption: [Nastawy regulatorów położenia i kąta yaw],
)

Badano lot z punktu (0, 0, 10) m do punktu (5, 5, 15) m z jednoczesnym obrotem do $psi$ = 45°, w warunkach idealnych oraz przy umiarkowanym wietrze: stały wiatr 5 m/s wzdłuż osi $x$ i podmuch +3 m/s w chwili 30-32 s.

#figure(image("img/z2_bez_wiatru.png", width: 90%), caption: [Lot do punktu docelowego - warunki idealne])

#figure(image("img/z2_wiatr.png", width: 90%), caption: [Lot do punktu docelowego - wiatr 5 m/s i podmuch 3 m/s])

#figure(
  table(columns: 6,
    table.header([Warunki], [Wielkość], [Przeregulowanie [%]], [$t_"ust"$ (5 %) [s]], [$t_"ust"$ (2 %) [s]], [Uchyb ustalony]),
    table.cell(rowspan: 4)[bez wiatru], ..wiersz([$x$], r.bez_wiatru.x, "m"), ..wiersz([$y$], r.bez_wiatru.y, "m"),
    ..wiersz([$z$], r.bez_wiatru.z, "m"), ..wiersz([$psi$], r.bez_wiatru.psi, "rad"),
    table.cell(rowspan: 4)[wiatr 5 m/s], ..wiersz([$x$], r.wiatr.x, "m"), ..wiersz([$y$], r.wiatr.y, "m"),
    ..wiersz([$z$], r.wiatr.z, "m"), ..wiersz([$psi$], r.wiatr.psi, "rad"),
  ),
  caption: [Wskaźniki jakości regulacji - zadanie 2 (przy wietrze $x$ i $y$ liczone do chwili podmuchu, 30 s)],
)

W warunkach idealnych BSP dolatuje do punktu docelowego z przeregulowaniem do #f(r.bez_wiatru.y.przeregulowanie, 0) % i ustala położenie po ok. #f(r.bez_wiatru.y.t_ust, 0) s. Oś $y$ jest wolniejsza od $x$, bo steruje nią wolniejsza pętla roll. Wysokość i kąt yaw ustalają się dużo szybciej i prawie nie zależą od ruchu w poziomie. Przy stałym wietrze 5 m/s BSP musi stale pochylać się pod wiatr. Człon I regulatorów położenia znosi uchyb ustalony, a przeregulowanie w osi wiatru rośnie do #f(r.wiatr.x.przeregulowanie, 0) %. Podmuch 3 m/s odsuwa BSP od celu najwyżej o #f(r.wiatr.podmuch, 2) m, a po ok. 15 s wraca on na miejsce (na końcu symulacji odległość od celu wynosi #f(r.wiatr.uchyb_koniec, 2) m).

== Wnioski

+ Model z ćwiczenia 5 uzupełniony o cztery regulatory PID, mikser $bold(A)^(-1)$ i ograniczenia poprawnie steruje wysokością, kątami roll i pitch oraz prędkością obrotu yaw. Każda wielkość osiąga wartość zadaną z uchybem ustalonym bliskim zera.
+ Przy przenoszeniu wzorów z wykładu do modelu trzeba uważać na układ współrzędnych. W układzie NED momenty roll i pitch mają przeciwny znak niż w macierzy $bold(A)$ i bez poprawki pętle roll i pitch byłyby niestabilne.
+ Nastawy z wykładu dają odpowiedzi bez oscylacji, ale o różnej dynamice: pitch ustala się w ok. #f(r.theta.t_ust5, 1) s, roll w ok. #f(r.phi.t_ust5, 1) s (pasmo 5 %), a roll wolno wraca z przeregulowania. Pętla kąta yaw z tymi nastawami byłaby niestabilna, dlatego reguluje się prędkość yaw, a kąt dopiero w zewnętrznej pętli.
+ Duży uchyb wysokości bez ograniczenia $Delta T$ powoduje nasycenie wszystkich wirników i utratę sterowania kątami, więc ograniczenie ciągu jest niezbędne przy jednoczesnej zmianie wysokości i położenia.
+ Kaskadowy układ (położenie → kąty → momenty) pozwala zadać punkt w przestrzeni. Jego szybkość ogranicza najwolniejsza pętla wewnętrzna, tu roll. Rampa wartości zadanej zmniejsza przeregulowanie wynikające z członu I.
+ Przy wietrze 5 m/s układ utrzymuje punkt docelowy bez uchybu ustalonego dzięki członowi I. Podmuch 3 m/s odsuwa BSP o #f(r.wiatr.podmuch, 2) m. Lepsze tłumienie zakłóceń dałyby szybsze nastawy pętli roll i pitch.

== Wykorzystanie sztucznej inteligencji

Przy wykonywaniu ćwiczenia korzystano z narzędzia sztucznej inteligencji (Claude, Anthropic) do utworzenia wykresów.
