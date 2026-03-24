function parameter = paramInit(method)
	% paramInit - Initialize parameters for a given method
	%
	% -------------------------------------------------------------------------
	% Input:
	%	method - string, specifying the method name (e.g., 'HALT')
	%
	% Output:
	%	parameter - matrix, each row is a combination of parameters
	%
	% -------------------------------------------------------------------------
	% Author : Xi Guo
	% Email  : xiguo@my.swjtu.edu.cn
	% Date   : 2025-10-27
	% -------------------------------------------------------------------------

	switch (method)
		case {'My'}
            alphaSpace = [1e-6, 1e-5, 1e-4, 1e-3, 0.01, 0.1, 1];
            betaSpace = [1e-6, 1e-5, 1e-4, 1e-3, 0.01, 0.1 1];
            tSpace = 1;
            paramSpace = {alphaSpace,betaSpace,tSpace};
            parameter = combvec(paramSpace{:})';
            parameter = sortrows(parameter, 'descend');
            % parameter = [0.01	0.01	1];
		case {'My2'}
            alphaSpace = [1e-4, 1e-3, 0.01, 0.1, 1];
            betaSpace = [1e-4, 1e-3, 0.01, 0.1 1];
            lambdaSpace = [1e-4, 1e-3, 0.01, 0.1 1];
            tSpace = 1:1:10;
            paramSpace = {alphaSpace,betaSpace,lambdaSpace,tSpace};
            parameter = combvec(paramSpace{:})';
            parameter = sortrows(parameter, 'descend');
		otherwise
			error('paramInit:UnknownMethod', 'Unknown method: %s', method);
	end
end
