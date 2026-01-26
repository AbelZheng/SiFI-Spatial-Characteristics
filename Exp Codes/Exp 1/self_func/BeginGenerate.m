function begin_sound = BeginGenerate(sr,frequency,dur,gatedur)
% begin_sound = BeginGenerate(sr,frequency,dur,gatedur)
%   此处显示详细说明
tone=ToneGenerate(sr,frequency,dur,gatedur);
tone=repmat(tone,1,3);
begin_sound=tone;
end
% tone=BeginGenerate(44100,1200,0.5,0.1);
