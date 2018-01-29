function[out, s_db, n_db] = sinewave(command, options, signal_plus_noise,noise)
%SINEWAVE	contains the routines for generating a gated sine test tone and
%           processing the subsequent response to find the SNR
%
%stimulus = sinewave('generate',{tone_frequency, sampling_frequency, duration, fade_time})
%           returns a sinewave normalised to unit amplitude
%
%est_snr = sweptsine('process',options, micsignal)
%           returns the estimated SNR, given the response of the system to
%           the signal returned using the 'generate' function
%
%
%Alastair Moore, January 2014

show_plots = 1;

%input validation
%% require all options to be specified for now
f_tone = options{1}
fs = options{2}
len = round(fs*options{3})
fade_len = round(fs*options{4})


if ~isa(command, 'char')
    error('sinewave: see help for usage');
end

if strcmpi(command, 'generate')
    out = sin(2*pi*f_tone*[0:len-1]'./fs);
    out(1:fade_len) = out(1:fade_len) .* cos_fade_in(fade_len);
    out(end-fade_len+[1:fade_len]) = out(end-fade_len+[1:fade_len]) .* cos_fade_out(fade_len);
    
elseif strcmpi(command, 'process')
    
    %check that two samples are the same size
    if ~isequal(size(signal_plus_noise),size(signal_plus_noise))
        error('sinewave: signals to be processed must be the same size');
    end
    
    
    %could try to find the sinewave in noise, but for now just use energy
    %ratio
    idc = [fs+1:length(signal_plus_noise)-fs]'; %ignore 1st and last second
    
    sumsq_n = sum(noise(idc,:).^2);
    sumsq_spn = sum(signal_plus_noise(idc,:).^2);
    if sumsq_n >= sumsq_spn
        warning('Noise is >= signal plus noise: Signal may not exist!')
    end
    s_db = 10*log10(sumsq_spn-sumsq_n);
    n_db = 10*log10(sumsq_n);
    out = s_db - n_db;   
    
    if 1
        figure;
        subplot(311);plotvstime(10*log10(signal_plus_noise(idc,:).^2));
        subplot(312);plotvstime(10*log10(noise(idc,:).^2));
        linkaxes(get(gcf,'children'))
        subplot(313);plotvsfreq(signal_plus_noise(idc,:),fs);hold all;plotvsfreq(noise(idc,:),fs);
        set(gcf,'Name','Sine in noise and noise only')
    end
else
    error('sweptsine: command must be "generate" or "process"');
end