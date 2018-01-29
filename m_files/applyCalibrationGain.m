function[out] = applyCalibrationGain(in,gains)

for n = 1:length(gains)
    out(:,n) = in(:,n) * gains(n);
end
