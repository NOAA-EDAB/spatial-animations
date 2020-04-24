#Script Generates spatial animation data for given species/year and outputs Nc file

library(ncdf4)

# Read in Data
bathymetry = read.table(here::here('NEBathymetry.txt'))
station = read.csv(here::here('stationview_x.csv'),as.is = T)

spp.data = read.csv(here::here('SurvDatSpec_Fall.csv'),header=F)
colnames(spp.data) = c('SVSPP','COMNAME','Species')

# Load sourced functions
source(here::here('R Code','gIDW.R'))
source(here::here('R Code','spp_year_interpolation.R'))


min.lat = 35
max.lat = 45
min.lon = -76
max.lon = -65
interval = 0.02

#Time range
year.start = 1980
year.stop = 1980
yearnames = year.start:year.stop
nyears = length(yearnames)

#Define interpolation grid
xi = seq(min.lon,max.lon,interval)
yi = seq(min.lat,max.lat,interval)

n.spp = length(spp.data$SVSPP)
out.dir = here::here('Output_Data','/')

# for(ss in 1:SpeciesNum){
for(ss in 1:1){
  
  
  filename.out = paste0(out.dir,spp.data$Species[ss],'-Fall_R.nc')
  
  #Define data arrays
  lat.array = array(0,dim = c(length(yi),length(xi),nyears))
  lon.array = array(0,dim = c(length(yi),length(xi),nyears))
  abundance = array(0,dim = c(length(yi),length(xi),nyears))
  
  catchview = read.csv(paste0(here::here('Catchview Data'),'/catchview_',spp.data$SVSPP[ss],'.csv'))
  
  for(y in 1:nyears){
    
    yr = yearnames[y]
    grd =spp.year.density(
      bathymetry = bathymetry,
      station = station,
      catchview = catchview,
      spp = spp.data$SVSPP[ss],
      radius = 2.5,
      minlength = 0,
      year.range = 2,
      yr = yr,
      min.lat = min.lat,
      max.lat = max.lat,
      min.lon = min.lon,
      max.lon = max.lon,
      interval = interval
    )
    #convert grd to matrix...
    grd$ID = 1:nrow(grd)
    grd$zi[grd$zi==-1]= NA
    
    abundance[,,y] = matrix(grd$zi,nrow =length(yi),ncol = length(xi),byrow=T)
    lon.array[,,y] = matrix(grd$x,nrow =length(yi),ncol = length(xi),byrow = T)
    lat.array[,,y] = matrix(grd$y,nrow =length(yi),ncol = length(xi),byrow = T)
    
  }
  
  #Build and write netCDF 

  #Define Dimensions
  timedim = ncdim_def('time','',1:nyears,unlim = T, create_dimvar = F)
  latdim = ncdim_def('latitude','',1:length(yi),unlim=T,create_dimvar = F)
  londim = ncdim_def('longtidue','',1:length(xi),unlim =T, create_dimvar = F)
  
  var.time = ncvar_def('time','year',timedim,prec='double')
  var.lat = ncvar_def('latitude','degrees',list(londim,latdim,timedim),prec='float')
  var.lon = ncvar_def('longitude','degrees',list(londim,latdim,timedim),prec='float')
  var.abundace = ncvar_def('abundance','',list(londim,latdim,timedim),prec = 'float')
  
  varfile = nc_create(filename.out,list(var.time,var.lat,var.lon,var.abundace))

  #Assign variables
  
  ncvar_put(varfile,var.time,yearnames,count = nyears)
  ncvar_put(varfile,var.lat,lat.array,count = c(length(yi),length(xi),nyears))
  ncvar_put(varfile,var.lon,lon.array,count = c(length(yi),length(xi),nyears))
  ncvar_put(varfile,var.abundace,abundance,count = c(length(yi),length(xi),nyears))

  nc_close(varfile)              
}