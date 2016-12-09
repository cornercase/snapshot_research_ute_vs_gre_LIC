% Function to weight T1 weighting based on flip angle, T1, and TR
% Sacq in arbitrary units
% FA = Flip angle, degrees
% T1 = T1, ms
% TR = repetition time, ms


function [Sacq] = weightT1( S0, FA, T1, TR )

numer = (1 - exp(-TR/T1));
denom = (1 - cosd(FA) * exp(-TR/T1));

Sacq = S0 * (numer/denom) * sind(FA);
