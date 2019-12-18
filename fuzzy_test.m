function fuzzy_test(numberOfModels)

addpath("./classes")
addpath("./abstraction")

x0 = [5.50677; 0.132906; 0.0019752; 49.3818];
u0 = 0.016783;

y0 = x0(4)/x0(3);

workpoint = struct('x0', x0, 'u0', u0, 'y0', y0, 't0', 0);
obj = Reactor(workpoint);

sim_length = 2000;
jumpK      = 100;

jumps  = -0.5:0.125:0.5;
uJumps = workpoint.u + jumps * workpoint.u;

y       = cell(size(jumps));
yfuz    = cell(size(jumps));
legends = cell(size(jumps));

ystat    = zeros(size(jumps));
ystatlin = zeros(size(jumps));

tanks       = TankSystem(workpoint);
fuzzyTanks  = FuzzyTankSystem(workpoint1, numberOfModels);

fuzzyTanksOutputs = cell(size(jumps));
fuzzyTanksWeights = cell(size(jumps));
	
for i = 1:size(uJumps, 2)
	uJump = uJumps(i)
	legends{i} = "F_{1in} = " + num2str(uJump);
	
	tanks.resetToWorkPoint(workpoint);
	linTanks.resetToWorkPoint(workpoint);
	fuzzyTanks.resetToWorkPoint(workpoint1);
	
	u = workpoint.u.*ones(1, sim_length);
	u(1, jumpK:end) = uJump;
	
	u1 = workpoint1.u.*ones(1, sim_length);
	u1(1, jumpK:end) = uJump;
	
	y{i}    = workpoint.y.*ones(1, sim_length);
	ylin{i} = workpoint.y.*ones(1, sim_length);
	yfuz{i} = workpoint.y.*ones(1, sim_length);
	
	for k = 1:1:sim_length
		y{i}(k)    = tanks.getOutput();
		ylin{i}(k) = linTanks.getOutput();
		yfuz{i}(k) = fuzzyTanks.getOutput();
		
		fuzzyTanksOutputs{i}(:, k) = fuzzyTanks.getModelOutputs();
		fuzzyTanksWeights{i}(:, k) = fuzzyTanks.getWeights();
		
		tanks.setControl(u(k));
		linTanks.setControl(u(k));
		fuzzyTanks.setControl(u(k));
		
		tanks.nextIteration();
		linTanks.nextIteration();
		fuzzyTanks.nextIteration();
	end
	tanks.x(end, :)
	ystat(i)    = y{i}(end);
	ystatlin(i) = yfuz{i}(end);
end


figure
	grid on
	hold on
	for i = 1:size(uJumps, 2)
		plot(y{i}, 'b')
	end
	
	set(gca, 'ColorOrderIndex', 1)
	
	for i = 1:size(uJumps, 2)
		plot(yfuz{i}, 'g')
	end
	
	for i = 1:size(uJumps, 2)
		plot(ylin{i}, 'm')
	end
	xlabel("t [s]")
	ylabel("h_2 [cm]")

end