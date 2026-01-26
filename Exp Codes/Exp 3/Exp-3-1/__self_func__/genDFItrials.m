function Trials = genDFItrials(poslNum, TarArray, IndArray, SOAlnum)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
total_conditions = poslNum * length(TarArray) * length(IndArray) * SOAlnum;
Conditions = zeros(total_conditions, 4);
Conditions(:,1) = repelem(1:poslNum,total_conditions/poslNum)';
Conditions(:,2) = repmat(repelem(TarArray,total_conditions/poslNum/length(TarArray))',poslNum,1);
Conditions(:,3) = repmat(repelem(IndArray,total_conditions/poslNum/length(TarArray)/length(IndArray))',...
    poslNum*length(TarArray),1);
Conditions(:,4) = repmat(repelem(1:SOAlnum,total_conditions/poslNum/length(TarArray)/length(IndArray)/SOAlnum)',...
    poslNum*length(TarArray)*length(IndArray),1);
Trials = Conditions;
end
