##############################################################
# manual installation of pyroSAR dependencies
# GDAL, GEOS, PROJ, SpatiaLite
# John Truckenbrodt, Rhys Kidd 2017-2019
##############################################################
#!/usr/bin/env bash

export PATH=${installdir}/bin:$PATH
export LD_LIBRARY_PATH=${installdir}/lib:$LD_LIBRARY_PATH
export PYTHONPATH=${pythonlibdir}:$PYTHONPATH

for dir in ${downloaddir} ${packagedir} ${pythonlibdir}; do
    mkdir -p ${dir}
done
########################################################################################################################
# download GDAL and its dependencies

declare -a remotes=(
                "https://download.osgeo.org/gdal/$GDALVERSION/gdal-$GDALVERSION.tar.gz"
                "https://download.osgeo.org/geos/geos-$geos_version.tar.bz2"
                "https://download.osgeo.org/proj/proj-$proj_version.tar.gz"
                )

for package in "${remotes[@]}"; do
    wget ${package} -P ${downloaddir}
done
########################################################################################################################
# unpack downloaded archives

for package in ${downloaddir}/*tar.gz; do
    tar xfvz ${package} -C ${packagedir}
done
for package in ${downloaddir}/*tar.bz2; do
    tar xfvj ${package} -C ${packagedir}
done