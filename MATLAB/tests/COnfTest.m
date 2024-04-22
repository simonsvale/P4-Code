
radio = configureSDR('B210','');

freq = [];

freq(1) = 775250000;
freq(2) = 1857850000;
freq(3) = 2115850000;
freq(4) = 3420480000;

[SSB, time] = frequencySweep(radio, freq, 60);
disp("SSBs:")
disp(SSB);

disp("Time:")
disp(datestr(time,'YYYY/mm/dd HH:MM:SS:FFF'));

clear radio;
clear SSB;
clear Time;
