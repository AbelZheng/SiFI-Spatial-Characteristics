function smoothed_noise= NoiseGenerate(sr,StiDur,GateDur)    
% smoothed_tone=(sr,frequency,dur,GateDur)
% sr: sample rate, e.g. 44100
% 
wn=rand(1,sr*StiDur);%生成白噪音原始刺激，2代表两个声道，time是以秒为单位的时间
gate = cos(linspace(pi, 2*pi, sr*GateDur)); %余弦变换
gate = (gate + 1) / 2;
offsetgate = fliplr(gate); 
sustain = ones(1, (length(wn)-length(gate)-length(offsetgate)) );
envelope = [gate, sustain, offsetgate];
smoothed_noise = envelope .* wn;
% subplot(3,1,1); plot(time,tone);
% subplot(3,1,2); plot(time,envelope,'o');
% subplot(3,1,3);plot(time,smoothed_tone);
end