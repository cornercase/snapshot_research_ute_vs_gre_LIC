function [] = make_fig_correlation()

exams = genImagePathStructs('./files/','file_subpaths.txt');
ute_r2_vals = []; ute_res = [];
gre_r2_vals = []; gre_res = [];
for n=1:length(exams)
    resFile = matfile(exams{n}.savePath);
     t_ute = resFile.resute;
     t_gre = resFile.resgre;
     ute_res(n) = 1/median(t_ute.Res);
     gre_res(n) = 1/median(t_gre.Res);
     ute_r2_mean(n) = 1/mean(t_ute.T2);
     gre_r2_mean(n) = 1/mean(t_gre.T2);
     ute_r2_median(n) = 1/median(t_ute.T2);
     gre_r2_median(n) = 1/median(t_gre.T2);
end
%%
h = subplot(1,2,1);
doScatter(ute_r2_median,gre_r2_median,gre_res*10^9,exams,h);
title('Median');
h = subplot(1,2,2);
doScatter(ute_r2_mean,gre_r2_mean,gre_res*10^9,exams,h);
title('Mean');
end

function [] = doScatter(ute,gre,res,exams,h);

hold on;
scatter(ute,gre,res);
xlabel('UTE R2s [Hz]');
ylabel('GRE R2s [Hz]');
for n=1:length(exams)
    offsets = make_offsets();
    for m=1:length(offsets)
        tid=(offsets(m,1)); 
        if strcmp(tid{1},exams{n}.patID)
            toffset = [offsets{m,2} offsets{m,3}];
        end
    end
    text(ute(n)+toffset(1),gre(n)+toffset(2),exams{n}.patID(2:3));
end
plot([0 1600],[0 1600]);
hold off;
end

%%

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