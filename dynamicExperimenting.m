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

sim_length = 150;

s = cell(1,1);

start = 50;
u = workpoint.u0.*ones(1, sim_length);
y = workpoint.y0.*ones(1, sim_length);
u(start:end) = workpoint.u0 + 0.001;
for k = 1:sim_length
	react.setControl(u(k));
	react.nextIteration();
end

y = react.x(:,4)./react.x(:, 3);

% figure
% 	subplot(2, 1, 1)
% 		hold on;
% 		stairs(y);
% 		title("Odpowiedü skokowa")
% 		ylabel("y")
% 	
% 	subplot(2, 1, 2)
% 		stairs(u(1:sim_length));
% 		ylabel("u")

y = (y' -y(1))
u = (u - u(1))/0.001
y = y/y(end)
% figure
% 	hold on
% 	plot(y)
	
Y = y(10:end)';
M = [y(9:end-1)' y(8:end-2)' u(9:end-1)' u(8:end-2)'];
w = M\Y;

y_m = y
for k = 10:sim_length
	k
	q = [y_m(k-1) y_m(k-2) u(k-1) u(k-2)];
	y_m(k) = q*w;
end
figure
	subplot(2, 1, 1)
		hold on;
		stairs(y);
		stairs(y_m);
		title("Wyjúcie modelu")
		ylabel("y")
		legend("Wyjúcie obiektu", "Wyjúcie modelu")
	
	subplot(2, 1, 2)
		stairs(u(1:sim_length));
		ylabel("u")

err = (y_m - y) * (y_m - y)' / sim_length;


utest = zeros*ones(1, sim_length);
y_test = zeros*ones(1, sim_length);
utest(50:end) = 1;
for k = 5:sim_length
	q = [y_test(k-1) y_test(k-2) utest(k-1) utest(k-2) ];
	y_test(k) = q*w;
end
	
save("data/weights.mat", "w");

ys = 1;
us = 1;

u = u*us;

wg = w;
wg(1:2) = w(1:2);
wg(3:end) = w(3:end)*ys/us;

for k = 5:sim_length
	q = [y_test(k-1) y_test(k-2) u(k-1) u(k-2)];
	y_test(k) = q*wg;
end
figure
subplot(2, 1, 1)
	stairs(y_test*8)
subplot(2, 1, 2)
	stairs(u)

	
ys = -20;
us = 8;

ys1 = -10;
us1 = 16;

u = u*us;

wt = w;
wt(1:2) = w(1:2);
wt(3:end) = w(3:end)*ys1/us1;
sim_length = 400;
utest = us*ones(1, sim_length);
y_test = ys*ones(1, sim_length);
y_static = ys*ones(1, sim_length);
utest(50:end) = us;
utest(200:end) = us1;
y_static(50:end) = ys;
y_static(200:end) = ys1;

for k = 5:sim_length
	k
	q = [y_test(k-1) y_test(k-2) utest(k-1) utest(k-2)];
	if utest(k) ~= 0
		wt(5:end) = w(5:end)*((y_static(k))/(utest(k)));
	end
	
	y_test(k) = q*wt;
end
figure
subplot(2, 1, 1)
	hold on
	stairs(y_test)
	stairs(y_static)
subplot(2, 1, 2)
	stairs(utest)