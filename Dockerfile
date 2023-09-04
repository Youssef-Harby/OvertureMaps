FROM apache/sedona

# Update and install build tools and Python
RUN apt-get update && \
    apt-get install -y build-essential cmake libboost-all-dev

# Install wget separately for debugging
RUN apt-get install -y wget

# Define the GDAL version here
ARG GDAL_VERSION=3.7.1

# Install Apache Arrow
RUN apt-get install -y -V ca-certificates lsb-release wget
RUN wget https://apache.jfrog.io/artifactory/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb
RUN apt-get install -y -V ./apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb
RUN apt-get update
RUN apt-get install -y -V libarrow-dev libparquet-dev

WORKDIR /home

# Download GDAL
RUN wget http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz

# Unzip and build GDAL with specific drivers enabled, then remove the tar file
RUN tar -xzvf gdal-${GDAL_VERSION}.tar.gz && \
    cd gdal-${GDAL_VERSION} && \
    mkdir build && \
    cd build && \
    cmake .. -UGDAL_ENABLE_DRIVER_* -UOGR_ENABLE_DRIVER_* -DGDAL_USE_ARROW=ON -DGDAL_ENABLE_PLUGINS:BOOL=ON -DGDAL_USE_PARQUET=ON && \
    cmake --build . && \
    cmake --build . --target install && \
    cd /home && \
    rm gdal-${GDAL_VERSION}.tar.gz

# Update environment variables
ENV PATH="/home/gdal-${GDAL_VERSION}/build:${PATH}"
ENV LD_LIBRARY_PATH="/home/gdal-${GDAL_VERSION}/build:${LD_LIBRARY_PATH}"

# Update shared library cache
RUN ldconfig

# Install Python GDAL package
RUN pip3 install GDAL==3.7.1.1
