function [] = make_fig_correlation(varargin)

p=inputParser();
p.addParameter('savePrefix',[]);
p.addParameter('saveOnlyHandle',[]);
p.addParameter('addRicianPlots',0);
p.addParameter('addTitle',1);
p.parse(varargin{:});

exams = genImagePathStructs('./files/','file_subpaths.txt');
ute_r2_vals = []; ute_res = [];
gre_r2_vals = []; gre_res = [];
r2s_1p5t = []; %database fit
r2s_1p5t_rexp = [];
fhandles = {};
for n=1:length(exams)
    fprintf('%i ',n);
    resFile = matfile(exams{n}.savePath);
    resCell=resFile.resCell;
    demographics = resFile.demographics;
     t_ute = resCell{findInd(resCell,'exp1_ute')};
     t_gre = resCell{findInd(resCell,'exp1_gre')};
     rexp_res = resFile.resCell;
     ute_res(n) = median(t_ute.Res);
     gre_res(n) = median(t_gre.Res);
     ute_lic_mean(n) = getLIC(1/mean(t_ute.T2),'R2*','3T','expc');
     gre_lic_mean(n) = getLIC(1/mean(t_gre.T2),'R2*','3T','expc');
     ute_lic_median(n) = getLIC(1/median(t_ute.T2),'R2*','3T','expc');
     gre_lic_median(n) = getLIC(1/median(t_gre.T2),'R2*','3T','expc');
     ute_lic_rexp_med(n) = getLIC(median(rexp_res{findInd(rexp_res,'rexp1_ute')}.T2),'R2*','3T','rician');
     gre_lic_rexp_med(n) = getLIC(median(rexp_res{findInd(rexp_res,'rexp1_gre')}.T2),'R2*','3T','rician');
     lic_1p5t(n) = getLIC(demographics.R2s_Liver_1p5T,'R2*','1.5T','expc');
%     lic_1p5t_rexp(n) = getLIC(median(resCell{5}.T2),'R2*','1.5T','rician');
end
%%
legendText = {'y=x'};
regopts = struct('lineslope',1,'xlab','UTE_R2s_3T','ylab','GRE_R2s_3T','textOn',0,'tickFontSize',14,'tickFontName','Times New Roman','labelFontSize',14);
h = figure(150); clf;fhandles{end+1} = struct('handle',h,'suffix','compare_all_clinical');

regopts.lineslope=2;regopts.ylab='3T LIC Estimate $[\frac{mg}{g}]$';regopts.xlab='1.5 Clinical LIC Estimate $[\frac{mg}{g}]$';regopts.lineOn=1;regopts.textInterpreter='latex';
doScatter(lic_1p5t,ute_lic_median,100,exams,h,regopts); legendText{end+1} = 'UTE fits';
regopts.lineOn=0;regopts.color = 'r';
doScatter(lic_1p5t,gre_lic_median,100,exams,h,regopts); legendText{end+1} = 'GRE fits';
if p.Results.addRicianPlots
    regopts.color = 'k';regopts.marker = 'o'
    doScatter(lic_1p5t,ute_lic_rexp_med,100,exams,h,regopts); legendText{end+1} = 'Rician UTE Fits';
    regopts.color = 'g';regopts.marker = '^'
    doScatter(lic_1p5t,gre_lic_rexp_med,100,exams,h,regopts); legendText{end+1} = 'Rician GRE Fits';
end
h = legend(gca,legendText,'Location','NorthWest');
%ht = title('3T research fits vs clinical (database) measurements');
kids = get(h);
set(get(kids.Children(1),'Children'),'LineWidth',2);
set(get(kids.Children(3),'Children'),'LineWidth',2)
if p.Results.addTitle; ht = title('3T Research LIC Estimates vs 1.5T Clinical LIC Estimate','Interpreter','latex','FontSize',14);
pos = get(ht,'Position');
set(ht,'Position',pos + [-3.5 .50 0]);
end
if 1==0 %don't compare to the rician values, just clinical
h = figure(156); clf;fhandles{end+1} = struct('handle',h,'suffix','compare_all_rician');
regopts.lineslope=2;regopts.ylab='3T LIC Estimate $[\frac{mg}{g}]$';regopts.xlab='1.5 Rician Fit LIC Estimate $[\frac{mg}{g}]$';regopts.lineOn=1;
regopts.color = 'b';
doScatter(lic_1p5t_rexp,ute_lic_median,100,exams,h,regopts);
regopts.lineOn=0;regopts.color = 'r';
doScatter(lic_1p5t_rexp,gre_lic_median,100,exams,h,regopts);
if p.Results.addRicianPlots
    regopts.color = 'k';regopts.marker = 'o'
    doScatter(lic_1p5t_rexp,ute_lic_rexp_med,100,exams,h,regopts)
    regopts.color = 'g';regopts.marker = '^'
    doScatter(lic_1p5t_rexp,gre_lic_rexp_med,100,exams,h,regopts)
