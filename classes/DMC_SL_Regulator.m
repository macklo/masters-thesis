classdef DMC_SL_Regulator < AbstractRegulator
	properties
		local_regulator_count, mf, reg, ny, nu,
        y, umin, umax, dumax, last_control
		fuzzyS, D, N, Nu, lambda, psii,
		fuzzyStaticModel, Mp, K1, s
		delta_Up, Ek, Uk, workpoint
	end
	
	methods
		function self = DMC_SL_Regulator(workpoint, fuzzyStaticModel, s, D, N, Nu, lambda, psii,  umin, umax, dumax)
			self.ny = 1;
			self.nu = 1;
			self.fuzzyStaticModel = fuzzyStaticModel;
			self.workpoint = workpoint;
            self.y = 0;
			self.dumax = dumax;
			self.umin = umin;
			self.umax = umax;
			self.last_control = 0;
			self.s = s;
			
			self.D = D;
			self.N = N;
			self.Nu = Nu;
			self.lambda = lambda;
			self.psii = psii;
			
			self.delta_Up = zeros((D-1) * self.nu, 1);
			self.Ek = zeros(N * self.ny,1);
			
			self.Uk = 0;
		end
		
		function [control] = calculate(self, output, setPoint)
            self.y = output;
			
            y_s = self.fuzzyStaticModel.getOutput(self.Uk + self.workpoint.u0) - self.workpoint.y_static0;
			s = self.s;
			if self.Uk ~= 0
				s = self.s*y_s/self.Uk;
			end
			M = zeros(self.N, self.Nu);
			for i = 1 : self.N
				for j = 1 : self.Nu
					if (i >= j)
						M(i,j) = s(i-j+1);
					else
						M(i,j) = 0;
					end
				end
			end
			
			self.Mp = zeros(self.N, self.D - 1);
			for i = 1:self.N
				for j = 1 : self.D - 1
					self.Mp(i, j) = s(i+j) - s(j);    
				end
			end
			K = ((M'*M + eye(size(M'*M))*self.lambda)^-1)*M';
			K = mat2cell(K, self.nu*ones(1, self.Nu));
			self.K1 = K{1};
			
			%% calculate difference
% 			y0 = output + self.Mp * self.delta_Up;
% 
% 			yzad = ones(self.Nu, 1) * setPoint;
% 			options = optimoptions(@fmincon,'MaxFunctionEvaluations', 1500, 'Display', 'off');
% 			duk = fmincon(@(duk)(yzad - y0 - M * duk)' * (yzad - y0 - M * duk) + self.lambda * duk' * duk, ones(self.Nu, 1) * self.delta_Up(1), [], [],[],[], ones(self.Nu,1)*self.umin, ones(self.Nu,1)*self.umax, [], options);
			ek = (setPoint - output)';
			
			%% extend diff to (N*ny, 1)
			self.Ek = zeros(self.N * self.ny,1);
			for i = 1 : self.ny : self.N * self.ny
				self.Ek(i : i+self.ny-1) = ek;
			end
			delta_Uk = self.K1 * (self.Ek - self.Mp * self.delta_Up);
			
			for i = 1:self.nu
				if (delta_Uk(i) > self.dumax(i))
					delta_Uk(i) = self.dumax(i);
				elseif (delta_Uk(i) < -self.dumax(i))
					delta_Uk(i) = -self.dumax(i);
				end
			end

			self.Uk = self.Uk + delta_Uk';
			
			for i = 1:self.nu
				if (self.Uk(i) > self.umax(i))
					self.Uk(i) = self.umax(i);
				elseif (self.Uk(i) < self.umin(i))
					self.Uk(i) = self.umin(i);
				end
			end
			
			self.delta_Up = circshift(self.delta_Up, self.nu);
			self.delta_Up(1:self.nu) = delta_Uk;
			
			%% return control
			control = self.Uk;
		end
	end
	
		methods (Static)
		function Si = DMC_get_Si(S, i)
			size = length(S);
			if i <= size
				Si = S(i);
			else
				Si = S(size);
			end
		end
	end
end

