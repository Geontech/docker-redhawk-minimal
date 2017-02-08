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

# IMPORTANT: This is not a full build of REDHAWK.  It skips the GPP and all 
# standard Components because for our purposes, they are unnecessary since the 
# external (host) GPP will be the one managing the lifecycle of the component
# within the container, directly run from the command line.

set -e

export OMNIEVENTS=/opt/omnievents
export LD_LIBRARY_PATH=${OSSIEHOME}/lib:${OMNIEVENTS}/lib64:${LD_LIBRARY_PATH}
export JAVA_HOME=`readlink -f "/usr/lib/jvm/default-java"`
export PYTHONPATH=${OSSIEHOME}/lib64/python:${OSSIEHOME}/lib/python:${PYTHONPATH}
export PATH=${OSSIEHOME}/bin:${JAVA_HOME}/bin:${PATH}

cd ${SOURCE_DIR}

# Build xsd manually
pushd ${XSD_SRC}
make install 2>&1 | tee xsd.log || {
    echo "xsdcxx make install failed!"
    exit 1
}
popd

# Build omniEvents manually
pushd ${OMNIEVENTS_SRC}
./reconf
./configure --prefix=${OMNIEVENTS}
make 2>&1 | tee omnievents-make.log || {
    echo "omniEvents make failed!"
    exit 1
}
make install 2>&1 | tee omnievents-install.log || {
    echo "omniEvents install failed!"
    exit 1
}
cd etc
make install 2>&1 | tee omnievents-service-install.log || {
    echo "omniEvents service install failed!"
    exit 1
}
ldconfig
popd

# Build core framework elements
pushd ${CORE_FRAMEWORK_SRC}

# Redhawk core
pushd redhawk/src
./reconf && ./configure CXXFLAGS="-fpermissive"
make 2>&1 | tee core-framework-make.log || {
    echo "Core Framework make failed!"
    exit 1
}
make install 2>&1 | tee core-framework-install.log || {
    echo "Core Framework install failed!"
    exit 1
}
ldconfig
popd

# BulkIO
pushd bulkioInterfaces
./reconf && ./configure CXXFLAGS="-fpermissive"
make 2>&1 | tee bulkioInterfaces-make.log || {
    echo "BulkIO Interfaces make failed!"
    exit 1
}
make install 2>&1 | tee bulkioInterfaces-install.log || {
    echo "BulkIO Interfaces install failed!"
    exit 1
}
ldconfig
popd

# BurstIO
pushd burstioInterfaces
./reconf && ./configure CXXFLAGS="-fpermissive"
make 2>&1 | tee burstioInterfaces-make.log || {
    echo "BurstIO Interfaces make failed!"
    exit 1
}
make install 2>&1 | tee burstioInterfaces-install.log || {
    echo "BurstIO Interfaces install failed!"
    exit 1
}
popd

# FrontEnd Interfaces
pushd frontendInterfaces
./reconf && ./configure CXXFLAGS="-fpermissive"
make 2>&1 | tee frontendInterfaces-make.log || {
    echo "FrontEnd Interfaces make failed!"
    exit 1
}
make install 2>&1 | tee frontendInterfaces-install.log || {
    echo "FrontEnd Interfaces install failed!"
    exit 1
}
popd


# Code Gen
# This is probably unnecesary, but could be handy if we try to script
# creating sub-images marrying newly-generated components to different 
# flow graphs, e.g., redhawk-sdr/redhawk-sdr-minimal:flowgraph1
pushd redhawk-codegen
python setup.py install --home=${OSSIEHOME}
popd
