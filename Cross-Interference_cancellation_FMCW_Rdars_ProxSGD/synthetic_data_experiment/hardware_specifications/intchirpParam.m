function intchirp = intchirpParam

intchirp.count             = 64;
intchirp.basefreq          = 76.235e9;
intchirp.slope             = 60e12;
intchirp.duration          = 60e-6;
intchirp.bandwidth         = intchirp.slope*intchirp.duration;
intchirp.repetetion_period = 160e-6 - 5e-9;
intchirp.start_time        = 0;


