function[sweep, fft_inv_sweep, scale_factor, inv_sweep] = generateSineSweep(f_start, f_finish, sweep_rate, Fs)
%GENERATESINESWEEP
%       Produces a logarithmic sine sweep and the fourier transform of the
%       inverse sweep, each in a column vector.
%
%       f_start:    Lowest frequency in the sine sweep
%       f_finish:   Highest frequency in the sine sweep
%       sweep_rate: Specificies the fastest the sweep can be (duration gets
%                   rounded up to a power of 2 samples.
%       Fs:         Sampling frequency in Hertz
%
%Alastair Moore, September 2006
%
% November 2008 - implemented improvements suggested in
%                 Farina07Advancements

%see switch statement for defaults depending on choice of method variable
method = 2; %switch beteen original version and advancements
if method == 2; f_finish = Fs/2; end %continue sweep right up to Nyquist


nOct = log2(f_finish/f_start);
T = sweep_rate * nOct;
%round T up to give a power of two samples
nSamples = T*Fs;
nSamples = 2^(ceil(log2(nSamples)));
T = nSamples / Fs;
sweep_rate = T / nOct
omega_1 = 2*pi()*f_start;
omega_2 = 2*pi()*f_finish;
K = T * omega_1 / (log( omega_2/omega_1 ));
L = T / (log( omega_2/omega_1 ));
t = [1:nSamples]/Fs;
%size(t)
sweep = sin(K * (exp(t/L)-1))';

%apply an onset/offset window to the sweep to avoid ringing in the
%frequency domain
%start with rectangular window
window = ones(nSamples,1);
switch method
    case 0; %do not window
    case 1 %original with fade in and out
        fade_time = 0.1;     %time in seconds (kind of - foudn by trial and error)
        len_in = round(10* sweep_rate * Fs * fade_time);
        len_out = round(sweep_rate * Fs * fade_time);
        if len_in > nSamples
            len_in = nSamples;
        end
        if len_out > nSamples
            len_out = nSamples;
        end
        fade_in = cosine_window(len_in,'rising');
        fade_out = cosine_window(len_out,'falling');
        
        %apply fade in and fade out (they can overlap)
        window(1:len_in) = window(1:len_in).*fade_in';
        window(end-len_out+1:end) = window(end-len_out+1:end).*fade_out';
        
    case 2 %fixed fade in time, crop ouput at last zero crossing before nyquist
        fade_time = 0.1; %seconds
        len_in = round(fade_time * Fs);
        if len_in > nSamples; len_in = nSamples; end
        fade_in = cosine_window(len_in,'rising');
        
        %find the last 'zero crossing' - minimum of absolut value
        i = find(abs(sweep(1:end-2)) - abs(sweep(2:end-1)) > 0 & abs(sweep(3:end)) - abs(sweep(2:end-1)) > 0,1,'last');
        len_out = length(sweep) - i;
        fade_out = zeros(1,len_out);
        
        %apply fade in and fade out (they can overlap)
        window(1:len_in) = window(1:len_in).*fade_in';
        window(end-len_out+1:end) = window(end-len_out+1:end).*fade_out';
        
end
%apply window
sweep = sweep.*window;

%Now generate inverse sweep
env = linspace(0, -6*nOct, nSamples)';
inv_sweep = 10.^(env/20) .* flipud(sweep);

%sweptsine.m will convolve the response to sweep with inv_sweep.
%This is done in frequency domain.  To make it quicker we'll take fft of
%inv_sweep here.  Added zeros to avoid time aliasing in the convolution
fft_inv_sweep = fft([inv_sweep;zeros(size(sweep))]);

%scale factor is a function of the sweep length. Best time to calculate it
%is now
%-take the db spectrum of the sweep and inverse.
db_sweep_spectrum = safe_db(abs(fft([sweep;zeros(nSamples,1)])));
db_inv_spectrum = safe_db(abs(fft_inv_sweep));
%-Convolve (add) to find the total amplitude.
total_db_spectrum = db_sweep_spectrum + db_inv_spectrum;
%-calculate the scale factor
scale_factor = 1/10^(total_db_spectrum(fix(end/4))/20);
