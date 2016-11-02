function out = tsjiolkovsky(DeltaV, Isp, M0, Me)
%TSJIOLKOVSKY       Determine parameters from Tsjiolkovsky's equation.
%
% value = TSJIOLKOVSKY(DeltaV, Isp, M0, Me) should be issued with one
% of the input parameters empty ([]); the function then calculates the
% value of this missing parameter.
%
% Definition of the parameter names:
%   - DeltaV   [km/s]  possible change in speed
%   - Isp      [s]     specific impulse
%   - M0       [kg]    start mass (wet mass)
%   - Me       [kg]    final mass (dry mass)
%
% TSJIOLKOVSKY is basically an implementation of all possible ways to
% solve Tsjiolkovsky's equation, once the three other parameters are known.
%
% TSJIOLKOVSKY is vectorized in the sense that all non-empty inputs may
% be arrays of any dimension. TSJIOLKOVSKY will compute the corresponding
% values for the requested output, with singleton expansion enabled.
%
% EXAMPLES:
%
%    >> % Basic usage
%    >> DeltaV = tsjiolkovsky([], 300, 1000, 150)
%    DeltaV =
%        5.5813
%
%    >> % With arrays
%    >> Isp = tsjiolkovsky([9.2 3.4], [], [9750 750], [250 50])
%    Isp =
%        256.0729   128.0270
%
%    >> % With singleton expansion
%    >> M0 = tsjiolkovsky([1.2; 2.4], [175 210], [], 50)
%    M0 =
%        100.6105   89.5429
%        202.4496  160.3587
%
% See also bsxfun.


% Author:
% Name       : Rody P.S. Oldenhuis
% E-mail     : oldenhuis@gmail.com
% Affiliation: LuxSpace sàrl


% If you find this work useful, please consider a donation:
% https://www.paypal.me/RodyO/3.5

    % Intialize
    error(nargchk(4,4,nargin,'struct'));
    emptyone = find(cellfun('isempty',{DeltaV,Isp,M0,Me}));
    assert(numel(emptyone)==1,...
          [mfilename ':unsupported_behavior'],...
          'Exactly 1 argument must be empty.');

    % constants
    g0   = 9.80665e-3;  % [km s-2]
    ceff = Isp*g0;      % [km/s]

    % Calculate requested output
    try
        switch emptyone
            case 1 % DeltaV
                out = bsxfun(@times, ceff, log(bsxfun(@rdivide, M0, Me)));
            case 2 % Isp
                out = bsxfun(@rdivide, DeltaV/g0, log(bsxfun(@rdivide,M0,Me)));
            case 3 % M0
                out = bsxfun(@times, Me, exp(bsxfun(@rdivide,DeltaV,ceff)));
            case 4 % Me
                out = bsxfun(@rdivide, M0, exp(bsxfun(@rdivide,DeltaV,ceff)));
        end
    catch ME
        ME2 = MException([mfilename ':output_error'], [...
                         'Could not compute value; most likely due to a ',...
                         'dimension mismatch.');
        throw(addCause(ME2,ME));
    end
end
