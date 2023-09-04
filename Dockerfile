FROM apache/sedona

# Update and install build tools and Python
RUN apt-get update && \
    apt-get install -y build-essential cmake
# Install wget separately for debugging
RUN apt-get install -y wget

# Define the GDAL version here
ARG GDAL_VERSION=3.7.1

WORKDIR /home

# Download GDAL
RUN wget http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz

# Unzip and build GDAL with specific drivers enabled, then remove the tar file
RUN tar -xzvf gdal-${GDAL_VERSION}.tar.gz && \
    cd gdal-${GDAL_VERSION} && \
    mkdir build && \
    cd build && \
    cmake .. -DOGR_ENABLE_DRIVER_GeoParquet=ON && \
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
