rx = comm.SDRuReceiver(...
              Platform ="B210", ...
              SerialNum ='8000748', ...
              CenterFrequency =2.5e9);

disp(getRadioTime(rx));
release(rx)
