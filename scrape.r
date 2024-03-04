library("pdftools")
library("tabulizer")
library("tidyverse")

pdf_file <- list.files("pdf")

txt <- pdf_data(paste0("pdf/", pdf_file), font_info = TRUE)

## Method default
tbls_1 <- extract_tables(paste0("pdf/", pdf_file))
tbls_2 <- extract_tables(paste0("pdf/", pdf_file), method = "lattice")
tbls_3 <- extract_tables(paste0("pdf/", pdf_file), method = "stream")

tbls_4 <- extract_tables(
    paste0("pdf/", pdf_file),
    # output = "csv",
    # outdir = "out",
    area = list(c(35, 41, 35 + 713, 41 + 530)),
    guess = FALSE,
)
tbls_5 <- extract_tables(
    paste0("pdf/", pdf_file),
    # output = "csv",
    # outdir = "out",
    area = list(c(35, 41, 35 + 713, 41 + 530)),
    guess = FALSE,
    decide = "lattice"
)

tbls_6 <- extract_tables(
    paste0("pdf/", pdf_file),
    # output = "csv",
    # outdir = "out",
    area = list(c(35, 41, 35 + 713, 41 + 530)),
    guess = FALSE,
    decide = "stream"
)

tbls_left <- extract_tables(
    paste0("pdf/", pdf_file),
    # output = "csv",
    # outdir = "out",
    area = list(c(0, 0, 792, 306)),
    guess = FALSE,
    decide = "stream"
)

tbls_right <- extract_tables(
    paste0("pdf/", pdf_file),
    # output = "csv",
    # outdir = "out",
    area = list(c(0, 306, 792, 612)),
    guess = FALSE,
    decide = "stream"
)

tbls <- list(tbls_1, tbls_2, tbls_3, tbls_4, tbls_5, tbls_6)

single_col_counts <- rep(0, 6)

for (tbl_i in 1:6) {
    tbl <- tbls[[tbl_i]]
    for (i in 1:537) {
        if (dim(tbl[[i]])[2] != 2) {
            single_col_counts[tbl_i] <- single_col_counts[tbl_i] + 1
        }
    }
}

tbls_lr <- list(tbls_left, tbls_right)

dif_count <- 0

for (i in 1:537) {
    if (dim(tbls_lr[[1]][[i]])[1] != dim(tbls_lr[[2]][[i]])[1]) {
        dif_count <- dif_count + 1
    }
}



# Go through pages

# Check if all (real) text on page in 2 col version

# IF yes, save

## If not, check if all text on page in one col version
## Use LR split to split into columns for each side
## Go through each side using two pointers and match

for (page_num in seq(2, 2)) {
    page <- tbls_1[[page_num]]
    if (ncol(page) == 2) {
        # 2 columns found
        page %>%
            as.vector() %>%
            str_replace_all("[ \r]", "") %>%
            nchar() %>%
            sum() %>%
            print()
        txt[[page_num]] %>%
            filter(font_name != "Times-Bold") %>%
            pull(text) %>%
            nchar() %>%
            sum() %>%
            print()
    }
}


txt[[page]] %>%
    filter(font_name != "Times-Bold") %>%
    pull(text) %>%
    nchar() %>%
    sum() %>%
    print()


project_tables <- function(pages) {
    cur_page_num <- 1
    cur_page <- pages[[cur_page_num]]
    cur_section <- "Title"
    cur_text <- ""
    for (i in 1:nrow(cur_page)) {
        if (cur_page[i, "font_size"] == 12.3) {
            if (cur_section == "Title") {
                cur_text <- paste(cur_text, cur_page[i, "text"])
            } else {
                ## FLUSH TITLE
                cur_section <- "Title"
            }
        } else if (cur_page[i, "font_size"] == 10.5) {
            if (cur_section == "Text") {
                cur_text <- paste(cur_text, cur_page[i, "text"])
            } else {
                ## FLUSH TABLE
                cur_section <- "Text"
            }
        }
    }
}

project_tables(txt[2:3])
