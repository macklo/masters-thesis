clear;
close all;
clc;

addpath('./abstraction')
addpath('./classes')
addpath('./..')


x0 = [5.50677; 0.132906; 0.0019752; 49.3818];
u0 = 0.016783;

y0 = x0(4)/x0(3);

workpoint = struct('x0', x0, 'u0', u0, 'y0', y0, 't0', 0);
react = Reactor(workpoint);

sim_length = 2000;

s = cell(1,1);

start = 1000;
u = workpoint.u0.*ones(1, sim_length);
y = workpoint.y0.*ones(1, sim_length);
u(start:end) = workpoint.u0 + 0.001;
for k = 1:sim_length
	react.setControl(u(k));
	react.nextIteration();
end

y = react.x(:,4)./react.x(:, 3);

s{1} = (y(start:end) - y(start-1))/0.001;

save('./data/s.mat', 's');
figure;
    stairs(s{1, 1});
	title("Odpowiedü skokowa")
	ylabel("y")
	xlabel("k")
	