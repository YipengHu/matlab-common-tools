
function  [C, W, sigma2, iter, T] = cpd_GRBF_guided(X, Y, gX, gY, ss2, ...
    beta, lambda, max_it, tol, viz, outliers, fgt, corresp,sigma2)

[N,D]=size(X); M=size(Y,1); K=size(gX,1);
if  (fgt==0), st=''; end;

% Initialization
iter=0;  ntol=tol+10; 
if ~exist('sigma2','var') || isempty(sigma2) || (sigma2==0), 
    sigma2=(M*trace(X'*X)+N*trace(Y'*Y)-2*sum(X)*sum(Y)')/(M*N*D);
end
sigma2_init=sigma2;

% Construct affinity matrix G
G = cpd_G([Y;gY],[Y;gY],beta);  % G = cpd_G(Y,Y,beta);

L=1;
T = [Y;gY]; W=zeros(M+K,D);
while (iter<max_it) && (ntol > tol) && (sigma2 > 1e-8) %(sigma2 > 1e-8)
%while (iter<max_it)  && (sigma2 > 1e-8) %(sigma2 > 1e-8)

    L_old=L;
    % Check wheather we want to use the Fast Gauss Transform
    if  (fgt==0)  % no FGT
        % [P1, Pt1, PX, L] = cpd_P_m(X,T(1:M,:), sigma2 ,outliers);
        % [P1, Pt1, PX, L] = cpd_P(X,T, sigma2 ,outliers);   % mex file
        [P1,Pt1, PX, L] = cpd_P_guided([X;gX],T,sigma2,outliers,K,ss2);
    else          % FGT
        [P1, Pt1, PX, L, sigma2, st]=cpd_Pfast(X, T, sigma2, outliers, sigma2_init, fgt);
    end
    
    L=L+lambda/2*trace(W'*G*W);
    ntol=abs((L-L_old)/L);
    disp([' CPD nonrigid ' st ' : dL= ' num2str(ntol) ', iter= ' num2str(iter) ' sigma2= ' num2str(sigma2)]);


    % M-step. Solve linear system for W.

    dP = spdiags(P1,0,M+K,M+K); % precompute diag(P)
    W = (dP*G+lambda*sigma2*eye(M+K)) \ (PX-dP*[Y;gY]);
    
    % % same, but solve symmetric system, this can be a bit faster
    % % but can have roundoff errors on idP step. If you want to speed up
    % % use rather a lowrank version: opt.method='nonrigid_lowrank'.
    %
    % idP=spdiags(1./P1,0,M,M); 
    % W=(G+lambda*sigma2*idP)\(idP*PX-Y)

    % update Y postions
    T = [Y;gY] + G*W;

    Np = sum(P1(1:end-K,:));  sigma2save = sigma2;
    sigma2 = abs((sum(sum(X.^2.*repmat(Pt1(1:end-K,:),1,D))) ...
        + sum(sum(T(1:end-K,:).^2.*repmat(P1(1:end-K,:),1,D))) ...
        - 2*trace(PX(1:end-K,:)'*T(1:end-K,:))) /(Np*D));

    iter=iter+1;
    
    % Plot the result on current iteration
    if  viz, cpd_plot_iter_guided([X;gX],T,K);  end

end


disp('CPD registration succesfully completed.');

%Find the correspondence, such that Y corresponds to X(C,:)
if corresp, C=cpd_Pcorrespondence(X,T,sigma2save,outliers); else C=0; end;
