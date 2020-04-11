library(dplyr)
library(igraph)

get_null_df_and_metrics <-function(df) {
  # select origin, dest, flights, make flights = to weight
  air_df = df %>% select(ORIGIN, DEST) %>% rename(from = ORIGIN, to = DEST)
  
  # select unweighted or weighted 
  #weighted_df <- (df %>% select(ORIGIN, DEST, flights) %>% 
  #                                    rename(from = ORIGIN, to = DEST, weight = flights))
  #weighted_g <- graph.data.frame(weighted_df, directed = TRUE)
  #g <- weighted_g
  
  unweighted_g <- graph_from_edgelist(df %>% select(ORIGIN, DEST) %>% as.matrix())
  g <- unweighted_g
  
  # get metrics of observed network
  observed_deg <- (degree(g, mode = "all"))
  observed_betweenness <- (betweenness(g))
  
  # get random network params
  numb_edges <- length(E(g))
  numb_vertices <-length(V(g))
  sum_weight <- sum(weighted_df$weight) # attempt to make rand grapgh with edges == total weight
  p_edges <- (numb_edges/(numb_vertices*(numb_vertices-1)))
  
  # make random network
  rand_g <- sample_gnp(n=numb_vertices, p=p_edges, directed=TRUE) %>%
    set_vertex_attr("label", value = V(g))
  V(rand_g)$name <- V(g)$name # name random network vertices same as original graphs
  
  # get metrics from random network
  rand_betweenness = (betweenness(rand_g))
  rand_deg <- (degree(rand_g, mode='all'))
  
  # make random g into a df
  rand_df <- as_data_frame(rand_g)
  names(rand_df) <- c('ORIGIN', 'DEST') # used for joining back to original coordinates
  # get the lat and longs
  original_origins <- select(df, c(ORIGIN, origin_lat, origin_lon))
  original_dests <- select(df, c(DEST, dest_lat, dest_lon))
  # combine random network nodes with lat/lons, dedupe
  rand_df_coords <- merge(rand_df, original_origins, by='ORIGIN', all.x=T)
  rand_df_coords <- merge(rand_df_coords, original_dests, by='DEST', all.x=T)
  rand_df_coords_deduped <-  rand_df_coords[!duplicated(rand_df_coords), ]
  
  # make a new df with all the stats for later use
  metrics_df <- data.frame(observed_betweenness, observed_deg, rand_betweenness, rand_deg)
  print(colMeans(metrics_df))
  return(list('rand_df' =rand_df_coords_deduped, 'metrics_df' = metrics_df))
}

# Make graphics for delta
results <- get_null_df_and_metrics(DL_2018)
dl_2018_rand_df <- results$rand_df
dl_2018_metrics <- results$metrics_df

hist(dl_2018_metrics$observed_betweenness, main="Observed Network, Delta 2018", col='blue',
     xlab="Betweenness of Each Node")
hist(dl_2018_metrics$rand_betweenness, main="Null Model, Delta 2018 ", col='blue',
     xlab="Betweenness of Each Node")

# Experimentation with random weights for the weighted graph
#dl_2018_rand_df$flights <- sample(1:5,nrow(dl_2018_rand_df),replace=TRUE)
#DL_2018$flights <- sample(1:5,nrow(DL_2018),replace=TRUE)
# use plot network function from "Data_Pipeline_with_maps"
plot_network_unweighted(df_map=dl_2018_rand_df, map_title="Null Model, Delta 2018", point_color='blue')
plot_network_unweighted(df_map=DL_2018, map_title='Delta in 2018, Unweighted', point_color='blue')

# Southwest
results <- get_null_df_and_metrics(WN_2018)
wn_2018_rand_df <- results$rand_df
wn_2018_metrics <- results$metrics_df

hist(wn_2018_metrics$observed_betweenness, main="Observed Network, Southwest 2018", col='gold',
     xlab="Betweenness of Each Node")
hist(wn_2018_metrics$rand_betweenness, main="Null Model, Southwest 2018 ", col='gold',
     xlab="Betweenness of Each Node")

# Experimentation with random weights for the weighted graph
#wn_2018_rand_df$flights <- sample(1:5,nrow(wn_2018_rand_df),replace=TRUE)
#WN_2018$flights <- sample(1:5,nrow(WN_2018),replace=TRUE)
# use plot network function from "Data_Pipeline_with_maps"
plot_network_unweighted(df_map=wn_2018_rand_df, map_title="Null Model, Southwest 2018", point_color='gold')
plot_network_unweighted(df_map=WN_2018, map_title='Southwest in 2018, Unweighted', point_color='gold')

