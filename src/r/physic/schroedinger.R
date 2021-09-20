# Exploring the  Schrodinger equation for the hydrogen atom or
# more generally one-electron atom or ions.

# Resources
#   https://web.iitd.ac.in/~nkurur/2013-14/IIsem/cyl100/hatom_radial.pdf

# Code
#   https://github.com/PhilipWee/OrbitalViewer


# Dependencies
library(svMisc)
library(plot3D)


#
# Functions
#

# Create the function for converting spherical to cartesian
spherical_to_cartesian <- function(sphericalCoords){
  r <- sphericalCoords[1]
  theta <- sphericalCoords[2]
  phi <- sphericalCoords[3]
  z <- round(r*cos(theta),digits = 5)
  xy_plane_length <- r*sin(theta)
  x <- round(xy_plane_length*cos(phi),digits = 5)
  y <- round(xy_plane_length*sin(phi),digits = 5)
  return(c(x,y,z))
}
# Check the function is running as expected
stopifnot(spherical_to_cartesian(c(3,0,pi)) == c(0.0, 0.0, 3.0))

# Create the function for converting cartesian to spherical
cartesian_to_spherical <- function(x,y,z){
  r <- sqrt(x*x + y*y + z*z)
  xy_plane_length <- sqrt(x*x + y*y)
  #handle the exception where it only has z value
  # if(xy_plane_length == 0){
  #   phi = 0
  # } else {
  phi = acos(x/xy_plane_length)
  # }
  #handle the exception where it is the origin
  # if(r == 0){
  #   theta = 0
  # } else {
  theta = acos(z/r)
  # }
  return(c(r,theta,phi))
}
# Check that the function is working as expected
stopifnot(round(cartesian_to_spherical(0,3,0),digits = 5) == c(3.0,1.5708,1.5708))

# Find the coefficient for a particular angular function for a particular m and l
angular_coefficient <- function(m,l){
  #There are four parts to the equation
  top_left <- 2*l + 1
  top_right <- factorial(l - abs(m))
  bottom_left <- 4*pi
  bottom_right <- factorial(l + abs(m))
  #epsilon depends on these conditions
  if(m>1){
    epsilon <- (-1)^m
  } else {
    epsilon <- 1
  }
  #put it together neatly
  angular_coefficient <- epsilon*sqrt((top_left*top_right)/(bottom_left*bottom_right)) 
}

# Makes the sin_part a function that doesnt have to go through the if else loop and just considers only the value itself
sin_part_finder <- function(m){
  if(m==0){
    return({
      function(theta){
        return(1)
      }
    })
  } else {
    return({
      function(theta){
        return(sin(theta)^m)
      }
    })
  } 
}
# Check that it is working
sin_part_finder_m2 <- sin_part_finder(2)
stopifnot(round(sin_part_finder_m2(0.5),digits = 5) == 0.22985)

# All the cosine functions with all the division done before hand
cos_part_list <- c(function(theta) cos(theta),
                   function(theta) 1.5*cos(theta)^2-0.5,
                   function(theta) 2.5*cos(theta)^2-0.5,
                   function(theta) 7.5*cos(theta)^2-4.5*cos(x),
                   function(theta) 1)

# Which particular function applies to the situation? extract it
cos_part_finder <- function(m,l){
  if(l-m == 1){
    return(cos_part_list[[1]])
  } else if(m == 0 && l == 2){
    return(cos_part_list[[2]])
  } else if(m == 1 && l == 3){
    return(cos_part_list[[3]])
  } else if(m == 0 && l == 3){
    return(cos_part_list[[4]])
  } else {
    return(cos_part_list[[5]])
  }
}

# Create the full angular function for a particular m and l
angular_function_finder <- function(m,l){
  sin_part_particular <- sin_part_finder(m)
  cos_part_particular <- cos_part_finder(m,l)
  angular_coefficient_particular <- angular_coefficient(m,l)
  return(function(theta,phi){
    exponential_part <- exp(1i*m*phi)
    angular_answer <- exponential_part*sin_part_particular(theta)*cos_part_particular(theta)*angular_coefficient_particular
    return(round(angular_answer,digits=5))
  })
}

#check if the angular function maker is doing what its supposed to be doing
angular_function_m0_l0 <- angular_function_finder(0,0)
angular_function_m0_l1 <- angular_function_finder(0,1)
angular_function_m1_l1 <- angular_function_finder(1,1)
angular_function_m0_l2 <- angular_function_finder(0,2)
stopifnot(round(angular_function_m0_l0(0,0),digits= 5) ==0.28209+0i)
stopifnot(round(angular_function_m0_l1(pi,0),digits= 5)== -0.48860+0i)
stopifnot(round(angular_function_m1_l1(pi/2,pi),digits= 5) == -0.34549+0i)
stopifnot(round(angular_function_m0_l2(pi,0),digits= 5) == 0.63078+0i)

