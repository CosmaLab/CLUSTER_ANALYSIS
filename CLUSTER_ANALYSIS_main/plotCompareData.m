% Function to plot data into a box plot and perform statistical tests to
% detect differences between the data types, if more than one data type is 
% present in the input columns.
% Two tests are performed to check for statistically significant
% differences:
%   1) Two-sample Kolmogorov-Smirnov test (kstest2)
%       Plotted in black;   one asterisk = p <= alphaval
%                           two asterisks = p <= alphaval/10
%                           three asterisks = p <= alphaval/100
%   2) Median value test, where the median values of the input data are
%       compared at the 95% confidence level.  This only provides a test 
%       for statistical differences at the p <= 0.05 level
%       Plotted in Red;   one asterisk = p <= 0.05
%
% Inputs
%   plotdat - 'm x n' array of 'm' data values each measured for 'n' data
%       types.  Values of 'NaN' are permitted, since the 'boxplot' function
%       allows them
%   barPosn - string having values of either 'top' or 'bottom' and indicate
%       where the horizontal bars indicating a statistically significant
%       difference between data types is plotted
%   alphaval - alpha value required for statistically significant
%       differences according to kstest2
%   strIn - cell array of strings having 3 entries
%       strIn{1} = names of datatypes [default = 'Type 1', 'Type 2', etc]
%       strIn{2} = plot title
%       strIn{3} = Y-axis title
%   figH - figure handle where the plot is to be included (optional)
%   ax_h - axis handle array where the subplot should be placed (optional)
%   nrc - 2-element array indicating the number of subplot [rows, columns]
%       if the plot is to be placed within a desired figure
%   subIdx - index value of the current subplot 
%
% Ouputs
%   p_values - 'n x n' array of p-values obtained when comparing the data
%       types to one another via the kstest2 function
%   ax_h - axis handle, updated if provided as input
%   figH - figure handle, updated if provided as input
%

function [p_values, ax_h, figH] = plotCompareData(plotdat,barPosn,alphaval,...
                                        strIn,figH,ax_h,nrc,subIdx)
%%

fontsize = 8;

if ~exist('plotdat','var') || isempty(plotdat) || ~isnumeric(plotdat)
    error('data to be box-plotted is not of a recognized format')
end
% figure out number of data types
nDatTypes = size(plotdat,2);


if ~exist('barPosn','var') || isempty(barPosn) || ~ischar(barPosn) ||...
    ~sum(strcmpi(barPosn,{'top','bottom'}))
    barPosn = 'top';
elseif strcmpi(barPosn,'top')
    barPosn = 'top'; % ensure it's lower case
elseif strcmpi(barPosn,'bottom')
    barPosn = 'bottom'; % ensure it's lower case
end

if ~exist('alphaval','var') || isempty(alphaval)
    alphaval = 0.05;
end

if ~exist('strIn','var') || isempty(strIn) || ~iscell(strIn)
    for c = 1:nDatTypes
        strIn{1}{1,c} = ['Type ' num2str(c)];
    end
    strIn{2} = ['Box plot of ' num2str(size(plotdat,2)) ' data type'];
    if nDatTypes > 1, strIn{2} = [strIn{2} 's']; end
    strIn{3} = 'Data values';
end

if ~exist('figH','var') || isempty(figH) || (~ishandle(figH) && ~isa(figH,'matlab.ui.Figure'))
    figH = figure;
end

if ~exist('nrc','var') || isempty(nrc) || length(nrc)~=2
    nrc = [1 1];
end

if (~exist('ax_h','var') || isempty(ax_h)) 
    ax_h = nan( prod(nrc),1 );
end

if ~exist('subIdx','var') || isempty(subIdx) 
    subIdx = 1;
elseif ~isnumeric(subIdx)
    error(['Unknown subplot index input, class = ' class(subIdx)])
elseif length(subIdx)~=1
    warning('Subplot index input has multiple values, using first one')
    subIdx = subIdx(1);
elseif subIdx > length(ax_h)
    error(['Subplot index input is larger than the number of axes, max allowed = ' num2str(length(ax_h))])
end


% assign colors to bar plots
colr = lines( nDatTypes );
if nDatTypes == 2
    % use blue & red
%     colr = [0 0 0.65; 0.95 0 0];
    colr = lines( 8 );
    colr = colr([8 2],:);
end

% create subaxis for plotting
ax_h( subIdx ) = subplot(nrc(1),nrc(2),subIdx,'parent',figH);

