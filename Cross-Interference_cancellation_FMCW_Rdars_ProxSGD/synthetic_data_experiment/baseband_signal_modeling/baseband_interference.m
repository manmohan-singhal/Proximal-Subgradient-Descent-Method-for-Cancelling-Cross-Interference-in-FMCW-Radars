function interference_baseband_sig =  baseband_interference(aggressor_distance,aggressor_velocity,intchirp,txchirp,ADC,lowpaas)

c = 3e8;
% generate time stamps vector
time_stamps = [];
for idx = 0:(ADC.count_chirp-1)
    t = (ADC.start_time + ADC.repetition_time*idx) : ADC.period : (ADC.start_time + ADC.repetition_time*idx + ADC.period*(ADC.count_sample-1));
    time_stamps = [time_stamps ; transpose(t)];
end

% delay vector for each sample
delay_vector = (aggressor_distance - aggressor_velocity*time_stamps)*(1/c);

% generate transmitted phase vector
txphase = zeros(ADC.count_sample*ADC.count_chirp,1);
txfreq = zeros(ADC.count_sample*ADC.count_chirp,1);
for idx = 1:ADC.count_sample*ADC.count_chirp
    %    chirp_idx = floor((time_stamps(idx)-ADC.start_time)*(1/txchirp.repetetion_time));
    chirp_instant = rem((time_stamps(idx)-txchirp.start_time),txchirp.repetetion_period);
    if chirp_instant <= txchirp.duration
        txphase(idx) = 2*pi*( txchirp.basefreq*chirp_instant + (1/2)*(txchirp.bandwidth*(1/txchirp.duration)*(chirp_instant^2)) );
        txfreq(idx) = txchirp.basefreq + (txchirp.bandwidth*(1/txchirp.duration)*(chirp_instant)) ;
    else
        txphase(idx) = 2*pi*( txchirp.basefreq*chirp_instant );
        txfreq(idx) = txchirp.basefreq;
    end

end

% generate interference phase vector
intphase = zeros(ADC.count_sample*ADC.count_chirp,1);
intfreq = zeros(ADC.count_sample*ADC.count_chirp,1);
for idx = 1:ADC.count_sample*ADC.count_chirp
    %    chirp_idx = floor((time_stamps(idx)-ADC.start_time)*(1/intchirp.repetetion_time));
    chirp_instant = rem((time_stamps(idx)-intchirp.start_time),intchirp.repetetion_period);
    if chirp_instant <= intchirp.duration
        intphase(idx) = 2*pi*( intchirp.basefreq*(chirp_instant - delay_vector(idx)) + (1/2)*(intchirp.bandwidth*(1/intchirp.duration)*((chirp_instant - delay_vector(idx))^2)) );
        intfreq(idx) = intchirp.basefreq + (intchirp.bandwidth*(1/intchirp.duration)*(chirp_instant - delay_vector(idx))) ;
    else
        intphase(idx) = 2*pi*( intchirp.basefreq*(chirp_instant - delay_vector(idx)) );
        intfreq(idx) = intchirp.basefreq;
    end

end

% generate baseband signal
interference_baseband_sig = exp(1i*(txphase-intphase));

% generaet interference frequency vector
interference_baseband_freq = abs(txfreq - intfreq);

% generate lowpaas filter output
interference_baseband_sig = interference_baseband_sig.*double(interference_baseband_freq <= lowpaas.cutoff);





