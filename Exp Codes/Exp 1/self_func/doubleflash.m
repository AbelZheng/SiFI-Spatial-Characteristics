try
%% %%%%%%%% General Settings %%%%%%%%%%%%%%
    % initiation
    clear all;
    clc;
    commandwindow;
    Screen('Preference', 'SkipSyncTests', 2);%0
    KbName('UnifyKeyNames');
    addpath('self_func');
    addpath('Instructions');
    rng('Shuffle'); % shuffle the randome number seed every time when matlab restarts
    
    %% Screen Properties
    % monitor
    ScreenNumber = max(Screen('Screens'));
    [ResX, ResY] = Screen('WindowSize',ScreenNumber);
    
    Cen_X = ResX/2;
    Cen_Y = ResY/2;
    background_color = [0 0 0]; %black
    white = [255 255 255];
    monitorwidth = 56;  % Width of the monitor in cm
    vdistance = 50;     % Visual distance in cm
    
    % Caculating pixel per degree
    pxlpdeg = (ResX/2)/rad2deg(atan((monitorwidth/2)/vdistance));
    
    RespDur = 2.5; % How long participants can respond in a trial
    
    % Open initial screen and initiate OpenGL for faster drawing
    AssertOpenGL;
    [wPtr,screenRect] = Screen('OpenWindow',ScreenNumber,background_color,[],[],2);
    Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    slack = Screen('GetFlipInterval',wPtr)/2; % minus a slack when calculating time points
    refresh = Screen('FrameRate', wPtr);     % get the refresh rate of Screen in Hz.
    HideCursor;    
    
    %% Basic Parameters
    FlashNumArray = [1, 2];
    flash_ISI = 100/1000;
    flash_on = 30/1000;
    rlength = 50;
    flash_rect = [Cen_X - rlength, Cen_Y - rlength, Cen_X + rlength, Cen_Y + rlength];
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
    
    %% Design matrix for Conditions
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
    Prac_ActualTotal_Trial = Prac_Total_Trial; % 
    
    % Others

    
    %% Visual Setup
    % screen
    screens = Screen('Screens');
    screenNumber = max(screens);
    [wPtr, rectsize] = Screen('OpenWindow', ScreenNumber, background_color, [], [], 2);
    HideCursor;
    InitializeMatlabOpenGL;
    
    %% Key
    KbName('UnifyKeyNames');
    spacekey = KbName('space');
    quit = KbName('q'); % setting interaction and quiting
    PressCodeArray = ['Z', 'M'];
    SubPressArray = PressCodeArray([1 2]);
    % Z for once; M for Twice
    
%% %%%%%%%% Presentation %%%%%%%%
    
    %% Start Block
    % Initialize data recording matrix
    RT = zeros(Total_Trial,1);
    acc = zeros(Total_Trial,1);
    RTKey = zeros(Total_Trial,1);
    BlockStartTime = GetSecs;
    
    keyIsDown = 0;
    [keyIsDown, keyTime, keyCode] = KbCheck;
    
    %% Stimuli setup
    tn = 7;
    Conditions(7,:) = [2, 1, 10];
    FlashN = Conditions(tn, 1);
    
    cross = MakeCross(wPtr,0.05,0.8,pxlpdeg,[128 128 128],[0 0 0]); % fixation
    redcross = MakeCross(wPtr,0.05,0.8,pxlpdeg,[255 0 0],[0 0 0]); % red fixation
    %% Stimuli presentation
    % cross
    Screen('DrawTexture', wPtr, cross);
    ITI = 1;
    vbl = Screen(wPtr, 'Flip');
    
    
   if FlashN == 2
        Screen('FillOval', wPtr, white, flash_rect);
        onset_t = Screen('Flip', wPtr, vbl + ITI - slack);
        vbl = Screen('Flip', wPtr, onset_t + flash_on - slack);
        Screen('FillOval', wPtr, white, flash_rect);
        onset_t = Screen('Flip', wPtr, vbl + flash_ISI - slack);
        vbl = Screen('Flip', wPtr, onset_t + flash_on - slack);
        WaitSecs(1);
   elseif FlashN == 1
        Screen('FillOval', wPtr, white, flash_rect);
        onset_t = Screen('Flip', wPtr, vbl + ITI - slack);
        vbl = Screen('Flip', wPtr, onset_t + flash_on - slack);
        WaitSecs(1);
   elseif FlashN == 0
        onset_t = Screen('Flip', wPtr, vbl + ITI - slack);
        vbl = Screen('Flip', wPtr, onset_t + 2 - slack);
        WaitSecs(1);         
   end
    
   Screen('FillOval', wPtr, white, [1000, 600, 1792, 1120]);
   Screen('Flip', wPtr);
   WaitSecs(2);

    
   %% 
   
    Screen('CloseAll');
    ShowCursor;
    
    
    
catch error
    Screen('CloseAll');
   % PsychPortAudio('Close',pahandle);
    rethrow(error);
end