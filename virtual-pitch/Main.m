%% Virtual Pitch Psychoacoustics Demonstration
% -------------------------------------------------------------------------
% This script provides an interactive menu to demonstrate the
% "missing fundamental" (virtual pitch) phenomenon using different
% controlled synthesis cases:
%   1) Square wave harmonic series (odd harmonics) +/- fundamental
%   2) Sawtooth harmonic series (all harmonics) +/- fundamental
%   3) High-frequency region (limits of virtual pitch perception)
%   4) F2 Dominant (decay manipulation)
%   5) Inharmonicity (detuned partials)
%   6) Melody-based psychoacoustic test (Imperial March)
% -------------------------------------------------------------------------

clear; close all; clc;
addpath("Functions");
% --- Global audio settings ---
fs = 44100;        % sample rate (Hz)
duration = 2.0;    % default playback duration for cases 1-5 (seconds)

while true
    clc;

    % --- MENU ---
    fprintf('====================================================\n');
    fprintf('    VIRTUAL PITCH (MISSING FUNDAMENTAL) DEMO        \n');
    fprintf('====================================================\n');
    fprintf('Select a demonstration:\n\n');
    fprintf('  [1] Square Wave (Odd Harmonics +/- Fundamental)\n');
    fprintf('  [2] Sawtooth Wave (All Harmonics +/- Fundamental)\n');
    fprintf('  [3] High Frequency Case (Existence Region limit)\n');
    fprintf('  [4] F2 Dominant (Variable Harmonic Decay)\n');
    fprintf('  [5] Inharmonicity (Detuned Harmonics Test)\n');
    fprintf('  [6] Imperial March (Psychoacoustic Test)\n');
    fprintf('  [0] Exit\n');
    fprintf('----------------------------------------------------\n');

    % Read as string first (robust against weird input)
    choiceString = input('Enter your choice (0-6): ', 's');
    choice = str2double(choiceString);

    % Validate numeric range
    while isnan(choice) || choice < 0 || choice > 6
        choiceString = input('Invalid. Enter (0-6): ', 's');
        choice = str2double(choiceString);
    end

    % --- Exit condition ---
    if choice == 0
        fprintf('\n----------------------------------------------------\n');
        fprintf('   Exiting application. May the Force be with you\n');
        fprintf('----------------------------------------------------\n');
        pause(1); % short pause to read message
        break;
    end

    % ---------------------------------------------------------------------
    % SETTINGS (F0, number of harmonics)
    % ---------------------------------------------------------------------
    % NOTE: For choice 6 (melody), f0 and nHarms are set as flags (0) so
    % downstream plotting/code doesn't assume a harmonic series case.
    % ---------------------------------------------------------------------

    if choice == 6
        % Vader case: fully automatic configuration
        f0 = 0;
        nHarms = 0;

    elseif choice == 3
        % High-frequency case: test in the 5–10 kHz region
        fprintf('\n--- High Frequency Settings ---\n');

        validInput = false;
        while ~validInput
            f0_str = input('Enter F0 (5000-10000 Hz) [Default: 5000]: ', 's');

            if isempty(f0_str)
                f0 = 5000; % default
                validInput = true;
            else
                val = str2double(f0_str);
                if isnan(val) || val < 5000 || val > 10000
                    fprintf('   ERROR: Value must be between 5000 and 10000 Hz.\n');
                else
                    f0 = val;
                    validInput = true;
                end
            end
        end

        nHarms = 5; % fixed (kept small at high F0)

    else
        % Standard cases: typical pitch region (200–400 Hz)
        fprintf('\n--- Frequency Settings ---\n');

        validInput = false;
        while ~validInput
            f0_str = input('Enter F0 (200-400 Hz) [Default: 200]: ', 's');

            if isempty(f0_str)
                f0 = 200; % default
                validInput = true;
            else
                val = str2double(f0_str);
                if isnan(val) || val < 200 || val > 400
                    fprintf('   ERROR: Value must be between 200 and 400 Hz.\n');
                else
                    f0 = val;
                    validInput = true;
                end
            end
        end

        nHarms = 10; % default harmonic count
    end

    % ---------------------------------------------------------------------
    % GENERATION
    % ---------------------------------------------------------------------
    % sigA: reference (typically "full" harmonic series including f0)
    % sigB: test condition (typically missing fundamental, level-changed, etc.)
    % ---------------------------------------------------------------------

    switch choice
        case 1
            type = 'Square Wave';

            % A: square-like harmonic set with fundamental present
            [sigA, ~] = generateComplexWave(f0, nHarms, duration, fs, 'square', false, 'standard');

            % B: same but missing fundamental
            [sigB, ~] = generateComplexWave(f0, nHarms, duration, fs, 'square', true,  'standard');

            labelA = 'Square Full';
            labelB = 'Square Missing Fundamental';

        case 2
            type = 'Sawtooth Wave';

            % A: sawtooth-like harmonic set with fundamental present
            [sigA, ~] = generateComplexWave(f0, nHarms, duration, fs, 'sawtooth', false, 'standard');

            % B: same but missing fundamental
            [sigB, ~] = generateComplexWave(f0, nHarms, duration, fs, 'sawtooth', true,  'standard');

            labelA = 'Sawtooth Full';
            labelB = 'Sawtooth Missing Fundamental';

        case 3
            type = 'High Frequency';

            % High-F0 sawtooth harmonics +/- fundamental
            [sigA, ~] = generateComplexWave(f0, nHarms, duration, fs, 'sawtooth', false, 'standard');
            [sigB, ~] = generateComplexWave(f0, nHarms, duration, fs, 'sawtooth', true,  'standard');

            labelA = 'HighFreq Full';
            labelB = 'HighFreq Missing Fundamental';

        case 4
            type = 'F2 Dominant';

            % A: normal harmonic decay
            [sigA, ~] = generateComplexWave(f0, nHarms, duration, fs, 'sawtooth', false, 'standard');

            % B: "aggressive" mode (as defined inside generateComplexWave)
            % Intended: make higher harmonics weaker so F2 becomes dominant cue
            [sigB, ~] = generateComplexWave(f0, nHarms, duration, fs, 'sawtooth', true, 'aggressive');

            labelA = 'Sawtooth Full';
            labelB = 'Sawtooth F2 Dominant Attenuated Harmonics';

        case 5
            type = 'Inharmonicity';

            % Manual synthesis here (not using generateComplexWave)
            t = 0:1/fs:duration;

            % A: harmonic reference (includes k=1 fundamental)
            sigA = zeros(size(t));
            for k = 1:nHarms
                sigA = sigA + (1/k)*sin(2*pi*k*f0*t);
            end
            sigA = sigA / max(abs(sigA));

            % B: inharmonic partials (starts from k=2, and each partial is shifted)
            % NOTE: This intentionally removes k=1 and detunes all remaining partials.
            sigB = zeros(size(t));
            shift = 50; % Hz offset applied to every partial (constant shift)
            for k = 2:nHarms
                sigB = sigB + (1/k)*sin(2*pi*((k*f0)+shift)*t);
            end
            sigB = sigB / max(abs(sigB));

            labelA = 'Reference Harmonic';
            labelB = 'Inharmonic Shifted';

        case 6
            % Melody-based psychoacoustic test
            % IMPORTANT: closes previous plots to keep UI clean.
            close all;

            type = 'Imperial March (Virtual Pitch)';
            fprintf('\n--- INITIATING SITH PROTOCOL ---\n');

            % Generate the melody (implementation is inside generateStressMelody)
            [sigA, songName] = generateStressMelody(fs, 1);

            % B: silence (kept to preserve plotting interface)
            sigB = zeros(size(sigA));

            % Re-assert flags to avoid harmonic-series assumptions in plotWaveAB
            f0 = 0;
            nHarms = 0;

            labelA = 'Imperial March Psychoacoustic';
            labelB = 'Silence';

            fprintf('Playing: %s...\n', songName);
    end

    % ---------------------------------------------------------------------
    % PLAYBACK
    % ---------------------------------------------------------------------
    if choice == 6
        % Special case: play only melody A
        sound(sigA, fs);
        pause(length(sigA)/fs + 0.5); % wait until finished
    else
        fprintf('\n1. Playing A (%s)...\n', labelA);
        sound(sigA, fs);
        pause(duration + 0.5);

        fprintf('2. Playing B (%s)...\n', labelB);
        sound(sigB, fs);
        pause(duration + 0.5);
    end

    % ---------------------------------------------------------------------
    % PLOTTING
    % ---------------------------------------------------------------------
    fprintf('Generating Plots...\n');
    plotWaveAB(sigA, sigB, fs, f0, nHarms, labelA, labelB);

    % ---------------------------------------------------------------------
    % EXPORT (optional)
    % ---------------------------------------------------------------------
    while true
        saveChoice = input('\nWould you like to export these audio files? (y/n): ', 's');
        if strcmpi(saveChoice, 'y') || strcmpi(saveChoice, 'n')
            break;
        end
    end

    if strcmpi(saveChoice, 'y')

    % Build a single export signal:
    if choice == 6
        yOut = sigA;
    else
        gap = zeros(round(0.5*fs), 1);  % 0.5 s gap between A and B
        
        % Ensure consistent shape (column vectors) for safe concatenation
        yOut = [sigA(:); gap; sigB(:)];
    end

    filenameOut = sprintf('%s__%s.wav', strrep(labelA,' ','_'), strrep(labelB,' ','_'));
    audiowrite(fullfile('audio_examples', filenameOut), yOut, fs);
    fprintf('Saved: %s\n', filenameOut);

    end


    input('\nPress Enter to return to main menu...');
end
