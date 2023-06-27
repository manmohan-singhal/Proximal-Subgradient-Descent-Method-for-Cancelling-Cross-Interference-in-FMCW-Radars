function [localSINR,localSINR_Range,localSINR_Doppler ]  =  local_snr(RD_mat,sig_bin,n_sig_bin, n_noise_bin)

[m,n] = size(RD_mat);

n_sig_bin_R    = n_sig_bin(1);
n_sig_bin_D    = n_sig_bin(2);
n_noise_bin_R  = n_noise_bin(1);
n_noise_bin_D  = n_noise_bin(2);


if ((n_sig_bin_R>n_noise_bin_R)||(n_sig_bin_D>n_noise_bin_D))
    error('Noise area is lesser then the Peak area');
end


a = sig_bin(1);
b = sig_bin(2);
%   Signal
% max row index
if (a+n_sig_bin_D <= m)
    MaxRowSig = a+n_sig_bin_D;
else
    MaxRowSig = m;
end

% max column index
if (b+n_sig_bin_R <= n)
    MaxColSig = b+n_sig_bin_R;
else
    MaxColSig = n;
end

% min row index
if (a - n_sig_bin_D > 0)
    MinRowSig =  a - n_sig_bin_D;
else
    MinRowSig = 1;
end
% min column index
if (b-n_sig_bin_R > 0)
    MinColSig = b-n_sig_bin_R;
else
    MinColSig = 1;
end


% Noise + signal
% max row index
if (a +n_sig_bin_D + n_noise_bin_D <= m)
    MaxRowLocal = a+n_sig_bin_D+n_noise_bin_D;
else
    MaxRowLocal = m;
end

% max column index
if (b+n_sig_bin_R +n_noise_bin_R <= n)
    MaxColLocal = b+n_sig_bin_R+n_noise_bin_R;
else
    MaxColLocal = n;
end

% min row index
if (a - n_sig_bin_D - n_noise_bin_D > 0)
    MinRowLocal = a- n_sig_bin_D-n_noise_bin_D;
else
    MinRowLocal = 1;
end
% min column index
if (b -n_sig_bin_R -n_noise_bin_R > 0)
    MinColLocal = b-n_sig_bin_R-n_noise_bin_R;
else
    MinColLocal = 1;
end

% Signal area
SignalBinsMat        = RD_mat(MinRowSig:MaxRowSig,MinColSig:MaxColSig);
[r1,c1] = size(SignalBinsMat);
n_sig_bins = r1*c1;
% signal + noise area
LocalBinsMat         = RD_mat(MinRowLocal:MaxRowLocal,MinColLocal:MaxColLocal);
[r2,c2] = size(LocalBinsMat);
n_loc_bins = r2*c2;
% signal power in its area
SignalPowerArea      = sum(sum(abs(SignalBinsMat).^2));
% noise power in its area
NoisePowerArea       = (sum(sum(abs(LocalBinsMat).^2)) -  SignalPowerArea);

% Area SINR 
localSINR            = 10*log10((SignalPowerArea/n_sig_bins)*((n_loc_bins-n_sig_bins)/NoisePowerArea));


% signal length in range direction
SignalBinsRange      = RD_mat(MinRowSig:MaxRowSig,b);  
% noise + signal length in range direction
LocalBinsRange       =  RD_mat(MinRowLocal:MaxRowLocal,b);
% signal power in it's length 
SignalPowerRange     =  sum(abs(SignalBinsRange).^2);
% noise power in it's length
NoisePowerRange      =  sum(abs(LocalBinsRange ).^2) - SignalPowerRange;

% SINR in Length
localSINR_Range      =  10*log10((SignalPowerRange)*(1/NoisePowerRange));


% signal length in doppler direction
SignalBinsDoppler    =  RD_mat(b,MinColSig:MaxColSig);  
% noise + signal length in doppler direction
LocalBinsDoppler     =  RD_mat(b,MinColLocal:MaxColLocal);
% signal power in it's length
SignalPowerDoppler   =  sum(abs(SignalBinsDoppler).^2);
% noise power in it's length
NoisePowerDoppler    =  sum(abs(LocalBinsDoppler).^2) - SignalPowerDoppler;

% SINR in length
localSINR_Doppler    =  10*log10((SignalPowerDoppler)*(1/NoisePowerDoppler));

