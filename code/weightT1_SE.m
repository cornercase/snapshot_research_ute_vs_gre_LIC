% Function to correct T1 weighting based on flip angle, T1, and TR
% Sacq in arbitrary units
% FA = Flip angle, degrees
% T1 = T1, ms
% TR = repetition time, ms

function [Sacq] = weightT1_SE(S0, T1, TR)

Sacq = S0 * (1-exp(-TR/T1));