%%%%%%%% Project DFI Exp3-1 formal exp%%%%%%%%%%%%%%%
% 1007
%% %%%%%%%% General Settings %%%%%%%%%%%%%%
% initiation
if ~exist('DFI3_1_data/') %
    mkdir DFI3_1_data
    mkdir DFI3_1_data/subinfo/
end
if ~exist('DFI3_1_data/subinfo/') %
    mkdir DFI3_1_data/subinfo/
end

%% %%%%%%%% Collect Subject Info %%%%%%%%%%%%%%
clear; clc; close all;
addpath('__self_func__');
addpath("__self_func__/Materials/");
rng('shuffle'); % shuffle the randome number seed every time when matlab restarts
[SubID,SubName,SubAge,SubGender,Handedness] = greeting();
disp(['Hello, ' SubName '!']);
save(['DFI3_1_data/subinfo/' num2str(SubID) '_' SubName '.mat'],...
    'SubID','SubName','SubAge','SubGender','Handedness');
PressMapping_index = mod(SubID, 2) + 1;

%% %%%%%%%% Main Procedure %%%%%%%%%%%%%%
try
    %% %%%%%%%% Designs %%%%%%%%%%%%%%%%%%%%%%%%%
    % Parameters
    flash_ISI = 42/1000;
    flash_on = 14/1000;
    cueDur = 300/1000;
    cuesgap = 500/1000;
    rlength = 1; % degree

    ITI = 500/1000; % units:ms
    fixation_dur = 500/1000; % units:ms

    % Matrix parameters
    TargetArray= [1, 2]; InducerArray = [0, 1, 2, 3, 4];
    ISI_level_Array = [3, 1, 1, 3];

    %%%%%%%%%% Design Matrix %%%%%%%%%%%%%%%%%
    % The first column indicates target position:
    %   1-left, 2-right
    % The second column indicates the Target number:
    %   [1, 2] also in catch trial [0, 3]
    % The third column indicates the Inducer number :
    %   [0, 1, 2, 3, 4]
    % The fourth column indicates the SOA :
    %   [1, 2] Inducer ahead of I-T pair, [3, 4] later than I-T pair
    %   only works in fusion or fission trials, that is 2T1I or 1T2I

    % Construct conditions
    trialpcond = 16;
    fission_t = genDFItrials(2,[1],[2],4);
    fusion_t = genDFItrials(2,[2],[1],4);
    formal_t = genDFItrials(2,[1,2],[0,1,2,3,4],1);
    idx = find(((formal_t(:,2) == 1) & formal_t(:,3) == 2) | ((formal_t(:,2) == 2) & formal_t(:,3) == 1));
    catch_t = genDFItrials(2, [0, 3], [0,1,2,3,4], 1);
    formal_t(:,4) = 0; formal_t(idx,:) = []; catch_t(:,4) = 0;
    Formal_Conditions = repmat([fission_t ; fusion_t; formal_t],trialpcond,1);
    Formal_Conditions = [Formal_Conditions; repmat(catch_t,8,1)];
    total_trial_num = length(Formal_Conditions);
    Formal_Conditions = Formal_Conditions(randperm(total_trial_num),:);

    %% %%%%%%%%%%% Visual Setup %%%%%%%%%%%%%%%%%%%
    % Open up a Screen
    Screen('Preference', 'SkipSyncTests', 1);
    ScreenNumber = max(Screen('Screens')); % count the screens
    AssertOpenGL;
    InitializeMatlabOpenGL;

    % Initiating Visual Display
    background_color = [127 ,127, 127]; % gray background
    [w, Rect] = Screen('OpenWindow',ScreenNumber,background_color);
    [cx, cy] = RectCenter(Rect); % get the center point
    white = WhiteIndex(w); black = BlackIndex(w);
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [ResX, ResY] = Screen('WindowSize',w);
    [width, height]=Screen('DisplaySize', w);
    flipIntv = Screen('GetFlipInterval',w);
    slack = flipIntv / 2;
    vdist = 60; % set visual distance as 50 cm
    pxlpdg = deg2pix(1,sqrt(width^2+height^2)/25.4,ResX,vdist,ResY/ResX); % calculate pixel per degree
    HideCursor;
    ListenChar(2);

    % Keys&Text
    KbName('UnifyKeyNames');
    escape= KbName('escape');
    blank = KbName('space');
    next = KbName('Y');
    prac_again = KbName('P');

    SubPressType =  [ 1 2;...    % 2 X 2 matrix
        2 1];
    PressCodeArray = {'Z', '/?'};
    SubPressArray = PressCodeArray(SubPressType(PressMapping_index,:));
    key_1 = KbName(SubPressArray{1});
    key_2 = KbName(SubPressArray{2});

    Intro_text = 'Press key to start.';
    Rest_text = 'Take a rest now!';
    Rest_over_text = 'Press key to continue.';

    Screen('TextFont',w,'Arial');
    Screen(w,'TextStyle',1); % 1bold text;0normal

    %% Draw Stimulus
    % Draw gradients
    canvas = drawgradient(rlength, pxlpdg, 127);
    gradient_canvas = Screen('MakeTexture',w,canvas);

    % Draw fixation
    fixsize = 2;
    cross = MakeCross(w,0.05,1,pxlpdg,[255, 255, 255],[127, 127, 127]);
    red_cross = MakeCross(w,0.05,1,pxlpdg,[255, 0, 0],[127, 127, 127]);

    % Locating target positions
    TargetRects = [];
    PositionArray = [-7, 7];
    radius = rlength * pxlpdg ; sidelength = 2 * radius;
    for i = 1:length(PositionArray)
        xc_i = ResX/2 + PositionArray(i)*pxlpdg;
        targetRect = CenterRectOnPoint([0 0 sidelength sidelength], xc_i, ResY/2);
        TargetRects = [TargetRects; targetRect];
    end
    TargetLorR = [ 1, 2; 2, 1];


    %% Instruction
    Screen(w,'TextSize', 50);
    DrawTextAt(w, 'Welcome!', ResX/2, ResY/4, white);
    DrawTextAt(w, 'Click to start experiment!', ResX/2, ResY/2, white);
    vbl = Screen(w, 'Flip');
    GetClicks;
    instruction_img_file = sprintf('__self_func__/Materials/instruction-%d.png', PressMapping_index);
    instruction_img = imread(instruction_img_file);
    instruction_text = Screen(w, 'MakeTexture', instruction_img);
    Screen(w, 'DrawTexture', instruction_text);
    vbl = Screen(w, 'Flip');
    KeyIsDown = 0;
    while true
        [KeyIsDown, ~, KeyCode] = KbCheck;
        if KeyIsDown && KeyCode(blank)
            break; end;
        if KeyIsDown && KeyCode(escape)
            Screen('CloseAll'); ShowCursor; break; end;
    end

    %% Prac Exp
    prac_done = 0;
    while ~prac_done
        % Construct a 10-trial-prac-exp
        Prac_Conditions = Formal_Conditions(randperm(total_trial_num, 10),:);
        presentationtrials = length(Prac_Conditions(:,1));
        exitFlag = false;
        Prac_Resp = zeros(presentationtrials,5);
        Prac_Resp(:,1) = -1;
        % 1-resp_num; 2-RT; 3-Tar_num; 4-Ind_num; 5-T/F;
        for ptn = 1:presentationtrials
            if exitFlag
                Screen('CloseAll');
                ShowCursor;
            end
            Tarpos = Prac_Conditions(ptn, 1);
            TarRect = TargetRects(TargetLorR(Tarpos,1),:);
            IndRect = TargetRects(TargetLorR(Tarpos,2),:);
            TargetFlash = Prac_Conditions(ptn, 2);
            InducerFlash = Prac_Conditions(ptn, 3);
            Prac_Resp(ptn,3:4) = [TargetFlash, InducerFlash];

            vbl = Screen(w, 'Flip'); % timing starts
            %%%%%%% Presentation %%%%%%%%%%%
            % Draw Fixation
            Screen('DrawTexture', w, cross);
            trial_start_time = Screen('Flip',w); % Presentation starts

            % Draw cue
            Screen('FrameRect', w, white, TarRect, 3);
            vbl = Screen('Flip', w, trial_start_time + fixation_dur - slack);
            Screen('FillRect', w, background_color);
            vbl = Screen('Flip', w, vbl + cueDur - slack);
            WaitSecs(cuesgap);

            % Flash Prep & Presentation
            while (TargetFlash>0) || (InducerFlash>0)
                % Prepare flash
                if TargetFlash > 0
                    Screen('DrawTexture', w, gradient_canvas, [], TarRect); end;
                if InducerFlash > 0
                    Screen('DrawTexture', w, gradient_canvas, [], IndRect); end;
                vbl = Screen('Flip', w);
                vbl = Screen('Flip', w, vbl + 3*flash_on - slack);
                vbl = Screen('Flip', w, vbl + 3*flash_ISI - slack);
                TargetFlash = TargetFlash - 1; InducerFlash = InducerFlash - 1;
            end

            %%%%%%% Response Collection %%%%%%%%%%%
            vbl = Screen('Flip', w, vbl + 0.05 - slack);
            Screen('DrawTexture', w, red_cross);
            t_start = Screen('Flip', w);

            keyIsDown = 0; prac_res = 0;
            while ~exitFlag && (GetSecs()-t_start) <= 3
                [keyIsDown, ~, keyCode] = KbCheck;
                if keyCode(escape); exitFlag = true; end
                if keyCode(key_1)
                    prac_res = 1; break;
                elseif keyCode(key_2)
                    prac_res = 2; break;
                elseif keyCode(blank)
                    prac_res = 3; break;
                end
            end
            prac_RT = GetSecs()-t_start;
            Prac_Resp(ptn,[1,2,5]) = [prac_res, prac_RT, prac_res == Prac_Conditions(ptn, 2)];
            vbl = Screen('Flip', w);

            % Feedback
            if prac_res == Prac_Conditions(ptn, 2)
                DrawTextAt(w,'Right!',ResX/2, ResY/4, white);
            else
                DrawTextAt(w,'Wrong!',ResX/2, ResY/4, white);
            end

            % ITI
            vbl = Screen('Flip', w);
            WaitSecs(ITI + 0.5*rand);
            vbl = Screen('Flip', w);
        end
        DrawTextAt(w, 'Congratulations!', ResX/2, ResY/2 - 100, white);
        DrawTextAt(w, 'You have finished the practice!',ResX/2, ResY/2, white);
        DrawTextAt(w, 'Continue to formal experiment?',ResX/2, ResY/4 + 100, white);
        vbl = Screen('Flip',w);
        KeyIsDown = 0;
        while true
            [KeyIsDown, ~, KeyCode] = KbCheck;
            if KeyIsDown && KeyCode(prac_again)
                vbl = Screen('Flip', w);
                break;
            end
            if KeyIsDown && KeyCode(escape)
                Screen('CloseAll'); ShowCursor; break;
            end
            if KeyIsDown && KeyCode(next)
                vbl = Screen('Flip', w);
                prac_done = 1;
                break;
            end
        end
    end
    %% Formal Exp
    vbl = Screen('Flip',w);
    DrawTextAt(w, 'Get ready for the formal test...',ResX/2, ResY/4, white);
    DrawTextAt(w, 'Press Space to start!',ResX/2, ResY/2, white);
    vbl = Screen('Flip',w);
    KeyIsDown = 0;
    while true
        [KeyIsDown, ~, KeyCode] = KbCheck;
        if KeyIsDown && KeyCode(blank)
            break; end;
        if KeyIsDown && KeyCode(escape)
            Screen('CloseAll'); ShowCursor; break;
        end
    end
    presentationtrials = length(Formal_Conditions);
    Resp = zeros(presentationtrials, 6);
    Resp(:,1) = -1;
    exitFlag = false;
    % 1-resp_num; 2-RT; 3-Tar_num; 4-Ind_num; 5-T/F; 6-ISI_level
    for tn = 1:presentationtrials
        if exitFlag
            ListenChar(0);
            ShowCursor;
            Screen('CloseAll');
        end
        Tarpos = Formal_Conditions(tn, 1);
        TarRect = TargetRects(TargetLorR(Tarpos,1),:);
        IndRect = TargetRects(TargetLorR(Tarpos,2),:);
        TargetFlash = Formal_Conditions(tn, 2);
        InducerFlash = Formal_Conditions(tn, 3);
        Resp(tn,[3,4,6]) = [TargetFlash, InducerFlash, Formal_Conditions(tn, 4)];

        vbl = Screen(w, 'Flip'); % timing starts

        %%%%%%% Presentation %%%%%%%%%%%
        % Draw Fixation
        Screen('DrawTexture', w, cross);
        trial_start_time = Screen('Flip',w); % Presentation starts
        % Draw cue
        Screen('FrameRect', w, white, TarRect, 3);
        vbl = Screen('Flip', w, trial_start_time + fixation_dur - slack);
        Screen('FillRect', w, background_color);
        vbl = Screen('Flip', w, vbl + cueDur - slack);
        WaitSecs(cuesgap);

        % Flash Prep & Presentation
        if Formal_Conditions(tn, 4) == 0
            while (TargetFlash>0) || (InducerFlash>0)
                % Prepare flash
                if TargetFlash > 0
                    Screen('DrawTexture', w, gradient_canvas, [], TarRect);
                end
                if InducerFlash > 0
                    Screen('DrawTexture', w, gradient_canvas, [], IndRect);
                end
                vbl = Screen('Flip', w);
                vbl = Screen('Flip', w, vbl + flash_on - slack);
                TargetFlash = TargetFlash - 1; InducerFlash = InducerFlash - 1;
                if (TargetFlash>0) || (InducerFlash>0)
                    vbl = Screen('Flip', w, vbl + flash_ISI - slack); end
            end
        else
            if Formal_Conditions(tn, 4) > 2
                if (TargetFlash == 2) && (InducerFlash == 1)
                    Screen('DrawTexture', w, gradient_canvas, [], TarRect);
                    Screen('DrawTexture', w, gradient_canvas, [], IndRect);
                    vbl = Screen('Flip', w);
                    vbl = Screen('Flip', w, vbl + flash_on - slack);
                    vbl = Screen('Flip', w, vbl + ...
                        ISI_level_Array(Formal_Conditions(tn, 4)) * flash_ISI - slack);
                    Screen('DrawTexture', w, gradient_canvas, [], TarRect);
                    vbl = Screen('Flip', w);
                    vbl = Screen('Flip', w, vbl + flash_on - slack);
                elseif (TargetFlash == 1) && (InducerFlash == 2)
                    Screen('DrawTexture', w, gradient_canvas, [], TarRect);
                    Screen('DrawTexture', w, gradient_canvas, [], IndRect);
                    vbl = Screen('Flip', w);
                    vbl = Screen('Flip', w, vbl + flash_on - slack);
                    vbl = Screen('Flip', w, vbl + ...
                        ISI_level_Array(Formal_Conditions(tn, 4)) * flash_ISI - slack);
                    Screen('DrawTexture', w, gradient_canvas, [], IndRect);
                    vbl = Screen('Flip', w);
                    vbl = Screen('Flip', w, vbl + flash_on - slack);
                end
            else
                if (TargetFlash == 2) && (InducerFlash == 1)
                    Screen('DrawTexture', w, gradient_canvas, [], TarRect);
                    vbl = Screen('Flip', w);
                    vbl = Screen('Flip', w, vbl + flash_on - slack);
                    vbl = Screen('Flip', w, vbl + ...
                        ISI_level_Array(Formal_Conditions(tn, 4)) * flash_ISI - slack);
                    Screen('DrawTexture', w, gradient_canvas, [], TarRect);
                    Screen('DrawTexture', w, gradient_canvas, [], IndRect);
                    vbl = Screen('Flip', w);
                    vbl = Screen('Flip', w, vbl + flash_on - slack);
                elseif (TargetFlash == 1) && (InducerFlash == 2)
                    Screen('DrawTexture', w, gradient_canvas, [], IndRect)
                    vbl = Screen('Flip', w);
                    vbl = Screen('Flip', w, vbl + flash_on - slack);
                    vbl = Screen('Flip', w, vbl + ...
                        ISI_level_Array(Formal_Conditions(tn, 4)) * flash_ISI - slack);
                    Screen('DrawTexture', w, gradient_canvas, [], TarRect);
                    Screen('DrawTexture', w, gradient_canvas, [], IndRect);
                    vbl = Screen('Flip', w);
                    vbl = Screen('Flip', w, vbl + flash_on - slack);
                end
            end
        end

        %%%%%%% Response Collection %%%%%%%%%%%
        vbl = Screen('Flip', w, vbl + 0.05 - slack);
        Screen('DrawTexture', w, red_cross);
        t_start = Screen('Flip', w);

        keyIsDown = 0; res = 0;
        while ~exitFlag && (GetSecs()-t_start) <= 3
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyCode(escape); exitFlag = true; end
            if keyCode(key_1)
                res = 1; break;
            elseif keyCode(key_2)
                res = 2; break;
            elseif keyCode(blank)
                res = 3; break;
            end
        end
        RT = GetSecs()-t_start;
        Resp(tn,[1,2,5]) = [res, RT, res == Formal_Conditions(tn, 2)];
        vbl = Screen('Flip', w);

        % ITI
        vbl = Screen('Flip', w);
        
        % Take a rest
        if mod(tn,84) == 0
            DrawTextAt(w, Rest_text, ResX/2, ResY/2, white);
            process_txt = sprintf('%d / 8 done...', fix(tn/84));
            DrawTextAt(w, process_txt, ResX/2, ResY/4, white);
            vbl = Screen('Flip',w);
            WaitSecs(30);
            DrawTextAt(w, Rest_over_text, ResX/2, ResY/2, white);
            vbl = Screen('Flip',w);
            KeyIsDown = 0;
            while true
                [KeyIsDown, ~, KeyCode] = KbCheck;
                if KeyIsDown && KeyCode(blank)
                    break;s
                end
                if KeyIsDown && KeyCode(escape)
                    Screen('CloseAll'); ShowCursor; break;  
                end
            end
        end

        WaitSecs(ITI + 0.5*rand);


    end

    Screen('CloseAll');
    ListenChar(0);
    ShowCursor;

    save(['DFI3_1_data/Sub_',num2str(SubID),'.mat'],'SubAge','SubGender','PressMapping_index', 'SubPressArray',...
        'Resp','Formal_Conditions');

catch error
    Screen('CloseAll');
    ListenChar(0);
    ShowCursor;
    rethrow(error);
    %% Save data to format when break
    save(['DFI3_1_data/DFI_error_Sub_',num2str(SubID),'.mat'],'SubAge','SubGender','PressMapping_index', 'SubPressArray',...
        'Resp','Formal_Conditions');
end



