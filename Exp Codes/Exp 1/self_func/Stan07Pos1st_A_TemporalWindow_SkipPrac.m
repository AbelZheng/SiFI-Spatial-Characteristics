%% _________________ Regular _____________________
% Constant stimuli method
% Standard duration: Short 600 ms + Long 3000 ms
% ranges from [0.55,0.7,0.8,0.9,1,1.1,1.2,1.3,1.45];
%% Initialization
sca;
close all;
clearvars;
rng('shuffle')
% ######## [TO DO] ########
Screen('Preference', 'SkipSyncTests', 1);%笔记本为1
monitorwidth=57;              % monitor width in cm.
vdistance=50;                 % visual distance in cm.

try
    %% collect subjt info
    Prompt = {'Subject Number', 'Your Name', 'Your Age', 'Your Gender: (1 is male, 2 is female)'};
    DlgTitle = 'Personalia' ;
    NumLines = 1;
    Answer = inputdlg(Prompt, DlgTitle, NumLines);
    SubjID = str2double (Answer{1});
    SubjName = Answer{2};
    SubjAge = str2double (Answer{3});
    SubjGender = str2double (Answer{4});  % 1- male; 2- female
    % record Target_press_mapping
    while (1)
        str = input('Please input press button mapping number: ','s');
        if (isempty(str))
            continue;
        elseif (strcmp(str,'1') || strcmp(str,'2'))
            PressMapping_index = str2double(str);      % Press button to target : 1- z corresponds to On beat; 2- z corresponds to Off beat
            break;                                  % This is for conterbalance
        end
    end
    %% basic parameters
    % key
    % key balance      
    SubPressType =        [ 1 2;...    % 2 X 2 matrix
                            2 1];      % each subject selects one row of two
                                       % within each row, each number is target press index
                                       % 1st- for On beat;
                                       % 2nd- for Off beat;     
                                       % Press button
    % Press button
    PressCodeArray  = ['Z' ,'M'];
    
    % SubjTarPressButtonMapping
    SubPressArray = PressCodeArray( SubPressType (PressMapping_index,:) ); % e.g. [ 'Z', 'M' ]
    % 1st number: Z for On beat;
    % 2nd number: M for Off beat; 
    
    % set the experimental parameters
    standard = 0.7;% 700ms/1200ms/2500ms
    TarExpArray=[0.7,1,1.3];%target expectancy
    TarExpPos=[1,2,3];
    ctResponseTime=3; % catch trial 问题出来后等待的时间
    % formal trial number
    totaltrial=40;
    catchtrial =8;
    Total_Trial=totaltrial+catchtrial;
    trialPerBlock= 16; %trial number per block
    nBlcok=Total_Trial/trialPerBlock;% 3个block
    Resttime=5; % rest time between block
    Qdelaytime=0.25;%问题延迟出现的的时间
    
    % Design matrix for Conditions
    % formal experiment matrix
    Conditions(:,1) = repmat (TarExpPos(1),totaltrial,1); % Condition 1——40个TarExpPos(1)
    TarExp_Index =  [repmat(TarExpArray(2),20,1);repmat(TarExpArray(1),10,1);repmat(TarExpArray(3),10,1)];%
    Conditions(:,2) = TarExp_Index;% Condition 2——Target Expectancy:1-on(20个),0.7-early(10个),1.3-late(10个)
    Conditions = [Conditions;zeros(8,2)]; % 每组增加8个catch trial
    Total_Trial= size(Conditions,1);%第一个维度行 得到总共的trial数
    Conditions = Conditions(randperm(Total_Trial),:);%打乱40+8个trial
    % praceticce trial number
    Prac_totaltrial=12;
    Prac_catchtrial = 2;
    Prac_Total_Trial=Prac_totaltrial+Prac_catchtrial;
    Prac_trialPerBlock= (Prac_totaltrial+Prac_catchtrial)/2; %trial number per block7个
    Prac_nBlcok=Prac_Total_Trial/Prac_trialPerBlock;%2个Practice Blcok
    % practice matrix
    Prac_Conditions(:,1) = repmat(TarExpPos(1),Prac_totaltrial,1); % Condition 1——12个TarExpPos(1)
    Prac_TarExp_Index =  [repmat(TarExpArray(2),6,1);repmat(TarExpArray(1),3,1);repmat(TarExpArray(3),3,1)];%
    Prac_Conditions(:,2) = Prac_TarExp_Index;% Condition 2——Target Expectancy:1-on,0.7-early,1.3-late
    Prac_Conditions = [Prac_Conditions;zeros(2,2)]; % 增加2个catch trial
    Prac_Total_Trial= size(Prac_Conditions,1);%第一个维度行 得到总共的14个trial数
    Prac_Conditions = Prac_Conditions(randperm(Prac_Total_Trial),:);%打乱12+2个trial
    Prac_ActualTotal_Trial = Prac_Total_Trial;%实际的练习试次数，不减少练习的时候=Prac_Total_Trial
    
    % initialize data recording matrix
    RT =zeros(Total_Trial,1);
    Correct=zeros(Total_Trial,1);
    RTKey=zeros(Total_Trial,1); %记录按键
    
    % Others
    KbName('UnifyKeyNames');
    spacekey=KbName('space');
    quit=KbName('q'); % set the quite botton
    
    %% Visual stimuli
    % Preparation
    
    % Get the pixels/ centre coordinate/refreshrate of the window
    [wPtr,rect]=Screen('OpenWindow',0);
    HideCursor;
    % Get the pixels/ centre coordinate/refreshrate of the window
    [screenXpixels, screenYpixels] = Screen('WindowSize', wPtr);
    refresh=Screen('FrameRate', wPtr); % return frame rate in Hz
    
    white=WhiteIndex(wPtr);
    black=BlackIndex(wPtr);
    grey= [166 172 175];
    
    %caculate pixel per the visual angle
    pxlpdeg=(screenXpixels/2)/rad2deg(atan((monitorwidth/2)/vdistance));
    
    % fixation
    fixpixel= 0.4; % 1/2 size
    xCoords = [-fixpixel*pxlpdeg+screenXpixels/2, fixpixel*pxlpdeg+screenXpixels/2,screenXpixels/2,screenXpixels/2];
    yCoords = [screenYpixels/2, screenYpixels/2, -fixpixel*pxlpdeg+screenYpixels/2,fixpixel*pxlpdeg+screenYpixels/2];
    allCoords = [xCoords; yCoords];
    
    %读取听觉播放时图片
    IMName = 'speaker.png';
    A = imread(IMName);
    imgCoords=[screenXpixels/2-2*fixpixel*pxlpdeg screenYpixels/2-2*fixpixel*pxlpdeg screenXpixels/2+2*fixpixel*pxlpdeg screenYpixels/2+2*fixpixel*pxlpdeg];
    %% Auditory stimuli
    % parameters for leading cue and target
    Tone_frequency=500;
    Last_cue_frequency=1000;
    sr=44100;  %sampling rate
    gatedur=5/1000; %fade in/out duration in seconds
    stiDur=25/1000; %stimuli duration in seconds
    
    % generate formal stimuli
    Sound_standardISI=zeros(1,round(standard*sr));% 线索间时间间隔
    Tone=Soundgenerate(sr,Tone_frequency,stiDur,gatedur);%cue tone/target tone
    Last_Cue_Tone=Soundgenerate(sr,Last_cue_frequency,stiDur,gatedur);% last cue tone
    %制作出所有条件（位置3*OnOffbeat3）的声音刺激，遍历条件矩阵的时候再抽取相应条件的声音刺激
    for pos=1:3 % target position:1-1st,2-2nd,3-3rd
        for exp=1:3 % target expectancy:1-early;2-On;3-late
            ISI= (TarExpPos(pos)-1)*(standard+stiDur)+TarExpArray(exp) * standard; % varied ISI
            Sound_ISI=zeros(1,round(ISI*sr));
            eval(['Sound' num2str(TarExpPos(pos)), num2str(exp), '=[Tone,Sound_standardISI,Tone,Sound_standardISI,Tone,Sound_standardISI,Last_Cue_Tone,Sound_ISI,Tone];'])
            eval(['Time' num2str(TarExpPos(pos)), num2str(exp), '=5*stiDur+stiDur*(TarExpPos(pos)-1)+3*standard+TarExpArray(exp)*standard+(TarExpPos(pos)-1)*standard;'])        
        end
    end
    Sound0=[Tone,Sound_standardISI,Tone,Sound_standardISI,Tone,Sound_standardISI,Last_Cue_Tone];%catch trial 的tone,线索之后没有target
    
    InitializePsychSound(1);
    PsychPortAudio('close');
    pahandle = PsychPortAudio('Open',3,[],2,sr,2);
    %open之后的输入参数是使用的设备，open之后第一个是指定设备编号，用ASIO虚拟声卡的时候就是用填ASIO的index2是mode默认即可，3延迟设置，1是尽量减少延迟，4是采样率写1设备对应的采样率，5是通道数。，sr也是ASIO对应的SR
    %% EXP - Instruction
    
    Screen('FillRect',wPtr,grey);
    Screen('TextFont',wPtr, 'Courier New');
    Screen('TextSize',wPtr, 30);
    Screen('TextStyle', wPtr, 1);    
    % 不同按键对应的指导语
    if PressMapping_index == 1 %Z for On beat;M for Off beat
        press_text = [ 'Please press ',SubPressArray(1),' button if you think target is On beat','. \n\n', ...
            'Please press ',SubPressArray(2),' button if you think target is Off beat','. \n\n\n', ...
            'Press ENTER to start. '];
    elseif PressMapping_index ==2
        press_text = [ 'Please press ',SubPressArray(2),' button if you think target is Off beat','. \n\n', ...
            'Please press ',SubPressArray(1),' button if you think target is On beat','. \n\n\n', ...
            'Press ENTER to start. '];     
    end
      % e.g.1 Please press Z button if you think target is On beat. 
      %       Please press M button if you think target is Off beat. 
      % e.g.2 Please press Z button if you think target is Off beat. 
      %       Please press M button if you think target is On beat. 
    DrawFormattedText(wPtr,press_text, 'center','center', black);
    Screen(wPtr,'Flip');
    KbWait;
    Screen('FillRect',wPtr,grey);
    when=Screen('Flip',wPtr);
    while KbCheck ; end
    %% EXP - practice 
    Prac_corr=0;
    Prac_Numcatch=0; 
    for nt=1:  Prac_ActualTotal_Trial
        picA=Screen('MakeTexture', wPtr,A);         Screen('DrawTexture', wPtr,  picA, [], imgCoords);
        when=Screen('Flip',wPtr,when+1.5);   %ITI=1.5s
        if Prac_Conditions(nt,1)~=0 %不是catch trial
            eval (['sound=Sound', num2str(Prac_Conditions(nt,1)), num2str(find(TarExpArray==Prac_Conditions(nt,2))) ';'])%find 找到具体Prac_condition值在TarExpArray对应的位置
            %[ ]必然是拼贴的字符 注意数字转换成字符
            eval (['time=Time', num2str(Prac_Conditions(nt,1)), num2str(find(TarExpArray==Prac_Conditions(nt,2))) ';'])
            PsychPortAudio('FillBuffer',pahandle,[sound;sound]);
            PsychPortAudio('Start',pahandle,1,when);