# Find the radial coefficient
# Hard coded as the coefficient changes with the differentiation, so it is easier to just hard code the numerical coefficient
radial_coefficient <- function(n,l){
  if(n == 0){
    return(2)
  } else if(n == 2){
    if(l == 0){
      return(1/sqrt(2))
    } else if(l == 1){
      return(1/sqrt(24))
    }
  } else if(n == 3){
    if(l == 0){
      return(2/81/sqrt(3))
    } else if(l == 1){
      return(8/27/sqrt(6))
    } else if(l == 2){
      return(4/81/sqrt(30))
    }
  } else if(n == 4){
    if(l == 0){
      return(1/4)
    } else if(l == 1){
      return(sqrt(5)/16/sqrt(3))
    } else if(l == 2){
      return(1/64/sqrt(5))
    } else if(l == 3){
      return(1/768/sqrt(35))
    }
  } 
}
# radial_coefficient(2,0)

#all the polynomials are predefined as doing the differentiation would take too
#much computational power 
#defining bohr radius
a <- 5.291772*10^-11

#hard coding the individual polynomial lists
polynomial_list_n1 <- list(
  function(R) 1
)

polynomial_list_n2 <- list(
  function(R) 1-R/2,
  function(R) R
)

polynomial_list_n3 <- list(
  function(R) 27-18*R+2*(R)^2,
  function(R) R-((R)^2)/6,
  function(R) (R)^2
)

polynomial_list_n4 <-list(
  function(R) 1-3*(R)/4+((R)^2)/8 - ((R)^3)/192,
  function(R) 1-(R)/4+((R)^2)/80,
  function(R) 1-(R)/12,
  function(R) (R)^3
)

#polynomial finder list
polynomial_list <- list(
  polynomial_list_n1,
  polynomial_list_n2,
  polynomial_list_n3,
  polynomial_list_n4
)

#find the radial part of the wave function
radial_wave_func_finder <- function(n,l){
  coefficient <- radial_coefficient(n,l)
  polynomial_function <- polynomial_list[[n]][[l+1]]
  return(function(r){
    R = r/a
    exponential_part <- exp(-R/n)
    polynomial_part <- polynomial_function(R)
    #script to test if it is correct
    # x = sprintf("exponential part:%f polynomial part:%f coefficient:%f",exponential_part,polynomial_part,coefficient)
    # print(x)
    radial_part <- coefficient*polynomial_function(R)*exponential_part
    return(round(radial_part,digits = 5))
  })
}

radial_wave_func_n2_l0 <- radial_wave_func_finder(2,0)
radial_wave_func_n2_l0(0.000000000001)

#make sure the radial wave func is working as intended
radial_wave_func_n1_l0 <- radial_wave_func_finder(1,0)
radial_wave_func_n2_l1 <- radial_wave_func_finder(2,1)
radial_wave_func_n3_l1 <- radial_wave_func_finder(3,1)
stopifnot(round(radial_wave_func_n1_l0(a),digits = 5) == 0.73576)
stopifnot(round(radial_wave_func_n2_l1(a),digits = 5) == 0.12381)
stopifnot(round(radial_wave_func_n3_l1(2*a),digits = 5) == 0.08281)

#get the probability density function for hydrogen
hydrogen_prob_density_func <- function(n,l,m){
  positive_m_Y <- angular_function_finder(abs(m),l)
  negative_m_Y <- angular_function_finder(-abs(m),l)
  R_part_func <- radial_wave_func_finder(n,l)
  if(m<0){
    return(function(r,theta,phi){
      Y_part <- (1i/sqrt(2))*(negative_m_Y(theta,phi)-((-1)^m)*positive_m_Y(theta,phi))
      R_part <- R_part_func(r)
      probability <- (R_part*Y_part)^2
      # print(sprintf("Y_part:%f,R_part:%f,probability:%f",Y_part,R_part,probability))
      return(probability)
    })
  } else if(m == 0){
    return(function(r,theta,phi){
      Y_part <- positive_m_Y(theta,phi)
      R_part <- R_part_func(r)
      probability <- (R_part*Y_part)^2
      # print(sprintf("Y_part:%f,R_part:%f,probability:%f",Y_part,R_part,probability))
      return(probability)
    })
  } else if(m >0){
    return(function(r,theta,phi){
      Y_part <- (1/sqrt(2))*(negative_m_Y(theta,phi)+((-1)^m)*positive_m_Y(theta,phi))
      R_part <- R_part_func(r)
      probability <- (R_part*Y_part)^2
      # print(sprintf("Y_part:%f,R_part:%f,probability:%f",Y_part,R_part,probability))
      return(probability)
    })
  }
}

