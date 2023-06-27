function data_cmplx = cmplx_data_channels(filename,NumChirpsPerFrame,NumSamplePerChirp,NumFramePerChannel,NumChannel)
% experimental data file extraction
FID = fopen(filename,'r');
data = fread(FID,'int16');

fclose(FID);

data_cmplx            = zeros(NumChirpsPerFrame*NumSamplePerChirp*NumFramePerChannel,NumChannel);

for ch=1:NumChannel
    for i = 1:NumChirpsPerFrame*NumSamplePerChirp*NumFramePerChannel
       
        data_cmplx(i,ch) = complex(data(2*NumChannel*(i-1)+2*ch-1) , data(2*NumChannel*(i-1)+2*ch));
    end
end


end