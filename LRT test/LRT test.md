ssh alex.gao1@arc.ucalgary.ca

mkdir -p /home/alex.gao1/sandbox/agonistType_LRT_test/
cd /home/alex.gao1/sandbox/agonistType_LRT_test/

salloc -c 4 --mem 64GB -t 05:00:00

module load R/4.4.1

R

```R SETUP
.libPaths("/home/alex.gao1/R")
setwd("/home/alex.gao1/sandbox/agonistType_LRT_test")

library(dplyr)
library(readr)
library(sleuth)

meta = read_tsv("meta.txt") %>% 
    mutate(treatment = factor(treatment, levels = c("NS", "LABA")),
           laba_type = factor(laba_type)) %>%
    mutate(sample = paste(laba_type, treatment, rep, sep = "_"), .before = 1)

meta_budInsert = read_tsv("meta_budInsert.txt") %>% 
    mutate(treatment = factor(treatment, levels = c("NS", "LABA")),
           laba_type = factor(laba_type)) %>%
    mutate(sample = paste(laba_type, treatment, rep, sep = "_"), .before = 1)

t2g = read_tsv("/work/giembycz_lab/ag_tools/Homo_sapiens.GRCh38.p13.cdna.all.070121.mart_export.txt") %>%
  select(target_id = 1, Gene = 2) %>%
  na.omit() %>% 
  distinct()
t2g <- t2g[!duplicated(t2g$target_id), ]

new_filter <- function(row, min_reads = 5, min_prop = 0.2){mean(row >= min_reads) >= min_prop}
```

```R CREATE SLEUTH OBJECTS
so = sleuth_prep(
    sample_to_covariates = meta,
    target_mapping = t2g,
    gene_mode = TRUE,
    aggregation_column = "Gene",
    filter_fun = new_filter,
    num_cores = 4
)
saveRDS(so, "so.rds")

so_budInsert = sleuth_prep(
    sample_to_covariates = meta_budInsert,
    target_mapping = t2g,
    gene_mode = TRUE,
    aggregation_column = "Gene",
    filter_fun = new_filter,
    num_cores = 4
)
saveRDS(so_budInsert, "so_budInsert.rds")
```

```R MODELLING
so = sleuth_fit(so, ~ laba_type * treatment, "full")
so = sleuth_fit(so, ~ laba_type + treatment, "reduced")
so = sleuth_lrt(so, "reduced", "full")
so_results = sleuth_results(so, "reduced:full", test_type = "lrt") %>%
    select(Gene = target_id, FDR = qval)

so_budInsert = sleuth_fit(so_budInsert, ~ laba_type * treatment, "full")
so_budInsert = sleuth_fit(so_budInsert, ~ laba_type + treatment, "reduced")
so_budInsert = sleuth_lrt(so_budInsert, "reduced", "full")
so_budInsert_results = sleuth_results(so_budInsert, "reduced:full", test_type = "lrt") %>%
    select(Gene = target_id, FDR = qval)

write_tsv(so_results, "laba_type_LRT.txt")
write_tsv(so_budInsert_results, "laba_type_LRT_budInsert.txt")


```