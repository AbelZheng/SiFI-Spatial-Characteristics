%% _________________ Regular _____________________
% 
% SOA ranges in [];
%% Initialization
sca;
close all;
clearvars;
rng('shuffle')
Screen('Preference', 'SkipSyncTests', 1); % notebook index is 1
monitorwidth=57;              % monitor width in cm.
vdistance=50;                 % visual distance in cm.

try
    %% Collect Subject Info
    Prompt = {'Subject Number', 'Name', 'Age', 'Gender:(1 is for male, 2 for female)'};
    DlgTitle = 'Personalia';
    Numlines = 1;
    Answer = inputdlg(Prompt, DlgTitle, Numlines);
    SubID = str2double(Answer{1});
    SubName = Answer{2};
    SubAge = str2double(Answer{3});
    SubGender = str2double(Answer{4});
    
    % Target_press_mapping
    while true
        str = input('Please input press button mapping number: ', 's');
        if isempty(str)
            continue;
        elseif strcmp(str,'1') || strcmp(str,'2')
            PressMapping_index = str2double(str);
            break;
        end
    end
    
    %% Basic Parameters
    % key balance
    SubPressType = [1 2;...
                    2 1];
    % Press button
    PressCodeArray = ['Z' , 'M'];
    
    % SubjTarPressButtonMapping
    SubPressArray = PressCodeArray (SubPressType (PressMapping_index,:) );
    % 1st
    % 2nd
    
    % Experimental Paramenters
    FlashNumArray = [1, 2];
    BeepNumArray = [0, 1, 2];
    SOA_Array = [70];
    SOAnum = length(SOA_Array);
    ctResponseTime = 3; % catch trial waiting time
    % formal trial setting
    totaltrial = 18;
    catchtrial = 6;
    Total_trial = totaltrial + catchtrial;
    trialPerBlock = 6;
    nBlock = Total_trial / trialPerBlock;
    Resttime = 5;
    Qdelaytime = 0.25;
    
    % Design matrix for Conditions
    % Formal experiment matrix
    Conditions(:,1) = repmat (FlashNumArray',totaltrial/length(FlashNumArray),1);
    Conditions(:,2) = repmat (BeepNumArray',totaltrial/length(BeepNumArray),1);
    Conditions(:,3) = repmat (SOA_Array',totaltrial/length(SOA_Array),1);
    % Adding catch trials
    Conditions = [Conditions; zeros(catchtrial,3)];
    Total_Trial = size(Conditions, 1);
    Conditions = Conditions(randperm(Total_Trial),:); % randomize the trial order
    
    % Practice trial setting
    Prac_totaltrial = 12;
    Prac_catchtrial = 2;
    Prac_Total_trial = Prac_totaltrial + Prac_catchtrial;
    Prac_nBlock = 2; %% changeable trial number per block
    Prac_trialPerBlock = Prac_Total_trial / Prac_nBlock;
    % Practice matrix
    Prac_Conditions(:,1) = repmat (FlashNumArray',Prac_totaltrial/length(FlashNumArray),1);
    Prac_Conditions(:,2) = repmat (BeepNumArray',Prac_totaltrial/length(BeepNumArray),1);
    Prac_Conditions(:,3) = repmat (SOA_Array',Prac_totaltrial/length(SOA_Array),1);
    % Adding catch trials
    Prac_Conditions = [Prac_Conditions; zeros(Prac_catchtrial,3)];
    Prac_Total_Trial = size(Prac_Conditions,1);
    Prac_Conditions = Prac_Conditions(randperm(Prac_Total_Trial),:);
    Prac_ActualTotal_Trial = Prac_Total_Trial; % 这一步操作是为了�?
    
    % Initialize data recording matrix
    RT = zeros(Total_Trial,1);
    Correct = zeros(Total_Trial,1);
    RTKey = zeros(Total_Trial,1);
    
    % Others
    KbName('UnifyKeyNames');
    spacekey = KbName('space');
    quit = KbName('q'); % setting interaction and quiting
    
    %% Visual stimuli
    % Preparation
    
    % Get the pixels / center coordinate / refreshrate
    [wPtr,rect] = Screen('OpenWindow', 0);
    % HideCursor; % 隐藏鼠标按键
    [Xpixels, Ypixels] = Screen('WindowSize', wPtr);
    refresh = Screen('FrameRate', wPtr);
    
    white = WhiteIndex(wPtr);
    black = BlackIndex(wPtr);
    grey = (white + black) / 2;
    ISI = 60/1000; 
    
    % Caculating pixel per degree
    pxlpdeg = (Xpixels/2)/rad2deg(atan((monitorwidth/2)/vdistance));
    
    % Fixation
    fixpixel = 0.4; % half size
    Xcoord = [-fixpixel*pxlpdeg + Xpixels/2, fixpixel * pxlpdeg + Xpixels/2, Xpixels/2, Xpixels/2];
    Ycoord = [Ypixels/2, Ypixels/2, -fixpixel * pxlpdeg + Ypixels/2, fixpixel * pxlpdeg + Ypixels/2];
    allCoords = [Xcoord; Ycoord];
    
    % The Flash disc
    
    %% Auditory stimuli
    % Parameters for leading
    Tone_frequency = 1000;
    sr = 44100; % sampling rate
    gateDur = 2/1000; %?? fade in/out; in seconds, instead of sudden burst
    stiDur = 7/1000; % stimulus on duration
    
    % generate formal stimuli  % how to make
    Tone = Soundgenerate(sr, Tone_frequency, stiDur, gateDur);
    for bn = 1:length(BeepNumArray)
        for soa = 1:length(SOA_Array)
            ISI = SOA_Array(soa)/1000 - Sti_Dur;
            Sound_ISI = zeros(1, round(ISI*sr));
            if BeepNumArray(bn) == 1
                eval(['Sound' num2str(BeepNumArray(bn)), num2str(SOA_Array(soa)), 
                    '=[Tone, Sound_ISI];'])
                eval(['Time' num2str(BeepNumArray(bn)), num2str(SOA_Array(soa)), 
                    '= stiDur + ISI;'])
            elseif BeepNumArray(bn) == 2
                eval(['Sound' num2str(BeepNumArray(bn)), num2str(SOA_Array(soa)), 
                    '=[Tone, Sound_ISI, Tone];'])
                eval(['Time' num2str(BeepNumArray(bn)), num2str(SOA_Array(soa)), 
                    '= stiDur + ISI + stiDur;'])
            end       
        end
    end
    
    InitializePsychSound(1);
    PsychPortAudio('close');
    pahandle = PsychPortAudio('Open', 3, [], 2, sr, 2);
    % PsychPortAudio('Volume', pahandle, 0.5); % 设置音量
    % open之后的输入参数是使用的设备，open之后第一个是指定设备编号，用ASIO虚拟声卡的时候就是用填ASIO的index2是mode默认即可�?
    % 3延迟设置�?1是尽量减少延迟，4是采样率�?1设备对应的采样率�?5是�?�道数�?�，sr也是ASIO对应的SR
    
    %% EXP -- Instruction
    
    Screen('FillRect', wPtr, grey);
    Screen('TextFont', wPtr, 'Arial');
    Screen('TextSize', wPtr, 30);
    Screen('TextStyle', wPtr, 1);
    % 不同按键对应的指导语
    if PressMapping_index == 1 %Z for 1 flash; M for 2 beat
        press_text = [ 'Please press ',SubPressArray(1),' button if you think it flashes once','. \n\n', ...
            'Please press ',SubPressArray(2),' button if you think it flashes twice','. \n\n\n', ...
            'Press ENTER to start. '];
    elseif PressMapping_index ==2
        press_text = [ 'Please press ',SubPressArray(2),' button if you think it flashes once','. \n\n', ...
            'Please press ',SubPressArray(1),' button if you think it flashes twice','. \n\n\n', ...
            'Press ENTER to start. '];     
    end
    DrawFormattedText(wPtr,press_text, 'center','center', black);
    Screen(wPtr,'Flip');
    KbWait;
    Screen('FillRect',wPtr,grey);
    when=Screen('Flip',wPtr);
    while KbCheck ; end   
    %% EXP -- Practice
    Prac_corr = 0;
    Prac_Numcatch = 0;
    for ptn = 1:Prac_ActualTotal_Trial
        picA = Screen('MakeTexture', wPtr, A);
        Screen('DrawTexture', wPtr, picA, [], imgCoords);
        when = Screen('Flip', wPtr, when+1); % ITI = 1s
        if Prac_Conditions(ptn, 1) ~= 0    % not catch trial
            eval(['sound = Sound', num2str(Prac_Conditions(ptn,1)), num2str(find(BeepNumArray == Prac_Conditions(ptn,2))) ';'])
            eval(['time = Time', num2str(Prac_Conditions(ptn,1)), num2str(find(BeepNumArray == Prac_Conditions(ptn,2))) ';'])
            PsychPortAudio('FillBuffer', pahandle, [sound;sound]);
            PsychPortAudio('Start', pahandle, 1, when);
%           DrawFormattedText(wPtr,'On beat or Off beat?', 'center', 'center', black);
%           [when, StimulusOnsetTime, FlipTimestamp]=Screen('Flip',wPtr,when+time+Qdelaytime);%声音播放完毕�?250ms后呈现问�?
            when = when + time;
        end
        % % Collect Key Input
        tic;
        WaitSecs(time);
        if Prac_Conditions(ptn, 1) == 0
            Prac_Numcatch = Prac_Numcatch + 1;
        end
        while 1
            [KeyIsDown, KeyTime, Keycode] = KbCheck;
            if Prac_Conditions(ptn, 1) == 0 % Catch trial's setting
                if KeyIsDown
                    DrawFormattedText(wPtr, 'Wrong', 'center', 'center', [255 0 0]);
                    when = Screen('Flip', wPtr);
                    Screen('FillRect', wPtr, grey);
                    when = Screen('Flip', wPtr, when + 0.2);
                    break;
                elseif ~KeyIsDown
                    if toc > ctResponseTime
                        break;
                    end
                end
            elseif Prac_Conditions(ptn, 1) ~= 0
                if KeyIsDown
                    if Keycode(quit)
                        Screen('CloseAll');
                        ShowCursor;
                        break;
                    end
                    % if real trial, collect the response; why the ~
                    if Keycode(KbName(SubPressArray(1)) ) && ( ~ Keycode( KbName(SubPressArray(2)) ))
                        % check accuracy
                        if Prac_Conditions(ptn, 2) == 1
                            DrawFormattedText(wPtr, 'Correct', 'center', black);
                            when = Screen('Flip', wPtr);
                            Prac_corr = Prac_corr + 1;
                            Screen('FillRect', wPtr, grey);
                            when = Screen('Flip', wPtr, when + 0.2);
                            break;
                        elseif
                            Prac_Conditions(ptn, 2) ~=1
                            DrawFormattedText(wPtr, 'Wrong', 'center', 'center', [255 0 0]);
                            when = Screen('Flip', wPtr);
                            Screen('FillRect', wPtr, grey);
                            when = Screen('Flip', wPtr, when + 0.2); 
                            break;
                        end
                    elseif Keycode( KbName(SubPressArray(2)) ) && ( ~ Keycode( KbName(SubPressArray(1)) ) ) % press button for Off beat
                          % check accuracy
                        if Prac_Conditions(ptn, 2) ~= 1
                            DrawFormattedText(wPtr, 'Correct', 'center', black);
                            when = Screen('Flip', wPtr);
                            Prac_corr = Prac_corr + 1;
                            Screen('FillRect', wPtr, grey);
                            when = Screen('Flip', wPtr, when + 0.2);
                            break;
                        elseif
                            Prac_Conditions(ptn, 2) ==1
                            DrawFormattedText(wPtr, 'Wrong', 'center', 'center', [255 0 0]);
                            when = Screen('Flip', wPtr);
                            Screen('FillRect', wPtr, grey);
                            when = Screen('Flip', wPtr, when + 0.2); 
                            break;
                        end  
                    end
                end
            end
        end
    end
    
        %% Exp -- Formal exp
        % Intro
        Screen('FillRect', wPtr, grey);
        DrawFormattedText(wPtr, press_text, 'center', 'center', black);
        Screen(wPtr, 'Flip');
        WaitSecs(0.5);
        KbWait;
        Screen('FillRect', wPtr, grey);
        when = Screen('Flip', wPtr);
        While KbCheck ; end
        Exp_corr = 0;
        Numcatch = 0;