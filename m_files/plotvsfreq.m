function[varargout] = plotvsfreq(data, Fs,varargin)
%PLOTVSFREQ plots the FFT of a vector of time samples.
%
%plotvsfreq(data)
%       plots against normalised frequency
%
%plotvsfreq(data, Fs)
%       plots against actual frequency where Fs is sampling frequency [Hz]
%
%Alastair Moore, October 2005

useNormalisedFreq = 0;
plot_phase = 0;


if (nargin <2) || isempty(Fs)
    useNormalisedFreq = 1;
    Fs = 2;
end
N = size(data,1);
%f_scale = [0:N-1] * Fs/N;
%freq_data = 1/N * rfft(data,N);
%h = plot(f_scale, safe_db(abs(freq_data)),varargin{:});

f_scale = [0:fix(1+N/2)-1] * Fs/N;
freq_data = rfft(data,N,1);
if mod(N,2)==0
    freq_data(2:end-1,:) = 2/N * freq_data(2:end-1,:); %scale bins
    freq_data([1 end],:) = 1/N * freq_data([1 end],:);
else
     freq_data(2:end,:) = 2/N * freq_data(2:end,:); %scale bins
    freq_data(1,:) = 1/N * freq_data(1,:);
end
h = plot(f_scale(2:end), 10*log10(freq_data(2:end,:).*conj(freq_data(2:end,:))),varargin{:});
ax1 = gca;
% set(ax1, 'XLim', [f_scale(2), f_scale(round(N/2))]);
set(ax1, 'XLim', [f_scale(2), f_scale(end)]);
set(ax1, 'XScale','log')
set(ax1,'XColor','k','YColor','k')
ylabel('Amplitude [dB]')


if useNormalisedFreq
    xlabel('Normalised Frequency [* \pi]');
else
    xlabel('Frequency [Hz]');
end


if nargout >= 1
    varargout{1} = h;
end
