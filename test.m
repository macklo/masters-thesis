close all
clear
clc

x0 = [5.50677; 0.132906; 0.0019752; 49.3818];
% x0 = [1 1 1 1];
u0 = 0.016783;

y0 = x0(4)/x0(3);

workpoint = struct('x0', x0, 'u0', u0, 'y0', y0, 't0', 0);

t0 = 0;
tfinal = 5;

r = Reactor(workpoint);

figure
hold on
grid on
legends = [];

for mult = -0.8:0.1:1
	u = u0 + mult * u0;
	legends = [legends u];
	[t, x] = r.simulate(x0, u, t0, tfinal);
	y = x(:,4)./x(:, 3);
	stairs(t, y)
end