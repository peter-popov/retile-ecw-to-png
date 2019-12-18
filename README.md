Retile settelite images from [ECW](https://en.wikipedia.org/wiki/ECW_(file_format)) to PNG
====================

This repository contains set of tools which I have used to convert berlin satelite into PNG tiles.

You can find input data here(please check the licence): 
 - [Digitale farbige Orthophotos 2019 (DOP20RGB)](https://fbinter.stadt-berlin.de/fb/?loginkey=showMap&mapId=k_luftbild2019_rgb@senstadt)

My goal was to obtain standard [slippy tiles](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames). I used docker to provide reproducible resuls.

Build base docker image
------------------
ECW is proprietary format. Luckuly, a read-only SDK is avalible free of charge. But we need to manually install it and accept the license (I cound not find a way to run an interactive script when building docker container).

**First**, download the sdk from [Hexagon](https://www.hexagongeospatial.com/en). At the moment of writing the latest version was [ERDAS ECW/JP2 SDK v5.4](https://download.hexagongeospatial.com/en/downloads/ecw/erdas-ecw-jp2-sdk-v5-4). Please place *erdas-ecw-sdk-5.4.0-linux.zip* in the root of this project. Name of the file hardcoded, so if you use a different version please modify [Dockerfile_base_ecw](Dockerfile_base_ecw#L9)) 

**Second**, build a base docker image:

    ➜ docker build -t ubuntu_ecw -f Dockerfile_base_ecw .

**Then**, run the image and follow the installations steps.

    ➜ docker run -it ubuntu_ecw

You will see something like this:
```console
    ERDAS ECW JPEG2000 SDK 5.4.0 Install
    ************************************


    Please select the appropriate license type to deploy ... 

    No License Fee Required 
    ******************************** 
    Enter 1 for "Desktop Read-Only Redistributable"
    Enter 2 for "Mobile Read-Only (Local decoding restriction apply)"

    Paid Licensees 
    ******************************** 
    Enter 3 for "Desktop Read-Write Redistributable"
    Enter 4 for "Server Read-Only End User"
    Enter 5 for "Server Read-Only Redistributable"
    Enter 6 for "Server Read-Write Redistributable"
    
    [1, 2, 3, 4, 5, or 6]
```
Choose option 1, read and accept the licince and finish the installation. After this we need to commit the installation results to the docker image so that we can use it aftrewards. Do the following:

    ➜ docker commit `docker ps -a --filter "ancestor=ubuntu_ecw" --filter "status=exited" --format "{{.ID}}" -n=1` ubuntu_ecw

If the above does not work you can try a step by step option. For exampe:

    ➜ docker ps -a --filter "ancestor=ubuntu_ecw" --format "{{.ID}}: {{.Image}} {{.Command}} {{.CreatedAt}}"

You should see id of the just exsited container:

    f2835e9552bc: ubuntu_ecw "./ERDAS_ECWJP2_SDK-…" 2019-12-16 17:08:57 +0100 CET

Commit it with the following command:

    ➜ docker commit f2835e9552bc ubuntu_ecw

Build the main docker image
------------------

Now the base image is ready we can build the main image. The most important step is to build a [GDAL library with ECW support](https://trac.osgeo.org/gdal/wiki/ECW). Docker makes it easy, but it still takes some time:

    ➜ docker built -t ubnutu_ecw_gdal .

Retiling
------------------

Run newly built docker container:

    ➜ docker run -it ubnutu_ecw_gdal bash

(TODO: mount data volume)

Inside the container (TODO: obtaining the vrt):

    ➜ root@d2057a62c34b:/data# gdal2tiles.py --profile=mercator --processes=6 -r bilinear -e -z 5-19 berlin.vrt berlin_tiles_hd/

