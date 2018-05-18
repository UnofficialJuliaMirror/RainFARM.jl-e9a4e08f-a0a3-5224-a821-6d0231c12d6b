#!/usr/bin/env julia
# Copyright (c) 2016, Jost von Hardenberg - ISAC-CNR, Italy
using RainFARM
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--radius", "-r"
            help = "Smoothing radius (in grid units)"
            arg_type = Float64
            default = 0.
        "--varname", "-v"
            help = "Input variable name (in orofile)"
            arg_type = AbstractString 
            default = "" 
        "infile"
            help = "The file to downscale"
            arg_type = AbstractString
            required = true
        "outfile"
            help = "The output file name"
            arg_type = AbstractString
            required = true
    end

    s.description="Smooth input file using convolution with a circle of fixed radius"
    s.version="0.1"
    s.add_version=true

    return parse_args(s)
end

args = parse_commandline()
radius=args["radius"]
filein=args["infile"]
fileout=args["outfile"]
varname=args["varname"]

(tin0,lonl0,latl0)=read_netcdf2d(filein,varname);
if(length(size(lonl0))>1)
dxl=max(lonl0[2,1]-lonl0[1,1],lonl0[1,2]-lonl0[1,1]);
else
dxl=lonl0[2]-lonl0[1];
end

println("dx=",dxl)
if(radius==0)
    radius=dxl
end

(tin,lonl,latl,varname)=read_netcdf2d(filein,varname);
(nx,ny,nt)=size(tin,1,2,3)

if(radius>0)
  nf2=div(radius,dxl)
else
  nf2=-radius
end

println("Smoothing with radius ",radius," = ",nf2, " pixel")

for i=1:nt
#    println("t=",i)
    tin[:,:,i]=smooth(tin[:,:,i],nf2)
end

run(`cp $filein $fileout`)
overwrite_netcdf2d(fileout,tin,varname)
