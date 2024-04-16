timing = 0.02;
duration = timing;
timer1 = tic;
startTime = tic;
for n = 1:100
    tic;    % Record current time
    while toc < duration % Wait 20ms(approx) into the future
    end
    for i = 1:4000
        fprintf("");
    end
    % Do code / transmission
    tic;
    disp("Nr: "+n+", dur: "+duration+", date: "+datestr(now,'SS.FFF') + " | toc=" + toc);
    duration = timing-(toc);    % Adjust next cycle to wait less if transmission was time-consuming
end
% disp("Total elapsed time: ", toc(timer1));

t = timer;
t.TimerFcn = @(~,thisEvent)disp([thisEvent.Type ' executed ' datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
t.TasksToExecute = 10;
t.ExecutionMode = 'fixedRate';
start(t)