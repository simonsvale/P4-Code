
timing = 0.02;
duration = timing;

for n = 1:1000
    
    % Wait duration
    tic;
    while toc < duration
    end

    % Do code / transmission
    tic;
    
    for i = 1:4000
        fprintf("");
    end

    disp("Nr: "+n+", dur: "+duration+", date: "+datestr(now,'SS.FFF'));

    % Take new timestamp
    duration = timing-(toc);

end









