classdef Numeric_DMC_Regulator < AbstractRegulator
	properties
		N, Mp, K1, delta_Up, H, Psi, M, A
		Ek, Uk, ny, nu, Umin, Umax, dUmax, Nu
	end
	
	methods
		function self = Numeric_DMC_Regulator(object, workpoint, s, D, N, Nu, lambda, psii, umin, umax, dumax)
			ny = object.ny;
			nu = object.nu;
			umin = [0; 0];
			umax = [4; 30];
			dumax = [0.5; 1];
			
			S = self.build_S(ny, nu, s, D);
			M = self.build_M(ny, nu, N, Nu, S);
			Lambda = self.build_Lambda(nu, Nu, lambda);
			Psi = self.build_Psi(ny, N, psii);
			
			self.H = self.build_H(M, Psi, Lambda);
			self.A = self.build_A(M, nu, Nu);
			
			self.dUmax = self.build_dUmax(dumax, Nu);
			
			self.Umin = self.build_Umin(umin, Nu);
			self.Umax = self.build_Umax(umax, Nu);
			
			self.M = M;
			self.Psi = Psi;
			
			self.Mp = self.build_Mp(D, N, S);
			self.K1 = self.build_K1(nu, M, Psi, Lambda, Nu);
			self.delta_Up = zeros((D-1) * nu, 1);
			self.Ek = zeros(N * ny,1);
			
			self.Uk = workpoint.u';
			self.N = N;
			self.Nu = Nu;
			
			self.ny = ny;
			self.nu = nu;
		end
		
		function control = calculate(self, output, setPoint)
			%% calculate difference
			ek = (setPoint - output)';
			
			%% extend diff to (N*ny, 1)
			self.Ek = zeros(self.N * self.ny,1);
			for i = 1 : self.ny : self.N * self.ny
				self.Ek(i : i+self.ny-1) = ek;
			end
			
			b = self.build_b(self.Umin, self.Umax, self.Uk, self.Nu);
			f = self.build_f(self.M, self.Psi, setPoint, output, self.Mp, self.delta_Up, self.N);
			options = optimset('Display', 'off');
			x = quadprog(self.H, f, self.A, b, [], [], -self.dUmax, self.dUmax, [], options);
			%% calculate next control
			delta_Uk = x(1:2);
			self.delta_Up = circshift(self.delta_Up, self.nu);
			self.delta_Up(1:self.nu) = delta_Uk;
			
			self.Uk = self.Uk + delta_Uk';
			
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
						Sl(i, j) = s{i, j}(l);               
					end;
				end;
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
				end;
			end;
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
		
		function H = build_H(M, Psi, Lambda)
			H = 2*(M'*Psi*M + Lambda);
		end
		
		function A = build_A(M, nu, Nu)
			I = eye(nu, nu);
			z = zeros(nu, nu);
			J = cell(Nu, Nu);
			for i = 1:Nu
				for j = 1:Nu
					if i >= j
						J{i, j} = I;
					else
						J{i, j} = z;
					end
				end
			end
			J = cell2mat(J);
			A = [-J; J];
		end
		
		function Umin = build_Umin(umin, Nu)
			nu = size(umin, 1);
			Umin = zeros(nu*Nu, 1);
			for i = 1:Nu
				Umin(nu*(i-1)+1:i*nu, 1) = umin;
			end
		end
		
		function Umax = build_Umax(umax, Nu)
			nu = size(umax, 1);
			Umax = zeros(nu*Nu, 1);
			for i = 1:Nu
				Umax(nu*(i-1)+1:i*nu, 1) = umax;
			end
		end
		
		function dUmax = build_dUmax(dumax, Nu)
			nu = size(dumax, 1);
			dUmax = zeros(Nu * nu, 1);
			for i = 1:Nu
				dUmax(nu*(i-1)+1:i*nu, 1) = dumax;
			end
		end
		
		function b = build_b(Umin, Umax, Uk, Nu)
			nu = size(Uk, 2);
			UK = zeros(Nu * nu, 1);
			for i = 1:Nu
				UK(nu*(i-1)+1:i*nu, 1) = Uk';
			end
			b = [-Umin + UK; Umax - UK];
		end
		
		function f = build_f(M, Psi, setPoint, output, Mp, delta_Up, N)
			ny = size(output, 1);
			Yk = zeros(N * ny, 1);
			Yzad = zeros(N * ny, 1);
			for i = 1:N
				Yk(ny*(i-1)+1:i*ny, 1) = output;
				Yzad(ny*(i-1)+1:i*ny, 1) = setPoint;
			end
			Y0 = Yk + Mp * delta_Up;
			f = -2*M'*Psi*(Yzad - Y0);
		end
			
	end
	
end

