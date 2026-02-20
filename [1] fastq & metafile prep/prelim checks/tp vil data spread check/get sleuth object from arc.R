.libPaths("/home/varuna.jayasinghe/R/x86_64-pc-linux-gnu-library/4.3")
setwd("/work/giembycz_lab/B2B_tbv_analysis/")

library(dplyr)
library(readr)
library(sleuth)

meta <- read_tsv("meta.txt") %>%
  select(sample = Sample, path = Path, treatment = Treatment, rep = rep) %>%
  mutate(treatment = gsub("Vilanterol", "Vil", treatment)) %>%
  filter(treatment %in% c("NS", "Vil")) %>%
  mutate(treatment = factor(treatment, levels = c("NS", "Vil")))

t2g <- read_tsv("/work/giembycz_lab/ag_tools/Homo_sapiens.GRCh38.p13.cdna.all.070121.mart_export.txt") %>%
  select(target_id = 1, Gene = 2, gene_id = 4) %>% 
  distinct(target_id, gene_id, .keep_all = T) %>%
  na.omit()

new_filter <- function(row, min_reads = 5, min_prop = 0.2){mean(row >= min_reads) >= min_prop}

so <- sleuth_prep(sample_to_covariates = meta,
                  target_mapping = t2g,
                  gene_mode = TRUE, 
                  aggregation_column = "Gene",
                  filter_fun = new_filter,
                  num_cores = 1
                  )

write_rds(so, "alex_vil_spread_check.R")

print("done")