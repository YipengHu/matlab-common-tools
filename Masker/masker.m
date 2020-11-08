% For viewing only:
%  masker(image_vol);
%  masker(image_vol, label_vol);
%       image_vol - 2d or 3d intensity image
%       label_vol - 2d or 3d mask with defalut cutoff=0.5
%
%Return edited/segmented mask, requiring hanging the command line:
%  label_out = masker(image_vol);
%  label_out = masker(image_vol, label_vol);
%
%Save variable "label_out" in specified filenname:
%  masker(image_vol, label_vol, filename);
%  label_out = masker(image_vol, label_vol, filename);
%
% GUI shortcuts:
%  Mouse scroll: change slice (the 3rd dimension) of the volume(s);
%  Left-click: labeling
%  Right-click: removing labeling
%  "s" + scroll: brush size
%  "c" + scroll: image intensity contrast
%  "a" + scroll: label transparency
%
% No toolbox dependency, MATLAB R2016* or newer for good graphic performance

% Yipeng Hu (yipeng.hu@ucl.ac.uk) August 2017
% UCL Centre for Medical Image Computing

function  label_vol = masker(image_vol, label_vol, filename, fig_pos, flag_msgbox)

%% configuration
CSelection = {[.1,.3,.7], [.6,.5,1], [.3,.9,.2]};
MaskColour = CSelection{random('unid',length(CSelection))};  % fix this if needs to
BrushSizeRange = [1,100,1];  % [min,max,step]
MaskCutoff = 1e-4;

if nargin<4, fig_pos=[]; end
if nargin<3, filename=[]; end  % do not write file. ['masker-mask-',num2str(now),'.mat']
size_image = size(image_vol);
if length(size_image)==2, size_image(3)=1; end
if nargin<2 || isempty(label_vol)
    label_vol = false(size_image);
elseif any(size_image(1:end-(size_image(3)==1))~=size(label_vol))
    error('Incompatible sizes between image and label.');
else
    label_vol = label_vol>=MaskCutoff;
end
image_vol = single(image_vol);
image_vol = (image_vol-min(image_vol(:)))./(max(image_vol(:))-min(image_vol(:)));

%% dynamic variables
idx_slice = 1;
idx_alpha = 0.5;  % [0,1]
idx_contrast = 1;  % [0,2]
BrushSize = BrushSizeRange(1)+BrushSizeRange(3)*2;
ButtonHold.Left = false;
ButtonHold.Right = false;
KeyHold.a = false;
KeyHold.s = false;
KeyHold.c = false;

%% pre-compute the coordinates
[xc,yc] = meshgrid(1:size_image(2),1:size_image(1));

%% build a GUI
hFigure = figure('Name','The little masker','Unit','Normalized', ...
    'NumberTitle','off','MenuBar','none', 'Toolbar','none');
if ~isempty(fig_pos), set(hFigure,'Position', fig_pos); end
hAxes = axes('parent',hFigure,'Unit','Normalized','Position',[0,0,1,1], ...
    'XGrid','off','YGrid','off','ZGrid','off');
axis(hAxes,'off');
% image
hImage = imagesc(zeros(size_image([1,2]),'single'),'Parent',hAxes);
updateDisplaySlice;
colormap(hAxes,'gray'); axis(hAxes,'equal','tight','manual');
% brush
BrushPoints = zeros(36,2);
updateBurshShape;
hold(hAxes,'on');
hBrush = plot(BrushPoints(:,1),BrushPoints(:,2),'.','linewidth',1);
set(hBrush,'color',MaskColour)
CurrentAxesPoint = get(hAxes,'CurrentPoint');
updateBrush(CurrentAxesPoint(1,:));

% user guide
if nargin<5 || isempty(flag_msgbox), flag_msgbox=true; end

if flag_msgbox
    msgbox({
        'Mouse scroll: change slice';
        'Left-click: labeling';
        'Right-click: removing labeling';
        '"s" + scroll: brush size';
        '"c" + scroll: image intensity contrast';
        '"a" + scroll: label transparency'}, 'The little masker guide');
end

%% figure callbacks
set(hFigure,'WindowScrollWheelFcn',@Callback_Figure_Scroll);
set(hFigure,'WindowButtonDownFcn',@Callback_Figure_MouseButtonDown);
set(hFigure,'WindowButtonUpFcn',@Callback_Figure_MouseButtonUp);
set(hFigure,'WindowButtonMotionFcn',@Callback_Figure_MouseMotion);
set(hFigure,'KeyPressFcn',@Callback_Figure_KeyPress);
set(hFigure,'KeyReleaseFcn',@Callback_Figure_KeyRelease);
set(hFigure,'DeleteFcn',@Callback_Figure_Delete);
% set(hFigure,'CloseRequestFcn',@Callback_Figure_CloseRequest);

if ~isempty(filename)
    if iscell(filename) && strcmpi(filename{1}(end-2:end),'.h5')
        fprintf('masker: File to be saved in:\n    %s\n',filename{1});
    end
else
    fprintf('masker: File to be saved in:\n    %s\n',filename);
end

if (nargout>0); waitfor(hFigure); end
return;


