function workpoint = calculateWorkpoint(y)
	myfun = @(x)fun(x, y);
	options = optimoptions('fsolve', 'FunctionTolerance', 1e-9, 'MaxIterations', 1000, 'MaxFunctionEvaluations', 2000);
	output = fsolve(myfun, [5.50677, 0.132906, 0.0019752, 49.3818, 0.016783]);
	
	workpoint = struct('x0', output(1:4), 'u0', output(5), 'y0', y, 't0', 0);
end