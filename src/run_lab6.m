% Symulacje do sprawozdania z LAB6: wykresy do ../docs/img i wskazniki do ../docs/wyniki.json
% Wymaga quad_control.slx (jesli go nie ma, buduje go build_control.m)
function run_lab6
here = fileparts(mfilename('fullpath')); cd(here);
img = fullfile(here, '..', 'docs', 'img'); if ~exist(img, 'dir'), mkdir(img); end
mdl = 'quad_control';
if ~exist([mdl '.slx'], 'file'), build_control; end
evalin('base', 'parametry');   % model czyta parametry z workspace
load_system(mdl);
R = struct();

%% Zrzut modelu
print(['-s' mdl], '-dpng', '-r200', fullfile(img, 'model.png'));

%% Zadanie 1 - skoki wysokosci, roll, pitch i predkosci yaw (warunki idealne)
t0 = 1;   % chwila skoku
o = symuluj(mdl, {'z_cel', 15}, 20);
[t, h] = sygnal(o, 'h'); [~, zr] = sygnal(o, 'z_ref');
R.z = wskazniki(t, h, 10, 15, t0);
f = fig(); plot(t, zr, '--', t, h); grid on; xlabel('t [s]'); ylabel('z [m]');
legend('z_{ref}', 'z', 'Location', 'southeast'); title('Skok wysokości 10 \rightarrow 15 m');
zapisz(f, img, 'z1_wysokosc');

kan = {'phi', 'phi_cel', 1, '\phi', 'roll'; 'theta', 'theta_cel', 2, '\theta', 'pitch'};
for i = 1:2
    o = symuluj(mdl, {'z_cel', 10, kan{i, 2}, pi/8}, 20);
    [t, e] = sygnal(o, 'eul'); [~, ref] = sygnal(o, [kan{i, 1} '_ref']); [~, h] = sygnal(o, 'h');
    R.(kan{i, 1}) = wskazniki(t, e(:, kan{i, 3}), 0, pi/8, t0);
    R.(kan{i, 1}).h_min = min(h);
    f = fig(); plot(t, rad2deg(ref), '--', t, rad2deg(e(:, kan{i, 3}))); grid on; xlabel('t [s]'); ylabel([kan{i, 4} ' [°]']);
    legend([kan{i, 4} '_{ref}'], kan{i, 4}, 'Location', 'southeast');
    title(sprintf('Skok kąta %s (%s) o \\pi/8 = 22,5°', kan{i, 5}, kan{i, 4}));
    zapisz(f, img, ['z1_' kan{i, 5}]);
end

o = symuluj(mdl, {'z_cel', 10, 'r_cel', pi/12}, 20);
[t, w] = sygnal(o, 'wb'); [~, rr] = sygnal(o, 'r_ref'); [~, e] = sygnal(o, 'eul');
R.r = wskazniki(t, w(:, 3), 0, pi/12, t0);
f = fig(); tiledlayout(2, 1, 'TileSpacing', 'compact');
nexttile; plot(t, rr, '--', t, w(:, 3)); grid on; ylabel('r [rad/s]');
legend('r_{ref}', 'r', 'Location', 'southeast'); title('Skok prędkości obrotu yaw o \pi/12 rad/s');
nexttile; plot(t, rad2deg(unwrap(e(:, 3)))); grid on; ylabel('\psi [°]'); xlabel('t [s]');
zapisz(f, img, 'z1_yaw');

%% Zadanie 2 - punkt docelowy (5, 5, 15) m i yaw pi/4, bez wiatru i z wiatrem
cel = {'tryb', 3, 'x_cel', 5, 'y_cel', 5, 'z_cel', 15, 'psi_cel', pi/4};
war = {'bez_wiatru', {}, 'bez wiatru'; ...
       'wiatr', {'Wind', [5 0 0], 'Gust', [3 0 0], 't_gust', 30}, 'wiatr 5 m/s + podmuch 3 m/s (30-32 s)'};
