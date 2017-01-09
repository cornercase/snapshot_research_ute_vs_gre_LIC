% Function to generate Bland Altman plots. Barry Greene, September 2008
% Bland, J.M., Altman, D.G. 'Statistical methods for assessing agreement ...
% between two methods of clinical measurement'(1986) Lancet, 1 (8476), pp. 307-310.
% Inputs: data1: Data from first instrument
%         data2: Data from second instument  
% Produces Bland Altman plot with mean difference and mean difference +/-
% 2*SD difference lines.
%
% Options (supplied as key-value pairs after data1 and data2)
% -----------------|------------------------------------|-----------------
% calcRatio        | Compute the difference ratio       | Default: 1
%                  | rather than difference             |
% -----------------|------------------------------------|-----------------
% convertToPercent | Output vaules as percent rather    | Default: 1
%                  | than ratio                         |
% -----------------|------------------------------------|-----------------
% xlabel           | The X axis label                   | Default:'Mean'
% -----------------|------------------------------------|-----------------
% ylabel           | The Y axis label                   | Default:'Precent Difference (Diff \div mean)*100')
% -----------------|------------------------------------|-----------------
% handle           | A figure handle to reuse if        | Default: []
%                  | provided                           |
% -----------------|------------------------------------|-----------------
% showMeanStd      | Display mean and sd on plot        | Default: 1
% -----------------|------------------------------------|-----------------
% overrideMean     | Use one data as absolute X         | Default: 0
%                  | reference                          | 1->data1
%                  |                                    | 2->data2)
% -----------------|------------------------------------|-----------------
% Interpreter      | Font Interpreter for labels        | Default: 'tex'
% -----------------|------------------------------------|-----------------
% FontName         | Font for labels                    | D: 'Helvetica'
% -----------------|------------------------------------|-----------------
% TickFontSize     | Font size x/y ticks                | Default: 14
% -----------------|------------------------------------|-----------------
% LabelFontSize    | Label font size                    | Default: 14
% -----------------|------------------------------------|-----------------


function [data_mean_o,data_diff_o,mdo,sdo,tso] = bland_altman(data1,data2,varargin)
p = inputParser();
p.addRequired('data1');
p.addRequired('data2');
p.addParameter('calcRatio',1);
p.addParameter('convertToPercent',1);
p.addParameter('xlabel','Mean');
p.addParameter('ylabel','Percent Difference (Diff \div mean)*100');
p.addParameter('handle',[]);
p.addParameter('showMeanStd',1);
p.addParameter('overrideMean',0);
p.addParameter('Interpreter','tex');
p.addParameter('FontName','Arial');
p.addParameter('TickFontSize',14);
p.addParameter('LabelFontSize',14);
p.addParameter('LatexFontOptions','');%'\sffamily\bfseries '
p.addParameter('splitPopulation',{});
p.addParameter('markersAndSizes',{'.',30;'o',10});
p.addParameter('yBounds',[]);
p.addParameter('useTstats',1);
p.parse(data1,data2,varargin{:});

mks = p.Results.markersAndSizes;

if ~iscell(data1)
    [m,n] = size(data1);
    if(n>m)
        data1 = data1';
        data1 = {data1};
    end

    [m,n] = size(data2);
    if(n>m)
        data2 = data2';
        data2 = {data2};
    end
end



if(size(data1)~=size(data2))
    error('Data matrices must be the same size')
end

if ~isempty(p.Results.splitPopulation)
    if length(data1) > 1
        error('population splitting by index not compatible with multiple datasets currently');
    end
    itrL = length(p.Results.splitPopulation);
    useSplit = 1
else
    itrL = length(data1);
    display('warning, not completely implemented');
    useSplit = 0;
end

tso = {}; mdo = {}; sdo = {};
data_diff_o = {}; data_mean_o = {};
for n=1:itrL
    if useSplit
        data1t = data1{1};
        data2t = data2{1};
        indsT = p.Results.splitPopulation{n};
        data1t = data1t(indsT);
        data2t = data2t(indsT);
    else
        data1t = data1{n};
        data2t = data2{n};
    end
    switch p.Results.overrideMean
        case 0
            data_mean = mean([data1t,data2t],2);  % Mean of values from each instrument 
        case 1
            data_mean = data1t;
        case 2
            data_mean = data2t;
    end
    data_diff = (data1t - data2t);              % Difference between data from each instrument
    if p.Results.calcRatio
        data_diff = data_diff./data_mean;
        if p.Results.convertToPercent
            data_diff = data_diff*100;
        end
    end
    md = mean(data_diff);               % Mean of difference between instruments
    sd = std(data_diff);                % Std dev of difference between instruments 
    
    [th,tp,tci,ttstats]= ttest(data_diff);
    tstats = struct('h',th,'p',tp,'ci',tci,'stats',ttstats);
    
    if(p.Results.useTstats)
        sd = tstats.stats.sd;
    end
    
    if isempty(p.Results.handle)
        h = figure;
    else
        h = p.Results.handle;
    end
    figure(h);
    plot(data_mean,data_diff,['k' mks{n,1}] ,'MarkerSize',mks{n,2},'LineWidth',3)   % Bland Altman plot
    boundsX = [min(data_mean),max(data_mean)];
    boundsY = [2*sd*ones(1,length(boundsX))+md;...
        -2*sd*ones(1,length(boundsX))+md];
    if tstats.h
        color = 'b';
    else
        color = '.b';
    end
    hold on,plot([min(data_mean),max(data_mean)],md*ones(1,2),['-' color],'LineWidth',2)             % Mean difference line  
    plot(boundsX,boundsY(1,:),'--r','LineWidth',2)                   % Mean plus 2*SD line  
    plot(boundsX,boundsY(2,:),'--r','LineWidth',2)                  % Mean minus 2*SD line   
    grid on
    %title('Bland Altman plot','FontSize',9)
    if ~isempty(p.Results.yBounds)
        ylim(p.Results.yBounds);
    end
    tso{n} = tstats;
    mdo{n} = md;
    sdo{n} = sd;
    data_diff_o{n} = data_diff;
    data_mean_o{n} = data_mean;
end

if p.Results.showMeanStd
    if strcmp(p.Results.Interpreter,'latex')
        ylab = sprintf('Mean = %0.2f Std = %0.2f\n%s',md,sd,[p.Results.LatexFontOptions p.Results.ylabel]);
    else
        ylab = sprintf('Mean = %0.2f Std = %0.2f\n%s',md,sd,p.Results.ylabel);
    end
else
    ylab = p.Results.ylabel;
end
if strcmp(p.Results.Interpreter,'latex')
    temp = ylabel('');
    position = get(temp,'Position');
    temp = strrep({ylab},{'\div'},{'$\div$'});
    ylab=temp{1};
    ylab= [p.Results.LatexFontOptions ylab];
    
    lines = strsplit(ylab,'\n');
    
    for n=1:max(size(lines))
        h = text(position(1)-1.5*max(size(lines))/n,position(2),lines{n},'HorizontalAlignment', 'center', 'interpreter', 'latex','Rotation',90,'FontSize',p.Results.LabelFontSize);
    end
        
    
end
xlabel([p.Results.LatexFontOptions p.Results.xlabel],'FontSize',p.Results.LabelFontSize,'Interpreter',p.Results.Interpreter);
%h_ylab = ylabel(ylab,'FontSize',p.Results.LabelFontSize,'Interpreter',p.Results.Interpreter);
if strcmp(p.Results.Interpreter,'latex')
%    set(h_ylab,'HorizontalAlignment','left');
end
set(gca,'FontSize',p.Results.TickFontSize,'FontName',p.Results.FontName);