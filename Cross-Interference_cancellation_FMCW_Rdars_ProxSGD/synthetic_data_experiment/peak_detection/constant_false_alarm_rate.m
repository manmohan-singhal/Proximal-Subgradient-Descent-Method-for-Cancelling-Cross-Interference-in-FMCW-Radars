function peak_bins_rdm = constant_false_alarm_rate(cell,Z,Threshold)

[NumChirps,NumSamplesPerChirp] = size(Z);

NTrR        =  cell.NumTrainingCellRange ;
NTrD        =  cell.NumTrainingCellDoppler ;
NGrR        =  cell.NumGuardCellRange ;
NGrD        =  cell.NumGuardCellDoppler;

DopplerIndices =[];
RangeIndices =[];
Magnitude = [];

for range = NTrR + NGrR + 1 : (NumSamplesPerChirp)-(NTrR + NGrR)
    for doppler = NTrD + NGrD + 1 : NumChirps - (NTrD+NGrD)
        power_level = 0;
        temp =0;
        for i = range - (NTrR + NGrR) : range + NTrR + NGrR
            for j = doppler - (NTrD + NGrD) : doppler - (NTrD+NGrD)
                if (abs(range-i) > NGrR || abs(range-j) > NGrD)
                    power_level = power_level + (abs(Z(j,i)))^2;
                    temp = temp +1;
                end
            end
        end
        
        
        threshold =   Threshold*(sqrt(power_level /temp));

        %Compare with threshold
    
        if (abs(Z(doppler,range)) > threshold)
            DopplerIndices = [  DopplerIndices ; doppler];
            RangeIndices = [RangeIndices ; range];
            Magnitude = [ Magnitude ; 20*log10(abs(Z(doppler,range)))];
        end

    end
end

peak_bins_rdm = [RangeIndices,DopplerIndices,Magnitude];

end
