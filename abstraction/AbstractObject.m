classdef (Abstract) AbstractObject < handle
	properties
		ny,nu,Ts
	end
	
	methods
		function self = AbstractObject(ny, nu, Ts)
			self.ny = ny;
			self.nu = nu;
			self.Ts = Ts;
		end
	end
	
	methods (Abstract)
		[output] = getOutput(self);
		setControl(self, control);
		nextIteration(self);
	end
end

