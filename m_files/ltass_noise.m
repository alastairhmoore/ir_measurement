function[out] = ltass_noise(fs,pm)
nsamples = round(pm.duration*fs);
out = v_stdspectrum(11,'t',fs,nsamples);
rms_dbfs = 20*log10(rms(out));
gain = 10^((pm.rms_dbfs-rms_dbfs)/20);
out = gain * out;