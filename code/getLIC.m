function LIC = getLIC(rval,constrast,field)

switch constrast
    case 'T2'
        if rval > 1
            rval = rval / 1000;
        end
        LIC=getLICfromR2(1/rval,field);
    case 'T2*'
        if rval > 1
            rval = rval / 1000;
        end
        LIC=getLICfromR2s(1/rval,field);
    case 'R2'
        LIC=getLICfromR2(rval,field);
    case 'R2*'
        LIC=getLICfromR2s(rval,field);
end

end





function [LIC] = getLICfromR2(R2,field)
R2i = 1000/46;  %base R2 @ 1.5T  %Stanisz 2005 mrm
switch field
    case '3T'
        disp( 'You may want to check your R2 3T model, getLIC.m');
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
        disp( 'You may want to check your R2s 3T model, getLIC.m');
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