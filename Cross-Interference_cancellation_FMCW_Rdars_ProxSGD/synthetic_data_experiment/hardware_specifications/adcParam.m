function ADC = adcParam

ADC.count_sample       = 512;
ADC.count_chirp        = 64;
ADC.period          = 1/(20e6);
ADC.start_time      = 2*ADC.period;
ADC.repetition_time = 160e-6;

