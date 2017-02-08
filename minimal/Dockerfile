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

RUN apt-get update -q

ADD redhawk-fs      /opt/redhawk
ADD omnievents-fs   /opt/omnievents

ENV PATH ${OSSIEHOME}/bin:${PATH}
ENV LD_LIBRARY_PATH ${OSSIEHOME}/lib64:${LD_LIBRARY_PATH}
ENV PYTHONPATH ${OSSIEHOME}/lib64/python:${OSSIEHOME}/lib/python:${PYTHONPATH}

WORKDIR ${SDRROOT}/dom

CMD ["/bin/bash", "--login"]
