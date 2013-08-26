function K = covBlackoutLin(cov, hyp, x, z, i)

% covBurst - Where did the kernel go - linear version
%
% Copyright (c) by James Robert Lloyd 2013-08-16.

if ~numel(cov)==1, error('Burst uses one covariance.'), end
for ii = 1:numel(cov)                        % iterate over covariance functions
  f = cov(ii); if iscell(f{:}), f = f{:}; end   % expand cell array if necessary
  j(ii) = cellstr(feval(f{:}));                          % collect number hypers
end

if nargin<3                                        % report number of parameters
  K = ['4' '+' char(j(1))]; for ii=2:length(cov), K = [K, '+', char(j(ii))]; end, return
end
if nargin<4, z = []; end                                   % make sure, z exists
[n,D] = size(x);
xeqz = numel(z)==0; dg = strcmp(z,'diag') && numel(z)>0;        % determine mode
if xeqz
    z = x;
end

v = [];               % v vector indicates to which covariance parameters belong
for ii = 1:length(cov), v = [v repmat(ii, 1, eval(char(j(ii))))]; end

location = hyp(1);
t_width = exp(hyp(2)); % The width of the transition
width = exp(hyp(3));
sf = exp(2*hyp(4));
ax = ((x >= (location - 0.5*(width+t_width))) & (x <= location - 0.5*(width-t_width)) & (x <= location)) .* ...
     (x - (location - 0.5*(width+t_width))) ./ t_width ...
     + ...
     ((x > (location - 0.5*(width-t_width))) & (x < location + 0.5*(width-t_width)))...
     + ...
     ((x >= (location + 0.5*(width-t_width))) & (x <= location + 0.5*(width+t_width)) & (x >= location)) .* ...
     (-x + (location + 0.5*(width+t_width))) ./ t_width;
if ~dg
    ax = repmat(ax, 1, length(z));
