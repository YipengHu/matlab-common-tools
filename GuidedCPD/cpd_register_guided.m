

function [Transform, normal] = cpd_register_guided(X, Y, opt)


[M,D]=size(Y); [N, D2]=size(X); 
% Check the input options and set the defaults
if nargin<2, error('cpd_rigid_register.m error! Not enough input parameters.'); end;
if nargin<3, opt.method='nonrigid'; end;
if ~isfield(opt,'method') || isempty(opt.method), opt.method = 'rigid'; end;
if ~isfield(opt,'normalize') || isempty(opt.normalize), opt.normalize = 1; end;
if ~isfield(opt,'max_it') || isempty(opt.max_it), opt.max_it = 150; end;
if ~isfield(opt,'tol') || isempty(opt.tol), opt.tol = 1e-5; end;
if ~isfield(opt,'viz') || isempty(opt.viz), opt.viz = 0; end;
if ~isfield(opt,'corresp') || isempty(opt.corresp), opt.corresp = 0; end;
if ~isfield(opt,'outliers') || isempty(opt.outliers), opt.outliers = 0.1; end;
if ~isfield(opt,'fgt') || isempty(opt.fgt), opt.fgt = 0; end;
if ~isfield(opt,'sigma2') || isempty(opt.sigma2), opt.sigma2 = 0; end;

% strictly rigid params
if ~isfield(opt,'rot') || isempty(opt.rot), opt.rot = 1; end;
if ~isfield(opt,'scale') || isempty(opt.scale), opt.scale = 1; end;
% strictly non-rigid params
if ~isfield(opt,'beta') || isempty(opt.beta), opt.beta = 1; end;
if ~isfield(opt,'lambda') || isempty(opt.lambda), opt.lambda = 1; end;
% lowrank app param
if ~isfield(opt,'numeig') || isempty(opt.numeig), opt.numeig = round(sqrt(M)); end;
if ~isfield(opt,'eigfgt') || isempty(opt.eigfgt), opt.eigfgt = 0; end;
% guided hyper params
if ~isfield(opt,'ss2') || isempty(opt.eigfgt), opt.ss2 = 1e-1; end;

% checking for the possible errors
if D~=D2, error('The dimension of point-sets is not the same.'); end;
if (D>M)||(D>N), disp('The dimensionality is larger than the number of points. Possibly the wrong orientation of X and Y.'); end;
if (M>1e+5)||(N>1e+5) && (opt.fgt==0), disp('The data sets are large. Use opt.fgt=1 to speed up the process.'); end;
if (M>1e+5)||(N>1e+5) && strcmpi(opt.method,'nonrigid'), disp('The data sets are large. Use opt.method=''nonrigid_lowrank'' to speed up the non-rigid registration'); end;
if (D<=1) || (D>3), opt.viz=0; end;
if (opt.normalize==1)&&(opt.scale==0),opt.scale=1; end;

% check if mex functions are compiled yet
% if ~exist('cpd_P','file')
%     disp('Looks like you have not compiled CPD mex files yet (needs to be done once)');
%     disp('Running cpd_make.m for you ...'); tic;
%     cpd_make;
% end

% Convert to double type, save Y
X=double(X);  
Y=double(Y); Yorig=Y; 

% Normalize to zero mean and unit variance
% normalisation includes landmarks
if  opt.normalize,
    if  all(isfield(opt,{'gX','gY'})) && strcmpi(opt.method(end-5:end),'guided'),
        K = size(opt.gX,1);
        Yorig = [Yorig;opt.gY];
        [X,Y,normal] = cpd_normalize([X;opt.gX],[Y;opt.gY]);
        opt.gX=X(end-K+1:end,:); opt.gY=Y(end-K+1:end,:);
        X=X(1:N,:);  Y=Y(1:M,:);
    else
        [X,Y,normal] = cpd_normalize(X,Y);
    end
else
    normal = [];
end;

disp(['%%%%% Starting CPD-' upper(opt.method) ' registration. %%%' ]); tic;

