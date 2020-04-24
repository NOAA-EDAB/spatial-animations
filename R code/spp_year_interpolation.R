#' Reads, manipulates, and interpolates survdat for spatial animations
#' 
#' Takes Fall survdat data, processes it, and generates values
#' on desired interpolation grid for species spatial visualizations
#' 
#' 
#' Author: J. Caracappa

# bathymetry = read.table('C:/Users/joseph.caracappa/Documents/GitHub/spatial-animations/NEBathymetry.txt')
# station = read.csv('C:/Users/joseph.caracappa/Documents/GitHub/spatial-animations/stationview_x.csv',as.is = T)
# spp = 4
# radius = 2.5
# minlength = 0
# year.range = 2
# yr = 1981
# min.lat = 35
# max.lat = 45
# min.lon = -76
# max.lon = -65
# interval = 0.02

spp.year.density = function(bathymetry,station,catchview,spp,radius,minlength,year.range,yr,min.lat,max.lat,min.lon,max.lon,interval){
  
  
  #Process bathymetry data
  lonb = bathymetry[,1]
  latb = bathymetry[,2]
  depth = bathymetry[,3]
  
  #Convert bathymetry to sp object
  colnames(bathymetry) = c('x','y','z')
  # sp::coordinates(bathymetry) = ~x+y
  
  #Process station data
  colnames(station) = c('cr','sta','str','ves','year','season','tow','shg','gear','estyr',
  'mon','dat','time','distb','distw','avgdpt','area','btemp','lat','long')
  
  hour = floor(station$time/100)
  latdd = floor(station$lat/100)+((station$lat/100)-floor(station$lat/100))/60*100
  londd = (floor(station$long/100)+((station$long/100)-floor(station$long/100))/60*100)*-1
  
 
  #Catchview
  
  colnames(catchview) = c('cat.cr','cat.str','cat.tow','cat.sta','cat.sea','cat.spp','cat.com','cat.sex','cat.wgt','cat.n')
  
  #Picking Data, subsetting station to +-current year
  k = which(station$year>=yr-year.range & station$year<=yr+year.range & station$season == 'FALL')
  nstations = length(k)
  latdd = latdd[k] 
  londd = londd[k]
  station2 = station[k,]
  
  #Assign catch to stations
  catch = numeric(nrow(station2)) 
  # kk =numeric()
  for(n in 1:nrow(station2)){
    k3 = which(catchview$cat.cr == station2$cr[n] & catchview$cat.str == station2$str[n] & catchview$cat.sta == station2$sta[n])
    if(length(k3) != 0){
      catch[n] = sum(catchview$cat.wgt[k3])
    }
    # kk[n] = length(k3)
  }
  
  #Gridding bathymetry
  latdepthconv = 0.1 #
  
  #interpolate bathymetry onto interpolation grid [xi,yi], uses yaImpute::ann for approx. nearest-neighbor
  grd = expand.grid(x = seq(min.lon,max.lon,interval),y=seq(min.lat,max.lat,interval) )
  xi = seq(min.lon,max.lon,interval)
  yi = seq(min.lat,max.lat,interval)

  knn.out = yaImpute::ann(target = as.matrix(grd),ref = as.matrix(bathymetry[,1:2]),k=1,verbose = F)
  bathy.match = knn.out$knnIndexDist[,1]
  grd$z = bathymetry$z[bathy.match]
  
  #output zi on grd
  # zi = matrix(-1, nrow = length(yi), ncol = length(xi))
  grd$zi = -1
  # test = rep(0, nrow(grd))
  options(warn =2)
  for(n in 1:nrow(grd)){
    depth.at.location = -grd$z[n]
    year.scalar = abs(yr-station2$year)
    depth.scalar = latdepthconv*abs(sqrt(station2$avgdpt)-sqrt(depth.at.location))
    #distance calculation
    dist = sqrt( (londd - grd$x[n])^2 + (latdd-grd$y[n])^2)
    adj.dist = dist + depth.scalar + 2*year.scalar
    #adjusted lat/lon
    adj.lon = grd$x[n]+(londd-grd$x[n])*(adj.dist/dist)
    adj.lat = grd$y[n]+(latdd-grd$y[n])*(adj.dist/dist)
    #adj dist = 0 
    k = which(dist == 0)
    adj.lon[k] = grd$x[n]+adj.dist[k]+0.02
    adj.lat[k] = grd$y[n]+adj.dist[k]+0.02#fixes this. unsure what original intent was
    # adj.lon[k] = grd$zi[n]+adj.dist[k]+0.02
    k = which(londd<grd$x[n])
    adj.lon[k] = adj.lon[k] - 0.01
    k= which(londd>=grd$x[n])
    adj.lon[k] = adj.lon[k] + 0.01
    k = which(latdd < grd$x[n])
    adj.lat[k] = adj.lat[k] - 0.01
    k = which(latdd >=grd$x[n])
    adj.lat[k] = adj.lat[k] + 0.01
    k = which(adj.dist < radius)
    # coverage = ceiling(nstations/100)
    coverage = 15
    if(length(k) == 0){
      next()
    }else if( length(k) >= coverage & min(dist[k],na.rm=T)<0.5){
        res = gIDW(Xc = adj.lon[k], Yc = adj.lat[k],Vc = catch[k]^(1/3),Xi = grd$x[n],Yi = grd$y[n],w = -1, r1 = 'n',r2 = coverage)    
        grd$zi[n] = res
    }
    if(n %% 1000 == 0){print(n)}
  }
  return(grd)
}

# grd2 = grd[-which(grd$zi == -1),]
# grd2$zi[grd2$zi == 0] = NA
# ggplot(data =grd2,aes(x=x,y=y,z = zi,fill = zi))+geom_contour()+geom_tile()+scale_fill_distiller(palette = 'Spectral')
