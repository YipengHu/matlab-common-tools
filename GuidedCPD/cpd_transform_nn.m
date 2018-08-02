function  T = cpd_transform_nn(Z, Transform, X, Y)

% T = cpd_normtransform(Z, Transform, X, Y);
% T = cpd_normtransform(Z, Transform, normal); where, [j1,j2,normal] = cpd_normalize(X,Y);

if  nargin>2 && ~isempty(X), normflag=true; else  normflag=false; end

switch lower(Transform.method)
    case {'rigid','affine','rigid_guided','affine_guided'}
        T=Transform.s*(Z*Transform.R')+repmat(Transform.t',[size(Z,1) 1]);
    case {'nonrigid','nonrigid_guided'}
        if  ~normflag,
            T=Transform.s*Z+repmat(Transform.t',[size(Z,1) 1])+cpd_G(Z, Transform.Yorig,Transform.beta)*Transform.W;
        else
            nz = size(Z,1);
            if  isstruct(X),
                normal = X;
                Y = (Transform.Yorig-ones(size(Transform.Yorig,1),1)*normal.yd)/normal.yscale;
            else
                [X,Y,normal]=cpd_normalize(X,Y);
            end
            % normalisation
            Z = (Z-ones(nz,1)*normal.yd)/normal.yscale;
            % transformation, Transform.s==1, and ones(nz,1)*Transform.t'
            T = Z + cpd_G(Z,Y,Transform.beta)*Transform.W;
            % denormalise
            T = T*normal.xscale+ones(nz,1)*normal.xd;
        end
end