function plotHRIR_TimeAndSpectrum(hL, hR, fs, labelStr, t_ms)
%plotHRIR_TimeAndSpectrum Plot HRIR pair (time domain + magnitude spectra).
%
% INPUTS
%   hL, hR   : HRIR for left/right ear (row or column vectors)
%   fs       : sample rate (Hz)
%   labelStr : string for title/caption context
%   t_ms     : (optional) time window to display in ms (default: 12 ms)
%
% NOTES
% - HRIRs can be long; the time plot is usually most informative when zoomed
%   to the first few milliseconds (onset/ITD region).
% - Spectrum shown as magnitude (dB) of FFT, using a Hann window.

    if nargin < 5 || isempty(t_ms)
        t_ms = 12; % show first 12 ms by default
    end

    hL = hL(:);
    hR = hR(:);

    % ---- Time axis (ms) ----
    t = (0:length(hL)-1) / fs * 1000;

    % ---- Time window for plotting ----
    iEnd = min(length(hL), round(t_ms/1000 * fs));

    % ---- FFT settings ----
    Nfft = 1024;
    wL = hann(length(hL));
    wR = hann(length(hR));

    HL = fft(hL .* wL, Nfft);
    HR = fft(hR .* wR, Nfft);

    f = (0:(Nfft/2)) / Nfft * fs;

    magL = 20*log10(abs(HL(1:Nfft/2+1)) + eps);
    magR = 20*log10(abs(HR(1:Nfft/2+1)) + eps);

    % ---- Plot ----
    figure('Name', "HRIR Time+Spectrum - " + labelStr);

    % Time domain
    subplot(2,1,1);
    plot(t(1:iEnd), hL(1:iEnd), 'LineWidth', 1.2); hold on;
    plot(t(1:iEnd), hR(1:iEnd), 'LineWidth', 1.2);
    grid on;
    xlabel('Time (ms)');
    ylabel('Amplitude');
    title("HRIR time domain (first " + num2str(t_ms) + " ms) – " + labelStr);
    legend('Left ear', 'Right ear', 'Location', 'southwest');

    % Magnitude spectra
    subplot(2,1,2);
    semilogx(f, magL, 'LineWidth', 1.2); hold on;
    semilogx(f, magR, 'LineWidth', 1.2);
    grid on;
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title('HRIR magnitude spectra');
    xlim([100 20000]);
    legend('Left ear', 'Right ear', 'Location', 'southwest');
end
