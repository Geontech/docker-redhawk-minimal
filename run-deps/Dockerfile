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
FROM ubuntu:16.04
MAINTAINER Thomas Goodwin <btgoodwin@geontech.com>

# Install runtime libs
RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -qy \
        libexpat1 \
        libuuid1 \
        uuid \
        liblog4cxx10v5 \
        python-numpy \
        libboost-date-time1.58.0 \
        libboost-filesystem1.58.0 \
        libboost-regex1.58.0 \
        libboost-serialization1.58.0 \
        libboost-system1.58.0 \
        libboost-thread1.58.0 \
        libapr1 \
        libaprutil1 \
        omniorb-nameserver \
        python-omniorb \
        omniorb-idl \
        libcos4-1 \
        default-jdk 

# The etc/omniORB.cfg temporary file and should be overwritten with a volume mount
# at runtime (-v my_omniORB.cfg:/etc/omniORB.cfg) to point at the omni server
# you're using.  This should ensure that a login shell will also get the env.
# variables configured.
COPY etc /etc
RUN echo 'unset OSSIEHOME && . /etc/profile ; ' >> /root/.profile

ONBUILD ENV SDRROOT     /opt/redhawk/sdr
ONBUILD ENV OSSIEHOME   /opt/redhawk/core
ONBUILD ENV OMNIEVENTS  /opt/omnievents
