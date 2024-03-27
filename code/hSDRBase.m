classdef(Abstract) hSDRBase < handle
%hSDRBase Base SDR helper class for RX/TX SDR object creation

%   Copyright 2022-2024 The MathWorks, Inc.

    properties(Dependent)
        % General Params
        CenterFrequency;
        DeviceAddress;
        ChannelMapping;
        SampleRate;
    end

    properties (Hidden, Dependent)
        MasterClockRate;
        SampleRateFactor;
    end

    properties (Dependent,SetAccess=protected)
        DeviceName;
        SDRObj;
    end

    properties (Access = protected)
        ProvidedUSRPSampleRate;
    end

    properties(Constant, Hidden)
        ListOfUSRPs = {'N200/N210/USRP2', 'N300', 'N310', 'N320/N321', ...
                       'B200', 'B210', 'X300', 'X310'};
        ListOfOtherTransceivers = {'Pluto', 'AD936x', 'FMCOMMS5', 'E3xx'};
        ListOfWTConfigurations = getWTDeviceOptions;
    end

    methods (Static)
        function options = getDeviceNameOptions
            options = string([hSDRBase.ListOfWTConfigurations, hSDRBase.ListOfOtherTransceivers, hSDRBase.ListOfUSRPs]);
        end
    end

    % MATLAB method for storing static properties
    methods (Static,Access=private)
        function out = getSetDeviceName(in)
            persistent name
            if nargin
                name = in;
            end
            out = name;
        end

        function out = getSetSDRObj(in)
            persistent sdrObj
            if nargin
                sdrObj = in;
            end
            out = sdrObj;
        end

        function out = getSetInstanceCount(in)
            persistent instanceCount
            if isempty(instanceCount)
                instanceCount = 0;
            end

            if nargin
                instanceCount = in;
            end
            out = instanceCount;
        end

        function out = getSetCreationListener(in)
            persistent creationListener
            if nargin
                creationListener = in;
            end
            out = creationListener;
        end

        function out = getSetDestructionListener(in)
            persistent destructionListener
            if nargin
                destructionListener = in;
            end
            out = destructionListener;
        end
    end

    methods

        %DeviceName
        function value = get.DeviceName(obj)
            value = obj.getSetDeviceName;
        end

        function set.DeviceName(obj,value)
            obj.getSetDeviceName(value);
        end

        %SDRObj
        function value = get.SDRObj(obj)
            value = obj.getSetSDRObj;
        end

        function set.SDRObj(obj,value)
            obj.getSetSDRObj(value);
        end

        %MasterClockRate
        function set.MasterClockRate(obj,value)
            if matches(obj.DeviceName, obj.ListOfUSRPs)
                obj.SDRObj.MasterClockRate = value;
            end
        end

        function value = get.MasterClockRate(obj)
            if matches(obj.DeviceName, obj.ListOfUSRPs)
                value = obj.SDRObj.MasterClockRate;
            end
        end

        %CenterFrequency
        function set.CenterFrequency(obj,value)
            obj.SDRObj.CenterFrequency = value;
        end

        function value = get.CenterFrequency(obj)
            value = obj.SDRObj.CenterFrequency;
        end

        %DeviceAddress
        function set.DeviceAddress(obj,value)
            switch obj.DeviceName
              case {'AD936x', 'FMCOMMS5', 'E3xx', 'N200/N210/USRP2', ...
                    'N300', 'N310', 'N320/N321', 'X300', 'X310'}
                obj.SDRObj.IPAddress = value;
              case 'Pluto'
                obj.SDRObj.RadioID = value;
              case 'RTL-SDR'
                obj.SDRObj.RadioAddress = value;
              case {'B200', 'B210'}
                obj.SDRObj.SerialNum = value;
              case obj.ListOfWTConfigurations
                error("hSDRBase:setDeviceAddress","DeviceAddress is read-only for %s", obj.DeviceName)
            end
        end

        function value = get.DeviceAddress(obj)
            switch obj.DeviceName
              case {'AD936x', 'FMCOMMS5', 'E3xx', 'N200/N210/USRP2', ...
                    'N300', 'N310', 'N320/N321', 'X300', 'X310'}
                value = obj.SDRObj.IPAddress;
              case {'B200', 'B210'}
                value = obj.SDRObj.SerialNum;
              case {'Pluto'}
                value = obj.SDRObj.RadioID;
              case 'RTL-SDR'
                value = obj.SDRObj.RadioAddress;
              case obj.ListOfWTConfigurations
                configs = radioConfigurations;
                value = configs(matches(obj.DeviceName,obj.ListOfWTConfigurations)).IPAddress;
            end
        end

        %ChannelMapping
        function set.ChannelMapping(obj,value)
            if (isstring(value) || ischar(value)) && all(matches(value,obj.getAntennaOptions))
                value = eval(value);
            end
            if matches(obj.DeviceName, [obj.ListOfOtherTransceivers obj.ListOfUSRPs])
                obj.SDRObj.ChannelMapping = value;
            elseif matches(obj.DeviceName, obj.ListOfWTConfigurations)
                obj.SDRObj.Antennas = value;
            else
                error("hSDRBase:setChannelMapping","ChannelMapping Property is read-only for %s", obj.DeviceName);
            end
        end

        function value = get.ChannelMapping(obj)
            if matches(obj.DeviceName, [obj.ListOfOtherTransceivers obj.ListOfUSRPs])
                value = obj.SDRObj.ChannelMapping;
            elseif matches(obj.DeviceName, obj.ListOfWTConfigurations)
                value = obj.SDRObj.Antennas;
            else
                value = 1;
            end
        end

        %SampleRateFactor
        function set.SampleRateFactor(obj, value)
            if matches(obj.DeviceName, obj.ListOfUSRPs)
                if isa(obj.SDRObj, 'comm.SDRuReceiver')
                    obj.SDRObj.DecimationFactor = value;
                else
                    obj.SDRObj.InterpolationFactor = value;
                end
            end
        end

        function value = get.SampleRateFactor(obj)
            if matches(obj.DeviceName, obj.ListOfUSRPs)
                if isa(obj.SDRObj, 'comm.SDRuReceiver')
                    value = obj.SDRObj.DecimationFactor;
                else
                    value = obj.SDRObj.InterpolationFactor;
                end
            end
        end

        %SampleRate
        function set.SampleRate(obj, value)
            switch obj.DeviceName
              case obj.ListOfOtherTransceivers
                obj.SDRObj.BasebandSampleRate = value;
              case ['RTL-SDR', obj.ListOfWTConfigurations]
                obj.SDRObj.SampleRate = value;
              case obj.ListOfUSRPs
                [obj.MasterClockRate, obj.SampleRateFactor] ...
                    = obj.hValidateUSRPSampleRate(obj.DeviceName, value);
            end
        end

        function value = get.SampleRate(obj)
            switch obj.DeviceName
              case obj.ListOfOtherTransceivers
                value = obj.SDRObj.BasebandSampleRate;
              case ['RTL-SDR', obj.ListOfWTConfigurations]
                value = obj.SDRObj.SampleRate;
              case obj.ListOfUSRPs
                value = obj.MasterClockRate/obj.SampleRateFactor;
            end
        end

        function release(obj)
            if ~matches(obj.DeviceName,obj.ListOfWTConfigurations)
                release(obj.SDRObj);
            end
        end

        function out = info(obj)
            if ~matches(obj.DeviceName,obj.ListOfWTConfigurations)
                out = info(obj.SDRObj);
            end
        end

        function antOpts = getAntennaOptions(obj)

        % Acquire valid antenna values based on radio
            switch obj.DeviceName
              case obj.ListOfWTConfigurations
                antennas = getWTDeviceAntennaOptions(obj.DeviceName);
              case {'X300','FMCOMMS5'}
                antennas = [1 2 3 4]';
              case {'Pluto', 'B200', 'N200/N210/USRP2'}
                antennas = 1;
              otherwise
                antennas = [1 2]';
            end

            % Generate a string array list of all valid antenna configurations
            antOpts = strings(0,1);
            for a = 1:length(antennas)
                % Generate unique combinations
                AntennaCombinations = nchoosek(antennas,a);
                % Generate list of all unique combinations
                for i = 1:size(AntennaCombinations, 1)
                    antOpts = [antOpts;string(mat2str(AntennaCombinations(i,:)))]; %#ok<AGROW>
                end
            end

        end

    end

    methods(Hidden)
        function delete(obj)
            if hSDRBase.getSetInstanceCount <= 0
                hSDRBase.getSetInstanceCount(0);
                obj.DeviceName = [];
                delete(obj.SDRObj);
                delete(hSDRBase.getSetCreationListener);
                delete(hSDRBase.getSetDestructionListener);
            end
        end
    end
    methods(Access=protected)
        function obj = hSDRBase
        % Use meta-class events to track how many instances of class
        % has been created.
            if hSDRBase.getSetInstanceCount == 0
                hSDRBase.getSetCreationListener(addlistener(?hSDRBase,'InstanceCreated',@(src,event)hSDRBase.getSetInstanceCount(hSDRBase.getSetInstanceCount + 1)));
                hSDRBase.getSetDestructionListener(addlistener(?hSDRBase,'InstanceDestroyed',@(src,event)hSDRBase.getSetInstanceCount(hSDRBase.getSetInstanceCount - 1)));
            end
        end

        function [mcr, f] = hValidateUSRPSampleRate(~, platform, sampleRate)
        % HGETUSRPRATEINFORMATION function provides the master clock rate and the
        % interpolation/decimation factor given a USRP platform and a desired
        % sampleRate. If the sample rate is not realizable using the provided
        % platform then an error is thrown informing the user of this. See
        % comm.SDRuTranmitter or comm.SDRuReceiver documentation pages for further
        % information on supported master clock rates and interpolation/decimation
        % factors.
            switch platform
              case 'N200/N210/USRP2'
                masterClockRate = 100e6;
                factor = [4:128 130:2:256 260:4:512];

              case {'N300', 'N310'}
                masterClockRate = [122.88e6 125e6 153.6e6];
                factor = [1:4 6:2:128 130:2:256 260:4:512 520:8:1024];

              case 'N320/N321'
                masterClockRate = [200e6 245.76e6 250e6];
                factor = [1:4 6:2:128 130:2:256 260:4:512 520:8:1024];

              case {'B200', 'B210'}
                minMasterClockRate = 5e6;
                maxMasterClockRate = 61.44e6;
                masterClockRate = minMasterClockRate:1e3:maxMasterClockRate;
                factor = [1:128 130:2:256 260:4:512];

              case {'X300', 'X310'}
                masterClockRate = [184.32e6 200e6];
                factor = [1:128 130:2:256 260:4:512];

              otherwise
                masterClockRate = nan;
                factor = nan;
            end

            possibleSampleRates = masterClockRate'./factor;
            % do not consider smaller sample rates, to satisfy Nyquist:
            possibleSampleRates(possibleSampleRates<sampleRate) = NaN;

            err = abs(possibleSampleRates - sampleRate);
            minErr = min(err,[],"all");
            if isnan(minErr)
                error("hSDRBase:hValidateUSRPSampleRate","The sample rate %.2g is not realizable using the %s radio.",sampleRate,platform);
            end

            [idx1, idx2] = find(err==minErr);
            mcr = masterClockRate(idx1(1));
            f = factor(idx2(1));
        end

        function findUSRP(~, deviceName,sdrObj)
            foundUSRPs = findsdru;
            deviceStatus = foundUSRPs({foundUSRPs.Platform} == deviceName);
            if ~isempty(deviceStatus)
                if matches(deviceName, {'B200', 'B210'})
                    sdrObj.SerialNum = deviceStatus(1).SerialNum;
                else
                    sdrObj.IPAddress = deviceStatus(1).IPAddress;
                end
            else
                warning("hSDRBase:deviceNotFound","Device %s not found", deviceName);
            end
        end

    end
end

function options = getWTDeviceOptions
% GETWTDEVICEOPTIONS returns a string array with all saved Wireless
% Testbench radio configurations and Communication toolbox support package
% SDRs

% Check for WT configurations if user has WT installed and a valid license
    if ~isempty(ver('wt')) && license('test','Wireless_Testbench')
        savedRadioConfigurations = radioConfigurations;
        options = cellstr({savedRadioConfigurations.Name});
    else
        options = {};
    end

end

function options = getWTDeviceAntennaOptions(deviceName)
    configs = radioConfigurations;
    radioHardware = configs(matches([configs.Name],deviceName)).Hardware;

    switch radioHardware
      case "USRP N310"
        options = ["RF0:RX2","RF1:RX2","RF2:RX2","RF3:RX2"];
      case {"USRP N320","USRP N321"}
        options = ["RF0:RX2","RF1:RX2"];
      case "USRP X310"
        options = ["RFA:RX2","RFB:RX2"];
      case "USRP X410"
        options = ["DB0:RF0:RX1","DB0:RF1:RX1","DB1:RF0:RX1","DB1:RF1:RX1"];
    end
end
