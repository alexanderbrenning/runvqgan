library("purrr")

# Working directory with task files and generated images:
wd <- "C:/Users/yo54pow/Nextcloud/Projects/vqgan-clip"

# Set working directory manually because this script
# may be run through a scheduler (see scheduler.R):
setwd(file.path(wd, "runvqgan"))
source("R/vqgan-functions.R")

# Find task files (see Readme file for details):
fnms <- get_task_files(path = wd, priority_folder = "alex")
fnms

# Process the task files - this cannot be parallelized
# because memory is limited:
for (fnm in fnms) {
  process_task_file(filename = fnm,
                    vqgan_path = "D:/Projects/VQGAN-CLIP", 
                    default_resolution = c(450, 300),
                    max_iter = 6000,
                    max_each = 25,
                    delay = 10)
}
