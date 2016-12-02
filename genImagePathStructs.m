function out = genImagePathStructs(imRoot,subPathFile)

fid = fopen(subPathFile,'r');
paths = {};
while ~feof(fid)
    line = fgets(fid);
    line = line(1:end-1); %trim the newline
    paths{end+1} = line;
end
fclose(fid);

out = {};
for n=1:length(paths)
    
    roiFiles = dir([imRoot paths{n} '/liver-*.dcm.mat']);
    roiPathCell = strsplit(paths{n},'/');
    imfolder = strjoin(roiPathCell(1:end-1),'/');
    imname = roiFiles(1).name;
    imname = imname(7:end-4);
    roiPath = [imRoot '/' paths{n} '/' roiFiles(1).name];
    imPath = [imRoot '/' imfolder '/' imname];
    outS = struct('im',imPath,'roi',roiPath);
    out{n} = outS;
end
