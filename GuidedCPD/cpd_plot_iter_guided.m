
function cpd_plot_iter_guided(X, Y, K)

if nargin<2, error('cpd_plot.m error! Not enough input parameters.'); end;
[m, d]=size(Y);

if d>3, error('cpd_plot.m error! Supported dimension for visualizations are only 2D and 3D.'); end;
if d<2, error('cpd_plot.m error! Supported dimension for visualizations are only 2D and 3D.'); end;

% for 2D case
if d==2,
    plot(X(:,1), X(:,2),'r*', Y(:,1), Y(:,2),'bo'); %axis off; axis([-1.5 2 -1.5 2]);
else
    % for 3D case
    plot3(X(1:end-K,1),X(1:end-K,2),X(1:end-K,3),'r.', ...
        Y(1:end-K,1),Y(1:end-K,2),Y(1:end-K,3),'b.', ...
        X(end-K+1:end,1),X(end-K+1:end,2),X(end-K+1:end,3),'rd', ...
        Y(end-K+1:end,1),Y(end-K+1:end,2),Y(end-K+1:end,3),'bd');
end

axis equal; drawnow;