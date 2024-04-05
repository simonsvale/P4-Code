function waveform = variableSampleCapture(Recv, captureDuration)
    % Capture wave
    fprinf("Capturing wave ");
    
    % Set return variable
    waveform = [-1,-1];

    warning('off','sdru:SDRuReceiver:ReceiveUnsuccessful'); % turn off specific warning
    
    while true
        
        try
            lastwarn(''); % Clear warning state.
            waveform = capture(Recv,captureDuration); % Capture wave
            [~, warning_id] = lastwarn; % Capture potential warning
            
            % Check if the warning was the one related to sample rate.
            switch warning_id
                case 'sdru:SDRuReceiver:ReceiveUnsuccessful'
                    if Recv.SampleRate >= 1.1e6
                        fprintf(".")
                        Recv.SampleRate = Recv.SampleRate - 1e6; % Negate a tiny amount
                        continue
                    end
  
                % If the wave was captured succesfully.
                otherwise
                    disp(newline+"New sample rate: "+Recv.SampleRate);
                    break   
            end

        catch err
            disp("CAPTURE ERROR: "+err.identifier);
            delete(Recv);
            break
        end
        
    end

    warning('on','sdru:SDRuReceiver:ReceiveUnsuccessful');

end