#testing the hydrogen prob density func
hydrogen_prob_density_func_test <- hydrogen_prob_density_func(2,0,0)
hydrogen_prob_density_func_test
coords <- cartesian_to_spherical(-3*a,-3*a,-3*a)
# round(Re(hydrogen_prob_density_func_test(coords[1],coords[2],coords[3])),digits = 5)
stopifnot(round(Re(hydrogen_prob_density_func_test(coords[1],coords[2],coords[3])),digits = 5) == 0.00056)

#Generating the coordinates and density at particular coordinate
create_density_data <- function(n,l,m,roa,Nx,Ny,Nz){
  current_density_func <- hydrogen_prob_density_func(n,l,m)
  density_data <- data.frame()
  x_range <- seq(from = -roa*a, to = roa*a, length.out = Nx)
  y_range <- seq(from = -roa*a, to = roa*a, length.out = Ny)
  z_range <- seq(from = -roa*a, to = roa*a, length.out = Nz)
  i=0
  for(x in x_range){
    for(y in y_range){
      for(z in z_range){
        sph_coords <- cartesian_to_spherical(x,y,z)
        density <- current_density_func(sph_coords[1],sph_coords[2],sph_coords[3])
        current_data <- data.frame(x = x,
                                   y = y,
                                   z = z,
                                   density = Re(density))
        density_data <- rbind(density_data,current_data)
        i = i+100/Nx/Ny/Nz
        progress(i)
      }
    }
  }
  return(density_data)
}

create_density_data_v2 <- function(n,l,m,roa,Nx,Ny,Nz){
  current_density_func <- hydrogen_prob_density_func(n,l,m)
  x_range <- seq(from = -roa*a, to = roa*a, length.out = Nx)
  y_range <- seq(from = -roa*a, to = roa*a, length.out = Ny)
  z_range <- seq(from = -roa*a, to = roa*a, length.out = Nz)
  x_column <- rep(x = x_range, times = Nx, each = Ny*Nz)
  y_column <- rep(x = y_range, times = Nx*Ny, each = Nz)
  z_column <- rep(x = z_range, times = Nx*Ny*Nz, each = 1)
  density_data <- data.frame(x_column,y_column,z_column)
  output <- character(length = Nx*Ny*Nz)
  # i=0
  for(row_no in 1:nrow(density_data)){
    spher_coords <- cartesian_to_spherical(density_data$x_column[row_no],density_data$y_column[row_no],density_data$z_column[row_no])
    output[row_no] <- Re(current_density_func(spher_coords[1],spher_coords[2],spher_coords[3]))
    progress(row_no/nrow(density_data)*100)
  }
  density_data <- cbind(density_data,output)
  return(density_data)
}

create_density_data_v3 <- function(n,l,m,roa,Nx,Ny,Nz){
  current_density_func <- hydrogen_prob_density_func(n,l,m)
  x_range <- seq(from = -roa*a, to = roa*a, length.out = Nx)
  y_range <- seq(from = -roa*a, to = roa*a, length.out = Ny)
  z_range <- seq(from = -roa*a, to = roa*a, length.out = Nz)
  x_column <- rep(x = x_range, times = Nx, each = Ny*Nz)
  y_column <- rep(x = y_range, times = Nx*Ny, each = Nz)
  z_column <- rep(x = z_range, times = Nx*Ny*Nz, each = 1)
  density_data <- data.frame(x_column,y_column,z_column)
  spher_coords <- matrix(cartesian_to_spherical(density_data$x_column,density_data$y_column,density_data$z_column),ncol = 3)
  # i=0
  density_data <- cbind(spher_coords[,3],density_data)
  density_data <- cbind(spher_coords[,2],density_data)
  density_data <- cbind(spher_coords[,1],density_data)
  density_data[density_data == "NaN"] <- 0
  names(density_data)<-c("r","theta","phi","x","y","z")
  output <- current_density_func(density_data$r,density_data$theta,density_data$phi)
  # progress(row_no/nrow(density_data)*100)
  density_data <- cbind(density_data,output)
  return(density_data)
}


#Original code, same as python
system.time(density_data_test<-create_density_data(4,0,0,40,10,10,10))
#save data first
system.time(density_data_test<-create_density_data_v2(4,0,0,40,10,10,10))
#performing all operations on data stored in dataframe rather than using for loop
system.time(density_data_test<-create_density_data_v3(4,2,2,40,40,40,40))

#set density
density_threshold <- 0

#only plot points above a certain density
density_data_rows_wanted <- which(Re(density_data_test$output) < density_threshold)
density_data_wanted <- density_data_test[density_data_rows_wanted,]

#modify the colvar so the color is more evenly spread
density_data_wanted$output <- ((-Re(density_data_wanted$output))^0.1)*10^5

#plot the points
scatter3D(x = density_data_wanted$x,
          y = density_data_wanted$y,
          z = density_data_wanted$z,
          colvar = density_data_wanted$output,
          pch = 19,
          theta = 25,
          phi = 45)
