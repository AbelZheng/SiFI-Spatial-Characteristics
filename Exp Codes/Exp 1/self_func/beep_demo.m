
% a testing demo for the sound play

clear;
clc;
sca;

InitializePsychSound;

% Open Psych-Audio port
freq = 48000;
pahandle = PsychPortAudio('Open', [], 1, 1, freq, 2);

% Set the volume
PsychPortAudio('Volume', pahandle, 0.5);

% Make a beep which we will play back to the user
[myBeep, samplingRate] = MakeBeep(500, 0.2, freq);
PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]);

% Show audio playback
PsychPortAudio('Start', pahandle, 1, 0, 1);
[startTime, endPositionSecs, xruns, estStopTime] = PsychPortAudio('Stop', pahandle, 1, 1);

% Close the audio device
PsychPortAudio('Close', pahandle);