library(optparse)

option_list <- list(
  make_option(opt_str = c("-i","--in_h5"),
              type = "character",
              default = NULL,
              help = "Input h5 file",
              metavar = "character"),
  make_option(opt_str = c("-c","--in_contig"),
              type = "character",
              default = NULL,
              help = "Contig Files",
              metavar = "character"),
  make_option(opt_str = c("-d","--out_dir"),
              type = "character",
              default = NULL,
              help = "Output directory",
              metavar = "character"),
  make_option(opt_str = c("-b","--in_batch"),
              type = "character",
              default = NULL,
              help = "Batch ID",
              metavar = "character"),
  make_option(opt_str = c("-t","--in_category"),
              type = "character",
              default = NULL,
              help = "scBCR or scTCR",
              metavar = "character"),
  make_option(opt_str = c("-o","--out_html"),
              type = "character",
              default = NULL,
              help = "Output HTML run summary file",
              metavar = "character")
)

opt_parser <- OptionParser(option_list = option_list)

args <- parse_args(opt_parser)

if(is.null(args$out_html)) {
  print_help(opt_parser)
  stop("No parameters supplied.")
}

if(!dir.exists(args$out_dir)) {
  dir.create(args$out_dir)
}

rmd_loc <- file.path(args$out_dir,
                     paste0(args$in_batch,
                            "_add_contig_to_metadata.Rmd"))

file.copy(system.file("rmarkdown/add_contig_to_metadata.Rmd", package = "H5weaver"),
          rmd_loc,
          overwrite = TRUE)

rmarkdown::render(
  input = rmd_loc,
  params = list(in_h5 = args$in_h5,
                in_contig = args$in_contig,
                in_batch = args$in_batch,
                in_category = args$in_category,
                out_dir = args$out_dir),
  output_file = args$out_html,
  quiet = TRUE
)

file.remove(rmd_loc)
