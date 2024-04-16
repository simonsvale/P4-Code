% t = timer('ExecutionMode', 'fixedRate', 'Period', 1, 'TimerFcn', @(~,~) disp(datetime('now','Format','HH:mm:ss.SSSSSS')));
% t.TasksToExecute = 3;
% start(t);

t = timer;
t.ExecutionMode = 'fixedRate';
t.Period = 1;
t.TimerFcn = @(~,~) disp(datetime('now','Format','HH:mm:ss.SSSSSS'));
t.TasksToExecute = 10;
start(t);
