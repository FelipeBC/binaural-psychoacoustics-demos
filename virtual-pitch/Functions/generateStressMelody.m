function [melodySignal, melodyName] = generateStressMelody(fs, ~)
% GENERATESTRESSMELODY
% -------------------------------------------------------------------------
% Generates an "Imperial March" melody where each note is randomly rendered
% under one of five spectral conditions to stress-test virtual pitch:
%   [1] Full harmonic series
%   [2] Missing fundamental (no k=1)
%   [3] Extreme: remove low harmonics (no k=1..5)
%   [4] Inharmonic: constant frequency shift added to each partial
%   [5] F2-dominant: second harmonic emphasized in level
%
% Inputs:
%   fs : sampling rate (Hz)
%   ~  : unused argument (kept for compatibility)
%
% Outputs:
%   melodySignal : concatenated audio signal of the full melody
%   melodyName   : name string printed and returned

    % ---------------------------------------------------------------------
    % 1) Notes and Frequencies (Hz)
    % ---------------------------------------------------------------------
    Eb4 = 311.13;  Gb4 = 369.99;  G4  = 392.00;  Bb4 = 466.16;
    D5  = 587.33;  Eb5 = 622.25;

    melodyName = 'Imperial March (Psychoacoustic Version)';

    % ---------------------------------------------------------------------
    % 2) Score (two-part phrase: low "call" + high "response")
    % ---------------------------------------------------------------------
    partA_notes = [G4, G4, G4, Eb4, Bb4, G4, Eb4, Bb4, G4];
    partB_notes = [D5, D5, D5, Eb5, Bb4, Gb4, Eb4, Bb4, G4];

    notes = [partA_notes, partB_notes];

    % Rhythm pattern (relative units), duplicated for A and B
    rhythmPattern = [1, 1, 1, 0.75, 0.25, 1, 0.75, 0.25, 2];
    rhythm = [rhythmPattern, rhythmPattern];

    % Tempo scaling (seconds per rhythm unit)
    tempo = 0.55;

    fprintf('\n--- Initiating: "%s" ---\n', melodyName);
    fprintf('Conditions: [1]Full [2]MisF1 [3]Extreme [4]Inharm [5]F2-Dom\n');

    melodySignal = [];

    % ---------------------------------------------------------------------
    % 3) Generation loop (each note gets a random condition with 20%% chance)
    % ---------------------------------------------------------------------
    for i = 1:length(notes)

        f0  = notes(i);
        dur = rhythm(i) * tempo;

        % NOTE: time vector includes endpoint (t = 0 ... dur)
        t = 0:1/fs:dur;

        % Random condition selection (each bin is 0.20 wide)
        roll = rand();
        if roll < 0.20
            cond = 1;      % Full
        elseif roll < 0.40
            cond = 2;      % Missing F1
        elseif roll < 0.60
            cond = 3;      % Extreme
        elseif roll < 0.80
            cond = 4;      % Inharmonic
        else
            cond = 5;      % F2 Dominant
        end

        sig = zeros(size(t));

        % -------------------------------------------------------------
        % Condition synthesis (harmonic sums)
        % -------------------------------------------------------------
        switch cond

            case 1  % Full
                typeStr = 'Full';
                for k = 1:12
                    sig = sig + (1/k) * sin(2*pi*k*f0*t);
                end

            case 2  % Missing F1
                typeStr = 'Missing F1';
                for k = 2:12
                    sig = sig + (1/k) * sin(2*pi*k*f0*t);
                end

            case 3  % Extreme
                typeStr = 'Extreme (No F1-F5)';
                for k = 6:16
                    sig = sig + (1/k) * sin(2*pi*k*f0*t);
                end

            case 4  % Inharmonic
                typeStr = 'Inharmonic';
                shift = 50; % constant detuning offset applied to every partial
                for k = 2:12
                    sig = sig + (1/k) * sin(2*pi*((k*f0)+shift)*t);
                end

            case 5  % F2 Predominant
                typeStr = 'F2 Dominant';

                % NOTE: This condition intentionally boosts k=2 and keeps
                % a reduced but present fundamental (k=1 at 0.3).
                for k = 1:12
                    if k == 2
                        amp = 1.0;
                    elseif k == 1
                        amp = 0.3;
                    else
                        amp = 0.3/k;
                    end
                    sig = sig + amp * sin(2*pi*k*f0*t);
                end
        end

        fprintf('Note %d: %s\n', i, typeStr);

        % -----------------------------------------------------------------
        % Soft envelope (fade in/out) to avoid clicks at concatenation
        % -----------------------------------------------------------------
        if max(abs(sig)) > 0
            sig = sig / max(abs(sig));
        end

        fadeSz = round(0.02 * fs); % 20 ms fade

        if length(sig) > 2*fadeSz
            env = ones(size(sig));
            env(1:fadeSz) = linspace(0, 1, fadeSz);
            env(end-fadeSz+1:end) = linspace(1, 0, fadeSz);
            sig = sig .* env;
        end

        % Concatenate note to the melody
        melodySignal = [melodySignal, sig];
    end

    % Add a short silence tail (0.5 s)
    melodySignal = [melodySignal, zeros(1, round(fs*0.5))];
end
