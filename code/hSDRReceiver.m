classdef hSDRReceiver < hSDRBase
%hSDRReceiver Receive data from an SDR supported by a Communications
% Toolbox Support Package
%   RX = hSDRReceiver(DEVICENAME) creates an hSDRReceiver object, RX, that
%   receives data from a software defined radio (SDR). DEVICENAME is a
%   scalar string or character array that is one of these values: 'AD936x',
%   'FMCOMMS5', 'E3xx', 'Pluto', 'RTL-SDR','N200/N210/USRP2', 'N300', 'N310',
%   'N320/N321', 'B200', 'B210', 'X300', 'X310', or a WT radio configuration.
%
%   RX = hSDRReceiver(DEVICENAME,Name,Value) creates an hSDRReceiver
%   object, RX, with the specified property Name set to the specified
%   Value. You can specify additional name-value pair arguments in any
%   order as (Name1,Value1,...,NameN,ValueN).
%
%   hSDRReceiver methods:
%
%   capture - Receive data from the SDR
%
%   hSDRReceiver properties:
%
%   Gain            - Receiver gain specified as a numeric value in dB,
%                     scalar string, or character array  of a value 'AGC
%                     Slow Attack', 'AGC Fast Attack', or 'Automatic Gain
%                     Control'.
%   OutputDataType  - Data type of output complex samples specified as a
%                     scalar string or character array of value 'double',
%                     'single', or 'int16'.
%   CenterFrequency - Desired center frequency for SDR capture (Hz)
%   DeviceAddress   - Identifiable address such as an IP address
%                     ('192.168.3.2'), serial number ('30AD2D5'), or usb
%                     port ('usb:0') specified as a scalar string or
%                     chararacter array.
%   ChannelMapping  - Channels to receive on
%   SampleRate      - Desired sample rate of SDR (Hz)
%   DeviceName      - Name of device used for SDR object creation
%                     (read-only)
%   SDRObj          - System object of specified SDR created by the support
%                     package API (read-only)
%
%   % Example 1:
%   %   Configure a USRP B210 radio to receive at 2.4 GHz with a sample
%   %   rate of 20 MHz and a capture duration of 500 msec.
%
%   rx = hSDRReceiver('B210',CenterFrequency=2.4e9,SampleRate=20e6);
%   captureDuration = milliseconds(500);
%   [wav,timestamp] = capture(rx,captureDuration);
%   release(rx);
%
%   % Example 2:
%   %   Configure an ADALM-Pluto radio to receive at 700 MHz with a %
%   %   sample rate of 1.98 MHz while using the fast attack automatic gain
%   %   control.
%
%   rx = hSDRReceiver("Pluto")
%   rx.CenterFrequency = 700e6;
%   rx.SampleRate = 1.98e6;
%   rx.Gain = "AGC Fast Attack";
%   captureDuration = milliseconds(20);
%
%   [wav,timestamp] = capture(rx,captureDuration);
%   release(rx);

