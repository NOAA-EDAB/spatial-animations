clear

% [SVSPP, COMNAME, Species]=textread('C:\Users\kristin.kleisner.NMFS\Desktop\mappingCode\Raw_input_SP_FA\Fall_Thorny\SurvDatSpec_Fall.csv',...
%     '%d %s %s' , 'delimiter', ',');

[SVSPP, COMNAME, Species]=textread('C:\Users\joseph.caracappa\Documents\GitHub\spatial-animations\SurvDatSpec_Fall.csv',...
    '%d %s %s' , 'delimiter', ',');

SpeciesNum = length(SVSPP);

%Specify grid
MaxLat=45;     MinLat=35;                                   %%%Change_____________________________
MaxLon=-65;  MinLon=-76;                                  %%%Change_____________________________
Interval=.02; 
[xi yi]=meshgrid(MinLon:Interval:MaxLon,MinLat:Interval:MaxLat);
year_start = 1968;
year_stop = 2014;
yearnames = year_start:year_stop;
nyears = length(yearnames);
% for ss = 1:SpeciesNum
ss = 1
    clear cmax;
    %set output directory
        outdir = 'C:\Users\joseph.caracappa\Documents\GitHub\spatial-animations\Output_Data\Sample_Output\';
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end
    %create array for gridded data to go into (need to work on this later)
    filename_out = [outdir,Species{ss}, '-Fall.nc'];
%     nccreate(filename.out,'lat',...
%         'Dimensions', {'r', size(xi,1), 'c', size(xi,2), 't', size(year.start:year.stop,2)},...
%         'Format','netcdf4_classic');
%     nccreate(filename.out,'',...
%         'Dimensions', {'r', size(xi,1), 'c', size(xi,2), 't', size(year.start:year.stop,2)},...
%         'Format','netcdf4_classic');
%     nccreate(filename.out,'abundance_1',...
%         'Dimensions', {'r', size(xi,1), 'c', size(xi,2), 't', size(year.start:year.stop,2)},...
%         'Format','netcdf4_classic');
%     nccreate(filename.out,'abundance_2',...
%         'Dimensions', {'r', size(xi,1), 'c', size(xi,2), 't', size(year.start:year.stop,2)},...
%         'Format','netcdf4_classic');
%     netcdf.close(filename.out);

    %pre-allocate variable space
    lat_array = zeros(size(xi,1),size(xi,2),size(year_start:year_stop,2));
    lon_array = zeros(size(xi,1),size(xi,2),size(year_start:year_stop,2));
    abundance_1 = zeros(size(xi,1),size(xi,2),size(year_start:year_stop,2));
    abundance_2 = zeros(size(xi,1),size(xi,2),size(year_start:year_stop,2));

    for y=1:nyears
        
        Yr=yearnames(y);
        str=int2str(yearnames(y));
        strc={Species{ss}, '-Fall', str}
        PlotMultipleYears_loopy;
        
        lon_array(:,:,y) = xi;
        lat_array(:,:,y) = yi;
        abundance_1(:,:,y) = zi;
        abundance_2(:,:,y) = zi2;
        %make netCDF file
        
%         text(-73.5,37,strc,'FontSize',16)
%         outdir = ['C:\Users\kristin.kleisner.NMFS\Desktop\mappingCode\Output_SP_FA\Fall_Thorny\',Species{ss}, '-Fall\'];

%         Name=[outdir, Species{ss}, ' fall_',str]
        
%         print('-dtiff','-r450',Name)
%         drawnow;
    end
    
    %create netcdf file
    ncid = netcdf.create(filename_out,'NC_WRITE');
    
    %Define dimensions
    dimidt = netcdf.defDim(ncid,'time',nyears);
    dimidlat = netcdf.defDim(ncid,'latitude',size(xi,1));
    dimidlon = netcdf.defDim(ncid,'longitude',size(xi,2));
    
    %Define IDs for dimension variables
    year_ID = netcdf.defVar(ncid,'time','double',[dimidt]);
    latitude_ID = netcdf.defVar(ncid,'latitude','double',[dimidlat]);
    longitude_ID = netcdf.defVar(ncid,'longitude','double',[dimidlon]);
    
    %Define abundance variables
    ab1_nc = netcdf.defVar(ncid,'abundance_1','double',[dimidlat dimidlon dimidt]);
    ab2_nc = netcdf.defVar(ncid,'abundance_2','double',[dimidlat dimidlon dimidt]);
    
    %end definition
    netcdf.endDef(ncid);
        
    %store variables
    netcdf.putVar(ncid,ab1_nc,abundance_1);
    netcdf.putVar(ncid,ab2_nc,abundance_2);
    
    netcdf.putVar(ncid,year_ID,yearnames);
    netcdf.putVar(ncid,longitude_ID,MinLon:Interval:MaxLon);
    netcdf.putVar(ncid,latitude_ID,MinLat:Interval:MaxLat);
    
    netcdf.close(ncid)
% end