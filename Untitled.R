
devtools::load_all()


update_edgelist()

tg <- read_csv("data/tangled.csv")

c(tg %>% pull(from),
          tg %>% pull(to)) %>% unique() %>% sort() %>% View


