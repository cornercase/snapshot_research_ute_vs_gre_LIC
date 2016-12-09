function [out,liverSignal, TE, roi, debug] = fitScanWithWithoutPDEst(images, roi, TE, contrastType, varargin)
    addpath('wood')

    debug = 0;
    p = inputParser;
    expectedFields = {'1.5T','3T'};
    expectedContrast = {'T2','T2*'};

    addRequired(p,'images');
    addRequired(p,'roi');
    addRequired(p,'TE');
    addRequired(p,'contrastType',@(x) any(validatestring(x,expectedContrast)));
    
    %addOptional(p,'height',defaultHeight,@isnumeric);
    
    addParameter(p,'TR',[]);
    addParameter(p,'flipAngle',[]);
    addParameter(p,'t1_correction',false);
    addParameter(p,'muscleT1',1008);
    addParameter(p,'preGuessT2s',0);
    addParameter(p,'fieldStrength','3T', @(x) any(validatestring(x,expectedFields)));
    addParameter(p,'plotVerify',false);

    p.parse(images,roi,TE,contrastType,varargin{:});
    
    TR 			= p.Results.TR
    t1correction=p.Results.t1_correction;
    muscleT1 	= p.Results.muscleT1;
    preGuessT2s = p.Results.preGuessT2s;
    fieldStrength=p.Results.fieldStrength;
    flipAngle   = p.Results.flipAngle
    plotVerify  = p.Results.plotVerify;
    
    if TR > 2
        disp( 'dividing TR by 1000 to get seconds.  Fix code if you want something else' );
        TR=TR/1000;
    end
    
    if muscleT1 > 10
        disp( 'dividing muscle T1 by 1000 to get seconds.  Fix code if you want something else');
        muscleT1 = muscleT1/1000;
    end
    
        try
            %% Prep the data
            Expd = struct;
            ExNoPd = struct;

            muscROItemp = reshape(roi.muscle, size(roi.muscle,1)*size(roi.muscle,2),1);
            liverROItemp = reshape(roi.liver, size(roi.liver,1)*size(roi.liver,2),1);
            imagesMatSize = size(images);
            images = reshape(images, imagesMatSize(1)*imagesMatSize(2),imagesMatSize(3));
            muscSignal = images(find(muscROItemp),:);
            muscSignal = mean(muscSignal,1);
            liverSignal = images(find(liverROItemp),:);
            images = reshape(images, imagesMatSize(1),imagesMatSize(2), ...
                             imagesMatSize(3));

            %% guess PD based on liver R2 guess
            [liverPDEa,liverT2b,res]=fastlsMat2(TE,liverSignal,.0000002);
            %[liverPDE,liverT2b] = mono_fit(liverSignal,TE);
            estR = 1./liverT2b;

            estimatedTconst = mean(liverT2b(~isinf(liverT2b))) %could be T2 or T2*
            startVal = .000001;
            %startVal = 0.001;
            [mPDEa,b,res]=fastlsMat2(TE,muscSignal,startVal);
            %            [mPDEa,b] = mono_fit(liverSignal,TE);

            if strcmp(contrastType,'T2')
                musclePDE = correctT1_SE(mean(mPDEa(~isinf(mPDEa))), muscleT1, TR);
            else
                musclePDE = correctT1_GRE(mean(mPDEa(~isinf(mPDEa))), flipAngle,muscleT1, TR);
            end
            disp('mean mpdea')
            mean(mPDEa(~isinf(mPDEa)))

            %% do PD based fit
            nRounds = 2;
            if preGuessT2s > 0
                guessT1 = recalcLiverT1(preGuessT2s,'T2*',fieldStrength);
            else
                guessT1 = recalcLiverT1(estimatedTconst,contrastType,fieldStrength);
            end

            %%

            %set up output variables
            S0pd= zeros(size(liverSignal,1),nRounds);
            T2pd= zeros(size(liverSignal,1),nRounds);
            Cpd= zeros(size(liverSignal,1),nRounds);
            Respd= zeros(size(liverSignal,1),nRounds);
            S0NoPd = zeros(size(liverSignal,1),1);
            T2NoPd = zeros(size(liverSignal,1),1);
            CNoPd = zeros(size(liverSignal,1),1);
            ResNoPd = zeros(size(liverSignal,1),1);

            for m=1:nRounds
                %do a T1 correction here?
                if t1correction
                    if preGuessT2s > 0
                        guessT1 = recalcLiverT1(preGuessT2s,'T2*',fieldStrength);
                    else
                        guessT1 = recalcLiverT1(estimatedTconst,contrastType,fieldStrength);
                    end
                    if strcmp(contrastType,'T2')
                        liverPDE = weightT1_SE(musclePDE, guessT1, TR);
                    else
                        liverPDE = weightT1_GRE(musclePDE, flipAngle, guessT1, TR);
                    end
                end
                hnew.Technique = 'ExpC';
                hnew.usePdEst = 'yes';
                hnew.S0est = liverPDE;
                hNoPd.Technique = 'ExpC';
                hNoPd.usePdEst = 'no';
                method = hnew.Technique;

                %assignin('base','hnew',hnew);
                %assignin('base','hNoPd',hNoPd);
                %do an exponential fit
                for n=1:size(liverSignal,1)
                    if m > 1
                        if T2pd(n,m-1) ~= 0 && T2pd(n,m-1) ~= Inf
                            [S0pd(n,m),T2pd(n,m),Cpd(n,m),Respd(n,m),Expd(n,m).ex] = NewFit2(TE',liverSignal(n,:),estR(n),method,hnew,hnew);
                        else
                            S0pd(n,m)= 0; T2pd(n,m) = 0; Cpd(n,m) = 0; Respd(n,m)= 0; Expd(n,m).ex = 'fail';
                        end
                    else
                        [S0pd(n,m),T2pd(n,m),Cpd(n,m),Respd(n,m),Expd(n,m).ex] ...
                            = NewFit2(TE',liverSignal(n,:),estR(n),method,hnew,hnew);
                        [S0NoPd(n),T2NoPd(n),CNoPd(n),ResNoPd(n),ExNoPd(n).ex] = NewFit2(TE',liverSignal(n,:),estR(n),method,hNoPd,hNoPd);
                    end
                    %T2pd = T2pd .*1000;
                    if m==0
                        [S0NoPd(n),T2NoPd(n),CNoPd(n),ResNoPd(n),ExNoPd(n).ex] = NewFit2(TE',liverSignal(n,:),estR(n),method,hNoPd,hNoPd);
                    end

                end 
                estR = 1./T2pd(:,m);
                T2vals = T2pd(:,m);
                T2vals = T2vals(T2vals~=Inf);
                T2vals = T2vals(T2vals>0);
                estimatedTconst = mean( T2vals ) ;
                
            end
                       
            if plotVerify  && 1==0
                doPlotVerify(liverSignal, TE, S0pd, T2pd, Cpd, S0NoPd,T2NoPd,CNoPd);
            end
            
            
            %do non-PD based fit
            out.error.happened = 0;

	    %out.ROI = roi;
	    %out.TE = te;
	    
            out.PD.S0 = S0pd;
            out.PD.T2 = T2pd;
            out.PD.C = Cpd;
            out.PD.Res = Respd;
            out.PD.Ex = Expd;

            out.noPD.S0 = S0NoPd;
            out.noPD.T2 = T2NoPd;
            out.noPD.C = CNoPd;
            out.noPD.Res = ResNoPd;
            out.noPD.Ex = ExNoPd;

            out.contrastType = contrastType;
        catch ME
             out.PD.S0 = -1;
             out.PD.T2 = -1;
             out.PD.C = -1;
             out.PD.Res = -1;
             out.PD.Ex = -1;

             out.noPD.S0 = -1;
             out.noPD.T2 = -1;
             out.noPD.C = -1;
             out.noPD.Res = -1;
             out.noPD.Ex = -1;

             out.error.ME = ME;
             out.error.happened = 1;
             disp('Error fitScanWithWithoutPDEst.m');


        end
        % end
        
        
end


function [] = doPlotVerify(liverSignal, S0pd, T2pd, Cpd, S0NoPd,T2NoPd,CNoPd)

go = true;
counter = 1;
while go
    % Construct a questdlg with three options
    choice = questdlg('yes','no');
    switch choice
        case 'yes'
            go=true;
        case 'Cake'
            go=false;
    end
    
    
    figure(1);clf;
    plot(TE,liverSignal(:,counter),'*');
    hold on;
    plot(TE,S0pd(counter,2).*exp(-TE(:)./T2pd(counter,2))+Cpd(counter,2),'b');
    plot(TE,S0NoPd(counter).*exp(-TE(:)./T2NoPd(counter))+CNoPd(counter),'r');
    legend('data','With PD','NoPd');
    counter = counter +1; 
    
    
end
end
