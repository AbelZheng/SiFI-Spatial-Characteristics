
%%%%%%%% Project DFI Exp2 %%%%%%%%%%%%%%%

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

    rest_num = 50;
    rest_minimun = 30; % units: s

    % Matrix parameters
    BeepArray = [0, 1, 2]; FlashArray = [1, 2, 3];
    SOAArray = [30, 60]; 
    PositionArray = [-60, -45, -30, -15, 0, 15, 30, 45, 60];
    PositionIndexArray = [1:length(PositionArray)]; % Easier for locating and calculating
    conditionptrial = 15; keytrialnum = conditionptrial*length(PositionIndexArray)*length(SOAArray)*2;
    alltrialnum = keytrialnum / 0.6;
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
    %   [30, 60] SOA between two successive stimuli in the same modality

    % Construct keytrial conditions
    keyConditions = [repelem([1:2], keytrialnum/2)', repelem([2,1],keytrialnum/2)',...
        repelem([PositionIndexArray, PositionIndexArray], keytrialnum/(length(PositionIndexArray)*2))',...
        repmat(SOAArray',keytrialnum/2,1)];

    % Add filler trials
    fillerConditions = [repelem(FlashArray, length(BeepArray))', repmat(BeepArray',length(FlashArray),1)];
    fillerConditions = fillerConditions(fillerConditions(:,1)~=fillerConditions(:,2),:);
    fillerConditions = [repmat(fillerConditions, 50, 1); zeros(10, 2)];
    fillerConditions(:,3) = PositionIndexArray(randi(numel(PositionIndexArray),1,length(fillerConditions)));
    fillerConditions(:,4) = SOAArray(randi(numel(SOAArray),1,length(fillerConditions)));

    % Combine all
    Conditions = [keyConditions; fillerConditions];
    Conditions = Conditions(randperm(length(Conditions)),:);
    FormalConditions = Conditions;

    % Generate practice trials and make sure there is one catch trial for demostration
    PracConditions = Conditions(randi(length(Conditions),practrialnum-1,1),:);
    PracConditions(end+1,:) = [0,0,5,30];
    PracConditions = PracConditions(randperm(length(PracConditions)),:);


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
    [width, height]=Screen('DisplaySize', wPtr);
%     pxlpdg = deg2pix(1,sqrt(width^2+height^2)/25.4,ResX,vdist,ResY/ResX); % calculate pixel per degree
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

    Response_text = 'Respond Now';
    Rest_text = 'Take a rest now!';
    Rest_over_text = 'Press key to continue.';
    
    Screen(wPtr,'TextSize', 30);
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
    DrawTextAt(wPtr, 'Click to start presentation!', ResX/2, ResY/2, white);
    vbl = Screen(wPtr, 'Flip');
    GetClicks;

    %% Prac_Presentation
    % additionally present accuracy rate
    
    pass_prac = 0;

    while pass_prac < 1
        Conditions = PracConditions;
        presentationtrials = length(PracConditions);
        Prac_Responses_Collected = zeros(presentationtrials, 3) * (-1); % -1 indicating unanswered
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
            while Flashn - 1 > 0
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
                    Prac_Responses_Collected(tn, 1) = 0;
                    Prac_Responses_Collected(tn, 3) = currTime - pre_over_time;
                    Screen('Flip', wPtr);
                    break;
                end

                % Regularly check keyborad
                KeyIsDown = 0;
                [KeyIsDown, KeyTime, KeyCode]  = KbCheck;

                if KeyIsDown
                    Screen('Flip', wPtr);
                    Prac_Responses_Collected(tn,3) = KeyTime - pre_over_time;

                    if KeyCode(escape)  % exit the experiment
                        Screen('CloseAll');
                        ShowCursor;
                        break;
                    end

                    if KeyCode(KbName(SubPressArray(1))) && (~ KeyCode(KbName(SubPressArray(2))))  % press button for visual target comes first
                        Prac_Responses_Collected(tn,1) = KbName(SubPressArray(1));
                        Prac_Responses_Collected(tn,2) = 1;
                        break;
                    elseif KeyCode(KbName(SubPressArray(2))) && (~ KeyCode(KbName(SubPressArray(1)))) % press button for audio target comes first
                        Prac_Responses_Collected(tn,1) = KbName(SubPressArray(2));
                        Prac_Responses_Collected(tn,2) = 2;
                        break;
                    end

                    if KeyCode(blank)
                        Prac_Responses_Collected(tn,1) = blank;
                        Prac_Responses_Collected(tn,2) = 3;
                        break;
                    end

                    commandwindow;
                end

            end

            Screen('Flip', wPtr, currTime + ITI + rand/2 - slack);
        end

        
        Prac_Accuracy = (Prac_Responses_Collected(:,2) == PracConditions([1:presentationtrials],1));

        Screen(wPtr,'TextSize', 40);
        DrawTextAt(wPtr, 'Practice is fiinshed.', ResX/2, ResY/4, white);
        DrawFormattedText(wPtr)
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
        
    end


    

    %% Formal_Presentation
    Conditions = FormalConditions;
    presentationtrials = 101; %length(Conditions); % or loop through all trials
    Responses_Collected = zeros(presentationtrials, 3) * (-1); % -1 indicating unanswered
    % Set up response matrix for collection
    % 1st row: Response key; 2nd row: Accurate, 0-wrong 1-right
    % 3rd row: Reaction time
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
        while Flashn - 1 > 0
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

    Screen(wPtr,'TextSize', 40);
    DrawTextAt(wPtr, 'Click to exit!', ResX/2, ResY/2, white);
    vbl = Screen(wPtr, 'Flip');
    GetClicks;


    Screen('CloseAll');
    PsychPortAudio('close'); 
    ShowCursor;


    Accuracy = (Responses_Collected(:,2) == Conditions([1:presentationtrials],1));

    %% Save data to format
catch error

    PsychPortAudio('close'); 
    Screen('CloseAll');
    ShowCursor;
    rethrow(error);
    %% Save data to format when break

end





function DrawTextAt(w,txt,x,y,color)
%draw text with center at x,y
%get BoundsRect
bRect= Screen('TextBounds', w,txt);
Screen('DrawText',w,txt,x-bRect(3)/2,y-bRect(4)/2,color);
end


function pixs=deg2pix(degree,inch,pwidth,vdist,ratio) 
% parameters: degree, inch (monitor size), pwidth (width in pixels), 
% vdist: viewsing distance
% ratio: ration = pheight/pwidth 高宽比
screenWidth = inch*2.54/sqrt(1+ratio^2);  
pix=screenWidth/pwidth; 
pixs = round(2*tan((degree/2)*pi/180) * vdist / pix); 
end

