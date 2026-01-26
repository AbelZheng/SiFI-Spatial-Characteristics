    clear;
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
    Conditions = Conditions(randperm(Total_Trial),:); % 这样索引行真的ok吗？
    
    % Practice trial number
    Prac_totaltrial = 12;
    Prac_catchtrial = 2;
    Prac_Total_trial = Prac_totaltrial + Prac_catchtrial;
    Prac_nBlock = 2; %% 可以修改的practice组数目
    Prac_trialPerBlock = Prac_Total_trial / Prac_nBlock;
    % Practice matrix
    Prac_Conditions(:,1) = repmat (FlashNumArray',Prac_totaltrial/length(FlashNumArray),1);
    Prac_Conditions(:,2) = repmat (BeepNumArray',Prac_totaltrial/length(BeepNumArray),1);
    Prac_Conditions(:,3) = repmat (SOA_Array',Prac_totaltrial/length(SOA_Array),1);
    % Adding catch trials
    Prac_Conditions = [Prac_Conditions; zeros(Prac_catchtrial,3)];
    Prac_Total_Trial = size(Prac_Conditions,1);
    Prac_Conditions = Prac_Conditions(randperm(Prac_Total_Trial),:);
    Prac_ActualTotal_Trial = Prac_Total_Trial; % 这一步操作是为了？
    