function  SrfPlot_tmp(x,y,lmx,lmy,trix,triy,fancy,titlename)

if  nargin<6, fancy=true; end  % ;)
if  nargin<7, titlename='surface/landmark plot'; end  

figure, axis equal, hold on; title(titlename)
h1 = patch('vertices',x,'faces',trix,'facecolor','none','edgecolor','r','edgealpha',.2);
h2 = patch('vertices',y,'faces',triy,'facecolor','none','edgecolor','g','edgealpha',.2);
plot3(lmx(:,1),lmx(:,2),lmx(:,3),'.r','markersize',50)
plot3(lmy(:,1),lmy(:,2),lmy(:,3),'.g','markersize',50)
view(3)

if  fancy, 
    set(h1,'facecolor','r'); 
    set(h2,'facecolor','g'); 
    set([h1,h2],'edgecolor','none','facealpha',.2)
    light; lighting phong;
end


