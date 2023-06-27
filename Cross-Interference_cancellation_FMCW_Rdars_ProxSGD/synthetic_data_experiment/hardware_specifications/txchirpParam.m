function txchirp = txchirpParam

txchirp.count             = 64;
txchirp.basefreq          = 77e9;
txchirp.slope             = 30e12;
txchirp.duration          = 60e-6;
txchirp.bandwidth         = txchirp.slope*txchirp.duration;
txchirp.repetetion_period = 160e-6;
txchirp.start_time        = 0;


