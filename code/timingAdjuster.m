
timing = 0.02;
duration = timing;


running = true;
while running
    
    % Wait duration
    tic;
    while toc < duration
    end

    % Do code / transmission
    tic;
    
    for i = 1:1000
        fprintf("");
    end

    disp("dur: "+duration+", date: "+datestr(now,'MM:SS.FFF'));

    % Take new timestamp
    duration = timing-(toc);

end









