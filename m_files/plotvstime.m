function[varargout] = plotvstime(data, Fs, varargin)
%function plotvstime(data, Fs)
%
%Scales the x-axis so that sample numbers are represented by time values
%according to the sampling fequency, Fs (if provided)
%
%Alastair Moore, October 2005


if (nargin < 2) || (isempty(Fs))
    h = plot(data,varargin{:});
    xlabel('Samples');    
else
    timescale = [1/Fs:1/Fs:length(data)/Fs];
    h = plot(timescale,data,varargin{:});
    xlabel('Time [seconds]');
end

ylabel('Amplitude')

if nargout >=1
    varargout{1} = h;
end