for k = 1:2
    o = symuluj(mdl, [cel war{k, 2}], 50);
    [t, X] = sygnal(o, 'Xe'); [~, xr] = sygnal(o, 'x_ref'); [~, yr] = sygnal(o, 'y_ref');
    [~, zr] = sygnal(o, 'z_ref'); [~, pr] = sygnal(o, 'psi_ref'); [~, e] = sygnal(o, 'eul');
    h = -X(:, 3);
    W = struct('x', wskazniki(t, X(:, 1), 0, 5, t0), 'y', wskazniki(t, X(:, 2), 0, 5, t0), ...
        'z', wskazniki(t, h, 10, 15, t0), 'psi', wskazniki(t, e(:, 3), 0, pi/4, t0));
    if k == 2
        p = t < 30;   % wskazniki przed podmuchem
        for c = {'x', 'y'}, W.(c{1}) = wskazniki(t(p), X(p, double(c{1}) - 119), 0, 5, t0); end
        g = t >= 30;
        W.podmuch = max(hypot(X(g, 1) - 5, X(g, 2) - 5));   % najwieksze odejscie od celu po podmuchu
        W.uchyb_koniec = hypot(X(end, 1) - 5, X(end, 2) - 5); % odleglosc od celu na koncu (50 s)
    end
    R.(war{k, 1}) = W;
    f = fig(); tiledlayout(3, 1, 'TileSpacing', 'compact');
    nexttile; plot(t, xr, '--', t, X(:, 1), t, yr, ':', t, X(:, 2)); grid on; ylabel('x, y [m]');
    legend('x_{ref}', 'x', 'y_{ref}', 'y', 'Location', 'southeast');
    title(['Lot do punktu (5, 5, 15) m, \psi = 45°, ' war{k, 3}]);
    nexttile; plot(t, zr, '--', t, h); grid on; ylabel('z [m]'); legend('z_{ref}', 'z', 'Location', 'southeast');
    nexttile; plot(t, rad2deg(pr), '--', t, rad2deg(e(:, 3))); grid on; ylabel('\psi [°]'); xlabel('t [s]');
    legend('\psi_{ref}', '\psi', 'Location', 'southeast');
    if k == 2, for a = 1:3, nexttile(a); xline(30, ':k', 'HandleVisibility', 'off'); end, end
    set(f, 'Position', [0 0 900 760]);
    zapisz(f, img, ['z2_' war{k, 1}]);
end

%% Zapis
fid = fopen(fullfile(here, '..', 'docs', 'wyniki.json'), 'w');
fprintf(fid, '%s', jsonencode(R, 'PrettyPrint', true)); fclose(fid);
disp(jsonencode(R, 'PrettyPrint', true));

end

%% Funkcje pomocnicze
function o = symuluj(mdl, a, T)
% ustawia zmienne (na czas symulacji) i puszcza symulacje
in = Simulink.SimulationInput(mdl);
for j = 1:2:numel(a), in = in.setVariable(a{j}, a{j + 1}); end
o = sim(in.setModelParameter('StopTime', num2str(T)));
end

function [t, d] = sygnal(o, nazwa)
% zapisany sygnal jako czas + macierz (wiersz = chwila czasu)
ts = o.logsout.get(nazwa).Values; d = squeeze(ts.Data); t = ts.Time;
if size(d, 1) ~= numel(t), d = d'; end
end

function w = wskazniki(t, y, y0, yk, t0)
% przeregulowanie [%], czas ustalania (pasmo 2 % i 5 %) liczony od skoku [s], uchyb ustalony
dy = yk - y0; e = (y - yk) / dy;
w.przeregulowanie = max(0, max(e)) * 100;
i = find(abs(e) > 0.02, 1, 'last');
if isempty(i), w.t_ust = 0; else, w.t_ust = t(min(i + 1, end)) - t0; end
i = find(abs(e) > 0.05, 1, 'last');                  % to samo dla pasma 5 %
if isempty(i), w.t_ust5 = 0; else, w.t_ust5 = t(min(i + 1, end)) - t0; end
w.uchyb = abs(y(end) - yk);
end

function f = fig()
% nowe okno wykresu
f = figure('Visible', 'off', 'Units', 'pixels', 'Position', [0 0 900 480], 'Color', 'w');
set(f, 'DefaultAxesFontSize', 11, 'DefaultLineLineWidth', 1.5);
end

function zapisz(f, img, nazwa)
% zapis do png
exportgraphics(f, fullfile(img, [nazwa '.png']), 'Resolution', 200); close(f);
end
