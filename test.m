close all
clear
clc

r = Reactor;

x0 = [5.50677; 0.132906; 0.0019752; 49.3818];
u0 = 0.016783;
u0 = 1;
y0 = x0(4)/x0(3);

t0 = 0;
tfinal = 10;

[t, x] = r.simulate(x0, u0, t0, tfinal);

y = x(:,4)./x(:, 3);

plot(t, y)