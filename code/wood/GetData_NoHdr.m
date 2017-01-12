function data=GetData_NoHdr(h)
ImagePath=get(h.ImagePath,'Userdata');
if(isempty(ImagePath)) 
    ImagePath='';
end

[fn,pn]=uigetfile([ImagePath,'*.dcm'],'Select File in Source Folder');
if isempty(fn)
    return
end
set(h.ImagePath,'Userdata', pn);
filelist=dir([pn,'*.*']); N=length(filelist); filecount=0;
wh=waitbar(0,'Reading Dicom Images');
for i=3:N
    if ~isdir([pn,filelist(i).name])
        if isdicom([pn,filelist(i).name])
             filecount=filecount+1;
             img=dicomread([pn,filelist(i).name]);
             if filecount==1
                 [Nrows,Ncols]=size(img);
                 data=zeros(Nrows, Ncols, N);  % initialize data and oversize slightly; This is just for speed.
             end
             data(:,:,filecount)=img;
        end
    end
end
data=data(:,:,1:filecount); %cleave off buffer lines. 
TE=str2num(get(h.TEarray,'String'));  % need to know how many TE's
nTE=length(TE);
Nslices=filecount/nTE;
Sequential=get(h.Sequential,'Value');  % find out whether TE or slice major ordering. Sequential means TE major orderiing. 
if Sequential
    data=reshape(data,[Nrows,Ncols,Nslices,nTE]);
else
    data=resphape(data,[Nrows,Ncols,nTE,Nslices]);
    date=permute(data,[1,2,4,3]);
end
TR=0;
FlipAngle=0;
close(wh);


out={'Anon','Anon','Anon', 'Unknown', 'Anon','Unknown',0};
set(h.MedianFilterWidth,'Userdata',out);  % Stuff it in a random location for use in main program

set(h.SourceDimValues,'String',[num2str(Nrows),' ',num2str(Ncols)]);

set(h.LoadImages,'UserData',data);
set(h.Crop,'UserData',data); 
set(h.EchoNumBox,'String','1');
set(h.SliceNumBox,'String','1');
set(h.Slices,'String',num2str([1:Nslices]));
set(h.SourceDimValues,'Userdata',[TR,FlipAngle]);
axes(h.axes2);imagesc(zeros(256)); axis(gca,'off');