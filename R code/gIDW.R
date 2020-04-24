#' performs inverse distance weight interpolation
#' 
#' Performs inverse distance weight interpolation on a 
#' specified interpolation grid. Transplated to R from
#'  Giuliano Langella's MatLab function .
#'  
#'  @Xc numeric vector. X coordinates of known points
#'  @Yc numeric vector. Y coordnates of known points
#'  @Vc numeric vector. Known values at [Xc, Yc] locations
#'  @Xi matrix. x coordinates of grid to be interpolated
#'  @Yi matrix. y coordinates of grid to be interpolated
#'  @w integer. Distance weight: w<0 for Inverse Distance Weighted interpolation, w=0 for simple moving average
#'  @r1 string. Neighborhood type: 'n' for number of neighbors, 'r' for fixed radius length
#'  @r2 scalar. Neighborhood size: r1='n' -> number of neighbors, r1='r' -> radius length
#'  
#'  @return Vi. matrix of interpolated values over interpolation grid
#'  
#'  Author: Giuiano Langella gyuliano@libero.it . Translated to R by J. Caracappa
#'  

# Xc = 1:10
# Yc = 1:10
# Vc = runif(10)*100
# Xi = matrix(runif(50^2)*10,nrow = 50, ncol = 50)
# Yi = matrix(runif(50^2)*10,nrow = 50, ncol = 50)
# r1 = 'n'
# # r1 = 'r'
# r2 = 3
# #r2 = 3
# w = -1


gIDW = function(Xc,Yc,Vc,Xi,Yi,w,r1,r2){
  if( length(Xc)!=length(Yc) | length(Xc)!=length(Vc)){
    stop('Vectors Xc, Yc and Vc are incorrectly sized!')
  }else if(length(Xi)!=length(Yi)){
    stop('Vectors Xi and Yi are incorrectly sized!')
  }
  if(!(r1 %in% c('r','n'))){
    stop('Parameter r1 not properly defined')
  }
  
  #Initialize output
  # Vi = matrix(0,nrow = nrow(Xi), ncol = ncol(Xi))
  Vi = numeric(length(Xi))
  
  #If fixed radius (r1 = 'r')
  if( r1 == 'r'){
    
    if(r2 <= 0){
      stop('Radius must be positive!')
    }
    
    for(i in 1:length(Xi)){
      D = sqrt( (Xi[i] - Xc)^2 + (Yi[i]-Yc)^2)
      D = D[D<r2]
      Vcc = Vc[D<r2]
      
      if(length(D) == 0){
        Vi[i] = NA
      } else {
        if( any(D==0)){
          Vi[i] = Vcc[D==0]
        }else{
          Vi[i] = sum(Vcc*(D^w))/sum(D^w)
        }
      }
    }
  #If Fixed neighbors number
  } else if(r1 == 'n'){
    
    if(r2 > length(Vc) | r2 <1){
      stop('Number of neighbors not congruent with data')
    }
    
    for(i in 1:length(Xi)){
      D = sqrt( (Xi[i]-Xc)^2 + (Yi[i]-Yc)^2)
      I = order(D,na.last = T)
      Vcc = Vc[I]
      if( D[1] == 0){
        Vi[i] = Vcc[1]
      }else{
        Vi[i] = sum( Vcc[1:r2]*(D[1:r2]^w),na.rm=T)/ sum(D[1:r2]^2,na.rm=T)
      }
    }
  }
  
  return(Vi)
  
}
