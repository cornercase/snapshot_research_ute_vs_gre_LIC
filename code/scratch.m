p = patsOut{1};

for n=1:100
    subplot(1,2,1);
    plot(1000*p.ETE, p.liverSigE(n,:),'*');
    hold on;
    plot(1000*p.ETE, p.ER.noPD.S0(n)*exp(-p.ETE./p.ER.noPD.T2(n))+p.ER.noPD.C(n))
    hold off
    
    subplot(1,2,2);
    plot(1000*p.STE, p.liverSigS(n,:),'*');
    hold on;
    plot(1000*p.STE, p.SR.noPD.S0(n)*exp(-p.STE./p.SR.noPD.T2(n))+p.SR.noPD.C(n))
    hold off
    pause;
end



%%

tcell = cell(3,2);

tcell{1,1} = 'col1';
tcell{1,2} = 'col2';
tcell{2,1} = 0.1;
tcell{2,2} = 3.4;
tcell{3,1} = 0;
tcell{3,2} = 4;


fid = fopen('test.csv', 'w') ;
fprintf(fid, '%s,', tcell{1,1:end-1}) ;
fprintf(fid, '%s\n', tcell{1,end}) ;
fclose(fid) ;


dlmwrite('test.csv', tcell(2:end,:), '-append') ;