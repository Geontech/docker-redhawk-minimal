# Docker REDHAWK Minimal

This project creates a minimal installation of REDHAWK SDR in an Ubuntu 16.04 Docker Image with an external volume for SDRROOT.  The external volume facilitates adding and removing Components without modifying the base image.  The overarching purpose of these is to facilitate having an external, modified GPP execute Components within the resulting Docker Container ([found here](https://github.com/GeonTech/core-framework)).  This allows the Component to interface with other installed frameworks, etc., within that image.

> Note: It is up to the integrator to extend the minimal image with their own additional dependencies, etc., for their intended integration.  This image is only REDHAWK SDR, no GPP.

## Component Requirements

The following are two new properties for REDHAWK Components that will be launchable with the modified GPP:

|ID|Required|Description|
|---|---|---|
| `__DOCKER_IMAGE__` | YES | Specifies the Docker image name, e.g., `my_image:tag`.|
| `__DOCKER_ARGS__` | NO | Allows for additional arguments to be passed on the command line to Docker, e.g., `--volumes-from my-filesystem -v something:/else` |

> Note: These IDs look a little strange compared to typical property IDs.  The `__DOCKER_IMAGE__` ID was chosen for a potential familiarity since it exists in the Application Factory implementation source code (but no where else) in the core-framework.  The `__DOCKER_ARGS__` was therefore chosen for no other reason but to look similar to `__DOCKER_IMAGE__`.  

## Host Domain Requirements

The host REDHAWK Domain must be running Docker and have the [modified](https://github.com/GeonTech/core-framework) GPP installed in place of the standard REDHAWK one.  It's a fork, so its base capabilities are the same as the standard one.  It has been extended to recognize the above property IDs and prefix a string of docker arguments ahead of the standard Component executable arguments.  

The result is the GPP will launch and manage a Docker container of the Component rather than locally launching the Component.  All CORBA connections, etc., will be handled automatically via REDHAWK, leaving the Component designer to manage their own needs.  The full command issued by the GPP becomes:

    docker run --sig-proxy=true --rm --net=host \
        --name COMPONENT_ID_COLON_IS_HYPHEN \
        -v docker_omniorb_cfg:/etc/omniORB.cfg \
        __DOCKER_ARGS__ \
        __DOCKER_IMAGE__ \
        ./component/NAME/IMPL/EXEC \
        OTHER_TYPICAL_REDHAWK_ARGUMENTS

The `docker_omniorb_cfg` property on the GPP allows you to configure the OmniORB instance within the launched containers to use a different IP than local host for the OmniORB connection.

> **Security Note:** By default, it is set to `/etc/omniORB.cfg`, so you may wish to change this property for security reasons.  It should be set to the absolute path in your file system.

## Setup

The following integration was performed on CentOS 7 64-bit.  

    make

The build process will run through several images to establish the `redhawk/minimal` image and `redhawk-sdrroot-fs` volume.  Effort has been taken to ensure that build dependencies of REDHAWK are handled in a separate image to avoid inflating the image size unnecessarily.

### Build Process Explained

The build process will generate the `redhawk/run-deps` runtime dependencies based off Ubuntu 16.04.  It then creates the `redhawk/build-deps` image which adds in development libraries, headers, etc. and source code for XSD 3.3.0, OmniEvents 2.7, and REDHAWK SDR 2.0.4.  Then the `redhawk/build` image is created to inject the build scripts (internal and external).  

At this point the external `builder/run-builder.sh` script runs the `redhawk/build` image and outputs the OmniEvents and REDHAWK products into the host OS.  Next, these two products are copied into the `redhawk/minimal` folder so that the `redhawk/minimal` image can be built, which uses the ADD command to pull those products into this new base image.  Finally, the `redhawk-sdrroot-fs` and `redhawk-ossiehome-fs` volumes are created, making the installation area of REDHAWK external to the image (in this case, `/opt/redhawk/sdr`).

### Proof of Life: REDHAWK

#### Very Basic

The first option is to use `make test` to run a container of `redhawk/minimal` with the SDRROOT mounted.  From there, you can run `nodeBooter -D` to see the default domain start.

#### Get the Popcorn

Another option is to manually boot the new `redhawk/minimal` image as a Domain in the host OS, if we have another system running Omni services (and prefereably, REDHAWK).  

Create an omniORB.cfg file that references that system's IP address and ensure ports are not blocked.  Then start a container of the image:

    docker run -it --rm --net=host \
        -v PATH_TO_YOUR_OMNIORB_CFG/omniORB.cfg:/etc/omniORB.cfg \
        --volumes-from redhawk-sdrroot-fs \
        redhawk/minimal \
        /bin/bash -l -c "nodeBooter -D --domainname REDHAWK_DOCKER"

Using the REDHAWK IDE, Explorer, or the Python interface on the host OS, you should be able to see a new domain: `REDHAWK_DOCKER`.

    >>> from ossie.utils import redhawk
    >>> redhawk.scan()
    ['REDHAWK_DOCKER']

Like any other REDHAWK Domain, you can have Device Managers join this Domain.

Press `CTRL+C` to quit the container and shut down this domain.

## Installing a New Component

There are two environment variables for using the `component-installer` make target.

| Name | Required | Description | Default |
| --- | --- | --- | --- |
| `RH_COMPONENT` | YES | The absolute path to the REDHAWK Component to install | NONE |
| `BASE_IMAGE` | NO | End user Docker image that inherits from `redhawk/component-installer` or provides its `WORKDIR`, `CMD`, and `install.sh` script | `redhawk/component-installer` |

The Component also needs to support the (presently) standard `./build.sh` script style where `distclean` fully cleans the project directory, and `./build.sh` builds all known implementations.  

For example, to perform the installation of the DockerComponent:

    make component-installer \
        RH_COMPONENT=${PWD}/example/DockerComponent

## Using a Component in a Waveform

One of the main reasons we went to this trouble is to have a Component with dependencies that are not available in the host OS (or are difficult to have, etc.).  This likely means being unable to compile the Component in the host OS.  The good news is you don't need to be able to compile it to use the Component in a Waveform.

To use a Component in a Waveform, copy the Component into the host system's `$SDRROOT/dom/components` folder.  In essence you're installing it _without compiling it_.  And since you don't need an executable in the host system, touch the file name for the implementation(s):

    cp -r SomeCppComponent $SDRROOT/dom/components
    cd $SDRROOT/dom/components/SomeCppComponent/cpp
    touch SomeCppComponent

This will let you reference the Component in a Waveform in the IDE and permit you to launch the Waveform even though the executable is invalid (in the host system).

> Note: For Python Components, there is no need to touch a file since the script is the executable.

## Next Steps

Take a moment to look in the `component-installer` directory.  Looking at the `run-install.sh`, you'll notice it runs the associated `redhawk/component-installer` image.  The Dockerfile for that image relies on the `redhawk/build-deps` image and mounts the already-built `redhawk-ossiehome-fs` and `redhawk-sdrroot-fs`.  This comprises a build environment suitable for compiling and installing REDHAWK Components (and other assets).  The runtime image (`redhawk/minimal`) only requires SDRROOT to be mounted unless OSSIEHOME has been modified by some other source.

Efforts to extend this build process, to insert new runtime and build dependencies, should inherit from the `redhawk/run-deps` and `redhawk/build-deps` images, respectively.  For the latter, any installation process requiring the OSSIEHOME or SDRROOT locations should also mount those volumes (e.g., `--volumes-from redhawk-ossiehome-fs`).
