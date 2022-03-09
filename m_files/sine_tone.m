function[out] = sine_tone(fs,pm)
out = sin(2*pi*pm.frequency*[0:1/fs:pm.duration].');
if isfield(pm,'rms_dbfs')
    rms_dbfs = 20*log10(rms(out));
    gain = 10^((pm.rms_dbfs-rms_dbfs)/20);
    out = gain * out;
end
