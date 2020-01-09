function [or, alt_TlNvc_start, alt_TlNeck_start] = FitCSATalus(Alt, Area)
%CREATEFIT(ALT,AREA)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : Alt
%      Y Output: Area
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 16-Dec-2019 09:38:00


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( Alt, Area );

% Set up fittype and options.
ft = fittype( 'gauss2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0 -Inf -Inf 0];
% opts.StartPoint = [max(Area) mean(Alt) 5 max(Area)/2 mean(Alt) 10];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'Area vs. Alt', 'untitled fit 1', 'Location', 'NorthEast' );
% Label axes
xlabel Alt
ylabel Area
grid on

% Orientation of bone along the y axis (Not Sure to be checked)
or_test_a = fitresult.a1 < fitresult.a2 ;
or_test_b = fitresult.b1 < fitresult.b2 ;
if or_test_a
    if or_test_b
        or = -1;
        alt_TlNvc_start = fitresult.b1;
    else
        or = 1;
        alt_TlNvc_start = fitresult.b1;
    end
else
    if or_test_b
        or = 1;
        alt_TlNvc_start = fitresult.b2;
    else
        or = -1;
        alt_TlNvc_start = fitresult.b2;
    end
end

% Values along the length of the Talus
alt_TlNvc_start = or*alt_TlNvc_start;
alt_TlNeck_start = 0.5*or*(fitresult.b1 + fitresult.b2);


