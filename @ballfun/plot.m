function varargout = plot(f, varargin)
%PLOT   Plot a BALLFUN on the ball
%
%   PLOT(f, 'slices') plot a BALLFUN and its slices on the planes X-Y, Y-Z
%   and X-Z.
%
%   PLOT(f, 'WedgeAz') plot a BALLFUN with a wedge in the azimuthal
%   (longitude) direction removed.
%
%   PLOT(f, 'WedgePol') plot a BALLFUN with a wedge in the polar
%   (latitude) direction removed.
%
% EXAMPLES:
%   f = cheb.galleryball;
%   plot(f)
%   plot(f, 'slices')   
%   plot(f, 'WedgeAz')
%   plot(f, 'WedgePol')
%
% See also BALLFUN/SURF

% Copyright 2019 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

if ( nargin == 1 )
    h = plotBall(f);
elseif ( nargin == 2 ) && ( strcmpi(varargin{1},'slices') || strcmpi(varargin{1},'slice') )
    h = plotSlices(f);
elseif ( nargin == 2 ) && ( strcmpi(varargin{1},'wedgeaz') )
    h = plotWedgeAz(f);
elseif ( nargin == 2 ) && ( strcmpi(varargin{1},'wedgepol') )
    h = plotWedgePol(f);
else
    error('CHEBFUN:BALLFUN:plot:input Invalid input arguments')
end

if ( nargout > 0 )
    varargout = { h }; 
end

end

function h = plotBall(f)
% Plot a BALLFUN function on the ball

% Copyright 2018 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

% Define the size of F: 
[m,n,p] = size(f);

% m >= 25 and n, p >= 28
m = 25*(m < 25) + m*(m >= 25);
n = 28*(n < 28) + n*(n>=28);
p = 28*(p < 28) + p*(p>=28);

% Impose m = 1 [6] and n, p = 0 [4] to avoid errors in the plot
m = m + mod(1-mod(m,6),6);
n = n + mod(4-mod(n,4),4);
p = p + mod(4-mod(p,4),4);

% Get the coeffs of the ballfun function F(r,lam,th), lam is the
% azimuthal variable in [-pi,pi] and theta the polar variable in [0,pi]
F = coeffs3(f, m, n, p);

% Convert to values
ff = real(ballfun.coeffs2vals(F));

% Permute lambda and theta
ff = permute(ff,[1 3 2]);

% Evaluation points
r   = chebpts( m );
lam  = [pi*trigpts( n ); pi];
th = [pi*trigpts( p );pi]-pi/2;

% Remove doubled-up data
r = r(floor(m/2)+1:end);
th = th(floor(p/2)+1:end);

% Reverse theta : 1st element of the array is theta = pi (South Pole), last element is
% th = 0 (not included) (North Pole)
ff  = ff(floor(m/2)+1:end,[1 end:-1:floor(p/2)+1],:);
ff(:,:,end+1) = ff(:,:,1);

% Define the meshgrid
[tt, rr, ll] = meshgrid(th, r, lam);

% Slices in the cylinder to plot
% Find the indice of r = 0.5
[~,idr]=min(abs(r-0.5));
rslice = rr(idr,1,1);
tslice = tt(1,[1,floor(p/4)+1],1);
lslice = ll(1,1,[1,floor(n/4)+1]);

hslicer = slice(tt,rr,ll,ff,tslice,rslice,lslice);

hold on
for j = 1:numel(hslicer)
    h = hslicer(j);
    [xs,ys,zs] = sph2cart(h.ZData,h.XData,h.YData);
    h = surf(xs,ys,zs,h.CData,'EdgeColor','none','FaceColor','Interp');
end
delete(hslicer);
hold off

axis([-1 1 -1 1 -1 1])
daspect([1 1 1])

camlight;
lighting phong;
material dull;

end

function h = plotSlices(f)
% Plot a BALLFUN function on the ballfun and its slices

% Plot f on the plane X-Y
subplot(2,2,2);
h1 = plot(diskfun(f,'z'));
colorbar
xlabel('X')
ylabel('Y')

% Plot f on the plane X-Z
subplot(2,2,3);
h2 = plot(diskfun(f,'y'));
colorbar
xlabel('X')
ylabel('Z')

% Plot f on the plane Y-Z
subplot(2,2,4);
h3 = plot(diskfun(f,'x'));
colorbar
xlabel('Y')
ylabel('Z')

% Plot f
subplot(2,2,1);
h4 = plotBall(f);
colorbar

h = {h1, h2, h3, h4};
end

function h = plotWedgeAz(f)
% Plot a BALLFUN with a wedge in the azimuthal direction removed

% Is the plot currently being held?
plotOnHold = ishold;
% Default plotting options
defaultOpts = {'facecolor', 'interp','edgecolor', 'none'};

% Azimuthal (longitude) values to include.  TODO: Make these optional inputs
az_intvl = [-pi/2 pi];

% Define the size of f: 
[m,n,p] = size(f);

% m >= 25 and n, p >= 28
m = 25*(m < 25) + m*(m >= 25);
n = 28*(n < 28) + n*(n>=28);
p = 28*(p < 28) + p*(p>=28);

