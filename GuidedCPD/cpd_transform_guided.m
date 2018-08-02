function  T = cpd_transform_guided(Z, Transform, normal)

% T = cpd_transform_guided(Z, Transform, normal);

if  nargin>2, normflag=true; else  normflag=false; end

switch lower(Transform.method)
    case {'rigid_guided','affine_guided'}
        T=Transform.s*(Z*Transform.R')+repmat(Transform.t',[size(Z,1) 1]);
    case {'nonrigid_guided'}
        if  ~normflag,
            T=Transform.s*Z+repmat(Transform.t',[size(Z,1) 1])+cpd_G(Z, Transform.Yorig,Transform.beta)*Transform.W;
        else
            nz = size(Z,1);
            % normalise with possible landmarks
            Y = (Transform.Yorig-ones(size(Transform.Yorig,1),1)*normal.yd)/normal.yscale;
            % normalisation for data
            Z = (Z-ones(nz,1)*normal.yd)/normal.yscale;
            % transformation, Transform.s==1, and ones(nz,1)*Transform.t'
            T = Z + cpd_G(Z,Y,Transform.beta)*Transform.W;
            % denormalise
            T = T*normal.xscale+ones(nz,1)*normal.xd;
        end
end