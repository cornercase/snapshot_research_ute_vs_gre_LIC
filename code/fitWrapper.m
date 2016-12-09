function [patsOut, debug] = fitWrapper(pats)
patsOut = cell(0);
for p=pats
    
     [imS teS roiS info] = loadFilesHere(p.imagesPath.basePath, p.pS, p.roiS);
     tcontrastType = 'T2';
     [p.SR, p.liverSigS, p.STE, p.ROI.S, p.Sdebug] = fitScanWithWithoutPDEst(imS, roiS, teS, tcontrastType, ...
          't1_correction',true, 'muscleT1', 1008,'fieldStrength','3T', ...
          'TR',info(1).TR, 'flipAngle', info(1).flipangle,'plotVerify',true);

    
     
    [imE teE roiE info] = loadFilesHere(p.imagesPath.basePath, p.pE, p.roiE,'slice',2);
    [p.ER, p.liverSigE, p.ETE, p.ROI.E, p.Edebug] = fitScanWithWithoutPDEst(imE, roiE, teE, tcontrastType, ...
         't1_correction',true, 'muscleT1', 1008,'fieldStrength','3T', ...
         'TR',info(1).TR, 'flipAngle', info(1).flipangle,'plotVerify',true);
    
    
      patsOut{end+1} = p;
    
end
debug = [];
