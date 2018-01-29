function[average] = weighted_av(windows)
%WEIGHTEDAV
%   weights each window according to the inverse of the signal power in
%   that window.  Reduces the impact of non-stationary noise, if it is
%   present.
%
%[average] = weighted_av(windows)
%   windows is an MxN matrix where M is the number of windows and N is the
%   number of samples in each window, as returned by MSWINDOW
%
%   See Nielsen, J.L.(1997), "Improvement of signal-to-noise ration in
%   long-term MLS measurments with high level nonstationary disturbances,"
%   J. Audio Eng. Soc., Vol 45, No 12.
%
%   Alastair Moore, September 2006

%Each row is a window. Each column is the same sample in consecutive windows
[nWindows, nSamples] = size(windows);

%column vector of weights (equation 15)
weights = 1./(sum(windows(:,1:end)')'/nSamples);

W = 1/sum(weights);

%weighted average (equation 9)
average = (1/W) * sum(repmat(weights,1,nSamples).*windows);