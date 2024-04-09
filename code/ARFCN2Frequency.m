% Converts NR-ARFCN to Hz
function centerFrequency = ARFCN2Frequency(ARFCN)
    % Check if ARFCN is a valid for 5G.
    if ARFCN >= 0 && ARFCN < 600000
        fRefOffset = 0;
        nRefOffset = 0;
        deltaFGlobal = 5000;
    
    elseif ARFCN >= 600000 && ARFCN < 2016667
        fRefOffset = 3e9;
        nRefOffset = 6e5;
        deltaFGlobal = 15000;
    
    elseif ARFCN >= 2016667 && ARFCN < 3279166
        fRefOffset = 24250.08 * 10e6;
        nRefOffset = 2016667;
        deltaFGlobal = 60000;
    
    else 
        disp("ARFCN not valid!")
        centerFrequency = -1;
        return
    
    end
    
    % Calculate frequency
    centerFrequency = fRefOffset + (deltaFGlobal * (ARFCN - nRefOffset));

end
