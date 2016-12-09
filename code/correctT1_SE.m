% Function to correct T1 weighting based on flip angle, T1, and TR
% Sacq in arbitrary units
% FA = Flip angle, degrees
% T1 = T1, ms
% TR = repetition time, ms

function [S0] = correctT1_SE(Sacq, T1, TR)

Sacq
T1
TR

S0 = Sacq / (1-exp(-TR/T1));