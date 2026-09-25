% Main Script, designed for:
%
% - Run static and movement renderer functions with several sounds
% - Apply some fx before convolution with HRIRs
% - Listen and export the binaural soundscape
% - Plot one or several trajectories
% - Plot time-domain and log-magnitude spectra of HRIRs


%% Loading data required  

addpath("Audios");
addpath("Functions");
addpath("SADIE_HRIRs");
load("SADIE_HRIRs/BRIR_parse.mat");

%% Room Tone

A = 0.02; 
[Ax1, A_Ax1] = static_renderer ('L.wav',315,0,A);
[Ax2, A_Ax2] = static_renderer ('R.wav',45,0,A);
[Ax3, A_Ax3] = static_renderer ('C.wav',0,0,A);
[Ax4, A_Ax4] = static_renderer ('Ls.wav',225,0,A);
[Ax5, A_Ax5] = static_renderer ('Rs.wav',135,0,A);

AxMaster = Ax1 + Ax2 + Ax3 + Ax4 + Ax5;

%% Fx and Dialogues 

[Fx1, FA_Fx1] = dynamic_renderer ('Door.wav',1,3,130,45,180,-45,0.5);
[Fx2, FA_Fx2] = dynamic_renderer ('Footsteps.wav',9,15,110,-45,310,-45,0.4);
[Fx3, FA_Fx3] = dynamic_renderer ('Dx1.wav',9,15,110,30,310,30,0.9);
[Fx4, A_Fx4]  = static_renderer ('Radio.wav',310,-20,0.3);

% dist, slap delay before HRIRs
dist = distortion('Music.wav',10,0.5);
SlapDel = delay(dist,0.1,0.3,fs);
[Fx5, A_Fx5]  = static_renderer (SlapDel,310,-20,0.1); 

% speaker simulation
Fx5 = highpass(Fx5,500,fs);
Fx5 = lowpass(Fx5,1000,fs);

[Fx6, FA_Fx6] = dynamic_renderer ('Footsteps2.wav',21,25,310,-45,450,-45,0.4);
[Fx7, FA_Fx7] = dynamic_renderer ('Dx2.wav',22.9,25,340,30,450,30,0.9);

% flanger before HRIRs
xflanger1 = flanger('Dx3.wav',fs,0.5,0.005,0.5);
[Fx8, FA_Fx8] = dynamic_renderer (xflanger1,28.62,29.32,270,-90,270,90,0.8);
xflanger2 = flanger('Dx4.wav',fs,0.5,0.005,0.5);
[Fx9, FA_Fx9] = dynamic_renderer (xflanger2,29.46,30,90,90,90,-90,0.8);

FxMaster = Fx1 + Fx2 + Fx3 + Fx4 + Fx5 + Fx6 + Fx7 + Fx8 + Fx9;

%% Master summing and audio exportation 

Master = AxMaster + FxMaster;
sound(Master,fs)
%audiowrite(fullfile('render','BinauralRadioDrama.wav'),Master,fs)

%% Plotting

% see plotTrajectoryHRTF.m
%plotTrajectoryHRTF({FA_Fx2,FA_Fx3,FA_Fx6,FA_Fx7}, az_el_angles, {'Footsteps1','Dx1','Footsteps2','Dx2'}); % needs Functions/skull.obj

%Find the HRIR closest to azimuth
%idx = closestHRIR(60, 0, az_el_angles);

% Retrieve left and right HRIRs for that direction
% hL = HRIR_set_L(idx, :);
% hR = HRIR_set_R(idx, :);

% Plot time-domain HRIRs and their log-magnitude spectra
% see plotHRIR_TimeAndSpectrum.m
% plotHRIR_TimeAndSpectrum(hL, hR, fs, ...
   % sprintf('Az = %g°, El = %g° (idx = %d)', az_el_angles(idx,1), az_el_angles(idx,2), idx), 3);