end
if ~dg
    az = ((z >= (location - 0.5*(width+t_width))) & (z <= location - 0.5*(width-t_width)) & (z < location)) .* ...
         (z - (location - 0.5*(width+t_width))) ./ t_width ...
         + ...
         ((z > (location - 0.5*(width-t_width))) & (z < location + 0.5*(width-t_width)))...
         + ...
         ((z >= (location + 0.5*(width-t_width))) & (z <= location + 0.5*(width+t_width)) & (z > location)) .* ...
         (-z + (location + 0.5*(width+t_width))) ./ t_width;
    az = repmat(az', length(x), 1);
else
    az = ax;
end

if nargin<5                                                        % covariances
  K = 0; if nargin==3, z = x; end                                 % set default
  for ii = 1:length(cov)                              % iteration over functions
    f = cov(ii); if iscell(f{:}), f = f{:}; end % expand cell array if necessary
    if ii == 1
        K = K + (1 - ax) .* feval(f{:}, hyp([false false false false (v==ii)]), x, z) .* (1 - az) + ...
                (ax) .* sf .* (az);
    end
  end
else                                                               % derivatives
  if i==1
    dx = ((x >= (location - 0.5*(width+t_width))) & (x <= location - 0.5*(width-t_width)) & (x <= location)) .* ...
         -1 ./ t_width ...
         + ...
         ((x >= (location + 0.5*(width-t_width))) & (x <= location + 0.5*(width+t_width)) & (x >= location)) .* ...
         +1 ./ t_width;
    dx = repmat(dx, 1, length(z));
    dz = ((z >= (location - 0.5*(width+t_width))) & (z <= location - 0.5*(width-t_width)) & (z <= location)) .* ...
         -1 ./ t_width ...
         + ...
         ((z >= (location + 0.5*(width-t_width))) & (z <= location + 0.5*(width+t_width)) & (z >= location)) .* ...
         +1 ./ t_width;
    dz = repmat(dz', length(x), 1);
    K = 0;
    for ii = 1:length(cov)                              % iteration over functions
        f = cov(ii); if iscell(f{:}), f = f{:}; end % expand cell array if necessary
        if ii == 1
            K = K + -dx .* feval(f{:}, hyp([false false false false (v==ii)]), x, z) .* (1-az);
            K = K + (1-ax) .* feval(f{:}, hyp([false false false false (v==ii)]), x, z) .* -dz;
            K = K + dx .* sf .* az;
            K = K + ax .* sf .* dz;
        end
    end
  elseif i==2
    dx = ((x >= (location - 0.5*(width+t_width))) & (x <= location - 0.5*(width-t_width)) & (x <= location)) .* ...
         -(x - (location - 0.5*width)) ./ t_width ...
         + ...
         ((x >= (location + 0.5*(width-t_width))) & (x <= location + 0.5*(width+t_width)) & (x >= location)) .* ...
         -((location + 0.5*width) - x) ./ t_width;
    dx = repmat(dx, 1, length(z));
    dz = ((z >= (location - 0.5*(width+t_width))) & (z <= location - 0.5*(width-t_width)) & (z <= location)) .* ...
         -(z - (location - 0.5*width)) ./ t_width ...
         + ...
         ((z >= (location + 0.5*(width-t_width))) & (z <= location + 0.5*(width+t_width)) & (z >= location)) .* ...
         -((location + 0.5*width) - z) ./ t_width;
    dz = repmat(dz', length(x), 1);
    K = 0;
    for ii = 1:length(cov)                              % iteration over functions
        f = cov(ii); if iscell(f{:}), f = f{:}; end % expand cell array if necessary
        if ii == 1
            K = K + -dx .* feval(f{:}, hyp([false false false false (v==ii)]), x, z) .* (1-az);
            K = K + (1-ax) .* feval(f{:}, hyp([false false false false (v==ii)]), x, z) .* -dz;
            K = K + dx .* sf .* az;
            K = K + ax .* sf .* dz;
        end
    end
  elseif i==3
    dx = ((x >= (location - 0.5*(width+t_width))) & (x <= location - 0.5*(width-t_width)) & (x <= location)) .* ...
         0.5*width ./ t_width ...
         + ...
         ((x >= (location + 0.5*(width-t_width))) & (x <= location + 0.5*(width+t_width)) & (x >= location)) .* ...
         0.5*width ./ t_width;
    dx = repmat(dx, 1, length(z));
    dz = ((z >= (location - 0.5*(width+t_width))) & (z <= location - 0.5*(width-t_width)) & (z <= location)) .* ...
         0.5*width ./ t_width ...
         + ...
         ((z >= (location + 0.5*(width-t_width))) & (z <= location + 0.5*(width+t_width)) & (z >= location)) .* ...
         0.5*width ./ t_width;
    dz = repmat(dz', length(x), 1);
    K = 0;
    for ii = 1:length(cov)                              % iteration over functions
        f = cov(ii); if iscell(f{:}), f = f{:}; end % expand cell array if necessary
        if ii == 1
            K = K + -dx .* feval(f{:}, hyp([false false false false (v==ii)]), x, z) .* (1-az);
            K = K + (1-ax) .* feval(f{:}, hyp([false false false false (v==ii)]), x, z) .* -dz;
            K = K + dx .* sf .* az;
            K = K + ax .* sf .* dz;
        end
    end
  elseif i ==4
    K = 2 * sf * ax .* ones(size(ax)) .* az;  
  elseif i<=length(v)+4
    i = i - 4;
    vi = v(i);                                       % which covariance function
    j = sum(v(1:i)==vi);                    % which parameter in that covariance
    f  = cov(vi);
    if iscell(f{:}), f = f{:}; end         % dereference cell array if necessary
    K = feval(f{:}, hyp([false false false false (v==vi)]), x, z, j);                   % compute derivative
    if vi == 1
        K = (1-ax) .* K .* (1-az);
    end
  else
    error('Unknown hyperparameter')
  end
end
