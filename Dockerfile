FROM ubuntu_ecw

RUN apt install -y build-essential python3.6 git wget sqlite3 libsqlite3-0 libsqlite3-dev pkg-config

RUN cp -r /hexagon/ERDAS-ECW_JPEG_2000_SDK-5.4.0/Desktop_Read-Only /usr/local/hexagon
RUN rm -r /usr/local/hexagon/lib/x64
RUN mv /usr/local/hexagon/lib/newabi/x64 /usr/local/hexagon/lib/x64
RUN cp /usr/local/hexagon/lib/x64/release/libNCSEcw* /usr/local/lib
RUN ldconfig /usr/local/hexagoCMD

# define a directory for download and unpacked packages
ENV downloaddir=originals
ENV packagedir=packages
# define the installation directory; This needs to be outside of the root directory so that the latter can be deleted in the end.
# In case installdir is set to a location outside of /usr/*, the following installation commands do not need to be run with a
# dministration rights (sudo)
ENV installdir=/usr/local
ENV pythonlibdir=${installdir}/lib64/python3.6/site-packages

# the version of GDAL and its dependencies
ENV GDALVERSION=2.4.1

# these versions are not quite as important. If you use already installed them you might need to define their location
# for the configuration of GDAL
ENV geos_version=3.7.1
ENV proj_version=6.0.0

ADD download_deps.sh .
RUN bash -e download_deps.sh

ENV PATH=${installdir}/bin:$PATH
ENV LD_LIBRARY_PATH=${installdir}/lib:$LD_LIBRARY_PATH
ENV PYTHONPATH=${pythonlibdir}:$PYTHONPATH
ENV threads=4


########################################################################################################################
# install GEOS
RUN cd ${packagedir}/geos* && ./configure --prefix ${installdir} && make -j${threads} && make install

########################################################################################################################
# install PROJ
RUN cd ${packagedir}/proj* && ./configure --prefix ${installdir} && make -j${threads} && make install

########################################################################################################################
# install GDAL
# please check the output of configure to make sure that the GEOS and PROJ drivers are enabled
# otherwise you might need to define the locations of the packages
WORKDIR ${packagedir}/gdal-${GDALVERSION}
RUN ./configure --without-python --prefix ${installdir} \
            --with-geos=${installdir}/bin/geos-config \
            --with-static-proj4=${installdir} \
            --with-libz=internal --with-pcraster=internal \
            --with-png=internal --with-pcidsk=internal \
            --with-libtiff=internal --with-geotiff=internal \
            --with-jpeg=internal --with-gif=internal \
            --with-qhull=internal --with-libjson-c=internal \
            --with-ecw=/usr/local/hexagon

RUN make -j${threads}
RUN make install

## Check if it works
RUN gdalinfo --formats | grep ECW

RUN ln -s /usr/bin/python3.6 /usr/bin/python
RUN apt install -y python3-distutils python3-dev
RUN cd ./swig/python && PYTHON=python3.6 make -j${threads} && python3.6 setup.py install --prefix=${installdir}