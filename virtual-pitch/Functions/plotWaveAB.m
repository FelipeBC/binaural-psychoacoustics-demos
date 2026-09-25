function plotWaveAB(yA, yB, fs, f0, nHarms, titleA, titleB)
% PLOTWAVEAB Visualises signals using conditional logic.
% -------------------------------------------------------------------------
% Logic:
%   - If f0 == 0 (melody case): plot ONLY one spectrogram for yA.
%   - If f0  > 0 (test cases): plot comparison (spectrogram A/B + FFT A/B).

    % ---------------------------------------------------------
    % STFT parameters
    % ---------------------------------------------------------
    wlen     = hann(2048);
    noverlap = 1024;
    nfft     = 4096;

    % Display dynamic range (dB below peak).
    % Increase (e.g., 90) to show more faint content; decrease (e.g., 70) for more contrast.
    dynRange_dB = 90;

    % ---------------------------------------------------------
    % MODE 1: MELODY ONLY (f0 == 0)
    % ---------------------------------------------------------
    if f0 == 0

        % Melody frequency view limit (kHz)
        yLimit_kHz = 10;

        % Compute STFT and convert to dB (then normalise so max = 0 dB)
        [S, F, T] = spectrogram(yA, wlen, noverlap, nfft, fs);
        SdB = 20*log10(abs(S) + 1e-12);
        SdB = SdB - max(SdB(:));   % 0 dB at peak

        % Plot with MATLAB defaults
        figure %('Name', 'Melody Analysis', 'NumberTitle', 'off', 'Color', 'w');
        imagesc(T, F/1000, SdB);
        axis xy

        ylim([0 yLimit_kHz]);
        xlim([0 8.81])
        clim([-dynRange_dB 0]); 

        
        % NOTE: Melody case uses "hot" colormap (lightsaber)
        colormap("hot");

        title(['Spectrogram: ' titleA], 'Interpreter', 'none', 'FontSize', 12);
        xlabel('Time (s)');
        ylabel('Frequency (kHz)');
        c = colorbar;
        c.Label.String = 'Magnitude (dB)';

        fprintf('Melody Spectrogram plotted\n');

    else
        % ---------------------------------------------------------
        % MODE 2: FULL COMPARISON (f0 > 0)
        % ---------------------------------------------------------

        % Frequency view limit based on harmonic count and fundamental
        hMax = nHarms;
        freqLimit_Hz = min(0.49*fs, 1.10 * hMax * f0);
        yLimit_kHz   = freqLimit_Hz / 1000;

        % Compute both STFTs
        [SA, FA, TA] = spectrogram(yA, wlen, noverlap, nfft, fs);
        [SB, FB, TB] = spectrogram(yB, wlen, noverlap, nfft, fs);

        % Convert to dB
        AdB = 20*log10(abs(SA) + 1e-12);
        BdB = 20*log10(abs(SB) + 1e-12);

        % Normalise BOTH to the same 0 dB reference (shared peak)
        peak = max([AdB(:); BdB(:)]);
        AdB = AdB - peak;
        BdB = BdB - peak;

        % --- Figure 1: Spectrogram comparison (A/B) ---
        figure('Name', 'Spectrogram Comparison', 'NumberTitle', 'off', 'Color', 'w');

        subplot(2,1,1);
        imagesc(TA, FA/1000, AdB);
        axis xy
        ylim([0 yLimit_kHz]);
        clim([-dynRange_dB 0]);
        colormap(parula);
        title(['Spectrogram: ' titleA], 'Interpreter', 'none', 'FontSize', 11);
        xlabel('Time (s)');
        ylabel('Frequency (kHz)');
        colorbar;

        subplot(2,1,2);
        imagesc(TB, FB/1000, BdB);
        axis xy
        ylim([0 yLimit_kHz]);
        clim([-dynRange_dB 0]);
        colormap(parula);
        title(['Spectrogram: ' titleB], 'Interpreter', 'none', 'FontSize', 11);
        xlabel('Time (s)');
        ylabel('Frequency (kHz)');
        colorbar;

        % --- Figure 2: FFT analysis ---
        figure('Name', 'FFT Analysis', 'NumberTitle', 'off', 'Color', 'w');

        subplot(2,1,1);
        plotFFT(yA, fs, freqLimit_Hz, titleA);

        subplot(2,1,2);
        plotFFT(yB, fs, freqLimit_Hz, titleB);
    end
end

% ---------------------------------------------------------
% Auxiliary FFT plotting function
% ---------------------------------------------------------
function plotFFT(y, fs, viewLimit, name)
% plotFFT Computes and plots the one-sided magnitude spectrum.
%
% Inputs:
%   y         : time-domain signal
%   fs        : sample rate (Hz)
%   viewLimit : x-axis upper limit (Hz)
%   name      : label for the plot title

    L = length(y);

    % One-sided magnitude spectrum
    Y  = fft(y);
    P2 = abs(Y/L);
    P1 = P2(1:floor(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);

    f = fs*(0:(L/2))/L;

    plot(f, P1, 'LineWidth', 1.5);
    title(['Spectrum: ' name], 'Interpreter', 'none');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;
    xlim([0 viewLimit]);
end