%%%% Choose the method and start CPD point-set registration
switch lower(opt.method),
    
    case 'rigid'
        [C, R, t, s, sigma2, iter, T] = cpd_rigid(X,Y, opt.rot, opt.scale, opt.max_it, opt.tol, opt.viz, opt.outliers, opt.fgt, opt.corresp, opt.sigma2);
    case 'affine'
        [C, R, t, sigma2, iter, T] = cpd_affine(X,Y, opt.max_it, opt.tol, opt.viz, opt.outliers, opt.fgt, opt.corresp, opt.sigma2); s=1;
    case 'nonrigid'
        [C, W, sigma2, iter, T] = cpd_GRBF(X, Y, opt.beta, opt.lambda, opt.max_it, opt.tol, opt.viz, opt.outliers, opt.fgt, opt.corresp, opt.sigma2);
    case 'nonrigid_lowrank'
        [C, W, sigma2, iter, T] = cpd_GRBF_lowrank(X, Y, opt.beta, opt.lambda, opt.max_it, opt.tol, opt.viz, opt.outliers, opt.fgt, opt.numeig, opt.eigfgt, opt.corresp, opt.sigma2);
    
    case 'rigid_guided'
        [C, R, t, s, sigma2, iter, T] = cpd_rigid_guided(X, Y, opt.gX, opt.gY, opt.ss2, ...
            opt.beta, opt.lambda, opt.max_it, opt.tol, opt.viz, opt.outliers, opt.fgt, opt.corresp, opt.sigma2);
    case 'affine_guided'
        [C, R, t, sigma2, iter, T] = cpd_affine_guided(X,Y, opt.gX, opt.gY, opt.ss2, ...
            opt.max_it, opt.tol, opt.viz, opt.outliers, opt.fgt, opt.corresp, opt.sigma2); s=1;
    case 'nonrigid_guided'
        [C, W, sigma2, iter, T] = cpd_GRBF_guided(X, Y, opt.gX, opt.gY, opt.ss2, ...
            opt.beta, opt.lambda, opt.max_it, opt.tol, opt.viz, opt.outliers, opt.fgt, opt.corresp, opt.sigma2);
    
    otherwise
        error('The opt.method value is invalid. Supported methods are: rigid, affine, nonrigid, nonrigid_lowrank');
end
%%%%
disptime(toc);

Transform.iter=iter;
Transform.method=opt.method;
Transform.Y=T;

% Denormalize transformation parameters
switch lower(opt.method)
    case {'rigid','affine'}
        Transform.R=R; Transform.t=t;Transform.s=s;
        if opt.normalize, % denormalize parameters and registered point set, if it was prenormalized
            Transform.s=Transform.s*(normal.xscale/normal.yscale);
            Transform.t=normal.xscale*Transform.t+normal.xd'-Transform.s*(Transform.R*normal.yd');
            Transform.Y=T*normal.xscale+repmat(normal.xd,M,1);
        end;
    case {'rigid_guided','affine_guided'}
        Transform.R=R; Transform.t=t;Transform.s=s;
        if opt.normalize, % denormalize parameters and registered point set, if it was prenormalized
            Transform.s=Transform.s*(normal.xscale/normal.yscale);
            Transform.t=normal.xscale*Transform.t+normal.xd'-Transform.s*(Transform.R*normal.yd');
            Transform.Y=T(1:M,:)*normal.xscale+repmat(normal.xd,M,1);
        end;
    case {'nonrigid','nonrigid_lowrank','nonrigid_guided'}
            Transform.beta=opt.beta;
            Transform.W=W;
            Transform.Yorig=Yorig;  % must include laandmarks for transformation; Yorig(1:M,:);
            Transform.s=1;
            Transform.t=zeros(D,1);
            Transform.M=M;
            if opt.normalize,
                % Transform.Y=T*normal.xscale+repmat(normal.xd,M,1);
                Transform.Y=T(1:M,:)*normal.xscale+repmat(normal.xd,M,1);
            end
            %         if opt.normalize,
            %             Transform=cpd_denormalize(Transform, normal);
            %             Transform.Y=cpd_transform(Yorig, Transform);
            %         end
%     case {'nonrigid_guided'}
%         Transform.beta=opt.beta;
%         Transform.W=W;
%         Transform.Yorig=Yorig;
%         Transform.s=1;
%         Transform.t=zeros(D,1);
%         if opt.normalize,
%             Transform.Y=T(1:M,:)*normal.xscale+repmat(normal.xd,M,1);
%         end
end




