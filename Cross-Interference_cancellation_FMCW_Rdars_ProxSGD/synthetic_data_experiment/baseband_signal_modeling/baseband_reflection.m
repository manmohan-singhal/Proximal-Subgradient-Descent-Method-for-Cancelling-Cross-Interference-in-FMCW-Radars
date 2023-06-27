function reflection_baseband_sig = baseband_reflection(target_distance,target_velocity,txchirp,ADC,lowpaas)

c = 3e8;

% generate time stamps vector
time_stamps = [];
for idx = 0:(ADC.count_chirp-1)
    t = (ADC.start_time + ADC.repetition_time*idx) : ADC.period : (ADC.start_time + ADC.repetition_time*idx + ADC.period*(ADC.count_sample-1));
    time_stamps = [time_stamps ; transpose(t)];
end

% delay vector for each sample
delay_vector = 2*(target_distance + target_velocity*time_stamps)*(1/c);

% generate phase and frequency vectors
txphase = zeros(ADC.count_sample*ADC.count_chirp,1);
rxphase = zeros(ADC.count_sample*ADC.count_chirp,1);
txfreq = zeros(ADC.count_sample*ADC.count_chirp,1);
rxfreq = zeros(ADC.count_sample*ADC.count_chirp,1);

for idx = 1:ADC.count_sample*ADC.count_chirp
%    chirp_idx = floor((time_stamps(idx)-ADC.start_time)*(1/txchirp.repetetion_time));
    chirp_instant = rem((time_stamps(idx)-txchirp.start_time),txchirp.repetetion_period);
    if chirp_instant <= txchirp.duration
        txphase(idx) = 2*pi*( txchirp.basefreq*chirp_instant + (1/2)*(txchirp.bandwidth*(1/txchirp.duration)*(chirp_instant^2)) );
        rxphase(idx) = 2*pi*( txchirp.basefreq*(chirp_instant-delay_vector(idx)) + (1/2)*(txchirp.bandwidth*(1/txchirp.duration)*((chirp_instant-delay_vector(idx))^2)) );
        txfreq(idx) = txchirp.basefreq + (txchirp.bandwidth*(1/txchirp.duration)*(chirp_instant)) ;
        rxfreq(idx) = txchirp.basefreq + (txchirp.bandwidth*(1/txchirp.duration)*(chirp_instant-delay_vector(idx)));
    else
        txphase(idx) = 2*pi*( txchirp.basefreq*chirp_instant );
        rxphase(idx) = 2*pi*( txchirp.basefreq*(chirp_instant-delay_vector(idx)) );
        txfreq(idx) = txchirp.basefreq;
        rxfreq(idx) = txchirp.basefreq;
    end

end

% generate baseband signal
reflection_baseband_sig = exp(1i*(txphase-rxphase));

% generaet reflection frequency vector
reflection_baseband_freq = abs(txfreq - rxfreq);

% generate lowpaas filter output
reflection_baseband_sig = reflection_baseband_sig.*double(reflection_baseband_freq <= lowpaas.cutoff);