%   Copyright 2022-2024 The MathWorks, Inc.
    properties(Dependent)
        Gain;
        OutputDataType;
    end

    properties(Hidden, Dependent)
        GainSource;
        SamplesPerFrame;
    end

    methods

        function obj = hSDRReceiver(deviceName, options)
            arguments
                deviceName string {validateRadioName(deviceName)}
                options.SampleRate
                options.CenterFrequency
                options.DeviceAddress
                options.ChannelMapping
                options.Gain
                options.OutputDataType
            end
            % Call base class constructor to set up listeners
            obj@hSDRBase;
            % Re-use existing SDRObj if constructor called with the same
            % deviceName
            if isempty(obj.DeviceName) || ~matches(deviceName,obj.DeviceName) || ~isvalid(obj.SDRObj)
                obj.DeviceName = deviceName;
                obj.SDRObj = obj.instantiateSDRObj(deviceName);
            else
                obj.release;
            end

            obj.OutputDataType = 'single';

            % Set property values according to NameValue pairs
            givenOptions = fieldnames(options);
            if ~isempty(givenOptions)
                for i=1:length(givenOptions)
                    obj.(givenOptions{i}) = options.(givenOptions{i});
                end
            end

        end % Constructor

        %SamplesPerFrame
        function set.SamplesPerFrame(obj,value)
            obj.SDRObj.SamplesPerFrame = value;
        end

        function value = get.SamplesPerFrame(obj)
            value = obj.SDRObj.SamplesPerFrame;
        end

        %OutputDataType
        function set.OutputDataType(obj,value)
            if matches(obj.DeviceName,obj.ListOfWTConfigurations)
                obj.SDRObj.CaptureDataType = value;
            else
                obj.SDRObj.OutputDataType = value;
            end
        end

        function value = get.OutputDataType(obj)
            if matches(obj.DeviceName,obj.ListOfWTConfigurations)
                value = obj.SDRObj.CaptureDataType;
            else
                value = obj.SDRObj.OutputDataType;
            end
        end

        %Gain
        function set.Gain(obj,value)
            switch obj.DeviceName
              case obj.ListOfOtherTransceivers
                if (ischar(value) || isstring(value))
                    value = validatestring(value,{'AGC Slow Attack', 'AGC Fast Attack'});
                    obj.GainSource = value;
                else
                    obj.GainSource = 'Manual';
                    obj.SDRObj.Gain = value;
                end
              case 'RTL-SDR'
                if (ischar(value) || isstring(value))
                    validatestring(value, {'Automatic Gain Control'});
                    obj.SDRObj.EnableTunerAGC = true;
                else
                    obj.SDRObj.EnableTunerAGC = false;
                    obj.SDRObj.TunerGain = value;
                end
              case obj.ListOfUSRPs
                obj.SDRObj.Gain = value;
              case obj.ListOfWTConfigurations
                obj.SDRObj.RadioGain = value;
            end

        end

        function value = get.Gain(obj)
            switch obj.DeviceName
              case obj.ListOfOtherTransceivers
                if matches(obj.GainSource, 'Manual')
                    value = obj.SDRObj.Gain;
                else
                    value = obj.GainSource;
                end
              case 'RTL-SDR'
                if obj.SDRObj.EnableTunerAGC
                    value = 'Automatic Gain Control';
                else
                    value = obj.SDRObj.TunerGain;
                end
              case obj.ListOfUSRPs
                value = obj.SDRObj.Gain;
              case obj.ListOfWTConfigurations
                value = obj.SDRObj.RadioGain;
            end
        end

        %GainSource
        function set.GainSource(obj, value)
            if matches(obj.DeviceName, obj.ListOfOtherTransceivers)
                obj.SDRObj.GainSource = value;
            end
        end

        function value = get.GainSource(obj)
            if matches(obj.DeviceName, obj.ListOfOtherTransceivers)
                value = obj.SDRObj.GainSource;
            end
        end

        function [data,timestamp] = capture(obj,len)
        %capture Capture data from the SDR board
        %
        % [WAVEFORM,TIMESTAMP] = CAPTURE(RX,CAPTUREDURATION) captures
        % IQ data from the air using an hSDRReceiver object, RX.
        %
        % LENGTH is the length of capture, specified as a duration data
        % type or number of samples. When specified as a duration data
        % type, the function converts LENGTH into N samples and returns
        % ceil(N) number of data samples.
        %
        % DATA is a column vector or matrix of complex values. The
        % RX.OutputDataType property determines the data type of DATA.
        % The columns in the matrix correspond to the antennas
        % specified by RX.ChannelMapping. Each column corresponds to
        % complex data received on one antenna.
        %
        % TIMESTAMP is the timestamp of requesting data capture from
        % the hardware.

            if isduration(len)
                len = ceil(seconds(len)*obj.SampleRate);
            end

            if matches(obj.DeviceName, obj.ListOfOtherTransceivers)
                [data,mData] = capture(obj.SDRObj,len,'EnableOversizeCapture',true);
            elseif matches(obj.DeviceName, obj.ListOfWTConfigurations)
                [data,mData.Date] = capture(obj.SDRObj,len);
            else % USRP and RTL-SDR
                 % Sometimes USRPs throw error message during burst capture.
                 % Throw as warning instead and supply zeros on output.
                try
                    [data,mData] = capture(obj.SDRObj,len);
                catch e
                    warning(e.identifier,'%s',e.message)
                    release(obj)
                    data = zeros(len,length(obj.ChannelMapping),'like',1i);
                    mData.Date = datetime('now');
                end

            end
            timestamp = datetime(mData.Date);
        end

    end

    methods(Access=private)

        function sdrObj = instantiateSDRObj(obj, deviceName)
            switch deviceName
              case obj.ListOfOtherTransceivers
                sdrObj = sdrrx(deviceName);

              case 'RTL-SDR'
                sdrObj = comm.SDRRTLReceiver;

              case obj.ListOfUSRPs
                sdrObj = comm.SDRuReceiver('Platform', obj.DeviceName);
                obj.findUSRP(deviceName,sdrObj);
              case obj.ListOfWTConfigurations
                sdrObj = basebandReceiver(deviceName);
            end
        end % function instantiateSDRObj

    end

end

function validateRadioName(radio)
    mustBeMember(radio,[hSDRBase.getDeviceNameOptions, "RTL-SDR"]);
end
