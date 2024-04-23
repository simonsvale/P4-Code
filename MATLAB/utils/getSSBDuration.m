function SSBDurationSeconds = getSSBDuration(centerFrequency)

    scs = hSynchronizationRasterInfo.getSCSOptions(centerFrequency);

    disp(scs);
    
    % See table 16.1 on page 337 in 
    % "5G NR - The next generation wireless access technology."
    switch scs
        case '15 kHz'
            SSBDurationSeconds = 0.000285;

        case '30 kHz'
            SSBDurationSeconds = 0.000143;

        otherwise
            disp("No subcarrier spacing found!");
            SSBDurationSeconds = 0;
            return
    end

end