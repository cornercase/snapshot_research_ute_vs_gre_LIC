% Function to calculate liver T1 @ 1.5T based on T2 or T2*
% contrast can be 'T2' or 'T2*' or LIC in mg/g dry
% Time value in ms, T1 returned in ms

function [T1] = recalcLiverT1(tval, contrast, field)
p=inputParser;
allowedFields = {'1.5T', '3T'};
allowedContrast = {'T2','T2*','LIC'};

p.addRequired('tval');
p.addRequired('contrast',@(x) any(validatestring(x,allowedContrast)));
p.addRequired('field',@(x) any(validatestring(x,allowedFields)));

switch contrast
    case 'T2'
        if tval < 1
            tval = tval*1000;
        end
    case 'T2*'
        if tval < 0.5
            tval=tval*1000;
        end
end

    LIC = 0;
    switch contrast
        case 'T2'
            %R1 = 0.0049 * (1000/tval) + 3.0871;
            %T1 = 1000/R1;
            LIC = getLIC(1000/tval,'R2',field);
        case 'T2*'
            %R1 = 2.0046 * (1000/tval)^0.1042;
            %T1 = 1000/R1;
            LIC = getLIC(1000/tval,'R2*',field);
        case 'LIC'
            LIC = tval;
    end
    
    switch field
        case '1.5T'
            R1 = 0.0265*LIC + 1.5031;
        case '3T'
            R1 = 1.059 + 0.0301* LIC;
        otherwise
            error('cannot calc liver T1 from LIC for provided field strength');
    end
    
    T1 = 1000/abs(R1);
end




function [LIC] = getLICfromR2(R2,field)
R2i = 1000/46;  %base R2 @ 1.5T  %Stanisz 2005 mrm
switch field
    case '3T'
        disp( 'You may want to check your R2 3T model, recalcLiverT1.m');
        R2io = 1000/42; %base R2 @ 3T  % also from Stanisz
        E = 0.8 * 3^0.56; %ghugre 2014 ismrm
        R2n = (R2-R2io)/E + R2i;
        R2 = R2n;
    case '1.5T'
        R2=R2;
    otherwise
        error('cannot calc liver T1 from T2 for provided field strength');
end        
LIC =(-sqrt((R2-6.88)/-0.438 + 26.06^2/(4*0.438^2))-26.06/(2*-0.438))^(1/0.702);
%LIC = (29.75 - sqrt(900.7-2.283/R2))^1.424
end

function [LIC] = getLICfromR2s(R2s,field)
R2si = 40; %base R2s @ 1.5T  %estimated from Storey 2007 JMRI
switch field
    case '3T'
        disp( 'You may want to check your R2s 3T model, recalcLiverT1.m');
        R2sio = 60; %base R2s @ 3T%estimated from Storey 2007 JMRI
        E=-0.0086 + 0.68*3;
        R2sn = (R2s-R2sio)/E + R2si;
        R2s = R2sn;
    case '1.5T'
        R2s=R2s;
    otherwise
        error('cannot calc liver T1 from T2* for provided field strength');
end
LIC = 0.0254 * R2s + 0.202;
end