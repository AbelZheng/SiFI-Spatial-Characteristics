try
    % Initiation
    PositionArray = [-60, -45, -30, -15, 0, 15, 30, 45, 60];
   
    % Open up a Screen
    Screen('Preference', 'SkipSyncTests', 2);
    ScreenNumber = max(Screen('Screens')); % count the screens
    AssertOpenGL;
    InitializeMatlabOpenGL;

    background_color = [0 ,0, 0]; % black background
    [wPtr,Rect] = Screen('OpenWindow',ScreenNumber,background_color,[],[],2);
    white=WhiteIndex(wPtr); black=BlackIndex(wPtr);
    Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    slack = Screen('GetFlipInterval',wPtr)/2; % minus a slack when calculating time points
    pxlpdg = round(ResX / 180);

    %% Draw Stimulus
    % draw gradients
    radius = rlength * pxlpdg * 2 ; sidelength = 2 * radius; 
    [drawx, drawy] = meshgrid(1:sidelength,1:sidelength);
    drawxc = sidelength/2; drawyc  = sidelength/2;
    circle = ((drawx-drawxc).^2 + (drawy-drawyc).^2) < radius^2;
    filtered =  eval(sprintf('log10(sqrt((drawx-drawxc).^2 + (drawy-drawyc).^2)/10+1)'));
    canvas = ones(sidelength)*255;
    gradient = canvas.*(1-filtered);
    canvas(circle) = gradient(circle);
    canvas(canvas<0) = 0; canvas(~circle) = 0;
    gradient_canvas = Screen('MakeTexture',wPtr,canvas);

    % draw fixation
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

    for i = 1:length(TargetRects)
        Screen('DrawTexture', wPtr, gradient_canvas, [], TargetRects(i,:));
    end
    
    Screen('Flip', wPtr);

    GetClicks;

    Screen('CloseAll');
catch error
    
end
