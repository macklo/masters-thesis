clc
clear
close all

addpath('./abstraction')
addpath('./classes')
addpath('./..')

load("./data/fuzzyStaticModel.mat")
load("./data/weights.mat")

fuzzyStaticModel = FuzzyStaticModel(mf, params);

x0 = [5.50677; 0.132906; 0.0019752; 49.3818];
u0 = 0.016783;

y0 = x0(4)/x0(3);

t0 = 0;
tfinal = 1.5;

workpoint = struct('x0', x0, 'u0', u0, 'y0', y0, 't0', 0, 'y_static0', fuzzyStaticModel.getOutput(u0));
obj = Reactor0(workpoint);

umin = 0.0016 - u0;
umax = 0.067;
dumax = 0.004;

D = 200;
N = 200;
Nu = 200;
lambda = 1e8;
psii = 1;
sim_length = 3000;

load("data/setPoints.mat")

y_m = 0*ones(1, sim_length);
y_static_0 = fuzzyStaticModel.getOutput(u0);
y_static = 0*ones(1, sim_length);

load('./data/hammersteinS.mat', 's');
reg = DMC_SL_Regulator(workpoint,fuzzyStaticModel, s, D, N, Nu, lambda, psii, umin, umax, dumax);

u = workpoint.u0.*ones(1, sim_length)-workpoint.u0;
y = workpoint.y0.*ones(1, sim_length)-workpoint.y0;
setPoints = setPoints - y0;

start= 5;
delta=1e-8;
for k = start:sim_length
	k
	output = obj.getOutput()
	y(k) = output;
	
	y_static(k) = fuzzyStaticModel.getOutput(u(k)+u0)-y_static_0;
	
	q = [y(k-1) y(k-2)  u(k-1) u(k-2)];
	w_tmp = w;
	if u(k) ~= 0
		w_tmp(3:end) = w(3:end)*y_static(k)/u(k);
	end
	y_m(k) = (q*w_tmp);
	
% 	%2. Linearyzacja modelu
% 	w_l = zeros(size(w));
% 	for i = 1:4
% 		q_tmp = q;
% 		q_tmp(i) = q(i) + delta;
% 		w_tmp = w;
% 		if u(k) ~= 0
% 			w_tmp(3:end) = w(3:end)*y_static(k)/u(k);
% 		end
% 		w_l(i) = (q_tmp*w_tmp - y_m(k))/delta;
% 	end
	
	%3. Oblicz odp. skokow¹
	startc = 10;

	uc = 0*ones(1, N+startc);
	yc = 0*ones(1, N+startc);
	vtmpv = 1;
	uc(startc:end) = vtmpv;
	for kc = 5:N+startc
		qc = [yc(kc-1) yc(kc-2) uc(kc-1) uc(kc-2)];
		yc(kc) = qc*w;
	end
	sc = (yc(startc+1:end) - yc(startc))/vtmpv;
	sc = sc*y_static(k)/self.Uk;
	plot(sc)

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
	d =  y(k) - y_m(k);
	
	%7. Oblicz trajektorie swobodna
	Y0 = zeros(N, 1);
	
	q = [y(k) y(k-1) u(k-1) u(k-1)];
	Y0(1) = q*w_tmp + d;
	
	q = [Y0(1) y(k) u(k-1) u(k-1)];
	Y0(2) = q*w_tmp + d;
	
	for it = 3:N
		q = [Y0(it-1) Y0(it-2) u(k-1) u(k-1)];
		Y0(it) = q*w_tmp + d;
	end
	plot(Y0)

	%8. Oblicz DELTAU
	Y_zad  = ones(N, 1)*setPoints(k);
	deltaU = K*(Y_zad - Y0);
	
	if (deltaU > dumax)
		deltaU = dumax;
	elseif (deltaU < -dumax)
		deltaU = -dumax;
	end

	%9.Do sterowania pierwszy element
	u(k) = u(k-1) + deltaU(1);

	%10. Ewentualnie przytnij
	if(u(k) > umax)
		u(k) = umax;
	elseif (u(k) < umin)
		u(k) = umin;
	end
	u(k)
	
	obj.setControl(u(k));
    obj.nextIteration();
	y(:, k) = obj.getOutput();
end


figure
	subplot(2, 1, 1)
		hold on;
		stairs(obj.t, setPoints(start:end));
		stairs(obj.t, y(start:end));
		legend("y_{zad}", "y")
		title("Przebieg dla DMC-SL")
		ylabel("Œrednie stê¿enie")
		xlabel("t [h]")
	
	subplot(2, 1, 2)
		stairs(obj.t, u(start:end));
		legend("u")
		title("Sterowanie")
		ylabel("F_I [m^3/h]")
		xlabel("t [h]")

e = (y - setPoints)*(y - setPoints)';