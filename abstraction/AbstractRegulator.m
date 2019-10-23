classdef (Abstract) AbstractRegulator < handle
	properties
	end
	
	methods (Abstract)
		[control] = calculate(self, output, setPoint);
	end
end

