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

# Note: This make file was adapted by example from Johnathan Corgan's
#       gnuradio-docker builder @ https://github.com/gnuradio/gnuradio-docker

.PHONY: all
all: minimal

## 
# STAMPS directory
##
stamps/.stamp:
	@mkdir -p stamps
	@touch $@

## 
# REDHAWK SDR depends on gnuradio's runtime environment.
##
stamps/run-deps.stamp: stamps/.stamp run-deps/Dockerfile
	docker build --rm \
		-f run-deps/Dockerfile \
		-t redhawk/run-deps \
		run-deps
	@touch $@

stamps/build-deps.stamp: stamps/run-deps.stamp build-deps/Dockerfile
	docker build --rm \
		-f build-deps/Dockerfile \
		-t redhawk/build-deps \
		build-deps
	@touch $@

stamps/builder-image.stamp: stamps/build-deps.stamp builder/Dockerfile
	docker build --rm \
		-f builder/Dockerfile \
		-t redhawk/builder \
		builder
	@touch $@

stamps/builder.stamp: stamps/builder-image.stamp
	# Note, this build script creates external file systems:
	#   ./work/redhawk-sdr <=> /opt/redhawk
	#   ./work/omnievents  <=> /opt/omnievents
	# These are added below.
	${PWD}/builder/run-builder.sh
	@touch $@

stamps/minimal-prep.stamp: stamps/builder.stamp minimal/Dockerfile
	cp -r ${PWD}/work/redhawk-sdr minimal/redhawk-fs
	cp -r ${PWD}/work/omnievents minimal/omnievents-fs
	docker build --rm \
		-f minimal/Dockerfile \
		-t redhawk/minimal \
		minimal	
	@touch $@

stamps/redhawk-sdrroot-fs.stamp: stamps/minimal-prep.stamp
	docker create \
		-v /opt/redhawk/sdr \
		--name redhawk-sdrroot-fs \
		redhawk/minimal \
		/bin/true
	@touch $@

stamps/redhawk-ossiehome-fs.stamp: stamps/minimal-prep.stamp
	docker create \
		-v /opt/redhawk/core \
		--name redhawk-ossiehome-fs \
		redhawk/minimal \
		/bin/true
	@touch $@

stamps/minimal.stamp: stamps/redhawk-sdrroot-fs.stamp stamps/redhawk-ossiehome-fs.stamp
	@touch $@

.PHONY: minimal
minimal: stamps/minimal.stamp

##
# Component installation
##
.PHONY: check-component-var
check-component-var:
ifndef RH_COMPONENT
	$(error RH_COMPONENT should be set to the absolute path of your Component)
endif

stamps/component-installer-image.stamp: stamps/minimal.stamp component-installer/Dockerfile
	docker build --rm \
		-f component-installer/Dockerfile \
		-t redhawk/component-installer \
		component-installer
	@touch $@

.PHONY: component-installer
component-installer: stamps/component-installer-image.stamp check-component-var
	./component-installer/run-install.sh

##
# Test environment -- This is similar to the prefix the host REDHAWK GPP will 
# use except for the following which are omitted here:
# 
#   --sig-proxy=true
#   -v <preferred omniORB.cfg>:/etc/omniORB.cfg
# 
# The first binds OS signals to the container allowing the GPP to control the 
# process lifecycle like normal, the second is the means for tweaking the 
# internal-to-external OmniORB configuration.
##
.PHONY: test
test: stamps/minimal.stamp
	docker run \
		-it \
		--rm \
		--net=host \
		--name TEST_RUN \
		--volumes-from redhawk-sdrroot-fs \
		redhawk/minimal
	@echo "Finished"

##
# Cleaning
##
clean-containers:
	@docker ps -a -q --filter=ancestor=redhawk/* | xargs -I {} docker rm {}

clean-volume-containers: clean-containers
	@docker rm \
		redhawk-sdrroot-fs \
		redhawk-ossiehome-fs || true

clean-images: clean-volume-containers
	@docker rmi \
		redhawk/component-installer \
		redhawk/builder \
		redhawk/build-deps \
		redhawk/minimal \
		redhawk/run-deps || true

clean-volumes: clean-images
	@docker volume rm `docker volume ls -q -f dangling=true` || true

clean:
	@sudo rm -rf minimal/redhawk-fs minimal/omnievents-fs
	@sudo rm -rf work
	@rm -rf stamps

distclean: clean-containers clean-volume-containers clean-images clean-volumes clean

.PHONY: \
	clean-containers \
	clean-volume-containers \
	clean-images \
	clean-volumes \
	clean \
	distclean
