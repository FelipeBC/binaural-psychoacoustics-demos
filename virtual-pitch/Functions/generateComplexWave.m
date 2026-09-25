function [y, t] = generateComplexWave(f0, nHarms, duration, fs, type, removeFundamental, decayType)
% GENERATECOMPLEXWAVE Generates complex tones for Psychoacoustics demos
% -------------------------------------------------------------------------
% This function synthesizes a harmonic complex tone by summing sinusoids
% up to nHarms, optionally removing the fundamental (n=1), and optionally
% applying an "aggressive" decay mode to attenuate higher harmonics.
%
% Inputs:
%   f0                : Fundamental frequency (Hz)
%   nHarms            : Number of harmonics requested
%   duration          : Signal duration (seconds)
%   fs                : Sampling rate (Hz)
%   type              : 'sine', 'square', 'sawtooth'
%   removeFundamental : true/false (if true, sets n=1 amplitude to 0)
%   decayType         : 'standard' or 'aggressive'
%
% Outputs:
%   y                 : Output waveform (normalized to peak 0.9)
%   t                 : Time vector (seconds)
% -------------------------------------------------------------------------
    % --- Time base ---
    dt = 1/fs;
    t  = 0:dt:duration-dt;

    % --- Initialize output ---
    y = zeros(size(t));

    % --- Harmonic summation loop ---
    for n = 1:nHarms

        % Harmonic frequency
        freq = n * f0;

        % Stop if harmonic exceeds Nyquist (prevents aliasing)
        if freq >= fs/2
            break;
        end

        % Determine amplitude for this partial depending on waveform type
        currentAmp = 0;
        switch lower(type)

            case 'sine'
                % Harmonic decay: 1/n
                currentAmp = 1/n;

            case 'square'
                % Square wave: odd harmonics only (1/n for odd, 0 for even)
                if mod(n, 2) ~= 0
                    currentAmp = 1/n;
                else
                    currentAmp = 0;
                end

            case 'sawtooth'
                % Sawtooth: all harmonics with 1/n decay
                currentAmp = 1/n;
        end

        % Logic for Demo 4 (Relative Levels):
        % In "aggressive" mode, harmonics above the 2nd are strongly attenuated
        if strcmp(decayType, 'aggressive') && n > 2
            currentAmp = currentAmp * 0.1; % Attenuate high harmonics
        end

        % Optionally remove the fundamental (n = 1)
        if n == 1 && removeFundamental
            currentAmp = 0;
        end

        % Add this partial if it has non-zero amplitude
        if currentAmp > 0
            y = y + currentAmp * sin(2*pi * freq * t);
        end
    end

    % --- Normalization ---
    % Normalize peak to 0.9 to avoid clipping during playback/export
    if max(abs(y)) > 0
        y = y / max(abs(y)) * 0.9;
    end
end
