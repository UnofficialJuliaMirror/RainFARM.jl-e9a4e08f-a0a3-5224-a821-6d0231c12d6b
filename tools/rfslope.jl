#!/usr/bin/env julia
# Copyright (c) 2016, Jost von Hardenberg - ISAC-CNR, Italy

using RainFARM
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "infile"
            help = "The input file to downscale"
            arg_type = AbstractString
            required = true
        "--varname", "-v"
            help = "Input variable name"
            arg_type = AbstractString
            default = ""
        "--outfile", "-o", "--out"
            help = "Output filename for spectrum"
            arg_type = AbstractString
            default = ""
    end

    s.description="Estimation of spatial spectral slope for RainFARM downscaling and (optional) computation of spectrum"

    return parse_args(s)
end

args = parse_commandline()
filenc=args["infile"]
varnc=args["varname"]
outfile=args["outfile"]

#println("Estimating slope ",filenc)

(pr,lon_mat,lat_mat)=read_netcdf2d(filenc, varnc);
#println("Size var:", size(pr)," size lon: ",size(lon_mat)," size lat: ", size(lat_mat))
# Calcolo fft3d e slope
(fxp,ftp)=fft3d(pr);
sx=fitslopex(fxp);
#println("Computed spatial spectral slope: ",sx)
println(sx)

if outfile!="" 
   nk=length(fxp[:])
   k=collect(1:nk)
   aa=zeros(nk,2)
   aa[:,1]=k
   aa[:,2]=fxp
   writedlm(outfile,aa)
end
