
options(readr.read_lazy = TRUE)
investors <- read_csv("data/investors.csv")
investments <- read_csv("data/investments.csv")
funding_rounds <- read_csv("data/funding_rounds.csv")
funding_round_participants <- funding_rounds |>
  select(uuid, investor_count) |>
  left_join(select(investments, funding_round_uuid, investor_uuid, investor_name),
            by = c("uuid" = "funding_round_uuid")) |>
  group_by(uuid) |>
  summarize(investor_uuids = list(investor_uuid),
            investor_names = list(investor_name))
orgs <- read_csv("data/organizations.csv")


fa <- orgs |>
  select(category_list)

cats <- cloud_orgs |>
  mutate(category_list = str_split(category_list, ",")) |>
  select(org_uuid, category_list) |>
  unnest(category_list) |>
  distinct() |>
  mutate(value = TRUE) |>
  pivot_wider(names_from="category_list") |>
  mutate(across(where(is.logical), ~!is.na(.))) |>
  select(-org_uuid)

library(psych)

cats_n <- cats |>
  mutate(across(where(is.logical), as.numeric))

x <- fa(cats_n, nfactors = 30, fm = "minres") |>
  pluck(loadings) |>
  unclass() |>
  as.data.frame() |>
  rownames_to_column() |>
  as_tibble() |>
  arrange(desc(MR1))

first_fa <- read_csv("~/Downloads/fa.csv")


first_fa <- x |>
  pivot_longer(cols = -rowname, names_to = "factor", values_to = "loading") |>
  group_by(rowname) |>
  filter(abs(loading) == max(abs(loading)),
         abs(loading) >= 0.3)


second_fa <- fa(cats_n |> select(-c(first_fa$rowname)), nfactors = 30, fm = "minres") |>
  pluck(loadings) |>
  unclass() |>
  as.data.frame() |>
  rownames_to_column() |>
  as_tibble() |>
  arrange(desc(MR1))

second_fa<- second_fa |>
  pivot_longer(cols = -rowname, names_to = "factor", values_to = "loading") |>
  group_by(rowname) |>
  filter(abs(loading) == max(abs(loading)))


x <- fa.parallel(as.matrix(cats_n), n.obs=0, nfactors = 2)
x <- factanal(as.matrix(cats_n), factors = 2)
