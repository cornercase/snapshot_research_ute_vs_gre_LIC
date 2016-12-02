%Driver script
% UTE vs GRE @ 3T

%generate paths
exams = genImagePathStructs('./files/','file_subpaths.txt');


%run fits
for n=1:1%length(exams)
    [im te dcminfo] = prepScan(exams{n}.ute);
    ute = struct('im',im,'te',te,'dcminfo',dcminfo);
    [im te dcminfo] = prepScan(exams{n}.gre);
    gre = struct('im',im,'te',te,'dcminfo',dcminfo);
    
    
end