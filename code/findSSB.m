function detectedSSB = findSSB(waveform,centerFrequency,scs,sampleRate,showFig)
% FINDSSB returns a logical value that depends on if WAVEFORM contains a
% valid SSB.
    ssbBlockPattern = hSynchronizationRasterInfo.getBlockPattern(scs,centerFrequency);
    scsNumeric = double(extract(scs,digitsPattern));
    searchBW = 3*scsNumeric;
    displayFigure = false;
    [correctedWaveform,~,NID2] = hSSBurstFrequencyCorrect(waveform,ssbBlockPattern,sampleRate,searchBW,displayFigure);

    % Create a reference grid for timing estimation
    nrbSSB = 20;
    refGrid = zeros([nrbSSB*12 2]);
    refGrid(nrPSSIndices,2) = nrPSS(NID2);

    % Calculate timing offset and demodulate the grid
    nSlot = 0;
    timingOffset = nrTimingEstimate(correctedWaveform,nrbSSB,scsNumeric,nSlot,refGrid,SampleRate=sampleRate);
    correctedWaveform = correctedWaveform(1+timingOffset:end,:);
    rxGrid = nrOFDMDemodulate(correctedWaveform,nrbSSB,scsNumeric,nSlot,SampleRate=sampleRate);
    rxGrid = rxGrid(:,2:5,:);

    % Extract the received SSS symbols from the SS/PBCH block
    sssIndices = nrSSSIndices;
    sssRx = nrExtractResources(sssIndices,rxGrid);

    % Correlate received SSS symbols with each possible SSS sequence
    sssEst = zeros(1,336);
    for NID1 = 0:335
        ncellid = (3*NID1) + NID2;
        sssRef = nrSSS(ncellid);
        sssEst(NID1+1) = sum(abs(mean(sssRx .* conj(sssRef),1)).^2);
    end

    % Determine NID1 by finding the strongest correlation
    NID1 = find(sssEst==max(sssEst)) - 1;

    % Form overall cell identity from estimated NID1 and NID2
    ncellid = (3*NID1) + NID2;

    % Calculate PBCH DM-RS indices
    dmrsIndices = nrPBCHDMRSIndices(ncellid);

    % Perform channel estimation using DM-RS symbols for each possible
    % DM-RS sequence and estimate the SNR
    dmrsEst = zeros(1,8);
    for ibar_SSB = 0:7
        refGrid = zeros([240 4]);
        refGrid(dmrsIndices) = nrPBCHDMRS(ncellid,ibar_SSB);
        [hest,nest] = nrChannelEstimate(rxGrid,refGrid,'AveragingWindow',[0 1]);
        dmrsEst(ibar_SSB+1) = 10*log10(mean(abs(hest(:).^2)) / nest);
    end

    % Record ibar_SSB for the highest SNR
    ibar_SSB = find(dmrsEst==max(dmrsEst)) - 1;

    % Channel Estimation using PBCH DM-RS and SSS
    refGrid = zeros([nrbSSB*12 4]);
    refGrid(dmrsIndices) = nrPBCHDMRS(ncellid,ibar_SSB);
    refGrid(sssIndices) = nrSSS(ncellid);
    [hest,nest] = nrChannelEstimate(rxGrid,refGrid,'AveragingWindow',[0 1]);

    % Extract the received PBCH symbols from the SS/PBCH block
    [pbchIndices,pbchIndicesInfo] = nrPBCHIndices(ncellid);
    pbchRx = nrExtractResources(pbchIndices,rxGrid);

    % Configure 'v' for PBCH scrambling according to TS 38.211 Section
    % 7.3.3.1 'v' is also the 2 LSBs of the SS/PBCH block index for
    % L_max=4, or the 3 LSBs for L_max=8 or 64.
    if centerFrequency <= 3e9
        L_max = 4;
        v = mod(ibar_SSB,L_max);
    else
        L_max = 8;
        v = ibar_SSB;
    end
    ssbIndex = v;

    % PBCH equalization and CSI calculation
    pbchHest = nrExtractResources(pbchIndices,hest);
    [pbchEq,csi] = nrEqualizeMMSE(pbchRx,pbchHest,nest);
    Qm = pbchIndicesInfo.G / pbchIndicesInfo.Gd;
    csi = repmat(csi.',Qm,1);
    csi = reshape(csi,[],1);

    % PBCH demodulation
    pbchBits = nrPBCHDecode(pbchEq,ncellid,v,nest);

    % Apply CSI
    pbchBits = pbchBits .* csi;

    % Perform BCH decoding
    polarListLength = 8;
    [~,crcBCH] = nrBCHDecode(pbchBits,polarListLength,L_max,ncellid);
    gscn = hSynchronizationRasterInfo.frequency2gscn(centerFrequency);
    if crcBCH == 0
        % Plot grid and highlight strongest SSB
        demodRB = 30;
        rxGrid = nrOFDMDemodulate(correctedWaveform,demodRB,scsNumeric,nSlot,SampleRate=sampleRate);
        % Extract 4 symbols of grid if exists
        if size(rxGrid,2) < 56
            last = size(rxGrid,2);
        else
            last = 14*4;
        end

        ssbFreqOrigin = 12*(demodRB-nrbSSB)/2 + 1;
        startSymbol = 1;
        numSymbolsSSB = 4;
        detectedSSB = true;

        if showFig
            figure;imagesc(abs(rxGrid(:,1:last,1))); axis xy
            xlabel('OFDM symbol'); ylabel('Subcarrier');
            ttl = sprintf('Resource Grid of SS Burst at GSCN %d (%.2f MHz)',gscn,centerFrequency/1e6);
            title(ttl)
            rectangle('Position',[startSymbol+0.5 ssbFreqOrigin-0.5 numSymbolsSSB 12*nrbSSB],EdgeColor='r',LineWidth=1.5)
            str = sprintf('Strongest SSB: %d',ssbIndex);
            text(startSymbol,ssbFreqOrigin-nrbSSB,0,str,FontSize=12,Color='w');
            drawnow
        end

    else
        detectedSSB = false;
        %fprintf("<strong>No SSB Detected at GSCN %d (%.2f MHz).</strong>\n",gscn,centerFrequency/1e6);
    end
end