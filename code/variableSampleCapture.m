function waveform = variableSampleCapture(Recv, captureDuration)
    % Capture wave
    disp("Capturing wave");
    
    % Set return variable
    waveform = [-1,-1];
    
    while true
        
        try
            lastwarn(''); % Clear warning state
            waveform = capture(Recv,captureDuration); % Capture wave
            [~, warning_id] = lastwarn; % Capture potential warning
            
            % Check if the warning was the one related to sample rate.
            switch warning_id
                case 'sdru:SDRuReceiver:ReceiveUnsuccessful'
                    if Recv.SampleRate >= 1e6
                        disp("Rate: "+Recv.SampleRate);
                        Recv.SampleRate = Recv.SampleRate - 0.5e6; % Negate a tiny amount
                        continue
                    end
                
                % If the wave was captured succesfully.
                otherwise
                    return    
            end

        catch err
            fprintf("CAPTURE ERROR: "+err.identifier+newline);
            delete(Recv);
            return
        end
        
    end

end