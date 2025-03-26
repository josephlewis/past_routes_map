library(leaflet)
library(htmlwidgets)
library(sf)
library(dplyr)

# List all shapefiles and geopackage files in the .Data/ folder
shapefiles <- list.files("./Data/", pattern = "\\.(shp|gpkg)$", full.names = TRUE, recursive = TRUE)

# Read all files into a list
shapes <- lapply(shapefiles, st_read)

for(i in 1:length(shapes)) { 
  
  shapes[[i]] <- sf::st_transform(shapes[[i]], crs = sf::st_crs(4326))
  
}

combined_shapes <- do.call(rbind, shapes)

# Create Leaflet Map
map <- leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolylines(data = combined_shapes, color = "black", weight = 2.5, opacity = 1)
saveWidget(map, file="index.html")