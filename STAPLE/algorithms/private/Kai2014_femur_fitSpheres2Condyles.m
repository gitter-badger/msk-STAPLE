% used by KaiFemur
% slice starts with just one curve, until it slices two condyles
% when there are two curves, the next time there is one is the end of
% loop
function CS = Kai2014_femur_fitSpheres2Condyles(DistFem, CS, debug_plots)

% main plots are in the main method function. 
% these debug plots are to see the details of the method
if nargin<3
    debug_plots=0;
end

X0 = CS.X0;
Z0 = CS.Z0;

area_limit = 4;%mm^2
sections_limit = 15;
% X0 points backwards in GIBOK

% most posterior point
[~ , I_Post_FC] = max( DistFem.Points*-X0 );
MostPostPoint = DistFem.Points(I_Post_FC,:);

FC_Med_Pts = [];
FC_Lat_Pts = [];
d = MostPostPoint*-X0 - 0.25;
count = 1;

% debug plot
if debug_plots == 1
    quickPlotTriang(DistFem, [], 1);
    plotDot(MostPostPoint,'g', 5.0);
end

keep_slicing = 1;

while keep_slicing

    [ Curves , ~, ~ ] = TriPlanIntersect(DistFem, X0 , d );
    Nbr_of_curves = length(Curves);
    
    % counting slices
    disp(['section #',num2str(count),': ', num2str(Nbr_of_curves),' curves.'])
    count = count+1;
    
    % check if the curves touch the bounding box of DistFem
    for cn = 1:Nbr_of_curves
        if abs(max(Curves(cn).Pts * Z0)-max(DistFem.Points * Z0)) < 8 %mm
            disp('The plane sections are as high as the distal femur.')
            disp('The condyle slicing is happening in the incorrect direction of the anterior-posterior axis.')
            disp('Inverting axis.')
            CS.X0 = -CS.X0;
            [CS, FC_Med_Pts, FC_Lat_Pts] = sliceFemoralCondyles(DistFem, CS);
            break
        end
    end
    
    % stop if just one curve is found after there has been a second profile
    if Nbr_of_curves == 1 && ~isempty(FC_Lat_Pts)        
        break
    else
        % next slicing plane moved by 1 mm
        d = d - 1;
    end
    
    % if there are too many curves maybe you are slicing from the
    % front (happened) -> invert and restart
    if Nbr_of_curves > 2
        disp('The quality of the mesh is low ( > 3 section areas detected).');
        disp('Skipping section')
        continue
    end    
    
    % otherwise store slices
    if Nbr_of_curves == 1
        % always for 1 curves
        FC_Med_Pts = [FC_Med_Pts; Curves.Pts];
        
    elseif Nbr_of_curves == 2
        % first check the size of the areas. If too small it might be
        % spurious
        if size(Curves(2).Pts,1)<sections_limit
            disp('Slice recognized as artefact (few points). Skipping it.')
            continue
        end
        % section leading to very small areas are also removed.
        % this condition is rarely reached
        [ ~, Area_sec2 ] = PlanPolygonCentroid3D( Curves(2).Pts );
        if abs(Area_sec2)<area_limit
            disp('Slice recognized as artefact (small area). Skipping it.')
            continue
        end
        % needs to identify which is the section near starting point
        % using distance from centroid for that
        Centroid = [];
        Dist2MostPostPoint = [];
        for cn = 1:Nbr_of_curves
            Centroid(cn,:) = mean(Curves(cn).Pts);
            Dist2MostPostPoint(cn) = norm(MostPostPoint-Centroid(cn,:));
        end
        % closest curve to Dist2MostPostPoint is the one that started as
        % single curve
        [~,IcurvePost1] = min(Dist2MostPostPoint);
        % store data accordingly
        FC_Med_Pts = [FC_Med_Pts; Curves(IcurvePost1).Pts];
        FC_Lat_Pts = [FC_Lat_Pts; Curves(3-IcurvePost1).Pts];
    end
    
        % plot curves after break condition!
        if debug_plots == 1
            c_set = ['r', 'b','k'];
            if ~isempty(Curves)
                for c = 1:Nbr_of_curves
                    if c>3; col = 'k'; else;  col = c_set(c);  end
                    plot3(Curves(c).Pts(:,1), Curves(c).Pts(:,2), Curves(c).Pts(:,3), col); hold on; axis equal
                end
            end
        end
    
end

% fitting spheres to points from the sliced curves
[center_med,radius_med] = sphereFit(FC_Med_Pts);
[center_lat,radius_lat] = sphereFit(FC_Lat_Pts);

% centre of the knee if the midpoint between spheres
KneeCenter = 0.5*(center_med+center_lat);

% store axes in structure
CS.Center_Lat = center_lat;
CS.Radius_Lat = radius_lat;
CS.Center_Med = center_med;
CS.Radius_Med = radius_med;
CS.KneeCenter = KneeCenter;

% plot spheres
if debug_plots == 1
    plotSphere(center_med, radius_med, 'r', 0.4);
    plotSphere(center_lat, radius_lat, 'b', 0.4);
end

end