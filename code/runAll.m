clear;
try
    load filesToProc;
catch e
    disp('No filesToProc matfile');
    findPatients;
end
filesToProc = prepFileDirs(filesToProc);

out = fitWrapper(filesToProc);

save('workspace');

beep;