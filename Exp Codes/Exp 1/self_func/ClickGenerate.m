function click = ClickGenerate(sr,dur)
% click = ClickGenerate(sr,dur)
time=linspace(0,dur,sr*dur);
tone=ones(1,size(time,2));
%subplot(3,1,1); plot(time,tone);
click=tone;
end
