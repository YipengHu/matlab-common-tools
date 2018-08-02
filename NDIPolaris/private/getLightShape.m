function  p = getLightShape(c,r,shape)


switch  lower(shape(1:3)),
    case  'cir',
        t = linspace(-pi,pi,20)';
        p = [r.*cos(t)+c(1),r.*sin(t)+c(2)];
    case  'tri',
    case  'squ',
end