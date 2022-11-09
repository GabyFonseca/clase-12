## Eduard Martinez
## Update: 

## llamar pacman (contiene la función p_load)
require(pacman)

## llamar y/o instalar librerias
p_load(tidyverse,rio,skimr,
       ggmap,
       sf, ## datos espaciales
       leaflet, ## visualizaciones
       tmaptools, ## geocodificar
       ggsn, ## map scale bar 
       osmdata) ## packages with census data

### **Geocodificar direcciones**
geocode_OSM("Casa de Nariño, Bogotá")

casa_narino = geocode_OSM("Casa de Narino, Bogota",as.sf=T)

leaflet() %>% addTiles() %>% addCircles(data=casa_narino)

cbd <- geocode_OSM("Centro Internacional, Bogotá", as.sf=T) 
cbd
leaflet() %>% addTiles() %>% addCircles(data=cbd)


#### **4.3.1. Features disponibles**

available_features() %>% head(20)

available_tags("boundary") 

### **4.4. Descargar features**
  
##OSM para Santa Marta
getbb("SAnta Marta, Colombia")
opq(bbox = getbb("Santa Marta, Colombia"))


## Objeto osm
osm = opq(bbox = getbb("Santa Marta, Colombia")) %>%
      add_osm_feature(key="amenity" , value="restaurant") 
class(osm)

osm_sf = osm %>% osmdata_sf()
osm_sf

restaurants = osm_sf$osm_points
leaflet() %>% addTiles() %>% addCircleMarkers(data=restaurants)




## Pintar las estaciones de autobus
leaflet() %>% addTiles() %>% addCircleMarkers(data=bus_station , col="red")

## **[5.] Operaciones geometricas**

### **5.1 Importar conjuntos de datos**

## my_house
my_house <- geocode_OSM("Calle 26 %23% 4-29, Bogotá", as.sf=T) 
my_house

## parques
parques <- opq(bbox = getbb("Bogota Colombia")) %>%
           add_osm_feature(key = "leisure", value = "park") %>%
           osmdata_sf() %>% .$osm_polygons %>% select(osm_id,name)

leaflet() %>% addTiles() %>% addPolygons(data=parques)

### **5.2 help:** `sf`

## Help
vignette("sf3")
vignette("sf4")

  ### **5.3 Afine transformations**
  
st_crs(my_house) == st_crs(parques) 

  ### **5.4 Filtrar datos**
  
## usando la geometría
chapinero <- getbb(place_name = "UPZ Chapinero, Bogota", 
                   featuretype = "boundary:administrative", 
                   format_out = "sf_polygon") %>% .$multipolygon

leaflet() %>% addTiles() %>% addPolygons(data=chapinero)

## crop puntos con poligono (opcion 2)
parques_chapi <- st_intersection(x = parques , y = chapinero)

leaflet() %>% addTiles() %>% addPolygons(data=chapinero,col="red") %>% addCircles(data=parques_chapi)

## crop puntos con poligono (opcion 3)
parques_chapi <- parques[chapinero,]

leaflet() %>% addTiles() %>% addPolygons(data=chapinero,col="red") %>% addCircles(data=parques_chapi)

  ### **5.5. Distancia a amenities**
  
## Distancia a un punto
my_house$dist_cbd <- st_distance(x=my_house , y=cbd)

my_house$dist_cbd %>% head()

## Distancia a muchos puntos
matrix_dist_bus <- st_distance(x=my_house , y=bus_station)

matrix_dist_bus[1:5,1:5]

min_dist_bus <- apply(matrix_dist_bus , 1 , min)

min_dist_bus %>% head()

my_house$dist_buse = min_dist_bus

## Distancia a muchos polygonos
matrix_dist_parque <- st_distance(x=my_house , y=parques)

matrix_dist_parque[1:5,1:5]

mean_dist_parque <- apply(matrix_dist_parque , 1 , mean)

mean_dist_parque %>% head()

my_house$dist_parque = mean_dist_parque

  ## **[6.] Visualizaciones**
  
## get Bogota-UPZ 
bog <- opq(bbox = getbb("Bogota Colombia")) %>%
       add_osm_feature(key="boundary", value="administrative") %>% 
       osmdata_sf()
bog <- bog$osm_multipolygons %>% subset(admin_level==9)

bog <- export(bog,"output/bog_upz.rds")

## basic plot
ggplot() + geom_sf(data=bog)

## plot variable
bog$normal <- rnorm(nrow(bog),100,10)
ggplot() + geom_sf(data=bog , aes(fill=normal))

## plot variable + scale
map <- ggplot() + geom_sf(data=bog , aes(fill=normal)) +
  scale_fill_viridis(option = "A" , name = "Variable")
map 

## add scale_bar
map <- map +
  scalebar(data = bog , dist = 5 , transform = T , dist_unit = "km") +
  north(data = bog , location = "topleft")
map 

## add theme
map <- map + theme_linedraw() + labs(x="" , y="")
map

## add osm layer
osm_layer <- get_stamenmap(bbox = as.vector(st_bbox(bog)), 
                           maptype="toner", source="osm", zoom=13) 

map2 <- ggmap(osm_layer) + 
  geom_sf(data=bog , aes(fill=normal) , alpha=0.3 , inherit.aes=F) +
  scale_fill_viridis(option = "D" , name = "Variable") +
  scalebar(data = bog , dist = 5 , transform = T , dist_unit = "km") +
  north(data = bog , location = "topleft") + theme_linedraw() + labs(x="" , y="")
map2