%           DrawFormattedText(wPtr,'On beat or Off beat?', 'center', 'center', black);
%           [when, StimulusOnsetTime, FlipTimestamp]=Screen('Flip',wPtr,when+time+Qdelaytime);%声音播放完毕后250ms后呈现问题
            StimulusOnsetTime=when+time;%
            else
            sound=Sound0;
            PsychPortAudio('FillBuffer',pahandle,[sound;sound]);
            PsychPortAudio('Start',pahandle,1,when);
            time=5*(stiDur+standard);% 第三个target出现前经历的时间
%           DrawFormattedText(wPtr,'On beat or Off beat?', 'center', 'center', black);
%           when=Screen('Flip',wPtr,when+time);%
            when=when+time;%播放完声音的时间
        end
        %% Collect key input
        tic;% 呈现问题时开始计时
        WaitSecs(time);%
        if  Prac_Conditions(nt,1)==0 %计算每个block catch trial的个数
            Prac_Numcatch=Prac_Numcatch+1;
        end
        while 1
            [KeyIsDown, KeyTime,Keycode]=KbCheck;
            if Prac_Conditions(nt,1)==0 %是catch trial
               if KeyIsDown
                    DrawFormattedText(wPtr,'Wrong', 'center', 'center', [255 0 0]);
                    when=Screen('Flip',wPtr);
                    Screen('FillRect',wPtr,grey);
                    when=Screen('Flip',wPtr,when+0.2);
                    break;
                elseif ~KeyIsDown
                    if toc>ctResponseTime
                        break;%跳出while循环
                    end
                end
            elseif Prac_Conditions(nt,1)~=0%不是catch trial
                if KeyIsDown
                    if Keycode(quit)  % 退出实验
                        Screen('CloseAll');
                        ShowCursor;
                        break;
                    end
                    if Keycode( KbName(SubPressArray(1)) ) && ( ~ Keycode( KbName(SubPressArray(2)) ) )  % press button for On beat response
                       %判断正误
                        if Prac_Conditions(nt,2)==1
                            DrawFormattedText(wPtr,'Correct', 'center', 'center', black);
                            when=Screen('Flip',wPtr);
                            Prac_corr=Prac_corr+1;
                            Screen('FillRect',wPtr,grey);
                            when=Screen('Flip',wPtr,when+0.2);
                            break;
                        elseif Prac_Conditions(nt,2)~=1
                            DrawFormattedText(wPtr,'Wrong', 'center', 'center', [255 0 0]);
                            when=Screen('Flip',wPtr);
                            Screen('FillRect',wPtr,grey);
                            when=Screen('Flip',wPtr,when+0.2);
                            break;
                        end
                    elseif Keycode( KbName(SubPressArray(2)) ) && ( ~ Keycode( KbName(SubPressArray(1)) ) ) % press button for Off beat
                        %判断正误
                        if Prac_Conditions(nt,2)~=1
                            DrawFormattedText(wPtr,'Correct', 'center', 'center', black);
                            when=Screen('Flip',wPtr);
                            Prac_corr=Prac_corr+1;
                            Screen('FillRect',wPtr,grey);
                            when=Screen('Flip',wPtr,when+0.2);
                            break;
                        elseif Prac_Conditions(nt,2)==1
                            DrawFormattedText(wPtr,'Wrong', 'center', 'center', [255 0 0]);
                            when=Screen('Flip',wPtr);
                            Screen('FillRect',wPtr,grey);
                            when=Screen('Flip',wPtr,when+0.2);
                            break;
                        end
                    end
                end
            end
        end
         % feedback after prac
         if mod(nt,  Prac_ActualTotal_Trial)==0%所有练习结束
             DrawFormattedText(wPtr,['Your correct rate is roughly ', num2str(Prac_corr/(Prac_ActualTotal_Trial-Prac_Numcatch)*100), '%. \n\n You finihsed practice part. \n\n Take a rest :)'], 'center', 'center', black);
             Screen('Flip',wPtr);
             WaitSecs(Resttime);
             DrawFormattedText(wPtr,'Strike ENTER to continue', 'center', 'center', black);
