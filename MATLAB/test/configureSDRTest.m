classdef configureSDRTest < matlab.unittest.TestCase
% Used to test the configureSDR() function from the functions folder
% No SDR should be connected during testing

    methods (Test)
        function testWithDefault(testCase)
            % Test when no serial number is provided
            deviceName = "B210";
            [rx, tx] = configureSDR(deviceName, "");

            % Verify the RX properties
            testCase.verifyRxProperties(rx, deviceName);

            % Verify the TX properties
            testCase.verifyTxProperties(tx, deviceName, '')

        end
    end

    methods (Test)
        function testWithGivenSerialNum(testCase)
            % Test when a serial number is provided
            deviceName = "B210";
            serialNum = "8000758";
            [rx, tx] = configureSDR(deviceName, serialNum);

            % Verify the RX properties
            testCase.verifyRxProperties(rx, deviceName);

            % Verify the TX properties
            testCase.verifyTxProperties(tx, deviceName, char(serialNum))
        end
    end

    methods
        function verifyRxProperties(testCase, rx, deviceName)
            % Helper method to verify all rx properties
            testCase.verifyEqual(rx.Gain, 76);
            testCase.verifyEqual(rx.OutputDataType, 'single');
            testCase.verifyEqual(rx.ChannelMapping, 1)
            testCase.verifyEqual(rx.SampleRate, 31e6)
            testCase.verifyEqual(rx.DeviceName, deviceName)
        end
    end

    methods
        function verifyTxProperties(testCase,tx, deviceName, serialNum)
            % Helper method to verify all tx properties
            testCase.verifyEqual(tx.Platform, char(deviceName))
            testCase.verifyEqual(tx.SerialNum, serialNum)
            testCase.verifyEqual(tx.ChannelMapping, 1)
            testCase.verifyEqual(tx.CenterFrequency, 2.4500e+09)
            testCase.verifyEqual(tx.LocalOscillatorOffset, 0)
            testCase.verifyEqual(tx.Gain, 76)
            testCase.verifyEqual(tx.PPSSource, 'Internal')
            testCase.verifyFalse(tx.EnableTimeTrigger)
            testCase.verifyEqual(tx.MasterClockRate, 31000000)
            testCase.verifyEqual(tx.InterpolationFactor, 512)
            testCase.verifyEqual(tx.TransportDataType, 'int16')
            testCase.verifyFalse(tx.EnableBurstMode)
        end
    end

end
