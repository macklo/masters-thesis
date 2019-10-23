classdef DMC_Regulator < AbstractRegulator
	properties
		N, Mp, K1, delta_Up,
		Ek, Uk, ny, nu, umin, umax, dumax
	end
	
	methods
		function self = DMC_Regulator(object, workpoint, s, D, N, Nu, lambda, psii, umin, umax, dumax)
			ny = object.ny;
			nu = object.nu;
			
			S = self.build_S(ny, nu, s, D);
			M = self.build_M(ny, nu, N, Nu, S);
			Lambda = self.build_Lambda(nu, Nu, lambda);
			Psi = self.build_Psi(ny, N, psii);
			self.Mp = self.build_Mp(D, N, S);
			self.K1 = self.build_K1(nu, M, Psi, Lambda, Nu);
			self.delta_Up = zeros((D-1) * nu, 1);
			self.Ek = zeros(N * ny,1);
			
			self.Uk = workpoint.u';
			self.N = N;
			
			self.ny = ny;
			self.nu = nu;
			self.dumax = dumax;
			self.umin = umin;
			self.umax = umax;
		end
		
		function control = calculate(self, output, setPoint)
			%% calculate difference
			ek = (setPoint - output)';
			
			%% extend diff to (N*ny, 1)
			self.Ek = zeros(self.N * self.ny,1);
			for i = 1 : self.ny : self.N * self.ny
				self.Ek(i : i+self.ny-1) = ek;
			end
			
			%% calculate next control
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
		function S = build_S(ny, nu, s, D)
			S = cell(D, 1);
			for l = 1 : D
				Sl = zeros(ny, nu);
				for i = 1 : ny
					for j = 1 : nu
						Sl{i, j} = s{i, j}(l);               
					end
				end
				S{l} = Sl;
			end
		end
		
		function M = build_M(ny, nu, N, Nu, S)
			M = cell(N, Nu);
			for i = 1 : N
				for j = 1 : Nu
					if (i >= j)
						M{i,j} = DMC_Regulator.DMC_get_Si(S, i-j+1);
					else
						M{i,j} = zeros(ny, nu);
					end
				end
			end
			M = cell2mat(M);
		end
		
		function Si = DMC_get_Si(S, i)
			size = length(S);
			if i <= size
				Si = S{i};
			else
				Si = S{size};
			end
		end
		
		function Mp = build_Mp(D, N, S)
			Mp = cell(N, D);
			for i = 1:N
				for j = 1 : D - 1
					Mp{i, j} = DMC_Regulator.DMC_get_Si(S, i+j) - ...
						DMC_Regulator.DMC_get_Si(S, j);    
				end
			end 
			Mp = cell2mat(Mp);
		end

		function penalty_factor = build_penalty_factor(n, N, val)
			if length(val) == n
				diagonal = diag(val);
			else
				diagonal = val .* eye(n);
			end
			
			penalty_factor = cell(N, N);
			for i = 1: N
				for j = 1: N
					if i == j
						penalty_factor{i, j} = diagonal;
					else
						penalty_factor{i, j} = zeros(n, n);
					end
				end
			end
			penalty_factor = cell2mat(penalty_factor);
		end
		
		function Lambda = build_Lambda(nu, Nu, lambda)
			Lambda = DMC_Regulator.build_penalty_factor(nu, Nu, lambda);
		end

		function Psi = build_Psi(ny, N, psii)
			Psi = DMC_Regulator.build_penalty_factor(ny, N, psii);
		end

		function K1 = build_K1(nu, M, Psi, Lambda, Nu)
			K = ((M'*Psi*M + Lambda)^-1)*M'*Psi;
			K = mat2cell(K, nu*ones(1, Nu));
			K1 = K{1};
		end
	end
	
end

