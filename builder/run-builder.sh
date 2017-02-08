#!/bin/bash
#
# This file is protected by Copyright. Please refer to the COPYRIGHT file distributed 
# with this source distribution.
#
# This file is part of Geon Technology's docker-redhawk-minimal.
#
# Geon Technology's docker-redhawk-minimal is free software: you can redistribute it and/or 
# modify it under the terms of the GNU Lesser General Public License as published by 
# the Free Software Foundation, either version 3 of the License, or (at your option) 
# any later version.
#
# Geon Technology's docker-redhawk-minimal is distributed in the hope that it will be useful, 
# but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.
#
set -e
set -o nounset

mkdir -p ${PWD}/work/omnievents
rm -rf ${PWD}/work/omnievents/*
mkdir -p ${PWD}/work/redhawk-sdr
rm -rf ${PWD}/work/redhawk-sdr/*

docker run -it --rm \
    -v ${PWD}/work/redhawk-sdr:/opt/redhawk \
    -v ${PWD}/work/omnievents:/opt/omnievents \
    redhawk/builder
