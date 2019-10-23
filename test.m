close all
clear
clc

r = Reactor;

x0 = [5.50677; 0.132906; 0.0019752; 49.3818];
% x0 = [1 1 1 1];
u0 = 0.016783;

y0 = x0(4)/x0(3);

t0 = 0;
tfinal = 10;

figure
hold on
grid on

for mult = 0
	[t, x] = r.simulate(x0, u0 + mult*u0, t0, tfinal);
	y = x(:,4)./x(:, 3);
	stairs(t, y)
end