%          Prac_Numcatch=0;
             Screen('Flip',wPtr);
             KbWait;
             Screen('FillRect',wPtr,grey);
             when=Screen('Flip',wPtr);
%         Prac_corr=0;
         else
             Screen('FillRect',wPtr,grey);
             when=Screen('Flip',wPtr);
         end
    end
    %% EXP - formal exp
    %Intro
    Screen('FillRect',wPtr,grey);
    DrawFormattedText(wPtr,press_text, 'center','center', black);
    Screen(wPtr,'Flip');
    WaitSecs(0.5);%
    KbWait; 
    Screen('FillRect',wPtr,grey);
    when=Screen('Flip',wPtr);
    while KbCheck ; end   
    Exp_corr=0;
    Numcatch=0;
    for nt=1:Total_Trial
        picA=Screen('MakeTexture', wPtr,A);         Screen('DrawTexture', wPtr,  picA, [], imgCoords);
        when=Screen('Flip',wPtr,when+1.5);   %ITI=1.5s 灰色空屏幕
        if Conditions(nt,1)~=0%不是catch trial
            eval (['sound=Sound', num2str(Conditions(nt,1)),num2str(find(TarExpArray==Conditions(nt,2))) ';'])%find 找到具体condition值在TarExpArray对应的位置
            eval (['time=Time', num2str(Conditions(nt,1)), num2str(find(TarExpArray==Conditions(nt,2))) ';'])
            PsychPortAudio('FillBuffer',pahandle,[sound;sound]);
            PsychPortAudio('Start',pahandle,1,when);
