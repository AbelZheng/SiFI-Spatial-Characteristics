% Program to create a warbling wave file with variable amplitude and pitch.
% function make_wav_file()
% Initialization / clean-up code.
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 20;

% Create the filename where we will save the waveform.
folder = pwd;
baseFileName = 'Test_Wave.wav';
fullFileName = fullfile(folder, baseFileName);
fprintf('Full File Name = %s\n', fullFileName);

% Set up the time axis:
Fs = 8000;
duration = 2; % seconds.
t = 1 : duration * Fs; % 2 seconds

% Set up the period (pitch, frequency):
T = 13; % Constant pitch if you use this.
T = linspace(25, 8, length(t)); % Pitch changes if you use this.

% Create the maximum amplitude:
Amplitude = 32767;
% Add an exponential decay:
Amplitude = Amplitude .* exp(-0.0003*t);

% Add an ocillation on the amplitude:
% Amplitude = Amplitude .* rand(1, length(x)); % Makes a shushing/roaring sound.
Amplitude = Amplitude .* sin(2.*pi.*t./2000); % Decaying pulsing sound.

% Construct the waveform:
y = int16(Amplitude .* sin(2.*pi.*t./T));
% y = abs(int16(Amplitude .* sin(2.*pi.*x./T)));

% Plot the waveform:
plot(t, y, 'b-');
title('Waveform', 'FontSize', fontSize);
xlabel('Time', 'FontSize', fontSize);
ylabel('Y', 'FontSize', fontSize);
grid on;
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
fprintf('Writing file %s...\n', fullFileName);

% Write the waveform to a file:
audiowrite(fullFileName, y, Fs);

% Play the sound as many times as the user wants.
playAgain = true;
counter = 1;
while playAgain
	% Play the sound that we just created.
	fprintf('Playing file %s   %d times...\n', fullFileName, counter);
	player = audioplayer(y, Fs);
	play(player);
	% Ask user if they want to play the sound again.
	promptMessage = sprintf('You have played the sound %d times.\nDo you want to play the sound again?', counter);
	titleBarCaption = 'Continue?';
	button = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'Yes');
	if strcmpi(button, 'No')
		playAgain = false;
		break;
	end
	counter = counter + 1;
end

% Alert user that we are done.
message = sprintf('Done playing %s.\n', fullFileName);
fprintf('%s\n', message);
promptMessage = sprintf('Done playing %s.\nClick OK to close the window\nor Cancel to leave it up.', fullFileName);
titleBarCaption = 'Continue?';
button = questdlg(promptMessage, titleBarCaption, 'OK', 'Cancel', 'OK');
if strcmpi(button, 'OK')
	close all;	% Close down the figure.
end

