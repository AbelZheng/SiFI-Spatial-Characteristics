    
    sr=44100;StartFixDur = 0.5; % frist start fixation duration
	ISI_Array = 1.5:0.1:2.5; % varied ISI
	%ClickDur = 0.001; %1ms 
	ToneDur = 0.01; % 10ms with 1 ms rise-and-fall time
	Tone_SOA_Array =[0.01: 0.01: 0.06]*10; % 10ms~60ms
	%NoiseDur = 0.1;
	RespDur = 1; 
	InterTrialDur = 1; % Inter-trial duration 

	BeginFreq = 300; %Hz
	BeginDur = 0.5; % same as StartFixDur
	BeginGateDur = 0.1;
	
	HighToneFreq=1000; %Hz
	LowToneFreq=800; %Hz
	ToneGateDur=0.001;
     
	% audio setup
	BeginSound=BeginGenerate(sr,BeginFreq,BeginDur, BeginGateDur);	% BeginGenerate(sr,frequency,dur,gatedur)
    %NoiseSound=NoiseGenerate(sr,NoiseDur); % NoiseGenerate(sr,dur)                         
    
	HighTone=ToneGenerate(sr,HighToneFreq, ToneDur,ToneGateDur); % ToneGenerate(sr,frequency,dur,gatedur)
	LowTone=ToneGenerate(sr,LowToneFreq, ToneDur,ToneGateDur); % ToneGenerate(sr,frequency,dur,gatedur)
	
   % audiowrite('tone_600Hz.wav',LowTone,sr);
   % audiowrite('tone_1200Hz.wav',HighTone,sr);