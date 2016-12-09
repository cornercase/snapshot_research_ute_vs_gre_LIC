function [S0map, T2map, Cmap, Resmap] = reshapeToLiverMap(S0,T2,C,Res,roi,plot);



S0map = doReshape(S0,roi);
T2map = doReshape(T2,roi);
Cmap = doReshape(C,roi);
Resmap = doReshape(Res,roi);

if plot
    subplot(2,2,1); imagesc(S0map); title('S0map'); colormap('parula'); colorbar
    subplot(2,2,2); imagesc(T2map); title('T2map'); colormap('parula'); colorbar
    subplot(2,2,3); imagesc(Cmap); title('Cmap'); colormap('parula'); colorbar
    %subplot(2,2,4); imagesc(Resmap); title('Resmap'); colormap('parula'); colorbar
end
    
end

function [map] = doReshape(v,roi)
    ROItemp = reshape(roi, size(roi,1)*size(roi,2),1);
    map = zeros(size(ROItemp));
    %size(find(ROItemp))
    %size(v)
    map(find(ROItemp))=v(:,end);
    map=reshape(map,size(roi,1),size(roi,2));
end