function [e] = fun(x, y)
	Z_Tc = 3.8223e10;
	Z_Td = 3.1457e11;
	Z_I  = 3.7920e18;
	Z_P  = 1.7700e9;
	Z_fm = 1.0067e15;

	E_Tc = 2.9442e3;
	E_Td = 2.9442e3;
	E_I  = 1.2550e5;
	E_P  = 1.8283e4;
	E_fm = 7.4478e4;

	f_p  = 0.58;

	F     = 1.00;
	V     = 0.1;
	C_Iin = 8.0;
	y_sp  = 25000.5;
	F_I   = 0.016783;
	R     = 8.314;
	M_m   = 100.12;
	C_min = 6.0;
	T     = 335;
	
	Z_exp_ERT = @(Z, E)(Z * exp(-E / (R*T)));
	
	P_0 = sqrt((2 * f_p * x(2) * Z_I * exp(-E_I/(R*T))) ...
				/(Z_Td * exp(-E_Td/(R*T)) + Z_Tc * exp(-E_Tc/(R*T))));
			
	e(1) = -(Z_exp_ERT(Z_P, E_P) + Z_exp_ERT(Z_fm, E_fm)) * x(1) * P_0 ...
		- (F * x(1)) / V + (F * C_min) / V;

	e(2) = -(Z_exp_ERT(Z_I, E_I) * x(2)) - (F * x(2)) / V + (x(5) * C_Iin) / V;

	e(3) = (0.5 * Z_exp_ERT(Z_Tc, E_Tc) + Z_exp_ERT(Z_Td, E_Td)) * P_0 * P_0 ...
		+ Z_exp_ERT(Z_fm, E_fm) * x(1) * P_0 - (F * x(3)) / V;

	e(4) = M_m * (Z_exp_ERT(Z_P, E_P) + Z_exp_ERT(Z_fm, E_fm)) * x(1) * P_0 ...
		- (F * x(4)) / V;
	
	e(5) = y - x(4)/x(3);

end

