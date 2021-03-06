library(readr)
library(ggraph)
library(dplyr)
library(tidygraph)
# library(networkD3)
library(ggthemes)
library(RColorBrewer)
library(scales)
library(lubridate)
#library(randomcoloR)

make_graph <- function(tangled) {

  tangled <- tangled %>% mutate(note = if_else(is.na(note), "",note))

  # attempt to roll up the payments
  money_types <- c("payment", "loan", "investment", "fine")
  tangled <- tangled %>% filter(e_type %in% money_types) %>%
    mutate(amt = as.numeric(note)) %>%
    group_by(from, to, e_type) %>%
    summarize(date = last(date),
              sum = sum(amt),
              note = if_else(is.na(sum), last(note), format(sum, scientific = F))
    ) %>% bind_rows(
      tangled %>% filter(!(e_type %in% money_types))
    )

  graph <- as_tbl_graph(tangled) %>% mutate(group = as.character(group_spinglass()))

  # the below few line will find the pagerank for all nodes, and use the
  # max pagerank as the group label
  g<-graph %>%
    mutate(centrality = centrality_pagerank()) %>% activate(nodes) %>%
    group_by(group) %>% mutate(g_max =  max(centrality))


  max_cent_df <- g %>% activate(nodes) %>% as_tibble() %>% group_by(group) %>% summarize(g_max = max(centrality))

  # the last summarize there handles ties
  max_cent <- g %>% activate(nodes) %>% as_tibble()%>%
    filter(centrality %in% max_cent_df$g_max)  %>%
    rename(group_label = name) %>% ungroup() %>%
    group_by(group) %>% arrange(g_max, desc(centrality), group_label) %>% summarize(group_label = first(group_label),
                                                                                    centrality = first(centrality),
                                                                                    g_max = first(g_max))

  graph <- g  %>% activate(nodes) %>%
    inner_join(max_cent, by = c("group" = "group",
                                "g_max" = "centrality")) %>%
    select(-g_max.y)  %>%
    mutate(n_tri = local_triangles())



  graph
}

weight_graph <- function(graph, in_group, out_group) {

  # for FR layouts, let's set an edge weight: in group = 2, out of group = 1
  get_group <- function(node, graph) {
    graph %>% activate(nodes) %>% as_tibble() %>% filter(row_number() == node) %>% pull(group) %>% as.numeric()
  }

  weights <- graph %>% activate(edges) %>% as_tibble() %>% rowwise() %>%
    mutate(the_group = if_else(get_group(to,graph) == get_group(from,graph),get_group(from,graph),NULL)) %>%
    group_by(the_group) %>% mutate(n=n()) %>% ungroup() %>%
    mutate(max_n = max(n), weight = if_else(!is.na(the_group), in_group, out_group)) %>% pull(weight)

  graph <- graph %>% activate(edges) %>% mutate(weight = weights)

  graph
}

get_palette <- function(graph) {
  # now handle some aesthetics
  n_group <-
    graph %>% activate(nodes) %>% pull(group) %>% n_distinct()
  
  base_pal <- c(
    "#3588d1",
    "#88cc1f",
    "#ab39f9",
    "#687f39",
    "#ee3597",
    "#12d388",
    "#6e1f1f",
    "#05aec0",
    "#f7393a",
    "#048a37",
    "#fc99d5",
    "#04451b",
    "#faa566",
    "#3f1ba1",
    "#9ac48a",
    "#a958ab",
    "#00d618",
    "#273b61",
    "#a06c32",
    "#2d6df9"
  )
  
  #distinctColorPalette(n_group, runTsne = TRUE)
  base_pal
}

build_graph <- function() {
  #tangled <- read_csv(here::here("data/tangled.csv"))
  #graph <- make_graph(tangled)
  readRDS(gzcon(url("https://github.com/schnee/tangled/raw/master/data/graph.RDS")))
}


get_local_graph <- function(graph, node_name, triangles, order = 2) {
  if(triangles){
    graph <- graph %>% filter(n_tri > 0)
  }
  node_id <-
    graph %>% activate(nodes) %>% mutate(node_id = row_number()) %>%
    filter(name == node_name) %>% pull(node_id)

  local_neighborhood <-
    graph %>% to_local_neighborhood(node = node_id, order)

  local_graph <- local_neighborhood$neighborhood
  local_graph
}

get_local_layout <- function(local_graph) {
  the_layout <- create_layout(local_graph, layout = "auto")
  the_layout
}

