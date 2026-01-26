function canvas = drawgradient(rlength, pxlpdg, bgcolor)
% Draw a gradient with given params
%     radius = rlength * pxlpdg ; sidelength = 2 * radius; 
%     [drawx, drawy] = meshgrid(1:sidelength,1:sidelength);
%     drawxc = sidelength/2; drawyc  = sidelength/2;
%     circle = ((drawx-drawxc).^2 + (drawy-drawyc).^2) < radius^2;
%     filtered =  eval(sprintf('log10(sqrt((drawx-drawxc).^2 + (drawy-drawyc).^2)/10+1)'));
%     canvas = ones(sidelength)*0;
%     gradient = canvas.*(1-filtered);
%     canvas(circle) = gradient(circle);
%     canvas(canvas<bgcolor) = 0; canvas(~circle) = 0;

    radius = rlength * pxlpdg ; sidelength = 2 * radius; 
    [drawx, drawy] = meshgrid(1:sidelength,1:sidelength);
    drawxc = sidelength/2; drawyc  = sidelength/2;
    circle = ((drawx-drawxc).^2 + (drawy-drawyc).^2) < radius^2;
    filtered =  eval(sprintf('log10(sqrt((drawx-drawxc).^2 + (drawy-drawyc).^2)/10+1)'));
    canvas = ones(sidelength)*255;
    gradient = canvas.*(1-filtered);
    canvas(circle) = gradient(circle);
    canvas(canvas<0) = 0; canvas(~circle) = 0;
    canvas = canvas / (255/bgcolor) + bgcolor;

%     imshow(canvas/255);
end
