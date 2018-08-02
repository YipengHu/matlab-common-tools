
function [C, B, t, sigma2, iter, T] = cpd_affine_guided(X,Y, gX, gY, ss2, ...
    max_it, tol, viz, outliers, fgt, corresp, sigma2)

if (fgt==0), st=''; end
[N, D]=size(X);[M, D]=size(Y);
K=size(gX,1);

% Initialize sigma and Y
if ~exist('sigma2','var') || isempty(sigma2) || (sigma2==0), 
    sigma2=(M*trace(X'*X)+N*trace(Y'*Y)-2*sum(X)*sum(Y)')/(M*N*D);
end
sigma2_init=sigma2;

T=[Y;gY];

% Optimization
iter=0; ntol=tol+10; L=1;
while (iter<max_it) && (ntol > tol) && (sigma2 > 10*eps)

    L_old=L;

    % Check wheather we want to use the Fast Gauss Transform
    if (fgt==0)  % no FGT
        % [P1,Pt1, PX, L]=cpd_P(X,T, sigma2 ,outliers); st='';
        [P1,Pt1,PX,L] = cpd_P_guided([X;gX],T,sigma2,outliers,K,ss2);
    else         % FGT
        [P1, Pt1, PX, L, sigma2, st]=cpd_Pfast([X;gX], T, sigma2, outliers, sigma2_init, fgt);
    end
    
    ntol=abs((L-L_old)/L);
    disp([' CPD Affine ' st ' : dL= ' num2str(ntol) ', iter= ' num2str(iter) ' sigma2= ' num2str(sigma2)]);
  
    % Precompute 
    Np=sum(P1);
    mu_x=[X;gX]'*Pt1/Np;
    mu_y=[Y;gY]'*P1/Np;


    % Solve for parameters
    B1=PX'*[Y;gY]-Np*(mu_x*mu_y');
    B2=([Y;gY].*repmat(P1,1,D))'*[Y;gY]-Np*(mu_y*mu_y');
    B=B1/B2; % B= B1 * inv(B2);
    
    
    t=mu_x-B*mu_y;
    
%     sigma2save=sigma2;
%     sigma2=abs(sum(sum([X;gX].^2.*repmat(Pt1,1,D)))- Np*(mu_x'*mu_x) -trace(B1*B'))/(Np*D); 
    % abs here to prevent roundoff errors that leads to negative sigma^2 in
    % rear cases
    
    % Update centroids positioins
    T=[Y;gY]*B'+repmat(t',[M+K,1]);
    
    % update sigma2
    Np0 = sum(P1(1:end-K));  sigma2save = sigma2;
    sigma2 = abs((sum(sum(X.^2.*repmat(Pt1(1:end-K,:),1,D))) ...
        + sum(sum(T(1:end-K,:).^2.*repmat(P1(1:end-K,:),1,D))) ...
        - 2*trace(PX(1:end-K,:)'*T(1:end-K,:))) /(Np0*D));

    iter=iter+1;
    if  viz, cpd_plot_iter_guided([X;gX],T,K);  end
    
end

% Find the correspondence, such that Y(C) corresponds to X
if corresp, C=cpd_Pcorrespondence(X,T,sigma2save,outliers); else C=0; end;


