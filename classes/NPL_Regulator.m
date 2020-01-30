classdef NPL_Regulator < AbstractRegulator
	properties
		N, Mp, K1, delta_Up, Nu
		Ek, Uk, ny, nu, umin, umax, dumax
		object, nws, nwu, nwy, lambda
		u, y, y_static, workpoint
	end
	
	methods
		function self = NPL_Regulator(object, workpoint, N, Nu, lambda, umin, umax, dumax)
			self.nwy = 4;
			self.nwu = 4;
			self.nws = 3;
			
			self.object = object;
			
			self.N = N;
			self.Nu = Nu;
			
			self.ny = 1;
			self.nu = 1;
			self.dumax = dumax;
			self.umin = umin;
			self.umax = umax;
			self.lambda = lambda;
			self.workpoint = workpoint;
			
			self.y = ones(1, 5) * workpoint.y0;
			
			self.u = ones(1, 5) * workpoint.u0;
			
			self.y_static = ones(1, 5) * object.fuzzyStaticModel.getOutput(workpoint.u0);
		end
		
		function control = calculate(self, output, setPoint)
			q = [self.y_static(end) self.y_static(end-1) self.y_static(end-2) ...
				self.u(end) self.u(end-1) self.u(end-2) self.u(end-3)  ...
				self.y(end) self.y(end-1) self.y(end-2) self.y(end-3)];
			
			w_l = zeros(size(self.object.w));
			y_m = self.object.getOutput(q);
			%2. Linearyzacja modelu
			delta=1e-8;
			for i = 1:11
				q_tmp = q;
				q_tmp(i) = q_tmp(i) + delta;
				w_l(i) = (self.object.getOutput(q_tmp) - y_m)/delta;
			end

% 			y_mlin(k) = q*w_l;

			%3. Oblicz odp. skokow¹
			sc=self.getS(w_l);
% 			plot(sc)

			%4. Oblicz macierz dynamiczna
			M = zeros(self.N, self.Nu);
			for i = 1:self.N
				for j = 1:self.Nu
					if (i >= j)
						M(i,j) = sc(i-j+1);
					else
						M(i,j) = 0;
					end
				end
			end

			%5. Oblicz K
			K = ((M'*M + self.lambda*eye(self.Nu, self.Nu))^(-1))*M';

			%6. Oblicz d
			d = output - y_m;

			%7. Oblicz trajektorie swobodna
			Y0 = zeros(self.N, 1);
			q = [self.y_static(end) self.y_static(end) self.y_static(end-1) ...
				self.u(end) self.u(end) self.u(end-1) self.u(end-2)  ...
				output self.y(end) self.y(end-1) self.y(end-2)];
			Y0(1) = self.object.getOutput(q) + d;
			
			q = [self.y_static(end) self.y_static(end) self.y_static(end) ...
				self.u(end) self.u(end) self.u(end) self.u(end-1)  ...
				Y0(1) output self.y(end) self.y(end-1)];
			Y0(2) = self.object.getOutput(q) + d;
			
			q = [self.y_static(end) self.y_static(end) self.y_static(end) ...
				self.u(end) self.u(end) self.u(end) self.u(end)  ...
				Y0(2) Y0(1) output self.y(end)];
			Y0(3) = self.object.getOutput(q) + d;
			
			q = [self.y_static(end) self.y_static(end) self.y_static(end) ...
				self.u(end) self.u(end) self.u(end) self.u(end)  ...
				Y0(3) Y0(2) Y0(1) output];
			Y0(4) = self.object.getOutput(q) + d;
			
			for i =5:self.N
				q = [self.y_static(end) self.y_static(end) self.y_static(end) ...
					self.u(end) self.u(end) self.u(end) self.u(end)  ...
					Y0(i-1) Y0(i-2) Y0(i-3) Y0(i-4)];
				Y0(i) = self.object.getOutput(q) + d;
			end
			
			%8. Oblicz DELTAU
			Y_zad  = ones(self.N, 1)*setPoint;
			deltaU = K*(Y_zad - Y0);
			
			if(deltaU > self.dumax)
				deltaU = self.dumax;
			elseif (deltaU < -self.dumax)
				deltaU = self.dumax;
			end

			%9.Do sterowania pierwszy element
			self.u(end+1) = self.u(end) + deltaU(1);

			%10. Ewentualnie przytnij
			if(self.u(end) > self.umax)
				self.u(end) = self.umin;
			elseif (self.u(end) < self.umin)
				self.u(end) = self.umin;
			end
			control = self.u(end);
			
			self.y_static = [self.y_static, self.object.fuzzyStaticModel.getOutput(control)];
			self.y = [self.y output];
		end
		
		function s = getS(self, w)
			
			sim_length = 6+self.Nu;
			y_m = ones(1, sim_length) * self.y(end);
			y_nl = ones(1, sim_length) * self.y(end);
			
			u = ones(1, sim_length) * self.u(end);
			
			y_static = ones(1, sim_length) * self.object.fuzzyStaticModel.getOutput(self.u(end));
			
			start = 5;
			u(start:sim_length) = self.workpoint.u0 + 0.001;
			y_static(sim_length) = self.object.fuzzyStaticModel.getOutput(self.u(end) + 0.001);
			for k = start:sim_length
% 				q = [y_static(k-1) y_static(k-2) y_static(k-3) ...
% 				u(k-1) u(k-2) u(k-3) u(k-4)  ...
% 				y_m(k-1) y_m(k-2) y_m(k-3) y_m(k-4)];
				q = [y_static(k-1) y_static(k-2) y_static(k-3) y_m(k-1) y_m(k-2) y_m(k-3) y_m(k-4)];
				
				y_m(k) = q*w;
% 				y_nl(k) = self.object.getOutput(q);
				y_static(k) = y_static(sim_length);
			end
			s = (y_m(start:end) - y_m(start-1))/0.001;
			plot(s)
		end
	end
	
end

