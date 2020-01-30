function [mf, linPoints] = createMembershipFunctionFromCuts(cuts, ymin, ymax, a)
	numberOfModels = length(cuts) + 1;
	mf = fismf.empty(numberOfModels, 0);

	mf(1, 1) = fismf("sigmf",[-a cuts(1)]);
	mf(numberOfModels, 1) = fismf("sigmf",[a cuts(numberOfModels - 1)]);
	for i = 2:numberOfModels-1
		mf(i, 1) = fismf("dsigmf", [a cuts(i-1) a cuts(i)]);
	end
	
	linPoints = zeros(numberOfModels, 1);
	linPoints(1) = ymin + (cuts(1)-ymin)/2;
	linPoints(numberOfModels) = ymax - (ymax - cuts(end))/2;
	for i = 2:numberOfModels-1
		linPoints(i) = cuts(i-1) + (cuts(i) - cuts(i-1))/2;
	end
	
	
	y = evalmf(mf, ymin:0.00001:ymax);

	figure
		hold on
		for i = 1:numberOfModels
			plot(ymin:0.00001:ymax, y(i, :))
		end
		xlabel("u")
		ylabel("\mu")
		title("Funkcje przynale¿noœci")
end

