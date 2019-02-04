library(tidygraph)
library(ggraph)
library(ggthemes)


get_local_plot <- function(graph, the_layout, node_name) {

  my_pal <- get_palette(graph)
  the_edge_types <-
    graph %>% activate(edges) %>% pull(e_type) %>% factor() %>% levels()
  
  my_edge_pal <- c("#C0C0C0", "#FFA500", "#00B300", "#FF0000", few_pal("Dark")(8))


  ggraph(the_layout) +
    geom_edge_fan(
      aes(
        linetype = e_type,
        color = e_type,
        label = note
      ),
      edge_width = .65,
      end_cap = circle(3, "mm"),
      spread = 3,
      start_cap = circle(3, "mm"),
      label_dodge = unit(2, "mm"),
      label_size = 3,
      arrow = arrow(type = "closed", length = unit(1.25, "mm"))
    ) +
    scale_edge_linetype_manual(guide = "none", values = c(5, rep(1, length(the_edge_types) -
                                                                   1))) +
    scale_edge_colour_manual(name = "Relationship",
                            values = my_edge_pal) +
    geom_node_point(color = "black", size = 4.5) +
    geom_node_point(aes(colour = group_label), size = 3.5) + geom_node_point(color = "white", size = 1) +
    geom_node_label(
      aes(label = name),
      size = 4,
      repel = TRUE,
      alpha = 0.75,
      show.legend = FALSE
    ) +
    scale_color_manual(name = "Community", values = my_pal) +
    ggthemes::theme_few() +
    theme(
      panel.border = element_blank(),
      axis.ticks = element_blank(),
      axis.text = element_blank(),
      axis.title = element_blank()
    ) +
    labs(
      title = paste0("The ", node_name, " Tangled Web"),
      caption = paste(now("UTC"), "http://schnee.world:81/myapps/tangler", sep =
                        '\n')
    )

}
