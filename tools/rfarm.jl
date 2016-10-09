#!/usr/bin/env julia

# RainFARM 
# Stochastic downscaling following 
# D'Onofrio et al. 2014, J of Hydrometeorology 15 , 830-843 and
# Rebora et. al 2006, JHM 7, 724 
# Includes orographic corrections

# Implementation in Julia language

# Copyright (c) 2016, Jost von Hardenberg - ISAC-CNR, Italy

using RainFARM
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--slope", "-s"
            help = "spatial spectral slope"
            arg_type = Float64
            default = 1.7
        "--nens", "-e"
            help = "number of ensemble members"
            arg_type = Int
            default = 1
        "--nf", "-n"
            help = "Subdivisions for downscaling"
            arg_type = Int
            default = 2
        "--weights", "-w", "--weight"
            help = "Weights file"
            arg_type = AbstractString
            default = "" 
        "--outfile", "-o", "--out"
            help = "Output filename radix"
            arg_type = AbstractString
            default = "rainfarm" 
        "infile"
            help = "The input file to downscale"
            arg_type = AbstractString
            required = true
        "--varname", "-v"
            help = "Input variable name"
            arg_type = AbstractString
            default = ""
        "--global", "-g"              
            action = :store_true
            help = "conserve precipitation over full domain"
        "--conv", "-c"              
            action = :store_true
            help = "conserve precipitation using convolution"
    end

    s.description="RainFARM downscaling: creates NENS realizations, downscaling INFILE, increasing spatial resolution by a factor NF. The slope is computed automatically unless specified. \ua0 Weights can be created with rfweights.jl"

    return parse_args(s)
end

args = parse_commandline()
nf=args["nf"]
filenc=args["infile"]
weightsnc=args["weights"]
nens=args["nens"]
varname=args["varname"]
fnbase=args["outfile"]
sx=args["slope"]
fglob=args["global"]
fsmooth=args["conv"]

println("Downscaling ",filenc)

(pr,lon_mat,lat_mat,varname)=read_netcdf2d(filenc, varname);

# Creo la griglia fine
(lon_f, lat_f)=lon_lat_fine(lon_mat, lat_mat,nf);

println("Output size: ",size(lon_f))

if(sx==0.) 
# Calcolo fft3d e slope
(fxp,ftp)=fft3d(pr);
sx=fitslopex(fxp);
println("Computed spatial spectral slope: ",sx)
else
println("Fixed spatial spectral slope: ",sx)
end

#if(varnc=="")
#   varnc="pr"
#end

if(fglob) 
  println("Conserving only global precipitation")
end

if(weightsnc!="")
    println("Using weights file ",weightsnc)
    (ww,lon_mat2,lat_mat2)=read_netcdf2d(weightsnc, "");
else
    ww=1.
end
# Downscaling
for iens=1:nens
  @printf("Realization %d\n",iens)
  @time rd=rainfarmn(pr, sx, nf, ww,fglob=fglob,fsmooth=fsmooth,verbose=true);
  fname=@sprintf("%s_%04d.nc",fnbase,iens);
  write_netcdf2d(fname,rd,lon_f,lat_f,varname,filenc)
end
