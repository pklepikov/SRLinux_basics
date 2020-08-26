#! /bin/bash

# Copy the SRL inmage X.Y.Z-N.tar.xz file into Project directory on Centos 8 Host Machine.
    # TBD 

# Copy the license.key into Project directory.
    # TBD

# Load the docker image. 
#    - To load the image, the user must have root privilege, or be part of the docker group.
    docker image load -i 20.6.1-286.tar.xz

# Turn off the Docker0 Tx checksum offload:
    ethtool --offload docker0 tx off
