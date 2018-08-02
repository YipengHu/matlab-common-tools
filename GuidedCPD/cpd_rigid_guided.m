
function [C, R, t, s, sigma2, iter, T] = cpd_rigid_guided(X,Y, gX, gY, ss2, ...
    rot, scale, max_it, tol, viz, outliers, fgt, corresp, sigma2)

[N, D] = size(X); 
M = size(Y,1);  
K = size(gX,1);
if viz, figure; end;
if  (fgt==0), st=''; end;

% Initialization
if ~exist('sigma2','var') || isempty(sigma2) || (sigma2==0), 
    sigma2=(M*trace(X'*X)+N*trace(Y'*Y)-2*sum(X)*sum(Y)')/(M*N*D);
end
sigma2_init=sigma2;

T = [Y;gY]; 
s=1; R=eye(D);

% Optimization
iter=0; ntol=tol+10; L=0;
while (iter<max_it) && (ntol > tol) && (sigma2 > 10*eps)

    L_old=L;
    % Check wheather we want to use the Fast Gauss Transform
    if (fgt==0)  % no FGT
        % [P1,Pt1, PX, L]=cpd_P(X,T, sigma2 ,outliers);
        % [P1,Pt1, PX, L] = cpd_P_m(X,T,sigma2,outliers);
        [P1,Pt1,PX,L] = cpd_P_guided([X;gX],T,sigma2,outliers,K,ss2);
    else         % FGT
        % [P1, Pt1, PX, L, sigma2, st]=cpd_Pfast(X, T, sigma2, outliers, sigma2_init, fgt);
    end

    ntol=abs((L-L_old)/L);
    disp([' CPD Rigid ' st ' : dL= ' num2str(ntol) ', iter= ' num2str(iter) ' sigma2= ' num2str(sigma2)]);


    % Precompute
    Np=sum(Pt1);  
    mu_x=[X;gX]'*Pt1/Np;
    mu_y=[Y;gY]'*P1/Np;

    % Solve for Rotation, scaling, translation and sigma^2
    A=PX'*[Y;gY]-Np*(mu_x*mu_y'); % A= X'P'*Y-X'P'1*1'P'Y/Np;
    [U,S,V]=svd(A); C=eye(D);
    if rot, C(end,end)=det(U*V'); end % check if we need strictly rotation (no reflections)
    R=U*C*V';

    if scale  % check if estimating scaling as well, otherwise s=1
        s=trace(S*C)/(sum(sum([Y;gY].^2.*repmat(P1,1,D))) - Np*(mu_y'*mu_y));
    else
        s=1;
    end

    t=mu_x-s*R*mu_y;

    % Update the GMM centroids
    T=s*[Y;gY]*R'+repmat(t',[M+K,1]);
    
    Np0 = sum(P1(1:end-K));  sigma2save = sigma2;
    sigma2 = abs((sum(sum(X.^2.*repmat(Pt1(1:end-K,:),1,D))) ...
        + sum(sum(T(1:end-K,:).^2.*repmat(P1(1:end-K,:),1,D))) ...
        - 2*trace(PX(1:end-K,:)'*T(1:end-K,:))) /(Np0*D));

    iter=iter+1;
    if  viz, cpd_plot_iter_guided([X;gX],T,K);  end
    
end

% Find the correspondence, such that Y corresponds to X(C,:)
if corresp, C=cpd_Pcorrespondence(X,T,sigma2save,outliers); else C=0; end;