hold( ax_h(subIdx), 'on')
box( ax_h(subIdx), 'on')

% make data box plot
boxh = boxplot(ax_h(subIdx),plotdat,strIn{1},...
    'Notch','on',...    'BoxStyle','filled')
    'Colors',colr);
% boxh rows:
% 1 - Upper Whisker, Ydata = [75th_pct, upper whisker]
% 2 - Lower Whisker, Ydata = [lower whisker, 25th_pct]
% 3 - Upper Adjacent Value, Ydata = [upper whisker, upper whisker]
% 4 - Lower Adjacent Value, Ydata = [lower whisker, lower whisker]
% 5 - Box, Ydata = [median, median+95%conf, 75th_pct, 75th_pct,
%                   median+95%conf, median, median-95%conf, 25th_pct, 
%                   25th_pct, median-95%conf, median]
% 6 - Median, Ydata = [median median]
% 7 - Outliers, Ydata = [outlier values]

% label the plot
ylabel(ax_h(subIdx),strIn{3})
set(ax_h(subIdx),'FontSize',fontsize)
title(ax_h(subIdx),strIn{2},'FontSize',fontsize+1)

% for many data types, rotate X-tick labels by 11 degrees for ease of reading
if nDatTypes > 3
    set( get( findobj( ax_h(subIdx),'Type','hggroup') ,'Parent'),'XTickLabelRotation',11 )
end

% find plot limits
yLim = get(ax_h(subIdx) ,'YLim');
ysep = yLim(2)-yLim(1);

%  get largest & smallest X & Y-values
maxY = 0; minY = Inf;
xBox = nan(nDatTypes,2);
for d1 = 1:nDatTypes
    yval = [get(boxh(3,d1),'Ydata'), get(boxh(4,d1),'Ydata'), ...
        get(boxh(5,d1),'Ydata'), get(boxh(7,d1),'Ydata')];
    maxY = max([maxY, yval]);
    minY = min([minY, yval]);
    % get largest & smalles X-values for each box plot
    xBox(d1,:) = [min(get(boxh(5,d1),'Xdata')), max(get(boxh(5,d1),'Xdata'))];
end



% add data points next to box
for i = 1:nDatTypes
    w = 0.5*(xBox(i,2)-xBox(i,1));
    ptidx = ~isnan(plotdat(:,i));
    npts = sum(ptidx);
    stepSz = w/npts;
    xDatSep = xBox(i,2)+0.75*stepSz:stepSz:xBox(i,2)+w;
%     size(xDatSep), size(plotdat(ptidx,i))
    plot(ax_h(subIdx), xDatSep, sort(plotdat(ptidx,i)),...
        'Marker','o',...
        'MarkerSize',3.5,...
        'LineStyle','none',...
        'MarkerEdgeColor',colr(i,:),...
        'MarkerFaceColor',colr(i,:))
end

% open the X-axis a bit to accomodate the plotted data points
xLim = get(ax_h(subIdx) ,'XLim');
xsep = xLim(2)-xDatSep(end);
sepMin = 0.1;
if xsep < sepMin
    set(ax_h(subIdx),'XLim',xLim+[0 sepMin])
end
xLim = get(ax_h(subIdx) ,'XLim');

% perform statistical tests to find differences in metrics
if nDatTypes > 1
    yBarSep = 0.03;
    yLimChg = 0.075*ysep;
    astrkSepY = 0.02; % 0.0175; % 
    astrkSepX = 0.034;
    ntests = sum(1:nDatTypes-1);
    hypKS = false( ntests,1 );
    pvalKS = nan( ntests,1 );
    p_values = nan(nDatTypes);
    hypMedn = false( ntests,1 );
    % avgMedn = nan( ntests,1 );
    cIdx = nan( ntests, 2);
    switch barPosn
        case 'top'
            yBarVal = yLimChg+maxY;
%             yBarVal = yLimChg+maxY+zeros( ntests,1);
        case 'bottom'
            yBarVal = minY-yLimChg;
%             yBarVal = minY-yLimChg+zeros( ntests,1);
    end
    m = 0;
    % cycle through data to perform stat tests
    for d1 = 1:nDatTypes-1
        for d2 = d1+1:nDatTypes
            m = m+1;
            % prepare x & y coordinates for plotting stat sig bars
            cIdx(m,:) = [d1 d2];
