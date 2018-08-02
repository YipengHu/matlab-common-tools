function  PtsPlot_tmp(x,y,lmx,lmy,titlename)

if  nargin<5, titlename='point/landmark plot'; end  

figure, axis equal, hold on; title(titlename);
plot(x(:,1),x(:,2),'.r')
plot(y(:,1),y(:,2),'.g')
plot(lmx(:,1),lmx(:,2),'or','markersize',10,'linewidth',2)
plot(lmy(:,1),lmy(:,2),'og','markersize',10,'linewidth',2)

