function plotSpectrogramComp(x1, x2, x3, fs, t_ini, t_fin)
% plotSpectrogramComp
%
% Generates a three-panel spectrogram comparison illustrating the effect
% chain applied to the "radio" source:
%   (1) Raw input signal
%   (2) After distortion and delay
%   (3) After band-limiting (HPF+LPF) and binaural rendering (HRIR)
%
% Inputs:
%   x1     : path to raw input audio file
%   x2     : processed mono signal (distortion + delay)
%   x3     : binaural signal after HPF/LPF and HRIR convolution (Nx2)
%   fs     : sample rate (Hz)
%   t_ini  : start time for display (s)
%   t_fin  : end time for display (s)
% -------------------------------------------------------------------------

% Load raw input
x1 = audioread(x1);

% FFT size for spectral resolution
Nfft = 4096;

figure

% -------------------------------------------------------------------------
% (1) Raw input
% -------------------------------------------------------------------------
subplot(3,1,1);
spectrogram(x1, hann(1024), 512, Nfft, fs, 'yaxis');
title('RAW INPUT');
xlim([t_ini t_fin]);

% -------------------------------------------------------------------------
% (2) After distortion and delay
% -------------------------------------------------------------------------
subplot(3,1,2);
spectrogram(x2, hann(1024), 512, Nfft, fs, 'yaxis');
title('DIST + DELAY');
xlim([t_ini t_fin]);

% -------------------------------------------------------------------------
% (3) After band-limiting and binaural rendering
%     Both ears are overlaid to show the final spectral envelope
% -------------------------------------------------------------------------
subplot(3,1,3);
spectrogram(x3(:,1), hann(1024), 512, Nfft, fs, 'yaxis'); % Left ear
hold on
spectrogram(x3(:,2), hann(1024), 512, Nfft, fs, 'yaxis'); % Right ear
title('HPF - LPF + HRIRs');
xlim([t_ini t_fin]);

end
