%handy set of scripts to configure the audio i/o device(s) and measurement options
%it saves files which define the options which other functions check for
%and read if present

% configure all the paths and returns the system sample rate
fs = setup 

% specify the output and input channels in cell array
chan_config = {[1],[1 2]}

% define the desired settings
signal_opt = []; % use empty variable to use the defaults
initial_gain_db = -10; % set a low value to start off with to avoid damage to loudspeaker
gain_opt.gain = 10^(initial_gain_db/20)

% Use a single frequency tone to check gains
disp('Ready to try test signal. Type dbcont to continue...')
keyboard
test_rec = test_signal(chan_config,1,gain_opt);

disp('Type dbcont to continue or adjust value of gain_opt.gain and retest using')
disp('test_rec = test_signal(chan_config,1,gain_opt);')
keyboard;

% do the actual system identification
[ir, extras] = getSysIR(chan_config,signal_opt,gain_opt);
msgbox('The amplitude of the ''raw system response'' waveform should be below 1. If not, adjust the gain structure somewhere and run ''[ir, extras] = getSysIR(chan_config,signal_opt,gain_opt);'' again.')


% plot the impulse response
figure;
plotvstime(20*log10(abs(ir)),fs)
ylabel('Impulse response squared magnitude [dB]')

