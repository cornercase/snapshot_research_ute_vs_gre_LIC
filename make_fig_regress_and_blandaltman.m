function [] = make_fig_correlation(varargin)

p=inputParser();
p.addParameter('savePrefix',[]);
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
     lic_1p5t_rexp(n) = getLIC(median(resCell{5}.T2),'R2*','1.5T','rician');
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
title('3T research fits vs 1.5T rician estimates','Interpreter','latex','FontSize',14);
end %end not comparing rician values

xstring = 'Mean LIC $[\frac{mg}{g}]$'; %\sffamily\bfseries 
h = figure(151); clf; fhandles{end+1} = struct('handle',h,'suffix','ute_gre');
bland_altman(ute_lic_median,gre_lic_median,'handle',h,'xlabel',xstring,'Interpreter',regopts.textInterpreter);
if p.Results.addTitle; title('ExpC Bland Altman LIC UTE vs 3T GRE','Interpreter','latex','FontSize',14);end
h = figure(152); clf;fhandles{end+1} = struct('handle',h,'suffix','ute_clin');
bland_altman(lic_1p5t,ute_lic_median,'handle',h,'xlabel',xstring,'Interpreter',regopts.textInterpreter);
if p.Results.addTitle; title('ExpC Bland Altman LIC UTE vs 1.5T GRE','Interpreter','latex','FontSize',14);end
h = figure(153); clf;fhandles{end+1} = struct('handle',h,'suffix','gre_clin');
bland_altman(lic_1p5t,gre_lic_median,'handle',h,'xlabel',xstring,'Interpreter',regopts.textInterpreter);    
if p.Results.addTitle; title('ExpC Bland Altman LIC 1.5T GRE vs 3T GRE','Interpreter','latex','FontSize',14);end
h = figure(157); clf;fhandles{end+1} = struct('handle',h,'suffix','phantom_UTE');
regopts.xlab = 'MnCl$_2$ Concentration $[\frac{\mu mol}{L} ]$'
regopts.ylab = 'Relaxation Rate $R_2^*$ $[Hz]$';
doMnCl2PhantomFigure(h,regopts);
if p.Results.addTitle; title('ExpC Regression of $MnCl_2$ Conc. $[\mu M]$ and $R_2^*$ $[Hz]$','Interpreter','latex','FontSize',14);end
%don't plot rician fits
%{ 
h = figure(240); clf;
regopts.lineOn=1;regopts.color='b';
doScatter(lic_1p5t,ute_lic_rexp_med,100,exams,h,regopts);
regopts.color = 'r';
regopts.lineOn=0;
doScatter(lic_1p5t,gre_lic_rexp_med,100,exams,h,regopts);
legend(gca,'theo. 2x scale','UTE fits','GRE fits','Location','NorthWest');
title('Rician Exp fit');
%[r,m,b] = regression(lic_1p5t,ute_lic_rexp_med);
x = [0 50];
%plot(x,x.*r(1)+r(2),'g');
%}

%h = figure(25); clf;
%doScatter(ute_r2_rexp_med,gre_r2_rexp_med,100,exams,h,regopts);
if ~isempty(p.Results.savePrefix)
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
    h =plot(arr,arr);xlim(arr);ylim(arr);
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

function [] = doBlandAltman(ute,gre,res,exams,h,opts);

hold on;
if isfield(opts, 'color')
    col = opts.color;
else
    col = 'b';
end
if (isfield(opts, 'lineOn') && opts.lineOn) || ~isfield(opts,'lineOn')
    plot([0 50],[0 50]);
end
scatter(ute-gre,gre,res,col);
set(gca,'FontName',opts.tickFontName,'FontSize',opts.tickFontSize);
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
%    text(ute(n)+toffset(1),gre(n)+toffset(2),exams{n}.patID(2:3));
end


end

%%

function [] = doMnCl2PhantomFigure(fhand,opts);
%copied from ownCloud/research/results/scanning/ISMRM2016/UTE
%modified 28-Dec-2016 by Eamon
thephantom = [...
0, 10  ;...
0.50, 55.1  ;...
0.75, 72.4  ;...
1.0, 99.7  ;...
1.5, 132.8  ;...
2.0, 193.1;...
2.5, 332;...
3.5, 384.4  ;...
5.0, 715.2  ;...
8.0, 1013.1  ;...
12, 1313.0  ;...
16, 1833.4  ;...
24, 2827 ];

pcola = thephantom(:,1);
pcolb = thephantom(:,2);


% fit y = ax+b
linfit_a = 116.7;
linfit_b = 1.589;
rsq = 0.9955;

figure(fhand);
tpos = get(gcf,'Position');
set(gcf,'Position',[tpos(1:2) 560 420]);
%set(gcf,'PaperUnits','points');
%set(gcf,'PaperSize',[560 420]);
%set(gcf,'PaperPosition',[0 0 560 420]);

plot(thephantom(:,1),thephantom(:,2),'k.','MarkerSize',30);
hold on;
%plot(thephantom(:,1),thephantom(:,1).*80*1.414, 'k--','LineWidth',3);
plot(thephantom(:,1),linfit_a.*thephantom(:,1)+linfit_b,'k','LineWidth',2);
set(gca,'FontName',opts.tickFontName,'FontSize',opts.tickFontSize);
htx = xlabel(opts.xlab,'Interpreter',opts.textInterpreter);
hty = ylabel(opts.ylab,'Interpreter',opts.textInterpreter);
set(hty,'Position',get(hty,'Position')+[-.2 0 0]);
set(htx,'Position',get(htx,'Position')+[-.2 0 0]);
%MnCl$_2$ Concentration $[\muM]$
%xlabel('this','Interpreter',opts.textInterpreter);
%Relaxation Rate $R_2^*$ $[Hz]$
%ylabel('that','Interpreter',opts.textInterpreter);
h = legend('Vial Relaxation Rates', ... %'Theoretical Relaxation Rate',...
    ['Linear Regression' sprintf('\n') 'y=116.7*[mM MnCl2] + 1.589' sprintf('\n') 'R^{2}=0.9955']);

%                                    [x y  ignore ignore]
set(h, 'Position', get(h,'Position')+[-.30 .013 0 0]);
set(h,'Box','off');
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
%saveas(gcf,'MnCl2_UTE_calibration','pdf');
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