function T=cpd_transform(Z, Transform);

switch lower(Transform.method)
    case {'rigid','affine'}
            T=Transform.s*(Z*Transform.R')+repmat(Transform.t',[size(Z,1) 1]);
    case 'nonrigid'
            T=Transform.s*Z+repmat(Transform.t',[size(Z,1) 1])+cpd_G(Z, Transform.Yorig,Transform.beta)*Transform.W;
end         
