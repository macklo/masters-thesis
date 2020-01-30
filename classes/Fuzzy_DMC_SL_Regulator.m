classdef Fuzzy_DMC_SL_Regulator < AbstractRegulator
	properties
		local_regulator_count, mf, reg, ny, nu,
        y, umin, umax, dumax, last_control
		fuzzyS, D, N, Nu, lambda, psii,
		fuzzyM, Mp, K1
		delta_Up, Ek, Uk
	end
	
	methods
		function self = Fuzzy_DMC_SL_Regulator(mf, fuzzyS, D, N, Nu, lambda, psii,  umin, umax, dumax)
			self.ny = 1;
			self.nu = 1;
            self.mf = mf;
			self.fuzzyS = fuzzyS;
            self.local_regulator_count = length(mf);
            self.y = 0;
			self.dumax = dumax;
			self.umin = umin;
			self.umax = umax;
			self.last_control = 90;
			
			self.D = D;
			self.N = N;
			self.Nu = Nu;
			self.lambda = lambda;
			self.psii = psii;
			
			self.delta_Up = zeros((D-1) * self.nu, 1);
			self.Ek = zeros(N * self.ny,1);
			
			self.Uk = 90;
		end
		
		function [control, weights] = calculate(self, output, setPoint)
            self.y = output;
			
            weights = evalmf(self.mf, self.y);
            mfSum   = sum(weights);
            weights = weights/mfSum;
			
			s = zeros(size(self.fuzzyS{1}));
			for i = 1: self.local_regulator_count
                s = s + weights(i) * self.fuzzyS{i};
			end

			S = s(1:self.D);
			
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
			
			%% calculate difference
			y0 = output + self.Mp * self.delta_Up;

			yzad = ones(self.Nu, 1) * setPoint;
			options = optimoptions(@fmincon,'MaxFunctionEvaluations', 1500, 'Display', 'off');
			duk = fmincon(@(duk)(yzad - y0 - M * duk)' * (yzad - y0 - M * duk) + self.lambda * duk' * duk, ones(self.Nu, 1) * self.delta_Up(1), [], [],[],[], ones(self.Nu,1)*(-45), ones(self.Nu,1)*(45), [], options);
			
			delta_Uk = duk(1);
			
			self.Uk = self.Uk + delta_Uk';
			
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

