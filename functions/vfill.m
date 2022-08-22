function [h] = vfill(xbounds,ColorSpec,varargin)
% h = vfill(xbounds,ColorSpec,varargin) creates fill objects bounded by 
% the values xbounds.  ColorSpec defines the color of the fill objects. 
% Optional varargin can be used to set edgecolor, transparency, etc.
% varargin must be in the form of name-value pairs (e.g., 'facealpha',.5 )
% Optional output h is the handle(s) of each patch object.  
% 
% 
%% Syntax
% 
%  vfill(scalarValue)
%  vfill([xstart yend])
%  vfill([xstart1,yend1,xstart2,yend2,...,xstartn,yendn])
%  vfill(...,ColorSpec)
%  vfill(...,ColorSpec,'PatchProperty','PatchValue')
%  vfill(...,'bottom')
%  h = vfill(...)
% 
%% Description 
% 
% vfill(scalarValue) places a horizontal line along y = scalarValue.
%
% vfill([xstart yend]) fills a vertical shaded region bounded by
% xstart and yend. 
%
% vfill([xstart1,yend1,xstart2,yend2,...,xstartn,yendn]) fills multiple
% vertical regions.
%
% vfill(...,ColorSpec) defines the face color of the patch(es) created by
% vfill. ColorSpec can be one of the Matlab color names (e.g. 'red'),
% abbreviations (e.g. 'r', or rgb triplet (e.g. [1 0 0]). ColorSpec may
% also be 'gray'. 
%
% vfill(...,ColorSpec,'PatchProperty','PatchValue') defines patch properties
% such as 'EdgeColor' and 'FaceAlpha'. 
% 
% vfill(...,'bottom') places the newly created patch(es) at the bottom of
% the uistack.  
%
% h = vfill(...) returns handle(s) of newly created patch objects. 
% 
% 
% 
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% INPUTS: 
% xbounds   Bounding values of area(s) to be filled. Can be in any of the
%           following forms: 
%           xbounds = [xstart1,xend1,xstart2,xend2,...,xstartn,xendn]
% 
%           xbounds = [xstart1 xend1;
%                      xstart2 xend2;
%                      ...
%                      xstartn xendn];
%
%           xbounds = [xstart1 xstart2 ... xstartn;
%                      xend1   xend2   ... xendn];
%
%           xbounds = scalarvalue produces a vertical line at scalarvalue.
% 
% ColorSpec Defines the color of the patch(es) to be created. Can be RGB 
%           value (e.g., [0 1 0]), short name (e.g., 'g'), or long name 
%           (e.g. 'green'). Also supports the 'gray' for 50% gray.
% 
% varargin  List of name-value pairs such as 'facealpha',.5,'edgecolor','r'.
% 
% varargin can also include the tag 'bottom' or 'back' to send the patch to the back.
% 
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% EXAMPLE: 
% 
% plot(0:100,(0:100).^2,'linewidth',2)
% vfill([80 90],'gray')
% vfill([5 15; 30 50],'g','facealpha',.6,'edgecolor','r','linestyle','--')
% vfill([65 75],'r','bottom')
% 
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
% Chad A. Greene, August 15, 2013. 
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
%
% See also hfill. 

assert(nargin>0,'The vfill function requires at least one input.')
plotbehind=false; 

if ~exist('ColorSpec','var')
    ColorSpec = 'k'; 
end

% Input check: 
assert(isnumeric(xbounds)==1,'xbounds must be numeric.') 
if length(xbounds)==1
    xbounds(2)=xbounds(1);
    varargin{length(varargin)+1} = 'edgecolor'; 
    varargin{length(varargin)+1} = ColorSpec; 
    
end
    
nxb = numel(xbounds); % number of elements in xbounds. 
if mod(nxb,2)
    fprintf('Number of bounding values must be even.');
    fprintf('In other words, enter start and end values for fill bounds.');
    return
end

if strcmpi(ColorSpec,'gray')||strcmpi(ColorSpec,'grey')
    ColorSpec = .5*[1 1 1];
end

for k = 1:length(varargin)
    if strcmpi(varargin{k},'bottom')||strcmpi(varargin{k},'back')
        plotbehind = true;
        varargink=k; 
    end
end

if plotbehind
    varargin(varargink,:)=[];
end
        
% Sort xbounds and start assuming they are in the order
% [xstart1,xend1,xstart2,xend2,...,xstartn,xendn]
sxb=sort(reshape(xbounds,nxb,1)); % sorted x bounds

% Current axis properties: 
ylim = get(gca,'ylim');
initialHoldState = ishold(gca);
hold on

% Plot the patches: 
n=0; % a counter
h = NaN(nxb/2,1); % preallocate patch handles for speed. 
for k = 1:2:nxb-1; 
    n=n+1;
    h(n) = fill([sxb(k) sxb(k+1) sxb(k+1) sxb(k)],...
        [ylim(1) ylim(1) ylim(2) ylim(2)],ColorSpec);
end

% Set optional input properties as name-value pairs: 
try
    [~]=set(h(:),varargin{:});
end

% Return hold state: 
if initialHoldState==0
    hold off;
end

if plotbehind
    uistack(h,'bottom');
end

if nargout==0
    clear h; 
end

end