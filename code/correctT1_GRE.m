% Function to correct T1 weighting based on flip angle, T1, and TR
% Sacq in arbitrary units
% FA = Flip angle, degrees
% T1 = T1, ms
% TR = repetition time, ms


function [S0] = correctT1( Sacq, FA, T1, TR )

numer = (1 - cosd(FA) * exp(-TR/T1));
denom = (1 - exp(-TR/T1));

S0 = (Sacq * numer)/(sind(FA) * denom);
