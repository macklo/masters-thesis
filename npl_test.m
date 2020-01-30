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
obj = Reactor(workpoint);

umin = 0.0016;
umax = 0.067;
dumax = 0.004;

N = 400;
Nu = 400;
lambda = 1e10;

sim_length = 500;

setPoints = build_random_setpoints_array(workpoint, sim_length, 300, 13000, 50000);

load("./data/fuzzyStaticModel.mat")
load("./data/weights.mat")
fuzzyStaticModel = FuzzyStaticModel(mf, params);
object = WHReactor(workpoint, fuzzyStaticModel, w);

reg = NPL_Regulator(object, workpoint, N, Nu, lambda, umin, umax, dumax);

u = workpoint.u0.*ones(1, sim_length);
y = workpoint.y0.*ones(1, sim_length);
y_m = workpoint.y0.*ones(1, sim_length);
y_static = workpoint.y0.*ones(1, sim_length);

for k = 5:sim_length
	k
    y(k) = obj.getOutput();
	
	q = [y_static(k-1) y_static(k-2) y_static(k-3), ...
		u(k-1) u(k-2) u(k-3) u(k-4), ...
		y(k-1) y(k-2) y(k-3) y(k-4)];
					
	w_l = zeros(size(object.w));
	y_m = object.getOutput(q);
	%2. Linearyzacja modelu
	delta=1e-8;
	for i = 1:11
		q_tmp = q;
		q_tmp(i) = q_tmp(i) + delta;
		w_l(i) = (object.getOutput(q_tmp) - y_m)/delta;
	end


	%3. Oblicz odp. skokow¹
	sc=reg.getS(w_l);
% 			plot(sc)

	%4. Oblicz macierz dynamiczna
	M = zeros(N, Nu);
	for i = 1:N
		for j = 1:Nu
			if (i >= j)
				M(i,j) = sc(i-j+1);
			else
				M(i,j) = 0;
			end
		end
	end

	%5. Oblicz K
	K = ((M'*M + lambda*eye(Nu, Nu))^(-1))*M';

	%6. Oblicz d
	d = y(k) - y_m;

	%7. Oblicz trajektorie swobodna
	Y0 = zeros(N, 1);
	q = [y_static(k-1) y_static(k-1) y_static(k-2) ...
		u(k-1) u(k-1) u(k-2) u(k-3)  ...
		y(k-1) y(k-1) y(k-2) y(k-3)];
	Y0(1) = object.getOutput(q) + d;

	q = [y_static(k-1) y_static(k-1) y_static(k-1) ...
		u(k-1) u(k-1) u(k-1) u(k-2)  ...
		Y0(1) y(k-1) y(k-2) y(k-3)];
	Y0(2) = object.getOutput(q) + d;

	q = [y_static(k-1) y_static(k-1) y_static(k-1) ...
		u(k-1) u(k-1) u(k-1) u(k-1)  ...
		Y0(2) Y0(1) y(k-1) y(k-2)];
	Y0(3) = object.getOutput(q) + d;

	q = [y_static(k-1) y_static(k-1) y_static(k-1) ...
		u(k-1) u(k-1) u(k-1) u(k-1)  ...
		Y0(3) Y0(2) Y0(1) y(k-1)];
	Y0(4) = object.getOutput(q) + d;

	for i =5:N
		q = [y_static(k-1) y_static(k-1) y_static(k-1) ...
			u(k-1) u(k-1) u(k-1) u(k-1)  ...
			Y0(i-1) Y0(i-2) Y0(i-3) Y0(i-4)];
		Y0(i) = object.getOutput(q) + d;
	end

	%8. Oblicz DELTAU
	Y_zad  = ones(N, 1)*setPoints(k);
	deltaU = K*(Y_zad - Y0);

	if(deltaU > dumax)
		deltaU = dumax;
	elseif (deltaU < -dumax)
		deltaU = dumax;
	end

	%9.Do sterowania pierwszy element
	u(k) = u(k-1) + deltaU(1);

	%10. Ewentualnie przytnij
	if(u(k) > umax)
		u(k) = umin;
	elseif (u(k) < umin)
		u(k) = umin;
	end
	obj.setControl(u(k));
    obj.nextIteration();
	
end

figure
	subplot(2, 1, 1)
		hold on;
		stairs(setPoints, 'b');
		stairs(y, 'r');
		legend("y_{zad}", "y")
		title("Wyjœcie")
		ylabel("Œrednie stê¿enie")
		xlabel("t [h]")
	
	subplot(2, 1, 2)
		stairs(u, 'r');
		legend("u")
		title("Sterowanie")
		ylabel("F_I [m^3/h]")
		xlabel("t [h]")

e = (y - setPoints)*(y - setPoints)';