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
FROM redhawk/build-deps
MAINTAINER Thomas Goodwin <btgoodwin@geontech.com>

RUN apt-get update -q

WORKDIR /root
ADD build.sh /root

# Set the environment variables as passed in from build-deps
ENV SDRROOT             ${SDRROOT}
ENV OSSIEHOME           ${OSSIEHOME}
ENV SOURCE_DIR          ${SOURCE_DIR}
ENV XSD_SRC             ${XSD_SRC}
ENV OMNIEVENTS_SRC      ${OMNIEVENTS_SRC}
ENV CORE_FRAMEWORK_SRC  ${CORE_FRAMEWORK_SRC}

CMD ["/bin/bash", "--login", "-c", "/root/build.sh"]
