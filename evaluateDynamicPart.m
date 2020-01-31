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

sim_length = 1000;

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

figure
	subplot(2, 1, 1)
		hold on;
		stairs(y);
		title("Odpowiedü skokowa")
		ylabel("y")
	
	subplot(2, 1, 2)
		stairs(u(1:sim_length));
		ylabel("u")

y = (y' -y(1))
u = (u - u(1))/0.001
y = y/y(end)
% figure
% 	hold on
% 	plot(y)
	
Y = y(10:end)';
M = [y(9:end-1)' y(8:end-2)' y(7:end-3)' y(6:end-4)' u(10:end)' u(9:end-1)' u(8:end-2)' u(7:end-3)' u(6:end-4)'];
w = M\Y;

y_m = y
for k = 10:sim_length
	k
	q = [y_m(k-1) y_m(k-2) y_m(k-3) y_m(k-4) u(k) u(k-1) u(k-2) u(k-3) u(k-4)];
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
	q = [y_test(k-1) y_test(k-2) y_test(k-3) y_test(k-4) utest(k) utest(k-1) utest(k-2) utest(k-3) utest(k-4)];
	y_test(k) = q*w;
end
figure
	plot(y_test)
	
save("data/weights.mat", "w");
s = (y(start:end) - y(start-1));
save("data/hammersteinS.mat", "s");
figure;
    stairs(s);
	title("Odpowiedü skokowa")
	ylabel("y")
	xlabel("k")
% ys = 13;
% us = 0.2;
% 
% u = u*us;
% 
% wt = w;
% wt(1:4) = w(1:4);
% wt(5:end) = w(5:end)*ys/us;
% 
% for k = 5:sim_length
% 	q = [y_test(k-1) y_test(k-2) y_test(k-3) y_test(k-4) u(k) u(k-1) u(k-2) u(k-3) u(k-4)];
% 	y_test(k) = q*wt;
% end
% figure
% subplot(2, 1, 1)
% 	plot(y_test)
% subplot(2, 1, 2)
% 	plot(u)