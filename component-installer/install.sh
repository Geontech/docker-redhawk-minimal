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

export LD_LIBRARY_PATH=${OSSIEHOME}/lib:${OMNIEVENTS}/lib64:${LD_LIBRARY_PATH}
export JAVA_HOME=`readlink -f "/usr/lib/jvm/default-java"`
export PYTHONPATH=${OSSIEHOME}/lib64/python:${OSSIEHOME}/lib/python:${PYTHONPATH}
export PATH=${OSSIEHOME}/bin:${JAVA_HOME}/bin:${PATH}

./build.sh distclean
./build.sh 2>&1 | tee component-build.log || {
    echo "Component build.sh failed.  Nothing installed See log."
    exit 1
}
for impl in ./* ; do
    targ="$(basename "$impl")"
    if [ -d "$targ" ] && [ ! "$targ" = 'tests' ] ; then
        make -C $targ install 2>&1 | tee component-install-$targ.log || {
            echo "Component ${targ} installation failed."
            exit 1
        }
    fi
done

# Clean up.
./build.sh distclean
