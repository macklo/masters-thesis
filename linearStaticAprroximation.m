clc 
close all
clear

x0 = [5.50677; 0.132906; 0.0019752; 49.3818];
u0 = 0.016783;

y0 = x0(4)/x0(3);

load("./data/staticValues.mat")

maxIndex = size(uValues, 1);
first = 1;
last = 200;

u = [uValues(first:last) ones(size(uValues(first:last)))];
y = staticVals(first:last);

p = u\y;

ym = polyval(p, uValues(first:last));

ep = ym(1) - staticVals(1);
el = ym(last) - staticVals(last);
figure
	hold on
	plot(uValues(first:last), ym)
	plot(uValues, staticVals);

startIndex = 1;
endIndex   = 2;

eps = 200000;
indexes = [];
params = [];
while true
	while true 
		u = [uValues(startIndex:endIndex) ones(size(uValues(startIndex:endIndex)))];
		y = staticVals(startIndex:endIndex);
		p = u\y;
		ym = polyval(p, uValues(startIndex:endIndex));
		ep = (ym(1) - y(1))^2;
		el = (ym(end) - y(end))^2;
		e  = (ym-y)'*(ym-y) / (endIndex - startIndex);
		if e > eps || endIndex == maxIndex
			if endIndex == maxIndex - 1
				endIndex = maxIndex;
			end
			indexes = [indexes; startIndex, endIndex];
			params = [params; p'];
			break;
		end
		endIndex = endIndex + 1;
	end
	startIndex = endIndex;
	endIndex = startIndex+1;
	if endIndex > maxIndex
		break
	end
end
figure
	hold on
	for i = 1:size(indexes, 1)
		ym = polyval(params(i, :), uValues(indexes(i, 1):indexes(i, 2)));
		plot(uValues(indexes(i, 1):indexes(i, 2)), ym)
	end
	plot(uValues, staticVals);
	title("Modele liniowe na tle charakterystyki statycznej")
	xlabel("u")
	ylabel("y")


a = 3000;
mf = createMembershipFunctionFromCuts(uValues(indexes(2:end,1)), uValues(1), uValues(end), 3000);

ym =[];

for u = uValues'
	mu = evalmf(mf, u);
	yc = 0;
	for i = 1:size(mu, 1)
		yc = yc + mu(i)*polyval(params(i, :), u);
	end
	ym = [ym; yc];
end

err = (ym - staticVals)' * (ym - staticVals) / maxIndex;
figure
	hold on
	plot(uValues, staticVals);
	plot(uValues, ym);
	legend("Zmierzone wartoœci", "Wartoœci z modelu")
	xlabel ("u");
	ylabel("y")
	

save("./data/fuzzyStaticModel.mat", "mf", "params");
