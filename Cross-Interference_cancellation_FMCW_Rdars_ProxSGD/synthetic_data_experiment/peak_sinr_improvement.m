close all;
clear all;
clc;



addpath('baseband_signal_modeling\')
addpath('hardware_specifications\')
addpath('peak_detection\')
addpath('performance_metrics\')
addpath('ProxSGD\')



sinr_grad    = 0;
sinr_int     = 0;
corr_grad    = 0;
corr_int     = 0;
time_grad    = 0;

itr = 1 ;


disp('Running...');
for j = 1:itr

    %% data generation 
    % reading parameter files
    ADC       = adcParam;      % victim radar's ADC specifications
    txchirp   = txchirpParam;  % victim radar's transmitted signal specifications
    intchirp  = intchirpParam; % aggressor radar's transmitted signal specifications
    lowpaas   = filterParam;   % victim radar's lowpaas filter specifications

    % target 
    target_range = 32;   % range of object
    target_velocity = 4; % velocity of object (+ve for velocity away from victim radar, -ve for velocity towards victim )
    % signal amplitudes
    tx_sig_amp   =   1;  % victim's transmitted signal amplitude
    rx_sig_amp   =   1;  % victim's received signal amplitude
    int_sig_amp  =   50; % amplitude of baseband interference signal after ADC in victim radar

    % baseband signal generation due to a singal object
    reflection_baseband_sig = tx_sig_amp*rx_sig_amp*baseband_reflection(target_range,target_velocity,txchirp,ADC,lowpaas); 

    % aggressor location
    aggressor_range = 0;    % aggressor radar range from the victim (assumed to be at same(near) location)
    aggressor_velocity = 0; % aggressor's velocity

    % baseband signal generation due a single aggressor's transmitted signal in victim radar
    interference_baseband_sig =  int_sig_amp*baseband_interference(aggressor_range,aggressor_velocity,intchirp,txchirp,ADC,lowpaas);

    % interference quantity
    int_samples = double(abs(interference_baseband_sig) > 0);% number of non-zero samples in interference baseband signal 
    int_percentage = sum(sum(int_samples))*(1/(ADC.count_sample*ADC.count_chirp))*100; % percentange of interference
 
    % beat signals
    beat_wo_int = reflection_baseband_sig;  % beat signal without interference 
    beat_wi_int = reflection_baseband_sig + interference_baseband_sig; % beat signal with interference
    
    % Thermal noise generation
    snr_db =  6; % SNR in dB
    beat_power_wo_int  = (tx_sig_amp*rx_sig_amp)^2; %signal power
    noise_power_wo_int = beat_power_wo_int*(10^(-1*(snr_db/10))); % noise power 
    cmplx_noise_wo_int = sqrt(noise_power_wo_int /2)*complex(randn(size(beat_wo_int )),randn(size(beat_wo_int ))); % noise signal

    beat_wo_int = beat_wo_int + cmplx_noise_wo_int; % beat signal without interference and with noise
    beat_wi_int = beat_wi_int + cmplx_noise_wo_int; % beat signal with interference and with noise

    % peak in Range-doppler spectrum grid
    grid_size = [ADC.count_sample, ADC.count_chirp]; % size of range-doppler grid
    peakIdx = peak_bin(target_range,target_velocity,grid_size,txchirp,ADC); % peak bin in Range-Doppler spectrum 

    data_sim_wi_int             =   beat_wi_int; % data for processing
    data_sim_wi_int_mat         =   reshape(data_sim_wi_int,grid_size); % N(samples per chirp)xL(number of chirps)
    RFFT_data_sim_wi_int        =   fft(data_sim_wi_int_mat,ADC.count_sample,1); % range FFT 
    RDFFT_data_sim_wi_int       =   fft( RFFT_data_sim_wi_int,ADC.count_chirp,2); % Range-Doppler FFT

    RD_mat         = RDFFT_data_sim_wi_int(1:ADC.count_sample/2,:) ; % positive half of Range-Doppler spectrum

    n_sig_bin      = [2 ,2];  % number of signal bins at left and right of peak bin for range and doppler respectively
    n_noise_bin    = [6 ,6];  % number of noise bins at left and right of peak bin for range and doppler respectively 
    % local SINR calculation at peak bin
    [loc_sinr_int,loc_sinr_range_int,loc_sinr_doppler_int ] = local_snr(RD_mat,peakIdx(1,:),n_sig_bin, n_noise_bin);
    sinr_int = sinr_int + loc_sinr_int; 
    
    % correlation coefficient calculation
    corr_coef_int = correlation_coeficient(beat_wo_int,beat_wi_int);
    corr_int = corr_int + corr_coef_int;


    %% Interference Mitigation Alorithm
 
    % Hyper parameters
    lambda = 0.4;
    initial_step_size = 0.5;
    limit = 0.1;
    maxIter = 128;
    %
    tic;
    [data_corr_mat_grad] = ProxSGD(data_sim_wi_int_mat,lambda,initial_step_size,limit,maxIter); %Interference matrix
    exec_time_ProxSGD = toc;

%     figure;
%     plot(real(data_corr_mat_grad(:,1)));
%     figure;
%     plot(real(data_sim_wi_int_mat(:,1)));
    %fprintf('*** data set 1 gradient descent time : %d ***\n',exec_time_ProxSGD);
    data_miti_mat_grad       =   data_sim_wi_int_mat - data_corr_mat_grad; % interefernce cancelled matrix
    RFFTGrad_data_miti       =   fft(data_miti_mat_grad,ADC.count_sample,1); % Range fft
    RDFFTGrad_data_miti      =   fft(RFFTGrad_data_miti,ADC.count_chirp,2); % Range-Doopler fft

    RD_mat         = RDFFTGrad_data_miti(1:ADC.count_sample/2,:); % positive half of RD FFT
    [loc_sinr_grad,loc_sinr_range_grad,loc_sinr_doppler_grad ] = local_snr(RD_mat,peakIdx(1,:),n_sig_bin, n_noise_bin); % SINR computation after interference cancellation
    sinr_grad = sinr_grad + loc_sinr_grad;

    % correlation coefficient
    corr_coef_grad = correlation_coeficient(beat_wo_int,reshape(data_miti_mat_grad,[numel(data_miti_mat_grad) 1]));
    corr_grad = corr_grad + corr_coef_grad;

    % execution time
    time_grad = time_grad + exec_time_ProxSGD;


end

sinr_grad    = sinr_grad/itr;
sinr_int     = sinr_int/itr;
corr_grad    = corr_grad/itr ;
corr_int     = corr_int/itr;
time_grad    = time_grad/itr;

disp('*********************************************');
fprintf('Interference Properties\n');
fprintf('Samples percentage: %s \n', num2str(int_percentage));
fprintf('SINR : %s \n', num2str(sinr_int));
fprintf('Correlation Coef. : %s \n', num2str(corr_int));
fprintf('Correlation Coef. in magn and angle : %s %s\n', num2str(abs(corr_int)),num2str(angle(corr_int)));

disp('*********************************************');
fprintf('ProxSGD\n');
fprintf('SINR : %s \n', num2str(sinr_grad));
fprintf('Correlation Coef. : %s\n', num2str(corr_grad));
fprintf('Correlation Coef. in magn and angle : %s %s\n', num2str(abs(corr_grad)),num2str(angle(corr_grad)));
fprintf('Execution Time : %s\n', num2str(time_grad));



