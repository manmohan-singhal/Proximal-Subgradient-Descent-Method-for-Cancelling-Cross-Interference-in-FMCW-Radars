close all; clear all; clc;

%% Experimental 
% Exp Data Para
NumChirpsPerFrame     = 128;
NumSamplePerChirp     = 256;
NumFramePerChannel    = 1;
NumChannel            = 4;

ts = 1e-1;% in us sampling period

% Reading Radar raw data from .bin file from captured by TI board, output = (:,4), Column = channel data

%%% data file
addpath('raw_ADC_data_files\')
filename = 'adc_data_wi_ds1.bin' ;     % 8 frames, 256 samples per chirp & 128 chirps

%%% Data extraction 
cmplx_data_exp = cmplx_data_channels(filename,NumChirpsPerFrame,NumSamplePerChirp,NumFramePerChannel,NumChannel);


%% DATA
% EXPERIMENTAL
StartChirpIdx         = 4;      % 4for processing, start from StartChirpIdx + 1
EndChirpIdx           = 5;      % 5for processing
ChannelIdx            = 1;      % for processing
BlockSize             = EndChirpIdx - StartChirpIdx;

data_exp                     = cmplx_data_exp(1+NumSamplePerChirp*StartChirpIdx:NumSamplePerChirp*EndChirpIdx,ChannelIdx);
%data_exp                     = data_exp/max(abs(data_exp)); %Data Normalization
data_exp  = data_exp /1000;
data_exp_mat                 = reshape(data_exp,[NumSamplePerChirp,(EndChirpIdx-StartChirpIdx)]); % N(samples per chirp)xL(number of chirps)
RFFT_data_exp                = fft(data_exp_mat,NumSamplePerChirp,1);


%% Interference Mitigation Alorithms


%ProxSGD 
disp('ProxSGD...')
% Hyper parameters

lambda = 0.001;
initial_step_size = 0.001;

limit = 0.1;

maxIter = 500;

% 

tic;
[data_corr_mat_grad_des ,delta_X_relchange_vec]= ProxSGD(data_exp_mat,lambda,initial_step_size,limit,maxIter);
exec_time_ProxSGD = toc;

fprintf('*** data set 1 ProxSGD time : %d ***\n',exec_time_ProxSGD);

%
figure;
plot(delta_X_relchange_vec)
title('relative correction matrix change')


data_miti_mat_grad_des      = data_exp_mat - data_corr_mat_grad_des;     
RFFTGradDes_data_set_miti     = fft(data_miti_mat_grad_des,NumSamplePerChirp,1);


%% plot the experimental results of ProxSGD

x_rect1 = [147 154 154 147 147]*ts;       y_rect1 = [-1 -1 2 2 -1];
hf1 = figure;
set(gcf, 'Position', [0 0 1000 210])
%subplot(311)
ax = gca;
ax.FontSize = 18;
%ax.FontWeight = 'bold';
plot([1:NumSamplePerChirp]*ts,real(data_exp),'LineWidth',1.5);        % Plot the received signal in the time domain
hold on
plot(x_rect1, y_rect1,'r-','LineWidth',1)

text(x_rect1(3),y_rect1(3)-0.2, '\leftarrow Interference','Color','red','Fontsize', 18,'FontWeight','bold')
xlim tight
ylim([-2.5 2.5]);
ax = gca;
ax.FontSize = 18;
%ax.FontWeight = 'bold';
%title('(a) Real time domain signal with interference','FontWeight','normal');
xlabel(['Time (' 956 's)']);
ylabel('Amplitude');
%xticklabels({'12', '24', '36', '48', '60'});
figure
set(gcf, 'Position', [0 0 1000 210])
%subplot(312);
plot([1:NumSamplePerChirp]*ts,real(data_exp-data_corr_mat_grad_des),'LineWidth',1.5);        % Plot the mitigated received signal in the time domain
hold on
plot(x_rect1, y_rect1,'r-','LineWidth',1)
text(x_rect1(3),y_rect1(3)-0.2, '\leftarrow Interference Cancelled','Color','red','Fontsize', 18,'FontWeight','bold')
xlim tight
ylim([-2.5 2.5]);
ax = gca;
ax.FontSize = 18;
%ax.FontWeight = 'bold';
%title('(b) Real time domain signal after interference mitigated','FontWeight','normal');
xlabel(['Time (' 956 's)']);
ylabel('Amplitude');
%xticklabels({'12', '24', '36', '48', '60'});
figure;
set(gcf, 'Position', [0 0 1000 210])
%subplot(313);
plot([1:NumSamplePerChirp]*ts,real(data_corr_mat_grad_des),'LineWidth',1.5);        % Plot the correction signal in the time domain
hold on
plot(x_rect1, y_rect1,'r-','LineWidth',1)
text(x_rect1(3),y_rect1(3)-0.2, '\leftarrow Estimated interference','Color','red','Fontsize', 18,'FontWeight','bold')
xlim tight
ylim([-2.5 2.5]);
ax = gca;
ax.FontSize = 18;
%ax.FontWeight = 'bold';
%title('(c) Real time domain correction signal','FontWeight','normal');
xlabel(['Time (' 956 's)']);
ylabel('Amplitude');
%xticklabels({'12', '24', '36', '48', '60'});


% x_rect2 = [20 20 20 20 20 20 20 20]; 
hf2 = figure;
set(gcf, 'Position', [0 0 1000 400])
% subplot(211);
plot(db(abs(RFFT_data_exp)),'r-','linewidth',1.5);         % Plot FFT of the received signal
% hold on
% plot(x_rect2,'r--')
xlim([1 256]);
% xticklabels({});
ylim([-40 40]);
ax = gca;
ax.FontSize = 18;
%ax.FontWeight = 'bold';
% title('(a)');
% xlabel('Frequency bins');
% ylabel('Amplitude(dB)');
hold on
%subplot(212);
plot(db(abs(RFFTGradDes_data_set_miti)),'Color',[0.466666666666667 0.674509803921569 0.188235294117647],'linewidth',1.5);         % Plot FFT of the mitigated received signal
grid on
xlim([1 256]);
% xticklabels({'10','20','30','40','50'});
ylim([-60 60]);
ax = gca;
ax.FontSize = 18;
%ax.FontWeight = 'bold';
legend('Before interference cancellation','After interference cancellation','Fontsize',20)
%title('Range FFT','FontWeight','normal');
xlabel('Frequency bin');
ylabel('Amplitude (dB)');


% path4figure = './figures/';
% 
% saveas(hf1, [path4figure 'time_domain_signals_one_chirp.fig']);
% saveas(hf2, [path4figure 'frequency_domain_signals_one_chirp.fig']);
% 
% saveas(hf1, [path4figure 'time_domain_signals_one_chirp.eps']);
% saveas(hf2, [path4figure 'frequency_domain_signals_one_chirp.eps']);

