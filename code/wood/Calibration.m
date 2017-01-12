function iron=Calibration(handles,RelaxivityValue)
RelaxivityType=get(handles.Relaxivity,'String');
FieldStrength=(get(handles.FieldStrength,'String'));
TissueTypeString=get(handles.TissueType,'String'); TissueType=TissueTypeString{get(handles.TissueType,'Value')};
TechniqueString=get(handles.Technique,'String'); Technique=TechniqueString{get(handles.Technique,'Value')};

if strcmp(FieldStrength,'3T')
    if strcmp(RelaxivityType,'R2')
        RelaxivityValue=RelaxivityValue/1.4847      % convert to equivalent 1.5 unit
    else
        if strcmp(TissueType,'Heart')
            RelaxivityValue=(RelaxivityValue+15)/1.88;   % convert to equivalent 1.5 unit
        else
            RelaxivityValue=(RelaxivityValue+11)/2;      % convert to equivalent 1.5 unit
        end
    end
end

switch TissueType
    case 'Liver'
       if strcmp(RelaxivityType,'R2*')
            if strcmp(Technique,'TruncExp')
                iron=RelaxivityValue*.03+.74;  % Use Garbowski Calibration.
            else
                iron=RelaxivityValue*.0254+.2; % Use Wood Calibration
            end
       else
            if RelaxivityValue < 276.5          % if estimated < 40, use St Pierre
                    iron=(-sqrt((RelaxivityValue-6.88)/(-.438)+26.06^2/(4*.438^2))-26.06/(2*(-.438)))^(1/.702);
            else
                    iron= (RelaxivityValue-276.5)*40/263.5+40;  % if greater, use Nilesh MonteCarlo sims. 
            end
       end
    case 'Heart'
       if strcmp(RelaxivityType,'R2*')
                iron=45*(1000/RelaxivityValue)^-1.22;
       else
                if RelaxivityValue<38.8825
                    R2s=(-.21+sqrt(.21^2+4*.0004*(11.32-RelaxivityValue)))/(2*(-.0004)); % Map to R2* by He et al 2009
                else
                    R2s=263;
                    warning('R2 out of range for heart calibration');
                end
                iron=45*(1000/R2s)^-1.22;   % Then convert to iron using Carpenter et al.
       end            
    otherwise
end