end

h = legend(gca,legendText,'Location','NorthWest');

kids = get(h);
set(get(kids.Children(1),'Children'),'LineWidth',2);
set(get(kids.Children(3),'Children'),'LineWidth',2)
tstring = '3T research fits vs 1.5T rician estimates';
title(tstring,'Interpreter','latex','FontSize',14);
end %end not comparing rician values

highLICindex = lic_1p5t>=25;

xstring = 'Mean LIC $[\frac{mg}{g}]$'; %\sffamily\bfseries 
h = figure(151); clf; fhandles{end+1} = struct('handle',h,'suffix','ute_gre');
[data_mean,data_diff,md,sd,tstats] = bland_altman(ute_lic_median,gre_lic_median,'splitPopulation',{~highLICindex,highLICindex},...
    'handle',h,'xlabel',xstring,'Interpreter',regopts.textInterpreter,'yBounds',[-80 80]);
tstring = 'ExpC Bland Altman LIC UTE vs 3T GRE';
if p.Results.addTitle; title(tstring,'Interpreter','latex','FontSize',14);end
fprintf('%s\n',tstring);printstats(data_mean,data_diff,md,sd,tstats);
fprintf('\n\n');

h = figure(152); clf;fhandles{end+1} = struct('handle',h,'suffix','ute_clin');
[data_mean,data_diff,md,sd,tstats] = bland_altman(lic_1p5t,ute_lic_median,'splitPopulation',{~highLICindex,highLICindex},...
    'handle',h,'xlabel',xstring,'Interpreter',regopts.textInterpreter,'yBounds',[-80 80],...
    'showMeanStd',0);
tstring = 'ExpC Bland Altman LIC UTE vs 1.5T GRE';
if p.Results.addTitle; title(tstring,'Interpreter','latex','FontSize',14);end
fprintf('%s\n',tstring);printstats(data_mean,data_diff,md,sd,tstats);
fprintf('\n\n');

h = figure(153); clf;fhandles{end+1} = struct('handle',h,'suffix','gre_clin');
[data_mean,data_diff,md,sd,tstats] = bland_altman(lic_1p5t,gre_lic_median,'splitPopulation',{~highLICindex,highLICindex},...
    'handle',h,'xlabel',xstring,'Interpreter',regopts.textInterpreter,'yBounds',[-80 80],...
    'showMeanStd',0);    
tstring = 'ExpC Bland Altman LIC 1.5T GRE vs 3T GRE';
if p.Results.addTitle; title(tstring,'Interpreter','latex','FontSize',14);end
fprintf('%s\n',tstring);printstats(data_mean,data_diff,md,sd,tstats);
fprintf('\n\n');

h = figure(157); clf;fhandles{end+1} = struct('handle',h,'suffix','phantom_UTE');
regopts.xlab = 'MnCl$_2$ Concentration $[\frac{\mu mol}{L} ]$'
regopts.ylab = 'Relaxation Rate $R_2^*$ $[Hz]$';
doMnCl2PhantomFigure(h,regopts);
if p.Results.addTitle; title('ExpC Regression of $MnCl_2$ Conc. $[\mu M]$ and $R_2^*$ $[Hz]$','Interpreter','latex','FontSize',14);end

if ~isempty(p.Results.savePrefix)
    if ~isempty(p.Results.saveOnlyHandle)
        fhandles = {fhandles{1}};
        fhandles{1}.handle = p.Results.saveOnlyHandle;
    end
    doSave(p.Results.savePrefix,fhandles);
end

end

function [] = doSave(savePrefix,fhandles)
    for n=1:max(size(fhandles))
        th=fhandles{n}.handle;
        set(th,'PaperSize',[3.42 3.42*420/560]*2)
        set(th,'PaperPosition',[0 0 3.42*2 2*3.42*420/560]);
        saveas(th,[savePrefix '-' fhandles{n}.suffix],'epsc');
        saveas(th,[savePrefix '-' fhandles{n}.suffix],'fig');
    end
end

function [] = doScatter(ute,gre,res,exams,h,opts);

hold on;
if isfield(opts, 'color')
    col = opts.color;
else
    col = 'b';
end
if strcmp('b',col);
    marker = 'o';
else
    marker = 'x';
