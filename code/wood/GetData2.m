function data=GetData(h)
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
wh=waitbar(0,'Reading Dicom Headers');
R1=get(h.R1,'Value');
for i=3:N
    if ~isdir([pn,filelist(i).name])
        if isdicom([pn,filelist(i).name])
             filecount=filecount+1;
             hdr{filecount}=dicominfo([pn,filelist(i).name]);
             if (strfind(hdr{filecount}.Manufacturer,'Philips')==1 & exist('hdr{filecount}.Private_2005_100e'))
                 if length(hdr{filecount}.Private_2005_100e)==1
                    ScaleSlope(filecount)=hdr{filecount}.Private_2005_100e;
                 else
                     ScaleSlope(filecount)=1;
                 end
             else
                 ScaleSlope(filecount)=1;
             end
             TE(filecount)=hdr{filecount}.EchoTime; 
             if (R1==1)
                 TI(filecount)=hdr{filecount}.TriggerTime;
             else
                 TI=[];
             end
             EchoNumber(filecount)=hdr{filecount}.EchoNumber;
             Position(filecount,:)=hdr{filecount}.ImagePositionPatient;
        end
    end
end
TR=hdr{1}.RepetitionTime;
FlipAngle=hdr{1}.FlipAngle;
if exist('hdr{1}.HeartRate') > 0
    RR=60./hdr{1}.HeartRate;
else
    RR=NaN;
end
close(wh);
data=zeros(hdr{1}.Rows,hdr{1}.Columns,filecount);
out=GetHeaderInfo(hdr{filecount});
set(h.MedianFilterWidth,'Userdata',out);  % Stuff it in a random location for use in main program
[diff,index]=max(max(Position)-min(Position)); % find the image direction with the largest magnitude change.
sortarray=[[1:filecount]',TE', Position(:,index)]; 
sortarray=sortrows(sortarray,[2,3]);   % sort by TE, then position. 
wh=waitbar(0,'Loading Dicom Files');
for i=1:filecount
      if mod(i,20)==0
            waitbar(i/N);
      end
      data(:,:,i)=double(dicomread(hdr{sortarray(i,1)}))./ScaleSlope(sortarray(i,1));   % Read the data in the correct order.
end

close(wh);  % clear the waitbar
[Nrows,Ncols,TotFiles]=size(data);
set(h.SourceDimValues,'String',[num2str(Nrows),' ',num2str(Ncols)]);
TE=unique(TE);  TEstring='';
for i=1:length(TE)
    TEstring=[TEstring,num2str(round(TE(i)*10)/10),', '];
end
nTE=length(TE);
if (nTE == 1)  % special case, signifies logmege or R1, this is a kluge workaround for discarding the dummy scan and correcting for lack of TE's in header file.
    Nslices = 1;
    if (R1 == 0)
        data=data(:,:,2:filecount);
    end
    data=permute(data,[1,2,4,3]);
else    % default
    Nslices=filecount/nTE;
    data=reshape(data, [Nrows,Ncols,Nslices,nTE]);
end

TE=unique(TE);  TEstring='';
for i=1:length(TE)
    TEstring=[TEstring,num2str(round(TE(i)*10)/10),', '];
end
TEstring=TEstring(1:length(TEstring)-2);  
set(h.TEarray,'String',TEstring);
set(h.R1,'Userdata',TI);
set(h.LoadImages,'UserData',data);
set(h.Crop,'UserData',data); 
set(h.EchoNumBox,'String','1');
set(h.SliceNumBox,'String','1');
set(h.Slices,'String',num2str([1:Nslices]));
set(h.SourceDimValues,'Userdata',[TR,FlipAngle,RR]);
axes(h.axes2);imagesc(zeros(256)); axis(gca,'off');