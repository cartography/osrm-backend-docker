# Railway profiles

The railway-profiles are based on OSM-attributes described in http://wiki.openstreetmap.org/wiki/Key:railway

The profiles are specifically designed to only calculate geometry between stops on a single railway-type at a time. OSRM only supports a single profile at a time - thus we need separate profiles for each type.

To enable a railway-type, we configure the speed-attribute for that specific type, and set the other types to '0'. OSM railway-types may be added if necessary.

´´´
speed_profile = {
  ["default"] = 0,
  ["subway"] = 0,
  ["tram"] = 50,
  ["rail"] = 0
}
´´´

Example: to create a profile for monorail (http://wiki.openstreetmap.org/wiki/Tag:railway%3Dmonorail) - copy railway.lua, and alter value for speed_profile to

´´´
speed_profile = {
  ["default"] = 0,
  ["monorail"] = 50
}
´´´
