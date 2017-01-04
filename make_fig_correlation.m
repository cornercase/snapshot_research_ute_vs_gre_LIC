function [] = make_fig_correlation()



exams = genImagePathStructs('./files/','file_subpaths.txt');
ute_r2_vals = []; ute_res = [];
gre_r2_vals = []; gre_res = [];
r2s_1p5t = []; %database fit
r2s_1p5t_rexp = [];
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
     ute_r2_mean(n) = 1/mean(t_ute.T2);
     gre_r2_mean(n) = 1/mean(t_gre.T2);
     ute_r2_median(n) = 1/median(t_ute.T2);
     gre_r2_median(n) = 1/median(t_gre.T2);
     ute_r2_rexp_med(n) = median(rexp_res{findInd(rexp_res,'rexp1_ute')}.T2);
     gre_r2_rexp_med(n) = median(rexp_res{findInd(rexp_res,'rexp1_gre')}.T2);
     r2s_1p5t(n) = demographics.R2s_Liver_1p5T;
     r2s_1p5t_rexp(n) = median(resCell{5}.T2);
end
%%
regopts = struct('lineslope',1,'xlab','UTE_R2s_3T','ylab','GRE_R2s_3T')
h = figure(15); clf;

regopts.lineslope=2;regopts.ylab='3T R2s';regopts.xlab='1.5 Clinical R2s';regopts.lineOn=1;
doScatter(r2s_1p5t,ute_r2_median,100,exams,h,regopts);
regopts.lineOn=0;regopts.color = 'r';
doScatter(r2s_1p5t,gre_r2_median,100,exams,h,regopts);
legend(gca,'theo. 2x scale','UTE fits','GRE fits','Location','NorthWest');
title('ExpC fit');


h = figure(24); clf;
regopts.lineOn=1;regopts.color='b';
doScatter(r2s_1p5t_rexp,ute_r2_rexp_med,100,exams,h,regopts);
regopts.color = 'r';
regopts.lineOn=0;
doScatter(r2s_1p5t_rexp,gre_r2_rexp_med,100,exams,h,regopts);
legend(gca,'theo. 2x scale','UTE fits','GRE fits','Location','NorthWest');
title('Rician Exp fit');
[r,m,b] = regression(r2s_1p5t,ute_r2_rexp_med)
x = [0 1600];
%plot(x,x.*r(1)+r(2),'g');


%h = figure(25); clf;
%doScatter(ute_r2_rexp_med,gre_r2_rexp_med,100,exams,h,regopts);


end

function [] = doScatter(ute,gre,res,exams,h,opts);

hold on;
if isfield(opts, 'color')
    col = opts.color;
else
    col = 'b';
end
if (isfield(opts, 'lineOn') && opts.lineOn) || ~isfield(opts,'lineOn')
    plot([0 1600],[0 1600*opts.lineslope]);
end
scatter(ute,gre,res,col);
xlabel(opts.xlab);
ylabel(opts.ylab);
offsets = make_offsets();
for n=1:length(exams)
    for m=1:length(offsets)
        tid=(offsets(m,1)); 
        if strcmp(tid{1},exams{n}.patID)
            toffset = [offsets{m,2} offsets{m,3}];
        end
    end
    text(ute(n)+toffset(1),gre(n)+toffset(2),exams{n}.patID(2:3));
end


end

%%

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