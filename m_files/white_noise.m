function[out] = white_noise(fs,pm)
nsamples = round(pm.duration*fs);
out = randn(nsamples,1);
rms_dbfs = 20*log10(rms(out));
gain = 10^((pm.rms_dbfs-rms_dbfs)/20);
out = gain * out;