% Impose m = 1 [6] and n, p = 0 [4] to avoid errors in the plot
m = m + mod(1-mod(m,6),6);
n = n + mod(4-mod(n,4),4);
p = p + mod(4-mod(p,4),4);

% Construct the values of lambda and theta to plot on the outer sphere (r=1)
lam = linspace(az_intvl(1),az_intvl(2),n);
th = linspace(0,pi,p)';

% Evaluate the function on the outer sphere
ff = permute(fevalm(f,1,lam,th),[3 2 1]);

% Plot the result
h = surf(sin(th)*cos(lam),sin(th)*sin(lam),cos(th)*ones(1,n),ff,defaultOpts{:});
hold on

% Construct the values of r and theta to plot from the origin to the outer
% sphere (r=1).
r = chebpts(m); r = r(floor(m/2)+1:end); th = th';

% Evaluate the function on the wedge from the origin along the az_intvl(1).
ff = permute(fevalm(f,r,lam(1),th),[1 3 2]);
% Plot the result
surf(r*sin(th)*cos(lam(1)),r*sin(th)*sin(lam(1)),ones(size(r))*cos(th),ff,defaultOpts{:})

% Evaluate the function on the wedge from the origin along the az_intvl(2).
ff = permute(fevalm(f,r,lam(end),th),[1 3 2]);
% Plot the result
surf(r*sin(th)*cos(lam(end)),r*sin(th)*sin(lam(end)),ones(size(r))*cos(th),ff,defaultOpts{:})

if ~plotOnHold
    hold off;
end

camlight;
lighting phong;
material dull;

axis([-1 1 -1 1 -1 1])
daspect([1 1 1])
end

function h = plotWedgePol(f)
% Plot a BALLFUN with a wedge in the polar direction removed

% Is the plot currently being held?
plotOnHold = ishold;
% Default plotting options
defaultOpts = {'facecolor', 'interp','edgecolor', 'none'};

% Polar (latitude) values to include.  TODO: Make these optional inputs
pol_intvl = [pi/2 pi];
% Azimuthal (longitude) values to include.  TODO: Make these optional inputs
az_intvl = [0 pi];

% Define the size of f: 
[m,n,p] = size(f);

% m >= 25 and n, p >= 28
m = 25*(m < 25) + m*(m >= 25);
n = 28*(n < 28) + n*(n>=28);
p = 28*(p < 28) + p*(p>=28);

% Impose m = 1 [6] and n, p = 0 [4] to avoid errors in the plot
m = m + mod(1-mod(m,6),6);
n = n + mod(4-mod(n,4),4);
p = p + mod(4-mod(p,4),4);

% Construct the values of lambda and theta to plot on the outer sphere (r=1)
% where the sphere is closed
lam = linspace(-pi,pi,n);
th = linspace(pol_intvl(1),pol_intvl(2),p)';

% Evaluate the function on the outer sphere
ff = permute(fevalm(f,1,lam,th),[3 2 1]);

% Plot the result
h = surf(sin(th)*cos(lam),sin(th)*sin(lam),cos(th)*ones(1,n),ff,defaultOpts{:});
hold on

% Construct the values of lambda and theta to plot on the outer sphere (r=1)
% where the sphere is open at the wedge
lam = linspace(az_intvl(1),az_intvl(2),n);
th = linspace(0,pol_intvl(1),p)';

% Evaluate the function on the outer sphere
ff = permute(fevalm(f,1,lam,th),[3 2 1]);

% Plot the result
surf(sin(th)*cos(lam),sin(th)*sin(lam),cos(th)*ones(1,n),ff,defaultOpts{:})

% Construct the values of r and theta to plot from the origin to the outer
% sphere (r=1).
r = chebpts(m); r = r(floor(m/2)+1:end); th = linspace(0,pol_intvl(1),p);

% Evaluate the function on the wedge from the origin along the az_intvl(1).
ff = permute(fevalm(f,r,lam(1),th),[1 3 2]);
% Plot the result
surf(r*sin(th)*cos(lam(1)),r*sin(th)*sin(lam(1)),ones(size(r))*cos(th),ff,defaultOpts{:})

% Construct the values of r and theta to plot from the origin to the outer
% sphere (r=1).
r = chebpts(m); r = r(floor(m/2)+1:end); th = linspace(0,pol_intvl(1),p);

% Evaluate the function on the wedge from the origin along the az_intvl(1).
ff = permute(fevalm(f,r,lam(end),th),[1 3 2]);
% Plot the result
surf(r*sin(th)*cos(lam(end)),r*sin(th)*sin(lam(end)),ones(size(r))*cos(th),ff,defaultOpts{:})

% Construct the values of r and lambda to plot from the origin to the outer
% sphere (r=1): slice along
r = chebpts(m); r = r(floor(m/2)+1:end); lam = linspace(-pi,pi,p);

% Evaluate the function on the wedge from the origin along the az_intvl(2).
ff = fevalm(f,r,lam,pol_intvl(1));
% Plot the result
surf(r*sin(pol_intvl(1))*cos(lam),r*sin(pol_intvl(1))*sin(lam),r*cos(pol_intvl(1))*ones(size(lam)),ff,defaultOpts{:})

if ~plotOnHold
    hold off;
end

camlight;
lighting phong;
material dull;

axis([-1 1 -1 1 -1 1])
daspect([1 1 1])
end

