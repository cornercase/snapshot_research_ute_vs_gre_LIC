function [map, pd]=calcmap(h,data)
[Nrows,Ncols,nTE]=size(data);
%R1=get(h.R1,'Value');
R1=0;
if (R1==1)
    TI=get(h.R1,'Userdata');
    [Y,I]=min(data,[],3);  % index contains the position into TI of the null point.
    for k=1:Nrows
        for m=1:Ncols
            map(k,m)=TI(I(k,m));
        end
    end
else
    %width=str2num(get(h.MedianFilterWidth,'String'));
    width=10;
    %Relaxivity=get(h.Relaxivity,'String');
    Relaxivity=h.Relaxivity;
    %OrganList=get(h.TissueType,'String');
    %Organ=OrganList{get(h.TissueType,'Value')}
    Organ=h.TissueType;
    if strcmp(Relaxivity,'R2*')==1
        switch Organ
            case 'Liver'
                TEmin=0.002;
            case 'Heart'
                TEmin=0.009;
            case 'Kidney'
                TEmin=0.005;
            case 'Pancreas'
                TEmin=0.003;
            case 'Spleen'
                TEmin=0.003;
            case 'UTE'
                TEmin=0.001;
            otherwise
                TEmin=0.002;
        end % switch Organ
    else
        switch Organ
            case 'Liver'
                TEmin=0.0121;
            case 'Heart'
                TEmin=0.060;
            case 'Kidney'
                TEmin=0.020;
            case 'Pituitary'
                TEmin=0.060;
            otherwise
                TEmin=0.006;
        end  % switch Organ
    end % strcmp Relaxivity R2*
    TEmin
    TE=h.TEarray'/1000;%str2num(get(h.TEarray,'string'))/1000;
        for d=1:nTE
            data(:,:,d)=medfilt2(squeeze(data(:,:,d)),[width,width]);
        end
    data=double(data);
    bdata=reshape(data,[Nrows*Ncols,nTE]);
    [a,b,res]=fastlsMat2(TE,bdata,TEmin);
    map=reshape(1./b,[Nrows,Ncols]);
    pd = reshape(a,[Nrows,Ncols]);
end