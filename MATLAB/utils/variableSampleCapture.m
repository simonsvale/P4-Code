function [waveform, timestamp] = variableSampleCapture(rx, captureDuration)
    % Set return variable
    waveform = [-1,-1];

    warning('off','sdru:SDRuReceiver:ReceiveUnsuccessful'); % turn off specific warning
    warning('off','sdru:reportSDRuStatus:UnknownStatus');
    
    while true
        
        try
            % Clear warning state.
            lastwarn('');

            % Get timestamp and capture wave.
            [waveform,timestamp] = capture(rx,captureDuration);
            disp("Timestamp: "+datestr(timestamp,'YYYY/mm/dd HH:MM:SS:FFF'));

            [~, warning_id] = lastwarn; % Capture potential warning

            % Check if the warning was the one related to sample rate.
            switch warning_id
                case 'sdru:SDRuReceiver:ReceiveUnsuccessful'
                    if Recv.SampleRate >= 1.1e6
                        fprintf(".");
                        Recv.SampleRate = rx.SampleRate - 1e6; % Negate a tiny amount
                        continue
                    end
                % If serial number does not match device.
                case 'sdru:reportSDRuStatus:UnknownStatus'
                    disp(newline+"Device with Serial Number: "+ rx.DeviceAddress+", is not connected, aborting capture.");
                    break

                % If the wave was captured succesfully.
                otherwise
                    %disp(newline+"New sample rate: "+Recv.SampleRate);
                    break   
            end

        catch err
            disp("CAPTURE ERROR: "+err.identifier);
            delete(rx);
            break
        end
        
    end
    
    % Turn the supressed warning back on.
    warning('on','sdru:SDRuReceiver:ReceiveUnsuccessful');
    warning('on','sdru:reportSDRuStatus:UnknownStatus');

end