end
if (isfield(opts, 'lineOn') && opts.lineOn) || ~isfield(opts,'lineOn')
    licMax = ceil(max([ute,gre]));
    licMax = licMax+5-mod(licMax,5);
    arr = [0 licMax];
    h =plot(arr,arr,'LineStyle','--','Color',[0.5 0.5 0.5]);xlim(arr);ylim(arr);
    set(h,'LineWidth',2);
end

h = scatter(ute,gre,col,marker);
sizeMap  = containers.Map({'r','b'},{90,70});
set(h,'SizeData',sizeMap(col),'LineWidth',2);%,'MarkerFaceColor',col);
set(gca,'FontName',opts.tickFontName,'FontSize',opts.tickFontSize);
latexFontOpts = '\sffamily\bfseries ';
ht = xlabel([opts.xlab],'Interpreter',opts.textInterpreter,'FontSize',opts.labelFontSize); 
ht = ylabel([opts.ylab],'Interpreter',opts.textInterpreter,'FontSize',opts.labelFontSize);
offsets = make_offsets();
for n=1:length(exams)
    for m=1:length(offsets)
        tid=(offsets(m,1)); 
        if strcmp(tid{1},exams{n}.patID)
            toffset = [offsets{m,2} offsets{m,3}];
        end
    end
    if (isfield(opts, 'textOn') && opts.textOn) || ~isfield(opts,'textOn')
        text(ute(n)+toffset(1),gre(n)+toffset(2),exams{n}.patID(2:3));
    end
    
end


end


%%

function [] = doMnCl2PhantomFigure(fhand,opts);
%copied from ownCloud/research/results/scanning/ISMRM2016/UTE
%modified 28-Dec-2016 by Eamon
thephantom = [...
0, 10 , 10.00 ;...
0.50, 55.1 ,63.03 ;...
0.75, 72.4 , 92.99 ;...
1.0, 99.7 ,120.11 ;...
1.5, 132.8 , 176.59;...
2.0, 193.1, 237.43;...
2.5, 332, 302.45;...
3.5, 384.4 , 427.11 ;...
5.0, 715.2 ,599.85 ;...
8.0, 1013.1 , 987.31 ;...
12, 1313.0 , 1443.87 ;...
16, 1833.4, 1916.87  ;...
24, 2827, 1987.69 ]; %[concen uteR2s greR2s]


pcola = thephantom(:,1);
pcolb = thephantom(:,2);

[regress_ute gof_ute] = fit(thephantom(:,1),thephantom(:,2),'poly1');
regress_ute_conf = predint(regress_ute,thephantom(:,1),0.95);
s_ute = regstats(thephantom(:,2),thephantom(:,1)); 
[regress_gre gof_gre] = fit(thephantom(1:end-1,1),thephantom(1:end-1,3),'poly1');
regress_gre_conf = predint(regress_gre,thephantom(:,1),0.95);
s_gre = regstats(thephantom(:,3),thephantom(:,1)); 

disp('ute');
regress_ute
gof_ute
fprintf('p = %f\n\n',s_ute.fstat.pval);
disp('gre');
regress_gre
gof_gre
fprintf('p = %f\n\n',s_gre.fstat.pval);
% fit y = ax+b
%linfit_a = 116.7;
%linfit_b = 1.589;
%rsq = 0.9955;

figure(fhand);
tpos = get(gcf,'Position');
set(gcf,'Position',[tpos(1:2) 560 420]);
%set(gcf,'PaperUnits','points');
%set(gcf,'PaperSize',[560 420]);
%set(gcf,'PaperPosition',[0 0 560 420]);

% OMG what a dirty dirty hack
plot([0 45],[0 45]);
drawnow;
tempAxisPos = get(gca,'Position');
clf;
%seriouly, the self-hate is deserved
h_sp1 = subplot(1,2,1);
hold on;
%set(h_sp1,'Position',tempAxisPos,'YAxisLocation','right');
set(h_sp1,'YAxisLocation','right','XTick',[]);
set(h_sp1,'FontName',opts.tickFontName,'FontSize',opts.tickFontSize);
hlsp1 = ylabel('Equivalent LIC $[\frac{mg}{g}]$','Interpreter',opts.textInterpreter);

plot([0 45],[0 45]);
h_sp2 = subplot(1,2,2);
plot(thephantom(:,1),thephantom(:,2),'bo','MarkerSize',10,'LineWidth',2);
set(h_sp2,'Position',tempAxisPos);
set(h_sp1,'Position',tempAxisPos);
set(hlsp1,'Position',get(hlsp1,'Position')-[-0.10 2 0]);
% definitely screw whoever has to maintain this cuz reasons
hold on;
%plot(thephantom(:,1),thephantom(:,1).*80*1.414, 'k--','LineWidth',3);
%plot(thephantom(:,1),linfit_a.*thephantom(:,1)+linfit_b,'k','LineWidth',2);
plot(regress_ute,'b');
plot(thephantom(:,1),thephantom(:,3),'rx','MarkerSize',10,'LineWidth',2);
plot(regress_gre,'r');
plot(thephantom(:,1),regress_ute_conf,'--b');
plot(thephantom(:,1),regress_gre_conf,'--r');
set(gca,'FontName',opts.tickFontName,'FontSize',opts.tickFontSize);