%             DrawFormattedText(wPtr,'On beat or Off beat?', 'center', 'center', black);
%             [when, StimulusOnsetTime, FlipTimestamp]=Screen('Flip',wPtr,when+time+Qdelaytime);%声音播放完毕后250ms后呈现问题
            StimulusOnsetTime=when+time;
        else
            sound=Sound0;
            PsychPortAudio('FillBuffer',pahandle,[sound;sound]);
            PsychPortAudio('Start',pahandle,1,when);
            time=5*(stiDur+standard);% 第三个target出现前经历的时间
%           DrawFormattedText(wPtr,'On beat or Off beat?', 'center', 'center',black);
%           [when, StimulusOnsetTime, FlipTimestamp]=Screen('Flip',wPtr,when+time);
            StimulusOnsetTime=when+time;
        end
        WaitSecs(time);%
        %% Collect key input       
        tic;% 呈现问题时开始计时
        if Conditions(nt,1)==0 %计算每个block catch trial的个数
                Numcatch=Numcatch+1;
        end
        while 1
            [KeyIsDown, KeyTime,Keycode]=KbCheck;
            if Conditions(nt,1)==0 %是catch trial
                if KeyIsDown
                    DrawFormattedText(wPtr,'Wrong', 'center', 'center', [255 0 0]);
                    when=Screen('Flip',wPtr);
                    Screen('FillRect',wPtr,grey);
                    when=Screen('Flip',wPtr,when+0.2);
                    break;
                elseif ~KeyIsDown
                    if toc>ctResponseTime
                        break;
                    end
                end
            elseif Conditions(nt,1)~=0%不是catch trial
                if KeyIsDown
                    %记录反应时与按键过程
                    RT(nt)=(KeyTime-StimulusOnsetTime)*1000;
                    RTKey(nt)=find(Keycode==1);
                    if Keycode(quit)  % 退出实验
                        Screen('CloseAll');
                        ShowCursor;
                    end
                    if  Keycode( KbName(SubPressArray(1)) ) && ( ~ Keycode( KbName(SubPressArray(2)) ) )%press button for On beat response
                        %判断正误
                        if Conditions(nt,2)==1
                            Correct(nt)=1;
                            Exp_corr=Exp_corr+1;
                        end
                    elseif Keycode( KbName(SubPressArray(2)) ) && ( ~ Keycode( KbName(SubPressArray(1)) ) ) % press button for Off beat response
                        %判断正误
                        if Conditions(nt,2)~=1
                            Correct(nt)=1;
                            Exp_corr=Exp_corr+1;   
                        end
                    end
                    break;
                end
            end
        end
        % rest between blocks
        if mod(nt,trialPerBlock)==0%一个block 结束
            DrawFormattedText(wPtr,['Your correct rate is roughly ', num2str(Exp_corr/(trialPerBlock-Numcatch)*100), '%. \n\n You finihsed ' num2str(nt/trialPerBlock) ' out of ' num2str(nBlcok) ' blocks. \n\n Take a rest :)'], 'center', 'center', black);
            Screen('Flip',wPtr)
            WaitSecs(Resttime);
            DrawFormattedText(wPtr,'Strike ENTER to continue', 'center', 'center', black);%
            Numcatch=0;
            Screen('Flip',wPtr);
            KbWait;
            Screen('FillRect',wPtr,grey);
            when=Screen('Flip',wPtr);
            Exp_corr=0;
        else
            Screen('FillRect',wPtr,grey);
            when=Screen('Flip',wPtr);
        end
    end
    %% 结束这一版块
    PsychPortAudio('close');
    Screen('DrawText',wPtr,'You have finished this part :)',200,360,black);
    Screen('Flip',wPtr);
    WaitSecs(0.5);
    Screen('CloseAll');
    ShowCursor;
