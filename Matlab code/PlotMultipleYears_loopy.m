% clear
% clf
%% Loading Data
% load ('C:\Users\kristin.kleisner.NMFS\Desktop\mappingCode\RawData\NEBathymetry.txt');
load ('C:\Users\joseph.caracappa\Documents\GitHub\spatial-animations\NEBathymetry.txt');
lonb=NEBathymetry(:,1); latb=NEBathymetry(:,2);depth=NEBathymetry(:,3);

[CR, STA, STR, VES, YEAR, SEASON, TOW, SHG, GEAR, ESTYR, MON, DAT, TIME, DISTB, DISTW, AVGDPT, AREA, BTEMP,  LAT, LONG]=...
    textread('C:\Users\joseph.caracappa\Documents\Website Visualizations\stationview_x.csv','%f %f %f %s %f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f','delimiter',',','headerlines',1);
%     textread('C:\Users\kristin.kleisner.NMFS\Desktop\mappingCode\Raw_input_SP_FA\Fall2\stationview_x.csv','%f %f %f %s %f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f','delimiter',',','headerlines',1);
      
Hour=floor(TIME/100); 
LATDD=floor(LAT./100)+((LAT./100)-floor(LAT./100))./60.*100; LONDD=(floor(LONG./100)+((LONG./100)-floor(LONG./100))./60.*100).*-1;

% catchviewName = ['C:\Users\kristin.kleisner.NMFS\Desktop\mappingCode\Raw_input_SP_FA\Fall2\catchview_', num2str(SVSPP(ss)),'.csv'];
catchviewName = ['C:\Users\joseph.caracappa\Documents\GitHub\spatial-animations\catchview_', num2str(SVSPP(ss)),'.csv'];
[catCR, catSTR, catTOW, catSTA, catSEA, catSPP, catCOM, catSEX, catWGT, catN]=...
        textread(catchviewName,'%f %f %f %f %s %f %s %f %f %f','delimiter',',', 'headerlines', 1, 'endofline', '\r');

    
    
%lengthviewName = ['C:\Users\kristin.kleisner.NMFS\Desktop\mappingCode\RawData\misc\lengthview_', num2str(SVSPP(ss)),'.csv'];
%[lenCR, lenSTR, lenTOW, lenSTA, lenSPP, lenCOM, lenSEX, lenLEN, lenEN]=...
        %textread(lengthviewName,'%f %f %f %f %f %s %f %f %f','delimiter',',','headerlines',1);



%% Picking Data

Radius=2.5;                                   %%%Change_____________________________
MinLength=0;

k=find(YEAR>=Yr-2 & YEAR<=Yr+2  & strcmp(SEASON,'FALL')==1);
NStations=length(k);
CR=CR(k); STA=STA(k); Hour=Hour(k); STR=STR(k); 
LATDD=LATDD(k); LONDD=LONDD(k);
AVGDPT=AVGDPT(k); YEAR=YEAR(k);

%%Assign catch to Stations
CATCH=zeros(length(CR),1);
for n=1:length(CR)
    k3=find(catCR==CR(n) & catSTR==STR(n) & catSTA==STA(n));
    if ~isempty(k3);
        CATCH(n)=sum(catWGT(k3));
    end
end

   

%% Gridding Bathymetry
LatDepConv=.1  %(.001---> 10 m change is .01 degree distance; .002 --10 m change is .02 degree)

depthgrid=griddata(lonb,latb,depth,xi,yi,'cubic');
[r c]=size(xi);


