classdef PID_Regulator < AbstractRegulator
	properties
		r1,r2,r3,
		ek1,ek2,last_u, 
        reg_count,
		isUnregular, config
	end
	
	methods
		function self = PID_Regulator(object, parameters, config)
			assert(object.ny <= object.nu);
			ny = object.ny; nu = object.nu;

			self.isUnregular = (ny ~= nu);
			if(self.isUnregular)
				assert(length(config) == ny);
				self.config = config;
			end
			
			self.reg_count = ny;
			self.initParams(parameters, object.Ts);

			self.ek1 = zeros(1, self.reg_count); % e(k-1)
			self.ek2 = zeros(1, self.reg_count); % e(k-2)
			self.last_u = zeros(1, self.reg_count);
		end
		
		function initParams(self, parameters, Ts)
			self.r1 = zeros(self.reg_count); 
			self.r2 = zeros(self.reg_count); 
			self.r3 = zeros(self.reg_count);
			for i = 1 : self.reg_count
				Kp = parameters{i}.Kp; 
				Ti = parameters{i}.Ti;
				Td = parameters{i}.Td;
				
				self.r1(i,i) = Kp*(1 + Ts/(2*Ti) + Td/Ts);
				self.r2(i,i) = Kp*(Ts/(2*Ti) - 2*Td/Ts -1);
				self.r3(i,i) = Kp*Td/Ts;
			end
		end
		
		function [control] = calculate(self, output, setPoint, workpoint)
			%% calc difference
			ek = (setPoint - output)';
			
			%% calc next control
			uk = self.last_u + ...
				ek * self.r1 + ... % e(k) * r1
				self.ek1 * self.r2 + ... % e(k-1) * r2
				self.ek2 * self.r3; % e(k-2) * r3
        
			%% include constraints
			% no constraints
			
			%% update local vars
			self.last_u = uk;
			self.ek2 = self.ek1;
			self.ek1 = ek;
			
			%% return calculated control
			if(self.isUnregular)
				%% Apply it to outputs specified by config
				control = workpoint;
				for i = 1:self.reg_count
					control(self.config(i)) = uk(i);
				end
			else
				control = uk';
			end
		end
	end
end

