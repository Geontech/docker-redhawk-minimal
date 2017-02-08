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
FROM redhawk/run-deps
MAINTAINER Thomas Goodwin <btgoodwin@geontech.com>

# Install dev libs and tools
RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -qy --no-install-recommends \
        build-essential \
        wget \
        autoconf \
        automake \
        libtool \
        libexpat1-dev \
        uuid-dev \
        liblog4cxx-dev \
        python-dev \
        python-jinja2 \
        pyqt4-dev-tools \
        libboost-date-time-dev \
        libboost-filesystem-dev \
        libboost-regex-dev \
        libboost-serialization-dev \
        libboost-system-dev \
        libboost-thread-dev \
        libxerces-c-dev \
        libapr1-dev \
        libaprutil1-dev \
        libomniorb4-dev \
        omniidl \
        omniidl-python \
        libcos4-dev \
        python-setuptools

# Forward environment variables from redhawk-sdr-deps
ONBUILD ENV SDRROOT     ${SDRROOT}
ONBUILD ENV OSSIEHOME   ${OSSIEHOME}

# Create a source directory
ENV SOURCE_DIR /tmp

# Collect all other source
WORKDIR ${SOURCE_DIR}

# Results in omniEvents-2.7.1
RUN wget https://github.com/RedhawkSDR/omniEvents/archive/2.7.1.tar.gz && \
    tar xf 2.7.1.tar.gz

# Results in xsd-3.3.0-2+dep
RUN wget http://www.codesynthesis.com/download/xsd/3.3/xsd-3.3.0-2+dep.tar.bz2 && \
    bzip2 -d xsd-3.3.0-2+dep.tar.bz2 && \
    tar xf xsd-3.3.0-2+dep.tar

# Results in core-framework-2.0.4
RUN wget https://github.com/RedhawkSDR/core-framework/archive/2.0.4.tar.gz && \
    tar xf 2.0.4.tar.gz

# Resulting helper paths for next layer
ONBUILD ENV SOURCE_DIR          ${SOURCE_DIR}
ONBUILD ENV XSD_SRC             xsd-3.3.0-2+dep
ONBUILD ENV OMNIEVENTS_SRC      omniEvents-2.7.1
ONBUILD ENV CORE_FRAMEWORK_SRC  core-framework-2.0.4
