library(leaflet)
library(htmlwidgets)
library(sf)
library(dplyr)

# List all shapefiles and geopackage files in the ./Data/ folder
shapefiles <- list.files("./Data/", pattern = "\\.(shp|gpkg)$", full.names = TRUE, recursive = TRUE)

# Define layer names (adjust these manually to match your files)
layer_names <- c("Bronze and Iron Age hollow ways, Khabur Valley, Mesopotamia", "Qhapaq Ñan - Camino Inca", "Roman roads in Wales")
layer_names_text <- c("Priß, D., Wainwright, J., Lawrence, D., Turnbull, L., Prell, C., Karittevlis, C., Ioannides, A.A., 2025. Filling the Gaps—Computational Approaches to Incomplete Archaeological Networks. J Archaeol Method Theory 32, 19. https://doi.org/10.1007/s10816-024-09688-z", "www.geogpsperu.com", "Burnham, B.C., Davies, J.L. (Eds.), 2010. Roman Frontiers in Wales and the Marches. Royal Commission on the Ancient and Historical Monuments of Wales, Aberystwyth. Digitised by Joseph Lewis")

shapes <- list()

# Read and transform all shapefiles into a list
for(i in 1:length(shapefiles)) {
  shapes[[i]] <- st_read(shapefiles[i])
  if(i == 1) { 
    sf::st_crs(shapes[[i]]) <- sf::st_crs(32637)
    }
  shapes[[i]] <- sf::st_make_valid(shapes[[i]])
  shapes[[i]] <- sf::st_cast(shapes[[i]], "LINESTRING")
  shapes[[i]] <- st_transform(shapes[[i]], crs = st_crs(4326))
  sf::st_geometry(shapes[[i]]) <- "geometry"
  shapes[[i]]$layer_names_text <- layer_names_text[i]
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
                 group = layer_names[i],
                 popup = ~layer_names_text)
}

# Add layer control
map <- map %>%
  addLayersControl(
    overlayGroups = layer_names,
    options = layersControlOptions(collapsed = FALSE)
  )

saveWidget(map, file="index.html")