zi=-1*ones(r,c);
for n=1:r
    n
    for m=1:c
        DepthAtLocation=-depthgrid(n,m);
        YearScalar=abs(Yr-YEAR);
        DepthScalar=LatDepConv*abs(sqrt(AVGDPT)-sqrt(DepthAtLocation));
        Dist =(  (LONDD-xi(n,m)).^2 + (LATDD-yi(n,m)).^2).^0.5;
        AdjDist=Dist+DepthScalar+.2*YearScalar;
        AdjLon=xi(n,m)+(LONDD-xi(n,m)).*((AdjDist./Dist));
        AdjLat=yi(n,m)+(LATDD-yi(n,m)).*((AdjDist./Dist));   
        k=find(Dist==0); AdjLon(k)=xi(n,m)+AdjDist(k)+.02;AdjLon(k)=zi(n,m)+AdjDist(k)+.02;
        k=find(LONDD-xi(n,m)<0); AdjLon(k)=AdjLon(k)-.01;
        k=find(LONDD-xi(n,m)>=0); AdjLon(k)=AdjLon(k)+.01;
        k=find(LATDD-xi(n,m)<0); AdjLat(k)=AdjLat(k)-.01;
        k=find(LATDD-xi(n,m)>=0); AdjLat(k)=AdjLat(k)+.01;
        k=find(AdjDist<Radius);
        coverage=ceil(NStations/100);
        coverage=15;
        if length(k)>=coverage & min(Dist(k))<.5;
            res=gIDW(AdjLon(k),AdjLat(k),(CATCH(k).^.333),xi(n,m),yi(n,m),-1,'n',coverage);
            zi(n,m)= res;
        end    
    end
end



% TrawlStrata=shaperead('C:\Users\kristin.kleisner.NMFS\Desktop\mappingCode\RawData\strata.shp');
% TrawlStrata=shaperead('C:\Users\joseph.caracappa\Documents\Website Visualizations\Shapefiles\strata\strata.shp');
iSampled=-1*ones(r,c);
% for n=1:310
%     n
%     k=find(STR==TrawlStrata(n).STRATA);
%     if length(k)>=1
%         k3=find(inpolygon(xi,yi,TrawlStrata(n).X,TrawlStrata(n).Y));
%         iSampled(k3)=1;
%     end
% end
k=find(iSampled<0);
zi2=zi;
zi2(k)=nan;

%figure
% load('C:\Documents and Settings\drichard\My Documents\RawData\CoastlineMatlab.dat')
% plot(CoastlineMatlab(:,1),CoastlineMatlab(:,2),'k');


k=find(zi2<0.00);
zi2(k)=nan;
% pcolor(xi,yi,(zi2));
% shading interp
% axis equal
% hold on
% 
% 
% 
%  box on
%  xlim([-76 -65])
% ylim([35 45])
% v=[-150 -50]
% contour(xi,yi,depthgrid,v,'Color',[.8 .8 .8])
% 
% [Hist, Idx] = hist(zi2(:), 1000);
% %cumHist = cumsum(Hist)/sum(Hist);
% %Idx_max = find(cumHist > 0.999,1);
% bin_max = Idx(end);
% 
% set(gca,'clim',[0 bin_max])
% 
% 
% states = shaperead('usastatehi', 'UseGeoCoords', true);
% geoshow(states, 'DefaultFaceColor', 'black', ...
%                 'DefaultEdgeColor', 'black');
% hold on
% % CL=shaperead('C:\Users\kristin.kleisner.NMFS\Desktop\mappingCode\RawData\Province.shp')
% CL=shaperead('C:\Users\joseph.caracappa\Documents\Website Visualizations\Shapefiles\PROVINCE\Province.shp')
% mapshow(CL,'FaceColor', 'black', ...
%                 'DefaultEdgeColor', 'black');
%             
% geoshow(states, 'FaceColor', 'black');
% set(gca,'xtick',[-74 -72 -70 -68 -66])
% set(gca,'xTickLabel',{'74 W';'72 W';'70 W';'68 W';'66 W'},'FontSize',10);
% set(gca,'Ytick',[ 36 38 40 42 44])
% set(gca,'YTickLabel',{'36 N';'38 N';'40 N';'42 N';'44 N'},'FontSize',10);
% 
% % set uniform color scheme for all the years based on first year range of
% % values
% if sum(CATCH(:)) > 0
% if ~exist('cmax', 'var')
% cmax = max(zi2(:));
% end
% caxis([0, cmax])
% colorbar;
% hcb=colorbar;
% colorTitleHandle = get(hcb,'Title');
% titleString = 'Numbers/Tow';
% set(colorTitleHandle ,'String',titleString);
% end
