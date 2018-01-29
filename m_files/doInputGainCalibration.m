function[calibration_gains] = doInputGainCalibration(playChan, recChan,Fs,freq, time, gain)

warning('TODO: Add help tect and do input validation')

%generate calibration output signal
calibration_sig = gain * sin(2*pi*freq*[0:Fs*time]'./Fs);

%record response
response = measurement_io(playChan, recChan, Fs, calibration_sig);

%plot it
figure;
plot(response)

fft_response = fft(response);
f_index = 1+ round(freq/Fs * length(response)) %index of dc is 1 in matlab!
calibration_gains = abs(fft_response(f_index,:));

figure;
for n = 1:length(recChan)
    subplot(length(recChan),1,n);
    plotvsfreq(response(:,n),Fs)
    title(['At ' num2str(freq) ' Hz, amplitude: ' num2str(calibration_gains(n))])
end
    
%convert gains into required compensation gains
warning('There might be a more proper way of doing this where the absolute amplitude is taken into consideration')
calibration_gains = 1./(normalise(calibration_gains));