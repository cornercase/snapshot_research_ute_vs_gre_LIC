function [imarray, tearray, dcminfocell] = prepScan(paths)
roi = load(paths(1).roi);
rdims = size(roi.roi.liver);
vroi = reshape(roi.roi.liver,rdims(1)*rdims(2),1);
nIms = size(paths,2);
imarray = zeros(sum(vroi),nIms);
tearray = zeros(1,nIms);
dcminfocell = cell(1,nIms);
for n=1:nIms
    [tim, TE, dcmInfo] = readDicomSeries(paths(n).im);
    if size(tim,1) ~= rdims(1)
        fprintf('resized slice %i',n);
        tim = imresize(tim,rdims(1)/size(tim,1));
    end
    tim = reshape(tim,rdims(1)*rdims(2),1); 
    imarray(:,n) = tim(vroi>0);
    tearray(n) = TE;
    dcminfocell{1,n} = dcmInfo;
end