%             if m > 1
%                 switch barPosn
%                     case 'top'
%                         yBarVal(m) = yBarVal(m-1)+yBarSep*ysep;
%                     case 'bottom'
%                         yBarVal(m) = yBarVal(m-1)-yBarSep*ysep;
%                 end
%             end
            
            % stat test 1: Two-sample Kolmogorov-Smirnov test
            [hypKS(m),pvalKS(m)] = kstest2(plotdat(:,d1),plotdat(:,d2),'Alpha',alphaval );
            p_values(d1,d2) = pvalKS(m);
            p_values(d2,d1) = pvalKS(m);
            
            % stat test 2: no overlap of their 95% median confidence values
            ydat1 = get(boxh(5,d1),'Ydata');
            notch1 = ydat1([2,end-1]); %[hi, low]
            ydat2 = get(boxh(5,d2),'Ydata');
            notch2 = ydat2([2,end-1]); %[hi, low]
            if notch1(2) > notch2(1) ... low(1) > high(2)
                    || notch1(1) < notch2(2) % hi(1) < low(2)
                % median values differ at 5% significance level
                hypMedn(m) = true;
                %             avgMedn(m) = mean([ydat1(1) ydat2(1)]);
            end
        end
    end
%     hypKS = logical(hypKS);
    ntrues = sum([hypKS;hypMedn]);
%     yBarVal = [yBarVal;yBarVal+yBarSep*ysep+yBarVal(end)-(yLimChg+maxY)];
    
    % add horiz lines & asterisks if sig diff by kstest
    n = 0;
    switch barPosn
        case 'top'
            y = maxY-yLimChg;
            yBarVal = yBarVal : yBarSep*ysep : yBarVal+ntrues*yBarSep*ysep;
        case 'bottom'
            y = minY+yLimChg;
            yBarVal = yBarVal : -1*yBarSep*ysep : yBarVal-ntrues*yBarSep*ysep;
    end
    
    for i = 1:m
        astKS = false;
        astMedn = false;
        
        % kstest2 hypothesis
        if hypKS(i) % stat sig diff, so plot bar w/ asterisk
            
            n = n+1;
            xKS = cIdx(i,:);
            yKS = [1 1]*yBarVal(n);
            plot(ax_h(subIdx),xKS,yKS,'k-','LineWidth',1.5)
            astKS = true;
            
        end
        
        % median difference hypothesis
        if hypMedn(i)
            
            n = n+1;
            xMedn = cIdx(i,:)+[1 -1]*0.05;
            yMedn = [1 1]*yBarVal(n);
            plot(ax_h(subIdx),xMedn,yMedn,'r-','LineWidth',1.5)
            astMedn = true;
            
        end
        
        % asterisk(s) for kstest2
        if astKS
            
            x = mean(xKS);
            switch barPosn
                case 'top'
                    y = yKS(1)+astrkSepY*ysep;
                case 'bottom'
                    y = yKS(1)-astrkSepY*ysep;
            end
            if pvalKS(i) <= alphaval/100,    x = x*[1 1 1]+[-1 0 1]*2*astrkSepX; % mark = '***';
            elseif pvalKS(i) <= alphaval/10, x = x*[1 1]+[-1 1]*astrkSepX; % mark = '**';
            end
            plot(ax_h(subIdx),x,y,'k*','MarkerSize',4)
            
        end
        
%         % asterisk for median separation
%         if astMedn
%             
%             x = mean(xMedn);
%             switch barPosn
%                 case 'top'
%                     y = yMedn(1)+astrkSepY*ysep;
%                 case 'bottom'
%                     y = yMedn(1)-astrkSepY*ysep;
%             end
%             plot(ax_h(subIdx),x,y,'r*','MarkerSize',4)
%             
%         end
    end
    
    % adjust the upper Y limit of the plot
    switch barPosn
        case 'top'
            set(ax_h(subIdx),'YLim',[yLim(1) max([yLim(2),y+yLimChg])])
        case 'bottom'
            set(ax_h(subIdx),'YLim',[min([yLim(1),y-yLimChg]) yLim(2)])
    end
    
else
    p_values = [];
end

% set y-ticks to start at zero if needed
yLim = get(ax_h(subIdx),'YLim');
if yLim(1) < 0
    plot(ax_h(subIdx),xLim,[0 0],'k:','LineWidth',0.75)
    yTicks = get(ax_h(subIdx),'YTick');
    yTicks = yTicks( yTicks>=0 );
    set(ax_h(subIdx),'YTick',yTicks)
end

% release holdiing on axis
hold( ax_h(subIdx), 'off')

end