try
    %% General Settings
    clear all;
    clc;
    commandwindow;
    Screen('Preference', 'SkipSyncTests', 1);%0
    KbName('UnifyKeyNames');
    addpath('self_func');
    addpath('Instructions');
    rng('Shuffle'); % shuffle the randome number seed every time when matlab restarts
  
    %% Startup Questions and Data File %% always start from practice and informaion entering
    ProcChoice = questdlg('Prac or Exp?', ...
        'Procedure', 'Prac', 'Practice again', 'Prac');
    switch ProcChoice
        case 'Prac'
            Proc_PracExp = 1; % Prac
        case 'Practice again'
            Proc_PracExp = 2; % Practice again
    end
    
    if Proc_PracExp == 1
        Prompt = {'Subject Number', 'Your Famliy Name', 'Your Age', 'Your Gender: (1 is male, 2 is female)'};
        DlgTitle = 'Personalia';
        NumLines = 1;
        Answer = inputdlg(Prompt, DlgTitle, NumLines);
        SubjID = str2double (Answer{1});
        SubjName = Answer{2};
        SubjAge = str2double (Answer{3});
        SubjGender = str2double (Answer{4});  % 1- male; 2- female
        
        %file name;
        data_dir = 'Data\';
        DataFileName = sprintf('%s%s%d%s%s%s%s%s',data_dir,'Sub',SubjID,'_',SubjName,'_',date,'\');% suject data file name, e.g. ...\Data\Sub1_x_1-Jan-2016\
        mkdir(DataFileName);
        
        save([DataFileName,'subj_info_temp.mat'], 'SubjName', 'SubjID', 'SubjAge', 'SubjGender', 'DataFileName'); % save file to directory 'DataFileName'
        save('subj_info_temp.mat', 'SubjName', 'SubjID', 'SubjAge', 'SubjGender', 'DataFileName'); % save file to current directory, for 'Practice again' use
    elseif Proc_PracExp == 2 % practice again
        load subj_info_temp.mat
    end
    BevFileName='Behave_Data';% name of the behavioral file???
    % record Target_press_mapping
    while (1)
        str = input('Please input press button mapping number: ','s');
        if (isempty(str))
            continue;
        elseif (strcmp(str,'1') || strcmp(str,'2'))
            PressMapping_index = str2double(str);      % Press button to target : 1- z corresponds to Vtarget first;; 2- z corresponds to Atarget first
            break;                                  % This is for conterbalance
        end
    end
    
    %% Screen Properties
    % monitor
    ScreenNumber = max(Screen('Screens'));
    [ResX, ResY] = Screen('WindowSize',ScreenNumber);
    Cen_X=ResX/2;
    Cen_Y=ResY/2;
    background_color=[0 0 0]; %black
    monitorwidth=60;  %屏幕的宽度，单位为cm
    vdistance=50;          %视距是50cm
    pxlpcm=ResX/monitorwidth;    %单位厘米的像素数量
    pxlpdeg=vdistance*tand(1)*pxlpcm;  %单位度数对应的像素数量            
    RespDur=2.5% 反应时间
    % Open initial screen and initiate OpenGL for faster drawing
    AssertOpenGL;
    [wPtr,screenRect] = Screen('OpenWindow',ScreenNumber,background_color,[],[],2);
    Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    slack=Screen('GetFlipInterval',wPtr)/2; %之后计算时间戳的时候记得减去slack
    refresh=Screen('FrameRate', wPtr);     % get the refresh rate of Screen in Hz.
    HideCursor;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% STIM VARIABLES %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%general setup
    % timing
    ISIArray =1.7* [0.01, 0.03, 0.05, 0.09, 0.2 ];  % [0.01, 0.03, 0.05, 0.09, 0.2 ]
    StiDur=0.01;% 0.01 10ms visual/audio stimuli with 1 ms rise-and-fall time
    CroDur=1;% cross fixation duration 1000ms
    CueTarInter=rand*0.4+0.8;% cue-target interval 800-1200ms之间的随机数 红十字的时长
    BlockRestTime = 1;%30    % rest time within interBlocks？？？
    InterTrialDur = 0.5; % Inter-trial duration 
    %TextFont&Size&color ??
    TrialFontSize = 18;  %Font Size after each trial
    BlockFontSize = 22;  %Font Size between blocks                                                                         
    PresentFont = 'Arial'; 
    AboveCenter = 80;  % default distance above center for words
    BelowCenter = 80;  % default distance below center for words            
    GreyColor = 105;   % gray 
    white=[255 255 255];
    % number
    NumBlocks = 5;%包含practice  一共5个block
    NumPracTrials =3; %25 %undefined 
    NumExpTrials  = 200; %200 for each block
    ntrial=800; %一共有800个试次
       %% visual setup
    % screen
    screens=Screen('Screens');      %打开屏幕
    screenNumber=max(screens);  % 编号最大屏幕用来呈现刺激
    [wPtr,rectsize]=Screen('OpenWindow',ScreenNumber,background_color,[],[],2);%打开窗口
    HideCursor;                            %隐藏鼠标
    InitializeMatlabOpenGL;          %启动OpenGL
    % audio stimuli
    % freq_standard = 600; %(Hz)
    sr=48000;  %%根据电脑的情况定义采样率
    GateDur = 0.001; %length of fade-in 
    InitializePsychSound %启动相关程序包
    devices=PsychPortAudio('GetDevices'); %%看设备中延时最小的设备的设备号及采样率
    pahandle = PsychPortAudio('Open',4,[],[],sr,2);%生成一个供PPA操作声音刺激的句柄pahandle,这里的2也是声道数
    wn=NoiseGenerate(sr,800/sr,GateDur);
    
    %% key
    % key balance      
    SubPressType =        [ 1 2;...    % 2 X 2 matrix
                            2 1];      % each subject selects one row of two
                                       % within each row, each number is target press index
                                       % 1st- for Vtarget first;
                                       % 2nd- for Atarget first;     
                                        % Press button
    % Press button
    PressCodeArray  = ['Z' ,'M'];
    
    % SubjTarPressButtonMapping
    SubPressArray = PressCodeArray( SubPressType (PressMapping_index,:) ); % e.g. [ 'Z', 'M' ]/[ 'M', 'Z' ]
    % 1st number: Z for Vtarget first;
    % 2nd number: M for Atarget first; 
    
%% %%%%%%%%%%%%%%%%%%% Instruction %%%%%%%%%%%%%%%%%%
    % instruction before practice
    if Proc_PracExp == 1  % Prac
        IMName = 'Instruction_pra';
        FileName = sprintf('%s.jpg',IMName);
        A = imread(FileName,'jpg');
        Screen('PutImage', wPtr, A);
        Screen('Flip', wPtr);
        WaitSecs(1);
        while 1
            keyIsdown = 0;
            [keyIsdown, keyTime, keyCode] = KbCheck;
            if (keyIsdown && keyCode(KbName('space')))
                break;
            end
        end   
    end
    % 不同按键对应的指导语
    if PressMapping_index == 1 
        press_text = [ 'Please press ',SubPressArray(1),' button if you think visual target comes first','. \n\n', ...
            'Please press ',SubPressArray(2),' button if you think audio target comes first','. \n\n\n', ...
            'Press space to start if you are ready. '];
    elseif PressMapping_index ==2
        press_text = [ 'Please press ',SubPressArray(2),' button if you think audio target comes first','. \n\n', ...
            'Please press ',SubPressArray(1),' button if you think visual target comes first','. \n\n\n', ...
            'Press space to start if you are ready. '];     
    end
      % e.g.1 Please press Z button if you think visual target comes first. 
      %       Please press M button if you think audio target comes first. 
      % e.g.2 Please press Z button if you think audio target comes first. 
      %       Please press M button if you think visual target comes first. 
    [tx, ty, fbox] = DrawFormattedText(wPtr, press_text, 'center', 'center', GreyColor, 0);
    currTime = Screen('Flip',wPtr,[]);
    WaitSecs(1); 
    while 1
        keyIsdown = 0;
        [keyIsdown, keyTime, keyCode] = KbCheck;
        if (keyIsdown && keyCode(KbName('space')))
            break;
        end
    end
 %% %%%%%%%%%%%%%%%%%%% Start Block/Design %%%%%%%%%%%%%%%%%
    Result_List=[];%
    Acc = [];%% only for static stimuli (same light & same size)???
    BlockStartTime=GetSecs; 
  % Design matrix for exp blocks 
        Conditions(:,1) = reshape( repmat([1,2],400,1), 800,1);  % Condition 1——cue modality type 60=总trial数/第一个条件数4
        % 1- visual;  2- audio;
        CueposIndex = reshape( repmat([-1,1],200,1),400,1);%10所有试次重复次数（如果是最后一列的话），也是上一个条件重复的次数60/第二个条件的个数6
        Conditions(:,2) = repmat( CueposIndex,2,1); % Condition 2——cue position type
        TarmodIndex = reshape( repmat([1,2],100,1),200,1);
        Conditions(:,3) = repmat( TarmodIndex,4,1); % Condition 3——first target modality type
        TarposIndex = reshape( repmat([-1,1],50,1),100,1);
        Conditions(:,4) = repmat( TarposIndex,8,1); % Condition 4——first target position type
        ISITimeIndex = reshape( repmat([1,2,3,4,5],10,1),50,1);
        Conditions(:,5) = repmat(ISITimeIndex,16,1); % Condition 5——ISI type
        for i=1:800 %
            if Conditions(i,3)==1%
                Conditions(i,6)=2;  %Condition 6——second target modality type;和1st target modality（第三列）相反——audio
            elseif Conditions(i,3)==2
                Conditions(i,6)=1; %Condition 6——second target modality type;和1st target modality（第三列）相反——visual
            end
        end
        Conditions(:,7) = Conditions(:,4);%Condition 7——sacond target position type;和1st target position（第四列）相同
        N_Trials= size(Conditions,1);%第一个维度行 得到总共的trial数
        Conditions = Conditions(randperm(N_Trials),:);%打乱800个trial
        % Randomly select some trials for Practice
        Conditions = [Conditions(randperm(N_Trials, NumExpTrials), : ) ;Conditions];%更新了conditions，practice+exp 更新为800+200个
        %default:NumExpTrials, just in order to easily lokcate the start row of each block
        
    %% Instruction    
    for Block =1 : NumBlocks
        keyIsDown =0;
        [keyIsDown, keyTime, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('p'))%按P键退出
                Block = Block - 1; % save partial Blocks 
                break;
            end
        end
        
        if Block ==2  % exp block1
            IMName = ['Instruction_exp',];
            FileName = sprintf('%s.jpg',IMName);
            A = imread(FileName,'jpg');
            Screen('PutImage', wPtr, A);
            Screen('Flip', wPtr);
            WaitSecs(1);
            while 1
                keyIsdown = 0;
                [keyIsdown, keyTime, keyCode] = KbCheck;
                if (keyIsdown && keyCode(KbName('space')))
                    break;
                end
            end
            
            [tx, ty, fbox] = DrawFormattedText(wPtr, press_text, 'center', 'center', GreyColor, 0);
            currTime = Screen('Flip',wPtr,[]);
            WaitSecs(1);
            while 1
                keyIsdown = 0;
                [keyIsdown, keyTime, keyCode] = KbCheck;
                if (keyIsdown && keyCode(KbName('space')))
                    break;
                end
            end
        end
        
        blockstart_text = 'Block Start...';
        Response_text = 'response now'; 
        
        Screen(wPtr,'TextFont',PresentFont);
        Screen(wPtr,'TextStyle',0); % 1bold text;0normal
        Screen(wPtr,'TextSize',BlockFontSize);
        [tx, ty, fbox] = DrawFormattedText(wPtr, blockstart_text, 'center', Cen_Y-AboveCenter, GreyColor, 0);
        currTime = Screen('Flip',wPtr,[]);
        WaitSecs(1);
      
       
        if Block == 1 % prac
            NumTrials = NumPracTrials;
        elseif Block ==2  % exp block 1
            NumTrials = NumExpTrials;
        else
            NumTrials = NumExpTrials;
        end
    
  %% Trial Loop Start
   Trial = 0;
        acc =[ Block, 0, 0 , -1]; % accuracy % [Block,N_acc, N_total, acc_percent]
        while Trial <= NumTrials-1%不是block中的最后一个trial
            
            keyIsDown = 0 ;
            [keyIsDown, keyTime, keyCode] = KbCheck;
            if keyIsDown
                if keyCode(KbName('p'))
                    break;
                end
            end
            
            Trial = Trial + 1;%这个trial是每个block的trial数
            TotalTrial=(Block-1)*NumExpTrials+Trial;
            %% get trial variables
            CueMod(Trial) = Conditions(TotalTrial,1); %第N个trial的第一列对应的CueModdality  %？？？波浪线
            CuePos(Trial) = Conditions(TotalTrial,2);%第N个trial的第二列对应的CuePosition
            FirstTarMod(Trial) = Conditions(TotalTrial,3); %第N个trial的第三列对应的 First Target Moddality
            FirstTarPos(Trial) = Conditions(TotalTrial,4);%第N个trial的第四列对应的First Target Position
            ISIIndex(Trial)=(Conditions(TotalTrial,5));
            ISI(Trial)=ISIArray(ISIIndex(Trial)); %第N个trial的第五列具体对应的ISI
            SecTarMod(Trial) = Conditions(TotalTrial,6); %第N个trial的第六列对应的 Second Target Moddality
            SecTarPos(Trial) = Conditions(TotalTrial,7);%第N个trial的第七列对应的 Second Target Position
            %% Stimuli setup
            % visual stimuli
            drect=vdistance*tand(0.8/2)*pxlpcm; %方形边长为1°,direct为半径 
            cross=MakeCross(wPtr,0.05,0.8,pxlpdeg,[128 128 128],[0 0 0]); %画注视点的
            redcross=MakeCross(wPtr,0.05,0.8,pxlpdeg,[255 0 0],[0 0 0]); %画注视点的
            x_Vcue=Cen_X+CuePos(Trial)*(vdistance*tand(21)*pxlpcm);  %visual cue的横坐标(left/right,21°)
            Visual_cue=[x_Vcue-drect,Cen_Y-drect,x_Vcue+drect,Cen_Y+drect];%visual cue的坐标 [x1,y1,x2,y2]左上角和右下角坐标
            First_x_Vtar=Cen_X+FirstTarPos(Trial)*(vdistance*tand(21)*pxlpcm);  %如果第一个target是visual，visual tar的横坐标(left/right,21°)
            Sec_x_Vtar=Cen_X+SecTarPos(Trial)*(vdistance*tand(21)*pxlpcm);  %如果第二个target是visual，visual tar的横坐标(left/right,21°)
            FirstVisual_tar=[First_x_Vtar-drect,Cen_Y-drect,First_x_Vtar+drect,Cen_Y+drect];%如果第一个target是visual，visual target的坐标
            SecVisual_tar=[Sec_x_Vtar-drect,Cen_Y-drect,Sec_x_Vtar+drect,Cen_Y+drect];%如果第二个target是visualvisual，visual target的坐标

           %% Stimuli presenttaion
            % cross
            Screen('DrawTexture',wPtr,cross);
            currTime=Screen(wPtr,'Flip');%先呈现注视点
            % exogenous cue
            if CueMod(Trial)==1 % visual cue
                visual_cue=[x_Vcue-drect,Cen_Y-drect,x_Vcue+drect,Cen_Y+drect];%visual cue的坐标 [x1,y1,x2,y2]左上角和右下角坐标
                Screen('FillRect', wPtr,GreyColor,visual_cue);% 画visual cue
               % Screen('DrawTexture',wPtr,cross);% 画cross
                currTime=Screen('Flip',wPtr,currTime+CroDur-slack); %第一个注视点1000ms后，呈现注视点+视觉刺激
            elseif CueMod(Trial)==2 % auditory cue
                if CuePos(Trial)==-1 % left auditory cue
                   % Screen('DrawTexture',wPtr,cross)% 画cross
                    PsychPortAudio('FillBuffer',pahandle,[wn;wn*0]);%左声道播放
                    currTime=Screen('Flip',wPtr,currTime+CroDur-slack);%第一个注视点300ms后，呈现注视点+听觉刺激
                    PsychPortAudio('Start',pahandle,1);% start sound
                    
                elseif CuePos(Trial)==1 % right auditory cue
                   % Screen('DrawTexture',wPtr,cross)% 画cross
                    PsychPortAudio('FillBuffer',pahandle,[wn*0;wn]);%右声道播放
                    currTime=Screen('Flip',wPtr,currTime+CroDur-slack);% 第一个注视点300ms后,呈现注视点+听觉刺激
                    PsychPortAudio('Start',pahandle,1);
                end
            end
            % cross cue-target interval redcross 1s
            Screen('DrawTexture',wPtr,redcross);
            currTime=Screen('Flip',wPtr,currTime+StiDur-slack);% cue呈现10ms后，恢复只有一个注视点
            % first target
            if FirstTarMod(Trial)==1  % first visual target
                FirstVisual_tar=[First_x_Vtar-drect,Cen_Y-drect,First_x_Vtar+drect,Cen_Y+drect];%first visual tar的坐标 [x1,y1,x2,y2]左上角和右下角坐标
                Screen('FillRect', wPtr,GreyColor,FirstVisual_tar);% 画first visual target
                Screen('DrawTexture',wPtr,cross);% 画cross
                currTime=Screen('Flip',wPtr,currTime+CueTarInter-slack); %第二个注视点60ms后，呈现注视点+视觉刺激
            elseif FirstTarMod(Trial)==2 % first auditory target
                if FirstTarPos(Trial)==-1
                    Screen('DrawTexture',wPtr,cross)%  画cross
                    PsychPortAudio('FillBuffer',pahandle,[wn;wn*0]);%左声道播放
                    currTime=Screen('Flip',wPtr,currTime+CueTarInter-slack);%第二个注视点60ms后，呈现注视点+听觉刺激
                    PsychPortAudio('Start',pahandle,1);
                elseif FirstTarPos(Trial)==1
                    Screen('DrawTexture',wPtr,cross)% 画cross
                    PsychPortAudio('FillBuffer',pahandle,[wn*0;wn]);%右声道播放
                    currTime=Screen('Flip',wPtr,currTime+CueTarInter-slack);%第二个注视点60ms后，呈现注视点+听觉刺激
                    PsychPortAudio('Start',pahandle,1);
                end
            end
            % cross 
            Screen('DrawTexture',wPtr,cross);
            currTime=Screen('Flip',wPtr,currTime+StiDur-slack);% cue呈现10ms后，恢复只有一个注视点
            % sencond target
            if SecTarMod(Trial)==1 % second visual target
                SecVisual_tar=[Sec_x_Vtar-drect,Cen_Y-drect,Sec_x_Vtar+drect,Cen_Y+drect];%second visual tar的坐标 [x1,y1,x2,y2]左上角和右下角坐标
                Screen('FillRect', wPtr,GreyColor,SecVisual_tar);% 画second visual target
                Screen('DrawTexture',wPtr,cross);% 画cross
                currTime=Screen('Flip',wPtr,currTime+ISI(Trial)-slack); %第一个target呈现ISI后，呈现second target
            elseif SecTarMod(Trial)==2 % second auditory target
                if SecTarPos(Trial)==-1
                    Screen('DrawTexture',wPtr,cross)% 画cross
                    PsychPortAudio('FillBuffer',pahandle,[wn;wn*0]);%左声道播放
                    currTime=Screen('Flip',wPtr,currTime+ISI(Trial)-slack);% 第一个target呈现ISI后，呈现second target
                    PsychPortAudio('Start',pahandle,1);
                elseif SecTarPos(Trial)==1
                    Screen('DrawTexture',wPtr,cross)% 画cross
                    PsychPortAudio('FillBuffer',pahandle,[wn*0;wn]);%右声道播放
                    currTime=Screen('Flip',wPtr,currTime+ISI(Trial)-slack);% 
                    PsychPortAudio('Start',pahandle,1);
                end
            end
            % "response now"
            [tx, ty, fbox] = DrawFormattedText(wPtr, Response_text, 'center', 'center', GreyColor, 0);
            ResponseOnsetTime=Screen('Flip',wPtr,currTime+StiDur-slack);%second target呈现10ms后，呈现“responsse now”
           
           
            % response record
            RecordIsOver = 0; % 
            Response(Trial) = -1; 
			RT(Trial)= -1;
            while 1    % until response
                keyIsDown = 0;
                [keyIsDown, keyTime, keyCode] = KbCheck;
                if keyIsDown
                    if keyCode( KbName(SubPressArray(1)) ) && ( ~ keyCode( KbName(SubPressArray(2)) ) )  % press button for visual target comes first
                        RecordIsOver = 1;
                        Response(Trial) = 1;  % record Response 区分两种反应按键：Z——visual target first Response(Trial)记录到哪里去 需要放到矩阵里吗???
                        RT(Trial) = keyTime - ResponseOnsetTime; % RT
                        %                         if (FirstTarMod(Trial)==1) %先呈现visual tar
                        %                             acc(2) = acc(2)+1; % accuracy % [Block,N_acc, N_total, acc_percent]
                        %                         end
                        break;
                    elseif keyCode( KbName(SubPressArray(2)) ) && ( ~ keyCode( KbName(SubPressArray(1)) ) ) % press button for audio target comes first
                        RecordIsOver = 1;
                        Response(Trial) = 2;  % record Response 区分两种反应按键：Z——audio target first
                        RT(Trial) = keyTime - ResponseOnsetTime; % RT
                        %                         if (FirstTarMod(Trial)==2) %先呈现audio tar
                        %                             acc(2) = acc(2)+1; % accuracy % [Block,N_acc, N_total, acc_percent]
                        %                         end
                        break;
                    end
                end
            end
           currTime = Screen('Flip',wPtr,[]);   % after response, change as only background
           currTime = Screen('Flip',wPtr,currTime + InterTrialDur - slack); % background duration
          
            % save trial result
            result_trial=[SubjID,SubjID, Block, Trial, ...
                CueMod(Trial), CuePos(Trial), FirstTarMod(Trial), FirstTarPos(Trial),  ...
                ISI(Trial)*1000, SecTarMod(Trial),SecTarPos(Trial), ...
                Response(Trial),RT(Trial)*1000,PressMapping_index];
            Result_List = [Result_List; result_trial];%随时更新Result_List
        end % end of trial loop
        
             
        % block feedback decision
        CompRes=(FirstTarMod==Response);
        CorreNum=sum(CompRes);
        Acc=CorreNum/NumPracTrials;
        Pracfeedback_text = [ 'Your accuracy is ',num2str(Acc),''];
        Expfeedback_text = ['Have a break!'];
        Finipra_text = ['Ready for the formal experiment!'];
        InterblockStart_text = ['If you are ready,please press space to continue!'];
        Finiblock_text = ['Experiment finished, thank you for your participation!'];
        Screen(wPtr,'TextFont',PresentFont);
		Screen(wPtr,'TextStyle',0); % 1bold text;0normal
        Screen(wPtr,'TextSize',BlockFontSize);
        if Block==1%文字提示练习部分正确率，并准备开始正式实验
            [tx, ty, fbox] = DrawFormattedText(wPtr,Pracfeedback_text, 'center', Cen_Y-AboveCenter, GreyColor, 0);
            currTime = Screen('Flip',wPtr,[],1);
        elseif Block==NumBlocks%提示实验结束
            BlockEndTime = GetSecs;
            ExpTimeCost = BlockEndTime-BlockStartTime;
            ExpTimeCost = ExpTimeCost/60; % in minutes
            [tx, ty, fbox] = DrawFormattedText(wPtr, Finiblock_text, 'center', Cen_Y-AboveCenter, GreyColor, 0);
            currTime = Screen('Flip',wPtr,[]);
        else%提示休息和准备开始下一个block
            [tx, ty, fbox] = DrawFormattedText(wPtr, Expfeedback_text, 'center', Cen_Y-AboveCenter, GreyColor, 0);
            currTime = Screen('Flip',wPtr,[]);
        end
        
        if (Block==1 || Block==NumBlocks)
			RestTime= 0.1;
		else RestTime=2;%30
		end 
        
        while GetSecs <= currTime + RestTime  %interblock rest time
        end
        
        if(Block==1)
            [tx, ty, fbox] = DrawFormattedText(wPtr,  Finipra_text, 'center', Cen_Y, GreyColor, 0);
            currTime = Screen('Flip',wPtr,[]); %interblock rest 结束后提示并等待space按键
        elseif (Block>=1 && Block~=NumBlocks)
            [tx, ty, fbox] = DrawFormattedText(wPtr, InterblockStart_text, 'center', Cen_Y, GreyColor, 0);
            currTime = Screen('Flip',wPtr,[]); %interblock rest 结束后提示并等待space按键
        end
        
        while 1
            [keyIsDown, keyTime,keyCode]=KbCheck;
            if Block == 1
                if keyCode(KbName('e'))  % go to normal experiment
                    break;
                elseif keyCode(KbName('p'))  % exit to practice again
                    break;
                end
            elseif Block > 1 && Block < NumBlocks
                if keyCode(KbName('space')) % press space to continue
                    break;
                elseif keyCode(KbName('p')) % exit
                    break;
                end
            elseif Block == NumBlocks
                if keyCode(KbName('p'))   % exit
                    break;
                end            
            end
        end
    end % end of block loop
    Screen('CloseAll');
    ShowCursor;
    PsychPortAudio('Close',pahandle);
%     result_trial=[SubjID,SubjID, Block, Trial, ...
%                 CueMod(Trial), CuePos(Trial), FirstTarMod(Trial), FirstTarPos(Trial),  ...
%                 ISI(Trial)*1000, SecTarMod(Trial),SecTarPos(Trial), ...
%                 Response(Trial),RT(Trial),PressMapping_index];
    VariableName={ 'SubjID','SubjID', 'Block', 'Trial', ...
        'CueMod(1-visual, 2-audio,','CuePos(1-left, 2-right,','FirstTarMod(1-visual, 2-audio,','FirstTarPos(1-left, 2-right,',...
        'ISI(ms)','SecTarMod (1-visual, 2-audio,','SecTarPos (1-left, 2-right,',...
        'Response(1-visual first,2-audio first)','RT(ms)','PressMapping_index(1-Z-Vtarget first,M-Atarget first;2-Z-Atarget first,M-Vtarget first;)'};
    save([DataFileName,BevFileName,'.mat'], 'Result_List','VariableName','Cen_X','Cen_Y','ResX','ResY','vdistance', ... 
            'ISI', ... % timing
            'StiDur', 'RespDur', 'ISIArray', ...    
            'PressMapping_index', 'SubPressArray');

    % copy file for each subject
    file = '*.m';
    f = dir(file);
    for i = 1:length(f)
        copyfile([pwd,'\',f(i).name],DataFileName);
    end 
    disp('finish all!');
catch error
    Screen('CloseAll');
   % PsychPortAudio('Close',pahandle);
    rethrow(error);
end
            
           