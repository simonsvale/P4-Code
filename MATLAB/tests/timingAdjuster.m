% t = timer('ExecutionMode', 'fixedRate', 'Period', 1, 'TimerFcn', @(~,~) disp(datetime('now','Format','HH:mm:ss.SSSSSS')));
% t.TasksToExecute = 3;
% start(t);

disp("Trying timer timings (precise)");
t = timer;
t.ExecutionMode = 'fixedRate';
t.Period = 1;
t.TimerFcn = @(~,~) disp(datetime('now','Format','HH:mm:ss.SSSSSS'));
t.TasksToExecute = 3;
start(t);
pause(5);

disp("Trying pause timings (unprecise)");
desired_frequency = 1; % Run code every 1 second
period = 1 / desired_frequency;
num_iterations = 5; % Run code 3 times
for i = 1:num_iterations
    start_time = datetime('now');
    disp(datetime('now','Format','HH:mm:ss.SSSSSS'));
    end_time = start_time + seconds(period);
    while datetime('now') < end_time
        pause(0.01); % small pause to avoid busy waiting
    end
end