hty = ylabel(opts.ylab,'Interpreter',opts.textInterpreter);
htx = xlabel(opts.xlab,'Interpreter',opts.textInterpreter);
set(h_sp1,'YTickLabel',[...
    '   ';...
    '  5';...
    ' 10';...
    ' 15';...
    ' 20';...
    ' 25';...
    ' 30';...
    ' 35';...
    ' 40';...
    ' 45']);
set(hty,'Position',get(hty,'Position')+[-.2 0 0]);
%set(htx,'Position',get(htx,'Position')+[-.2 0 0]);
%MnCl$_2$ Concentration $[\muM]$
%xlabel('this','Interpreter',opts.textInterpreter);
%Relaxation Rate $R_2^*$ $[Hz]$
%ylabel('that','Interpreter',opts.textInterpreter);
h = legend('UTE R_2^* Estimate', ... %'Theoretical Relaxation Rate',...
    'UTE Linear Regression',...
    'GRE R_2^* Estimates',...
    'GRE Linear Regression (excl 24 mM vial)');

%['Linear Regression' sprintf('\n') 'y=116.7*[mM MnCl2] + 1.589' sprintf('\n') 'R^{2}=0.9955'],...
%                                    [x y  ignore ignore]
set(h, 'Position', get(h,'Position')+[-.20 .013 0 0]);
set(h,'Box','off');
%{
ha = findall(h);
for n=1:size(ha,1)
    try
        LineWidth = get(ha(n),'LineWidth');
        position = get(ha(n),'YData');
        if LineWidth == .5 && ~strcmp(get(ha(n),'Marker'),'.')
            set(ha(n),'YData',[0.59 0.59]);
        end
    catch err
        continue;
    end
end
%}
%saveas(gcf,'MnCl2_UTE_calibration','pdf');
ylim([0 3561.525]);
set(h_sp2,'Box','off');
xl = get(gca,'XLim'); yl = get(gca,'YLim');
plot(xl,[yl(2) yl(2)],'k');
plot([xl(2) xl(2)],yl,'k');
for n=1:8
    plot([xl(2)-0.2 xl(2)],[5*n 5*n]*(3561.525/45.0),'k');
end
end

function out = findInd(c,str)
    for n=1:size(c,2)
        try 
            if strcmp(c{n}.fitString,str)
                out=n;
                break;
            end
        catch err
            if strcmp(c{n}.fit,str)
                out=n;
                break;
            end
        end
    end
end

function [] = printstats(data_mean,data_diff,md,sd,tstats)
    pstring = [...
        'Data mean  = %0.2f\n'...
        'Data sd    = %0.2f\n'...
        'Data tstat = %0.2f\n'...
        'Data ts sd = %0.2f\n'...
        'Hyp. true  = %i\n\n'];
    for n=1:2
        ts = tstats{n};
        fprintf(pstring,md{n},sd{n},ts.stats.tstat,ts.stats.sd,ts.h);
    end
end

function offsets = make_offsets()
offsets = cell(0,3);
offsets(end+1,:) = {'013',-80,0};
offsets(end+1,:) = {'054',20,-20};
offsets(end+1,:) = {'037',20,0};
offsets(end+1,:) = {'057',20,0};
offsets(end+1,:) = {'065',-80,0};
offsets(end+1,:) = {'060',20,20};
offsets(end+1,:) = {'010',20,-20};
offsets(end+1,:) = {'055',-80,0};
offsets(end+1,:) = {'056',20,0};
offsets(end+1,:) = {'028',25,0};
offsets(end+1,:) = {'026',25,0};
offsets(end+1,:) = {'061',-80,-20};
offsets(end+1,:) = {'062',-85,20};
offsets(end+1,:) = {'064',-80,0};
offsets(end+1,:) = {'015',20,-20};
offsets(end+1,:) = {'039',20,0};
offsets(end+1,:) = {'058',20,0};
offsets(end+1,:) = {'025',-80,10};
offsets(end+1,:) = {'034',20,-10};
offsets(end+1,:) = {'022',20,-10};
offsets(end+1,:) = {'023',-85,10};
offsets(end+1,:) = {'033',-85,-10};
end