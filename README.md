# docker-osrm
Open Source Routing Machine (OSRM) Docker Image [\[Docker Hub\]](https://hub.docker.com/r/cartography/osrm-backend-docker/)

## Installation

1. Install [Docker](https://www.docker.com/)

2. Manual deploy (optional):
  * Pull automated build from Docker Hub  
  ```$ docker pull cartography/osrm-backend-docker```
  * or build from GitHub  
  ```$ docker build -t="cartography/osrm-backend-docker" github.com/cartography/osrm-backend-docker```
  * or you can clone & build :)  
  ```
  $ git clone https://github.com/cartography/osrm-backend-docker.git  
  $ docker build -t="cartography/osrm-backend-docker" osrm-backend-docker/
  ```

## Usage
Run it:  
```docker run -d -p 5000:5000 cartography/osrm-backend-docker:latest osrm label "http://your/path/to/data.osm.pbf"```  

Explanation:  
```-d -> Run container in background and print container ID```  
```-p 5000:5000 -> Publish a container port to host```  
```osrm -> Go via entrypoint script, w/o osrm keyword - classic mode```  
```label -> Your label of OSM data```  
```url -> Link to OSM data in PBF format```  

For example:  
```docker run -d -p 5000:5000 cartography/osrm-backend-docker:latest osrm California "http://download.geofabrik.de/north-america/us/california-latest.osm.pbf"```
