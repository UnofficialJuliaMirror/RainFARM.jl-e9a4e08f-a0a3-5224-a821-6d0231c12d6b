__precompile__()
module RainFARM
export agg,fft3d,initmetagauss,gaussianize,metagauss,aggspec
export mergespec_spaceonly,downscale_spaceonly,lon_lat_fini,fitslopex
export read_netcdf2d,write_netcdf2d,rainfarmn,interpola,smooth
export overwrite_netcdf2d

using Interpolations, NetCDF

include("rf/agg.jl")
include("rf/aggspec.jl")
include("rf/smooth.jl")
include("rf/fft3d.jl")
include("rf/initmetagauss.jl")
include("rf/gaussianize.jl")
include("rf/metagauss.jl")
include("rf/mergespec_spaceonly.jl")
include("rf/downscale_spaceonly.jl")
include("rf/lon_lat_fini.jl")
include("rf/fitslopex.jl")
include("rf/read_netcdf2d.jl")
include("rf/write_netcdf2d.jl")
include("rf/overwrite_netcdf2d.jl")
include("rf/interpola.jl")
include("rf/rainfarmn.jl")

end
