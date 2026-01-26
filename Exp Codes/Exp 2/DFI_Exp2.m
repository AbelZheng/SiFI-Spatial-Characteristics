%%%%%%%% Project DFI Exp2 %%%%%%%%%%%%%%%
%%
if ~exist('DFI2_data/') % 在没有data/时建立新的文件夹
    mkdir DFI2_data
end
%%
try
    %% %%%%%%%% General Settings %%%%%%%%%%%%%%
    % initiation
    clear; clc; close all;
    commandwindow;
    addpath('__self_func__');
    rng('shuffle'); % shuffle the randome number seed every time when matlab restarts
    PressMapping_index = 1; % default for testing

    %% %%%%%%%% Collect Subject Info %%%%%%%%%%%%%%
    Prompt = {'Subject Number', 'Name', 'Age', 'Gender:(1 is for male, 2 for female)', 'Button mapping number'};
    DlgTitle = 'Personalia';
    Numlines = 1;
    Answer = inputdlg(Prompt, DlgTitle, Numlines);
    SubID = str2double(Answer{1});
    SubName = Answer{2};
    SubAge = str2double(Answer{3});
    SubGender = str2double(Answer{4});
    PressMapping_index = str2double(Answer{5});

    %% %%%%%%%% Designs %%%%%%%%%%%%%%%%%%%%%%%%%
    % Parameters
    flash_ISI = 50/1000;
    flash_on = 33/1000;
    cueDur = 500/1000;
    cuesgap = 500/1000;
    rlength = 2; % degree

    Tone_frequency = 2000;
    sr = 44100; % sampling rate 96000 for 1705; normally 44100; 48000 for behringer
    gateDur = 2/1000; %?? fade in/out; in seconds, instead of sudden burst
    stiDur = 10/1000; % stimulus on duration

    ITI = 1000/1000; % units:ms
    fixation_dur = 1000/1000; % units:ms

    rest_num = 5;
    rest_minimun = 1 ; % units: s

    % Matrix parameters
    BeepArray = [0, 1, 2]; FlashArray = [1, 2, 3];
    SOAArray = [30, 60]; 
    PositionArray = [-60, -45, -30, -15, 0, 15, 30, 45, 60];
    PositionIndexArray = [1:length(PositionArray)]; % Easier for locating and calculating
    conditionptrial = 12; keytrialnum = conditionptrial*length(PositionIndexArray)*length(SOAArray)*2;
    practrialnum = 10;

    %%%%%%%%%% Design Matrix %%%%%%%%%%%%%%%%%
    % The first column indicates the Flashnum :
    %   [0, 1, 2, 3] 0 is catch trial.
    % The second column indicates the Beepnum :
    %   [0, 1, 2]
    % The third column indicates the Stimuluspos :
    %   [ 1,   2,   3,   4, 5, 6,  7,  8,  9];
    %   [-30, -20, -10, -5, 0, 5, 10, 20, 30];
    % The fourth column indicates the SOA :
    %   [40, 70] SOA between two successive stimuli in the same modality

    % Construct keytrial conditions
    keyConditions = [repelem([1:2], keytrialnum/2)', repelem([2,1],keytrialnum/2)',...
        repelem([PositionIndexArray, PositionIndexArray], keytrialnum/(length(PositionIndexArray)*2))',...
        repmat(SOAArray',keytrialnum/2,1)];

    % Add filler trials
    fillerConditions_1 = zeros(180,4);
    fillerConditions_1(1:90,1) = 1;
    fillerConditions_1(91:180,1) = 2;
    fillerConditions_1(:,3) = repmat([1:9]',20,1);
    fillerConditions_1(91:180,4) = 70;

    fillerConditions_2 = zeros(270,4);
    fillerConditions_2(1:135,1:2) = 1;
    fillerConditions_2(136:270,1:2) = 2;
    fillerConditions_2(:,3) = repmat([1:9]',30,1);
    fillerConditions_2(136:270,4) = 70;

    fillerConditions_3 = zeros(225,4);
    fillerConditions_3(:,1) = 3;
    fillerConditions_3(:,2) = [repmat([0],45,1);repmat([1],90,1);repmat([2],90,1)];
    fillerConditions_3(:,3) = repmat([1:9]',25,1);
    fillerConditions_3(136:end,4) = 70;

    fillerConditions_4 = zeros(43,4);
    fillerConditions_4(:,2) = BeepArray(randi(3,43,1));

    % Combine all
    Conditions = [keyConditions; fillerConditions_1; fillerConditions_2; fillerConditions_3; fillerConditions_4];
%     Conditions = Conditions(randperm(length(Conditions)),:);
    FormalConditions = Conditions;

    % Generate practice trials and make sure there is one catch trial for demostration
    PracConditions = Conditions(randi(length(Conditions),practrialnum-1,1),:);
%     PracConditions(end+1,:) = [0,0,5,30];
%     PracConditions = PracConditions(randperm(length(PracConditions)),:);


    %% %%%%%%%%%%% Visual Setup %%%%%%%%%%%%%%%%%%%
    % Open up a Screen
    Screen('Preference', 'SkipSyncTests', 1);
    ScreenNumber = max(Screen('Screens')); % count the screens
    AssertOpenGL;
    InitializeMatlabOpenGL;

    % Initiating Visual Display
    background_color = [0 ,0, 0]; % black background
    [wPtr,Rect] = Screen('OpenWindow',ScreenNumber,background_color,[],[],2);
    white=WhiteIndex(wPtr); black=BlackIndex(wPtr);
    Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    slack = Screen('GetFlipInterval',wPtr)/2; % minus a slack when calculating time points
    HideCursor;
    [ResX, ResY] = Screen('WindowSize',wPtr);
    pxlpdg = round(ResX / 180); % the full screen has a wide range of 180 degrees    

    % Keys&Text
    KbName('UnifyKeyNames');
    escape= KbName('escape');
    blank = KbName('space');
    next = KbName('Y');
    prac_again = KbName('P');

    SubPressType =  [ 1 2;...    % 2 X 2 matrix
                      2 1];
    PressCodeArray = {'Z', '/?'};
    %PressMapping_index = 1;
    SubPressArray = PressCodeArray(SubPressType(PressMapping_index,:));

    Introduction_1_png = imread('instruction_1.png');
    Introduction_1 = Screen('MakeTexture', wPtr, Introduction_1_png);
    Introduction_2_png = imread('instruction_2.png');
    Introduction_2 = Screen('MakeTexture', wPtr, Introduction_2_png);
    Rest_text = 'Take a rest now!';
    Rest_over_text = 'Press key to continue.';
    
    Screen(wPtr,'TextSize', 40);
    Screen(wPtr,'TextFont', 'Arial');
    Screen(wPtr,'TextStyle',1); % 1-bold text;0-normal
    
    %% Draw Stimulus
    % Draw gradients
    radius = rlength * pxlpdg ; sidelength = 2 * radius; 
    [drawx, drawy] = meshgrid(1:sidelength,1:sidelength);
    drawxc = sidelength/2; drawyc  = sidelength/2;
    circle = ((drawx-drawxc).^2 + (drawy-drawyc).^2) < radius^2;
    filtered =  eval(sprintf('log10(sqrt((drawx-drawxc).^2 + (drawy-drawyc).^2)/10+1)'));
    canvas = ones(sidelength)*255;
    gradient = canvas.*(1-filtered);
    canvas(circle) = gradient(circle);
    canvas(canvas<0) = 0; canvas(~circle) = 0;
    gradient_canvas = Screen('MakeTexture',wPtr,canvas);

    % Draw fixation
    fixsize = 2;
    crl = fixsize*pxlpdg ; crw = 0.05*crl;
    crossrect = zeros(crl,crl);
    crossrect(:,:) = 0;
    crossrect(:,round(crl/2-crw/2):round(crl/2+crw/2)) = 255;
    crossrect(round(crl/2-crw/2):round(crl/2+crw/2),:) = 255;
    cross = Screen('MakeTexture',wPtr,crossrect);

    % Locating target positions
    TargetRects = [];
    for i = PositionIndexArray
        xc_i = ResX/2 + PositionArray(i)*pxlpdg;
        targetRect = CenterRectOnPoint([0 0 sidelength sidelength], xc_i, ResY/2);
        TargetRects = [TargetRects; targetRect];
    end

    %% Auditory setup
    InitializePsychSound(1);
    PsychPortAudio('Close'); % Make sure it was closed before reopening
    pahandle = PsychPortAudio('Open', [], [], 2, sr, 2); % find specific index

    % generate formal stimuli
    Tone = Soundgenerate(sr, Tone_frequency, stiDur, gateDur);

    %% Generate auditory stimuli
    for soa = SOAArray
        ISI = soa/1000 - stiDur;
        Sound_ISI = zeros(1, round(ISI*sr));
        for bn = BeepArray
            if bn
                soundi = repmat([Tone, Sound_ISI], 1, bn);
                eval([sprintf('sound_BN_%s_SOA_%s =',num2str(bn),num2str(soa)),'soundi;']);
            else
                soundblank = zeros(1,sr);
                eval([sprintf('sound_BN_%s_SOA_%s =',num2str(bn),num2str(soa)),'soundblank;'])
            end
        end
    end

    %% Instruction
    Screen(wPtr,'TextSize', 60);
    DrawTextAt(wPtr, 'Welcome!', ResX/2, ResY/4, white);
    DrawTextAt(wPtr, 'Click to start experiment!', ResX/2, ResY/2, white);
    vbl = Screen(wPtr, 'Flip');
    GetClicks;
    
    Screen(wPtr,'TextSize', 40);
    Screen('DrawTexture', wPtr, eval(['Introduction_',num2str(PressMapping_index)]));
    vbl = Screen(wPtr, 'Flip');

    KeyIsDown = 0;
    while true
        [KeyIsDown, ~, KeyCode] = KbCheck;
        if KeyIsDown && KeyCode(blank)
            break;
        end
    end

    %% Prac_Formal_Presentation
    pass_prac = 0; % entering which block

    while pass_prac < 2

        if pass_prac == 0 % prac_conditions
            PracConditions = PracConditions(randperm(length(PracConditions)),:);
            Conditions = PracConditions;
            presentationtrials = length(PracConditions);
            Responses_Collected = zeros(presentationtrials, 3) * (-1); % -1 indicating unanswered

        elseif pass_prac == 1 % formal_condition
            Conditions = FormalConditions;
            presentationtrials = 6 ; %length(Conditions); % or loop through all trials
            Responses_Collected = zeros(presentationtrials, 3) * (-1); % -1 indicating unanswered
            % Set up response matrix for collection
            % 1st row: Response key; 2nd row: Accurate, 0-wrong 1-right
            % 3rd row: Reaction time
        end

        Screen(wPtr,'TextSize', 70);

        for tn = 1:presentationtrials
            Flashn = Conditions(tn,1);

            vbl = Screen(wPtr, 'Flip'); % timing starts

            %%%%%%% Presentation %%%%%%%%%%%
            % Draw Fixation
            Screen('DrawTexture', wPtr, cross);
            trial_start_time = Screen('Flip',wPtr); % Presentation starts

            % Draw cue
            Screen('FrameRect', wPtr, white, TargetRects(Conditions(tn,3),:), 3);
            vbl = Screen('Flip', wPtr, trial_start_time + fixation_dur - slack);
            Screen('FillRect', wPtr, black);
            vbl = Screen('Flip', wPtr, vbl + cueDur - slack);

            % Prepare audio
            sound_on = eval([sprintf('sound_BN_%s_SOA_%s',num2str(Conditions(tn,2)),num2str(Conditions(tn,4)))]);
            commandwindow;
            PsychPortAudio('FillBuffer', pahandle, [sound_on;sound_on]);

            % Prepare flash
            if Flashn ~= 0
                Screen('DrawTexture', wPtr, gradient_canvas, [], TargetRects(Conditions(tn,3),:));
            end

            % Present
            WaitSecs(cuesgap);
            audio_on = PsychPortAudio('Start', pahandle, 1);
            vbl = Screen('Flip', wPtr, audio_on);

            Screen('FillRect', wPtr, black);
            vbl = Screen('Flip', wPtr, vbl + flash_on - slack);
            while Flashn - 1.5 > 0
                Screen('DrawTexture', wPtr, gradient_canvas, [], TargetRects(Conditions(tn,3),:));
                vbl = Screen('Flip', wPtr, vbl + flash_ISI - slack);
                Screen('FillRect', wPtr, black);
                vbl = Screen('Flip', wPtr, vbl + flash_on - slack);
                Flashn = Flashn - 1;
            end

            %%%%%%% Response %%%%%%%%%%%
            DrawTextAt(wPtr, 'X', ResX/2, 5*ResY/8, white);
            %         [auido_startTime, ~, ~, estStopTime] = PsychPortAudio('Stop', pahandle);
            %         response_onset = max(vbl, estStopTime);

            pre_over_time = GetSecs;

            if Conditions(tn,1) == 0
                WaitSecs(2);
            end


            while true
                currTime = GetSecs;

                if (currTime - pre_over_time) > 0.5
                    DrawTextAt(wPtr, 'X', ResX/2, 5*ResY/8, white);
                    Screen('Flip', wPtr);
                end

                if (currTime - pre_over_time) > 3
                    Responses_Collected(tn, 1) = 0;
                    Responses_Collected(tn, 2) = 0;
                    Responses_Collected(tn, 3) = currTime - pre_over_time;
                    Screen('Flip', wPtr);
                    break;
                end

                % Regularly check keyborad
                KeyIsDown = 0;
                [KeyIsDown, KeyTime, KeyCode]  = KbCheck;

                if KeyIsDown
                    Screen('Flip', wPtr);
                    Responses_Collected(tn,3) = KeyTime - pre_over_time;

                    if KeyCode(escape)  % exit the experiment
                        Screen('CloseAll');
                        ShowCursor;
                        break;
                    end

                    if KeyCode(KbName(SubPressArray(1))) && (~ KeyCode(KbName(SubPressArray(2))))  % press button for visual target comes first
                        Responses_Collected(tn,1) = KbName(SubPressArray(1));
                        Responses_Collected(tn,2) = 1;
                        break;
                    elseif KeyCode(KbName(SubPressArray(2))) && (~ KeyCode(KbName(SubPressArray(1)))) % press button for audio target comes first
                        Responses_Collected(tn,1) = KbName(SubPressArray(2));
                        Responses_Collected(tn,2) = 2;
                        break;
                    end

                    if KeyCode(blank)
                        Responses_Collected(tn,1) = blank;
                        Responses_Collected(tn,2) = 3;
                        break;
                    end

                    commandwindow;
                end

            end

            Screen('Flip', wPtr, currTime + ITI + rand/2 - slack);

            if mod(tn,rest_num) == 0
                Screen(wPtr,'TextSize', 40);
                DrawTextAt(wPtr, Rest_text, ResX/2, 3*ResY/4, white);
                RestOnsetTime = Screen('Flip',wPtr); %“respond now”after every presentation
                DrawTextAt(wPtr, Rest_over_text, ResX/2, 3*ResY/4, white);
                Rest_overOnsetTime = Screen('Flip', wPtr, RestOnsetTime + rest_minimun - slack);
                KbWait;
                Screen(wPtr,'TextSize', 70);
                WaitSecs(0.5);
            end
        end
        
        if pass_prac == 0
            Prac_Responses = Responses_Collected;
            Prac_Accuracy = (Prac_Responses(:,2) == PracConditions([1:presentationtrials],1));

            Screen(wPtr,'TextSize', 40);
            DrawTextAt(wPtr, 'Practice is finished, please contact the instructor.', ResX/2, ResY/4, white);
            DrawTextAt(wPtr, sprintf('Your accuracy is %.2f.', mean(Prac_Accuracy)), ResX/2, ResY/4 + 100, white);
            vbl = Screen(wPtr, 'Flip');

            KeyIsDown = 0;
            while true
                [KeyIsDown, ~, KeyCode] = KbCheck;
                if KeyIsDown && KeyCode(next)
                    pass_prac = pass_prac + 1;
                    break;
                elseif KeyIsDown && KeyCode(prac_again)
                    break;
                end
            end

        elseif pass_prac == 1
            Formal_Responses = Responses_Collected;
            pass_prac = pass_prac + 1;
            Formal_Accuracy = (Formal_Responses(:,2) == FormalConditions([1:presentationtrials],1));
        end
        
    end

    Screen(wPtr,'TextSize', 40);
    DrawTextAt(wPtr, 'Click to exit!', ResX/2, ResY/2, white);
    vbl = Screen(wPtr, 'Flip');
    GetClicks;

    Screen('CloseAll');
    PsychPortAudio('close'); 
    ShowCursor;

    %% %%%%%%%% Save the data to format %%%%%%%%%%%%%%
    save(['DFI2_data/DFI_Sub',num2str(SubID),SubName,'.mat'],'SubAge','SubGender','PressMapping_index', 'SubPressArray',...
        'Formal_Responses','Formal_Accuracy');
    % SubPressArray:1-Z/; 2-/Z
catch error

    PsychPortAudio('close'); 
    Screen('CloseAll');
    ShowCursor;
    rethrow(error);
    %% Save data to format when break
    save(['DFI2_data/DFI_error_Sub',num2str(SubID),SubName,'.mat'],'SubAge','SubGender','PressMapping_index', 'SubPressArray',...
        'Prac_Responses','Prac_Accuracy','Responses_Collected');
end