catch e
    Screen('CloseAll');
    ShowCursor;
    rethrow(e)
    fprintf(1,'The identifier was:\n%s',e.identifier);
    fprintf(1,'There was an error! The message was:\n%s',e.message);
end
%% save data
save(['data/Tarpos1st_Sub',num2str(SubjID),SubjName,'.mat'],'SubjAge','SubjGender','PressMapping_index', 'SubPressArray','RT','RTKey','Correct','Conditions');
% PressMapping_index:1- z corresponds to On beat; 2- z corresponds to Off beat
% SubPressArray:1-ZM; 2-MZ
%% Rough analysis
% for sub=1:5
%     Correctonbeat=[];
%     Correctoffbeat=[];
%     RTonbeat=[];
%     RToffbeat=[];
%     load(['data/Tarpos1st_Sub',num2str(SubjID),SubjName,'.mat'],'RT','Correct','Conditions');%这里我不知道怎么写可以遍历一个条件的所有被试数据
%     for i=1:size(Conditions,1)
%         if Conditions(i,2)==1
%             Correctonbeat=[Correctonbeat,Correct(i)];
%             RTonbeat==[RTonbeat,RT(i)];
%         elseif  Conditions(i,2)~=1 && Conditions(i,2)~=0
%             Correctoffbeat=[Correctoffbeat,Correct(i)];
%             RTonbeat==[RToffbeat,RT(i)];
%         end
%     end
%     ResultCorrest(sub,1)=mean(Correctonbeat);%我不知道这部分结果跑出来长什么样子，是每个Result包含了所有被试的平均值吗？第一列的被实名来自哪里？
%     ResultCorrest(sub,2)=mean(Correctoffbeat);
%     ResultRT(sub,1)=mean(RTonbeat);
%     ResultRT(sub,2)=mean(RToffbeat);
% end