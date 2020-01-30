clc
clear
close all

load("./data/fuzzyStaticModel.mat")
load("./data/weights.mat")

fuzzyStaticModel = FuzzyStaticModel(mf, params);


x0 = [5.50677; 0.132906; 0.0019752; 49.3818];
u0 = 0.016783;

y0 = x0(4)/x0(3);

t0 = 0;
tfinal = 1.5;

workpoint = struct('x0', x0, 'u0', u0, 'y0', y0, 't0', 0);

sim_length = 10000;

umin = 0.0016;
umax = 0.067;

% uVals = build_random_setpoints_array(workpoint, sim_length, 400, umin, umax);
load("./data/uTrajectory.mat")
load("./data/yTrajectory.mat")

u = uVals(1:sim_length);
y_m = workpoint.y0.*ones(1, sim_length);

whReactor = WHReactor(workpoint, fuzzyStaticModel, w);

start= 1;
for k = start:sim_length
	k
	whReactor.setControl(u(k));
	whReactor.nextIteration();
	y_m(k) = whReactor.getOutput();
end

figure
plot(whReactor.u)

% err = (y_m - y) * (y_m - y)' / sim_length;

t = whReactor.t;

figure
	subplot(2, 1, 1)
		hold on;
		stairs(t, y(1:sim_length), 'b');
		stairs(t, y_m, 'r');
		legend("y", "y_m")
		title("Wyjœcie")
		ylabel("Œrednie stê¿enie")
		xlabel("t [h]")
	
	subplot(2, 1, 2)
		stairs(t, u(1:sim_length), 'r');
		legend("u")
		title("Sterowanie")
		ylabel("F_I [m^3/h]")
		xlabel("t [h]")