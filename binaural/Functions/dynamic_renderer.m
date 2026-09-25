function [y, FrameAngle] = dynamic_renderer (input_file, tStart, tEnd, az_ini, el_ini, az_end, el_end, A)
%DYNAMIC_RENDERER Dynamic binaural rendering using time-varying HRIRs with OLA/FFT convolution.
%
% This implementation is adapted from teaching materials and example code
% provided by Dr. Frank Stevens (University of York).
%
% The function renders a *moving* mono sound source in binaural stereo by
% updating the HRIR (selected from a discrete azimuth/elevation grid) over time.
% The rendering is implemented using Overlap-Add (OLA) with FFT-based convolution:
% each windowed input frame is convolved with the current (smoothed) HRIR pair,
% then overlap-added into the output buffers.
%
% The input can be provided either as:
%   - a filename (string or char), in which case the audio is loaded from disk, or
%   - a signal vector already in memory (assumed to be mono).
%
% INPUTS:
%   input_file : audio filename OR mono signal vector
%   tStart     : trajectory start time in seconds
%   tEnd       : trajectory end time in seconds
%   az_ini     : start azimuth in degrees
%   el_ini     : start elevation in degrees
%   az_end     : end azimuth in degrees
%   el_end     : end elevation in degrees
%   A          : linear output gain applied after normalisation
%
% OUTPUTS:
%   y          : stereo binaural output signal [left right]
%   FrameAngle : HRIR index (into az_el_angles) selected for each processed frame
%
% DATA / ASSUMPTIONS:
%   - HRIR data is loaded from 'BRIR_parse.mat' (HRIR_set_L, HRIR_set_R, fs, az_el_angles).
%   - A fixed frame size of 1024 samples and 50% overlap are used.
%   - HRIR transitions are smoothed via a simple first-order crossfade (alpha = 0.1).
%--------------------------------------------------------------------------

    % --- 1. Fixed parameters and data loading ---
    
    % Fixed parameters 
    brir_data_file = 'BRIR_parse.mat';     % BRIR/HRIR data file
    frame_size = 1024;                    % frame length (samples)
    
    % Load BRIR/HRIR dataset and metadata
    load(brir_data_file, 'HRIR_set_L', 'HRIR_set_R', 'fs', 'az_el_angles');
   
    % --- 2. Load/accept input signal and validate sample rate ---
    if ischar(input_file) || isstring(input_file)
        % Load audio source from file
        [x, wav_Fs] = audioread(input_file);
    
        % Ensure sample rate matches the HRIR dataset
        if wav_Fs ~= fs
            error('Sampling rates must match. wav_Fs: %d, fs: %d', wav_Fs, fs);
        end
    else
        % Otherwise, assume the input is already a mono signal in memory
        x = input_file;
    end

    % --- 3. Derived sizes and OLA/FFT parameters ---
    Ninput = length(x);                   % number of input samples
    [~, NIR] = size(HRIR_set_L);          % HRIR length (samples)
    
    step_size = frame_size / 2;           % 50% overlap
    y_length = Ninput + NIR - 1;          % output length due to convolution
    frame_conv_len = frame_size + NIR - 1;% length of per-frame convolution result
    
    w = hann(frame_size, 'periodic');     % Hann window for frame processing

    % Number of frames that fit with the chosen overlap
    Nframes = floor((Ninput - frame_size) / step_size); 

    if Nframes <= 0
        error('Input signal is too short for the selected frame size and overlap.');
    end
    
    % --- 4. Trajectory computation and initialisation ---
    
    % Compute HRIR index for each frame based on the requested motion path
    FrameAngle = trajectory(Nframes, step_size, fs, tStart, tEnd, ...
    az_ini, el_ini, az_end, el_end, az_el_angles); % see trajectory.m
    
    % Output buffer (stereo)
    y = zeros(y_length, 2);
    
    % Preallocated buffers for FFT convolution (zero-padded)
    IRPad = zeros(frame_conv_len, 2);         % padded HRIRs (L/R)
    currentFrame = zeros(frame_conv_len, 1);  % padded input frame
    
    % Initialise the smoothed HRIR state using the first selected direction
    idx0 = FrameAngle(1);
    hL_prev = HRIR_set_L(idx0, :)';           % initial left HRIR
    hR_prev = HRIR_set_R(idx0, :)';           % initial right HRIR

    % --- 5. OLA processing loop ---
    
    for n = 1 : Nframes
        % 5.1 Window and zero-pad the current input frame
        frame_start = 1 + (n - 1) * step_size;
        frame_end = frame_start + frame_size - 1;
        
        currentFrame(1:frame_size) = x(frame_start : frame_end) .* w;
        
        % 5.2 Select target HRIR and apply smoothing (crossfade)
        idx = FrameAngle(n);
        hL_t = HRIR_set_L(idx, :)'; 
        hR_t = HRIR_set_R(idx, :)'; 
        
        % Simple first-order smoothing:
        % h_prev <- (1-alpha)*h_prev + alpha*h_target
        alpha = 0.1;
        hL_prev = (1 - alpha) * hL_prev + alpha * hL_t;
        hR_prev = (1 - alpha) * hR_prev + alpha * hR_t;
        
        % 5.3 Pad the smoothed HRIRs for FFT-based convolution
        IRPad(1:NIR, 1) = hL_prev; 
        IRPad(1:NIR, 2) = hR_prev; 
        
        % 5.4 FFT convolution (per frame)
        convResL = ifft(fft(currentFrame) .* fft(IRPad(:, 1)));
        convResR = ifft(fft(currentFrame) .* fft(IRPad(:, 2)));
        
        % 5.5 Overlap-add into the output buffers
        output_start = frame_start;
        output_end = frame_start + frame_conv_len - 1;
        
        y(output_start : output_end, 1) = y(output_start : output_end, 1) + convResL;
        y(output_start : output_end, 2) = y(output_start : output_end, 2) + convResR;
    end
    
    % --- 6. Output normalisation ---
    
    % Normalise 
    y = A .* y ./ max(max(abs(y)));

end
