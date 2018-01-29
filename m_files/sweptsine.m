function[out, extras] = sweptsine(command, options, micsignal)
%SWEPTSINE	contains the routines for generating a swept sine signal and
%           processing the subsequenct response into an impulse response
%
%stimulus = sweptsine('generate',{f_start, f_finish, sweep_rate, Fs})
%           returns a swept sinewave from f_start to f_finish at sweep_rate
%           octaves per second.
%
%est_ir = sweptsine('process',options, micsignal)
%           returns the estimated system impulse response, given the response
%           of the signal to the swept-sine generated using the same options
%
%           Based on: Farina, A.,"Simultaneous measurement of impulse
%           response and distortion with a swept-sine technique," 108th
%           Convention of Audio Eng Soc, (2000).
%
%Alastair Moore, September 2006

%Defaults
f_start = 20;
f_finish = 20000;
sweep_rate = 1;
Fs = 44100;
show_plots = 0;

%input validation
%% extract data from options (more or less blindly)
if (nargin > 1)&&(~isempty(options));
    f_start = cell2mat(options(1));
    if (f_start <= 0)
        error('sweptsine: f_start must be greater than zero');
    end
    f_finish = cell2mat(options(2));
    if (f_finish < f_start)
        error('sweptsine: f_finish must be greater than f_start');
    end
    sweep_rate = cell2mat(options(3));
    Fs = cell2mat(options(4));
end
%Print values
if 1
    f_start = f_start
    f_finish = f_finish
    sweep_rate = sweep_rate
    Fs = Fs
end

if (nargin > 2)
    [siglength, nChan] = size(micsignal);
end

if (nargin < 1) || (nargin > 3) || ~isa(command, 'char')
    error('sweptsine: see help for usage');
elseif strcmpi(command, 'generate')
    %check to see if the m-sequence has already been stored
    %if so, the sequence will be loaded into ms
    load stimulus_path;
    if exist([stimulus_path,'sweptsine_',num2str(f_start),'_',num2str(f_finish),'_',num2str(sweep_rate),'_',num2str(Fs),'.mat'],'file')
        load([stimulus_path,'sweptsine_',num2str(f_start),'_',num2str(f_finish),'_',num2str(sweep_rate),'_',num2str(Fs),'.mat'])
    else
        [sweep fft_inv_sweep, scale_factor] = generateSineSweep(f_start, f_finish, sweep_rate, Fs);
        save([stimulus_path,'sweptsine_',num2str(f_start),'_',num2str(f_finish),'_',num2str(sweep_rate),'_',num2str(Fs),'.mat'],'sweep','fft_inv_sweep','scale_factor')
    end
    %copy signal vertically
    %out = repmat(ms, repetitions,1);
    out = sweep;
elseif strcmpi(command, 'process')
    load stimulus_path;
    if exist([stimulus_path,'sweptsine_',num2str(f_start),'_',num2str(f_finish),'_',num2str(sweep_rate),'_',num2str(Fs),'.mat'],'file')
        load([stimulus_path,'sweptsine_',num2str(f_start),'_',num2str(f_finish),'_',num2str(sweep_rate),'_',num2str(Fs),'.mat'])
    else
        [sweep fft_inv_sweep, scale_factor] = generateSineSweep(f_start, f_finish, sweep_rate, Fs);
        save([stimulus_path,'sweptsine_',num2str(f_start),'_',num2str(f_finish),'_',num2str(sweep_rate),'_',num2str(Fs),'.mat'],'sweep','fft_inv_sweep','scale_factor')
    end
    
    %do processing one channel at a time (mswindow is mono process)
    
    for i = 1:nChan
        % convolve system response with inverse sweep
        %out(:,i)=IntelISPConv(micsignal(:,i),inv_sweep);
        %full_response(:,i) = conv(micsignal(:,1),inv_sweep);
        full_response(:,i) = real(ifft( fft([micsignal(1:length(sweep),i);zeros(length(sweep),1)]) .* fft_inv_sweep));
    end
    if show_plots
        figure;
        subplot(211)
        plot(linspace(1/Fs,length(full_response)/Fs,length(full_response)),full_response)
        title('Impulse response including non-linear compononents prior linear section')
        xlabel('Time [s]')
        ylabel('Amplitude [linear]')
        subplot(212)
        plot(linspace(Fs/length(full_response),Fs,length(full_response)),20*log10(abs(fft(full_response))));
        xlabel('Frequency [Hz]')
        ylabel('Amplitude [dB]')
    end

    % scaling to normalise
    full_response = full_response * scale_factor;
    

    %only return the linear part 
    out = full_response(length(sweep):end,:);
    
    if nargout > 1
        extras.hir = full_response;
    end

else
	error('sweptsine: command must be "generate" or "process"');
end