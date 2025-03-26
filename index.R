library(leaflet)
library(htmlwidgets)
library(sf)
library(dplyr)

# List all shapefiles and geopackage files in the ./Data/ folder
shapefiles <- list.files("./Data/", pattern = "\\.(shp|gpkg)$", full.names = TRUE, recursive = TRUE)

# Define layer names (adjust these manually to match your files)
layer_names <- c("Qhapaq Ñan - Camino Inca  www.geogpsperu.com", "Roman roads in Wales")

shapes <- list()

# Read and transform all shapefiles into a list
for(i in 1:length(shapefiles)) {
  shapes[[i]] <- st_read(shapefiles[i])
  shapes[[i]] <- sf::st_make_valid(shapes[[i]])
  shapes[[i]] <- sf::st_cast(shapes[[i]], "LINESTRING")
  shapes[[i]] <- st_transform(shapes[[i]], crs = st_crs(4326))
  sf::st_geometry(shapes[[i]]) <- "geometry"
}

# Create Leaflet Map
map <- leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron)

# Add each shape as a separate layer
for (i in seq_along(shapes)) {
  map <- map %>%
    addPolylines(data = shapes[[i]], 
                 color = "black", 
                 weight = 1, 
                 opacity = 1, 
                 group = layer_names[i])
}

# Add layer control
map <- map %>%
  addLayersControl(
    overlayGroups = layer_names,
    options = layersControlOptions(collapsed = FALSE)
  )

saveWidget(map, file="index.html")

# combined_shapes <- do.call(rbind, shapes)
