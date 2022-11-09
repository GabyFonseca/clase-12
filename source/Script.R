
ggplot(data = bog ) + geom_sf()

bog$variable = runif(135,10,50) %>% round() 


ggplot(data = bog , aes(fill=variable)) + geom_sf()


ggplot(data = bog , aes(fill=variable)) + geom_sf() + 
  scale_fill_viridis_b()

map = ggplot(data = bog , aes(fill=variable)) + geom_sf() + 
      scale_fill_viridis_b(option = "A")
map

map = map + scalebar(data = bog , location = "bottomright" , 
                     dist = 5 , dist_unit = "km" , transform = T)

map

map = map + north(data = bog , location = "topleft")
map

map = map + theme_linedraw()
map

map = map + labs(x="" , y="" , fill="Dist. Uniforme")
map



osm_layer <- get_stamenmap(bbox = as.vector(getbb("Bogota Colombia")), 
                           maptype="toner", source="osm", zoom=13) 

map2 = ggmap(osm_layer) + 
       geom_sf(data=bog , aes(fill=variable) , alpha=0.3 , inherit.aes = F) +
       scale_fill_viridis_b(option = "A") + 
       scalebar(data = bog , location = "bottomright" , 
                     dist = 5 , dist_unit = "km" , transform = T) + 
      north(data = bog , location = "topleft")  + theme_linedraw()+ 
      labs(x="" , y="" , fill="Dist. Uniforme")
map2


  