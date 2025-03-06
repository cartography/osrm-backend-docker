# OSRM API
This project uses [osrm-backend](https://github.com/Project-OSRM/osrm-backend) project.
Open Source Routing Machine (OSRM) Docker Image [GitHub Container Registry](https://github.com/project-osrm/osrm-backend/pkgs/container/osrm-backend)

## Profiles

The `profiles` folder contains custom profile code that is copied into the docker image. That is
the only addition to the upstream image. See `profiles/README.md` from more information.

## Architecture

### Docker build

This project builds a custom docker image with the upstream osrm-backend image as a base
and copies the custom profiles into it as mentioned above. This custom image is then used
in both the CronJobs (for building the osrm data) and for the main deployments.

### Data pipeline and redeploy

This project uses Kubernetes CronJobs with init containers to build the OSRM data / graph. The
job ends with a redeployment of the main services.

There are three CronJobs, each corresponding to a main deployment servicing a specific profile: 

- bus
- rail
- water (ferry)

Each CronJob runs the following init containers in sequence:

1. Download OSM data (protobuf file) from a GCP bucket
2. Run osrm-extract (with our custom docker image) with a specific profile and the OSM data as input
3. Run osrm-contract (with our custom docker image) on the output of the previous step
4. Copy the output (osrm data) to a GCP bucket

The main contanier of the CronJob then finishes the pipeline by triggering a redeploy
of the main service.

### Main routing service (deployment)

The main deployment has its own init container which downloads the osrm data uploaded by
step 4 in the CronJob pipeline as described above.

The main container then simply runs `osrm-routed`  (with our custom docker image) 
with the downloaded data as input.

## Running locally

You can modify profile code locally and test it as follows:

1. After you changed some profile code (say `profiles/bus.lua`), run 
   `docker build -t osrm .`
2. Make sure you have an OSM protobuf file for the area you are interested in. Let's assume
    you have a `data/` folder that contains this file. Assume it is called `norway.osm.pbf`.
3. Run `osrm-extract` like this:
   `docker run -t -v "${PWD}/data:/data" osrm osrm-extract -p /opt/bus.lua /data/norway.osm.pbf`
4. Run `osrm-contract` like this:
   `docker run -t -v "${PWD}/data:/data" osrm osrm-contract  /data/norway.osrm`
5. Finally you can run the routing service itself, using this data:
   `docker run -t -i -p 5001:5000 -v "${PWD}/data:/data" osrm osrm-routed  /data/norway.osrm`

The OSRM routing service is now available on "http://localhost:5000".

You can use `osrm-frontend` to test it:

    docker run -p 9966:9966 -e OSRM_BACKEND=http://localhost:5001 osrm/osrm-frontend

Please note that in this example I have used port 5001 on the host machine. This is because
on recent versions of macOS, port 5000 is reserved the AirTunes.
