 function smoothed_tone= Soundgenerate(sr,frequency,dur,gatedur)
time=linspace(0,dur,sr*dur);
tone=sin(2*pi*frequency*time);
gate = cos(linspace(pi, 2*pi, sr*gatedur)); %余弦变换
gate = (gate + 1) / 2;
offsetgate = fliplr(gate); 
sustain = ones(1, (length(tone)-2*length(gate)));
envelope = [gate, sustain, offsetgate]; %最开始和最后都有fade out
smoothed_tone = envelope .* tone;
% subplot(3,1,1); plot(time,tone);
% subplot(3,1,2); plot(time,envelope,'o');
% subplot(3,1,3);plot(time,smoothed_tone);
end