%% --- nested ---
    function  Callback_Figure_Delete(~,~)
        if ~isempty(filename)
            
            if iscell(filename) && strcmpi(filename{1}(end-2:end),'.h5')   % save to h5
                h5write(filename{1},filename{2},uint8(label_vol));
                fprintf('masker: Masks saved: %s.\n',filename{1});
            else  % save to mat file
                if exist(filename,'file')
                    filename = [strrep(filename,'.mat',''),num2str(now)];
                end
                save(filename,'label_vol');
                fprintf('masker: Masks saved: %s.\n',filename);
            end
        end
    end

%     function  Callback_Figure_CloseRequest(~,~)
%         % setappdata(hFigure,'label_vol',label_vol);
%         % assignin('caller','label_out',label_vol)
%         % label_out = label_vol;
%         % delete(gcf);
%     end

    function  updateDisplaySlice
        r_slice = image_vol(:,:,idx_slice)*idx_contrast+(label_vol(:,:,idx_slice)*idx_alpha*MaskColour(1));
        g_slice = image_vol(:,:,idx_slice)*idx_contrast+(label_vol(:,:,idx_slice)*idx_alpha*MaskColour(2));
        b_slice = image_vol(:,:,idx_slice)*idx_contrast+(label_vol(:,:,idx_slice)*idx_alpha*MaskColour(3));
        set(hImage,'CData',cat(3,r_slice,g_slice,b_slice))
    end

    function  updateBurshShape
        t = linspace(-pi,pi,36);
        BrushPoints(:,1) = cos(t)*BrushSize;
        BrushPoints(:,2) = sin(t)*BrushSize;
    end

    function  updateBrush(p)
        hBrush.XData = BrushPoints(:,1)+p(1);
        hBrush.YData = BrushPoints(:,2)+p(2);
    end

    function  applyBrush(p,flag_add)
        label_new = ((xc-p(1)).^2+(yc-p(2)).^2)<=(BrushSize^2);
        if  flag_add
            label_vol(:,:,idx_slice) = label_vol(:,:,idx_slice) | label_new;
        else
            label_vol(:,:,idx_slice) = label_vol(:,:,idx_slice) .* ~label_new;
        end
    end

    function  Callback_Figure_Scroll(~,eventdata)
        if KeyHold.a  % change alpha
            idx_alpha = idx_alpha - eventdata.VerticalScrollCount * 0.1;
            if (idx_alpha<0); idx_alpha=0; return; end
            if (idx_alpha>1); idx_alpha=1; return; end
            updateDisplaySlice;
            return;
        end
        if KeyHold.s  % change size
            BrushSize = BrushSize - eventdata.VerticalScrollCount * BrushSizeRange(3);
            if (BrushSize<BrushSizeRange(1)); BrushSize=BrushSizeRange(1); return; end
            if (BrushSize>BrushSizeRange(2)); BrushSize=BrushSizeRange(2); return; end
            updateBurshShape;   % CurrentAxesPoint = get(hAxes,'CurrentPoint');  % TODO: a strange bug here
            updateBrush(CurrentAxesPoint(1,:));
            return;
        end
        if KeyHold.c  % change alpha
            idx_contrast = idx_contrast - eventdata.VerticalScrollCount * 0.1;
            if (idx_contrast<0); idx_contrast=0; return; end
            if (idx_contrast>2); idx_contrast=2; return; end
            updateDisplaySlice;
            return;
        end
        % otherwise browse
        idx_slice = idx_slice + eventdata.VerticalScrollCount;
        if (idx_slice<1); idx_slice=1; return; end
        if (idx_slice>size_image(3)); idx_slice= size_image(3); return; end
        updateDisplaySlice;
        fprintf('masker: Slice = %d/%d.\n',idx_slice,size_image(3));
    end

    function  Callback_Figure_MouseMotion(~,~)
        CurrentAxesPoint = get(hAxes,'CurrentPoint');
        updateBrush(CurrentAxesPoint(1,:));
        if ButtonHold.Left  % add
            applyBrush(CurrentAxesPoint(1,:),true);
            updateDisplaySlice;
        end
        if ButtonHold.Right  % delete
            applyBrush(CurrentAxesPoint(1,:),false);
            updateDisplaySlice;
        end
    end

    function  Callback_Figure_MouseButtonDown(hObject,~)
        CurrentAxesPoint = get(hAxes,'CurrentPoint');
        switch  lower(get(hObject,'SelectionType'))
            case  'alt'
                ButtonHold.Right = true;
                ButtonHold.Left = false;
                applyBrush(CurrentAxesPoint(1,:),false);
                updateDisplaySlice;
                updateBrush(CurrentAxesPoint(1,:));
            case  'normal'
                ButtonHold.Left = true;
                ButtonHold.Right = false;
                applyBrush(CurrentAxesPoint(1,:),true);
                updateDisplaySlice;
                updateBrush(CurrentAxesPoint(1,:));
        end
    end

    function  Callback_Figure_MouseButtonUp(~,~)
        ButtonHold.Right = false;
        ButtonHold.Left = false;
    end

    function  Callback_Figure_KeyPress(~,eventdata)
        KeyHold = structfun(@(x) and(x,false), KeyHold, 'Uniform',false);
        KeyHold.(lower(eventdata.Key)) = true;
    end

    function  Callback_Figure_KeyRelease(~,eventdata)
        KeyHold.(lower(eventdata.Key)) = false;
    end


end  % global function
