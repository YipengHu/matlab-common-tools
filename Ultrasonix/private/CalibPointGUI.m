function  pts = CalibPointGUI(vol,par_rec)


num_slice = size(vol,3);


%% interactivey get the probe points
slicen = 1;
pts = zeros(0,3);
keepgoing = true;
hfig = figure;
himg = 0.1;  % NB: 0 or 1 can not be used as root handle
while  keepgoing,
    if  ~ishandle(himg),
        himg = imagesc(vol(:,:,slicen)); 
        axis equal tight; colormap('gray');
        htit = title('Left click to define point; Right click for options.');
        hold on; plot(pts(:,1),pts(:,2),'bo');
    end
    [x,y,button] = ginput(1);
    switch  button,
        case  1, % left 
            plot(x,y,'ro');
            pts = [pts;x,y,par_rec(2,slicen)]; %#ok<AGROW>
        case  {2,3}, % middle or right
            answer = questdlg('Would you like to finish the calibration or proceed to next slice?', ...
                'igitkUltrasonix - calibrateUS3D','Finish','Next','Cancel','Cancel');
            switch  answer
                case  'Finish',
                    keepgoing = false;
                    close(hfig);
                case  'Next',
                    if  slicen==num_slice, slicen=1; else slicen=slicen+1; end
                    delete([himg,htit]);
                case  'Cancel',
            end
    end
end