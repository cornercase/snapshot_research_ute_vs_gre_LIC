function [results] = runParallelFitting(filesToProc, myvars, hpcc, appendRoot, preguessT2s)

%chooseImageType = myvars.chooseImageTypeInd;
muscleT1 = myvars.muscleT1;
results = struct;
%if nargin > 4
 %   preguessT2s = varargin(1)
%end
%for chooseImageType = 1:4
%parfor_progress(length(filesToProc));
    parfor patItr=1:length(filesToProc)
        
        p = load([appendRoot filesToProc{patItr}]);
        
        result = bostonFittingWholePatient(p.patMat, muscleT1, preguessT2s(patItr));
        results(patItr).result = result;
        %parfor_progress();
        %fprintf('Finished %0i\n',patItr);
        %save('workspace_temp');
    end
    %end