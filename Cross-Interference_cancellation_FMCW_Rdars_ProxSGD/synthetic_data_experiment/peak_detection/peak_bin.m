function peakIdx = peak_bin(range,velocity,grid_size,txchirp,ADC)


c = 3e8;

% algeb calculated signal bin 

range_bin = ((2*txchirp.basefreq*velocity)/(c) + (2*txchirp.bandwidth*range)/(txchirp.duration*c))*ADC.period*grid_size(1) + 1;
range_bin = round(range_bin);

doppler_bin = (2*velocity*txchirp.basefreq*txchirp.repetetion_period*grid_size(2))/(c) + 1;
if (doppler_bin < 0)
    doppler_bin = grid_size(2) + doppler_bin;
end
doppler_bin = round(doppler_bin);
peakIdx = [range_bin doppler_bin];

