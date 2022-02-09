library("stringr")
library("purrr")
library("magrittr")

params_to_args <- function(args, resolution = resolution, each = 1) {
  txt <- args$text
  if (!is.null(args$style))
    txt <- paste0(txt, c(" in the style of ", "")[(args$style=="")+1], args$style)
  arg <- paste("-p", shQuote(txt))
  if (each > 1)
    arg <- rep(arg, each = each)
  if (!is.null(args$in_file))
    arg <- paste(arg, "-ip", args$in_file)
  if (!is.null(args$template_file))
    arg <- paste(arg, "-ii", args$template_file)
  if (!is.null(args$iterations))
    arg <- paste(arg, "-i", args$iterations)
  if (is.null(args$resolution)) {
    arg <- paste(arg, "-s", resolution[1], resolution[2])
  } else {
    arg <- paste(arg, "-s", args$resolution[1], args$resolution[2])
  }
  if (!is.null(args$raw))
    arg <- paste(arg, args$raw)
  cnt <- 1
  for (i in 1:length(arg)) {
    out_fnm <- paste0(file.path(args$out_path, args$out_file), "_", cnt, ".png")
    while (file.exists(out_fnm)) {
      cnt <- cnt + 1
      out_fnm <- paste0(file.path(args$out_path, args$out_file), "_", cnt, ".png")
    }
    arg[i] <- paste(arg[i], "-o", out_fnm)
    cnt <- cnt + 1
  }
  arg
}

generate <- function(
  text, 
  title = "output", 
  style = "",
  out_file = title, 
  out_path = "C:/Users/yo54pow/Nextcloud/Projects/vqgan-clip",
  out_folder = title,
  in_file = NULL,
  template_file = NULL,
  iterations = NULL,
  raw = NULL,
  resolution = c(450, 300),
  portrait = FALSE,
  each = 1,
  anaconda_call = 'cmd.exe "/K" "C:/ProgramData/Anaconda3/Scripts/activate.bat C:/ProgramData/Anaconda3',
  vqgan_path = "D:/Projects/VQGAN-CLIP",
  vqgan_call = "python generate.py",
  save_call = TRUE)
{
  resolution <- sort(resolution, decreasing = !portrait)
  
  params <- list(
    text = text,
    style = style,
    in_file = in_file,
    out_path = file.path(out_path, out_folder),
    out_file = out_file,
    template_file = template_file,
    iterations = iterations,
    resolution = resolution,
    raw = raw
  )
  
  arg <- params_to_args(params, each = each)
  
  if (!is.null(vqgan_path)) {
    owd <- getwd()
    setwd(vqgan_path)
  }
  
  res <- system(
    input = paste(vqgan_call, arg), 
    command = anaconda_call)
  
  if (!is.null(vqgan_path)) {
    setwd(owd)
  }
  
  if ((res == 0) & save_call) {
    out_fnm <- arg %>% stringr::str_extract("-o .*$") %>% stringr::str_replace("-o ", "") %>%
      stringr::str_replace("\\.png", ".txt")
    if (length(arg) == length(out_fnm)) {
      for (i in 1:length(arg))
        writeLines(paste0(vqgan_call, " ", arg[i], "\n"), con = out_fnm[i])
    }
  }
  
  res
}

quickly_generate <- function(text, resolution = c(300,200), iterations = 100, ...) {
  generate(text = text, resolution = resolution, iterations = iterations, ...)
}

process_task_file <- function(filename, 
                              vqgan_path = "D:/Projects/VQGAN-CLIP",
                              default_resolution = c(450, 300),
                              max_iter = 99999,
                              max_each = 100,
                              delay = 0) {
  params <- NULL
  
  # File showing error messages, if needed:
  err_file <- gsub("\\.txt$", "_ERROR.txt", filename)
  
  cat("\n---------> Processing task file", filename, " <---------\n")
  res <- try(params <- jsonlite::read_json(filename, simplifyVector = TRUE))
  
  if (alexmisc::failed(res)) {
    cat("Error reading file ", filename, ". Not a JSON file??\n", sep = "")
    writeLines("Error in parameter file. Not in JSON format??", con = err_file)
  } else {
    # Guess output folder if information is missing:
    if (is.null(params$out_folder)) {
      out_folder <- fnm %>% stringr::str_remove(wd) %>%
        stringr::str_extract("^/[:alnum:]*/") %>%
        stringr::str_remove_all("/")
      if (out_folder == "tasks")
        out_folder <- "output"
      params$out_folder <- out_folder
    }
    
    # Check that all required information was provided:
    if (!all(c("text", "style", "iterations", "out_file", "out_folder", "portrait", "each") %in% names(params))) {
      cat("Error reading file ", filename, ". Check format!\n", sep = "")
      writeLines("Error in parameter file. Check format!", con = err_file)
    }
    
    if (!file.exists(file.path(wd, params$out_folder))) {
      cat("Error: target folder", filename, "does not exist.\n")
      writeLines("Error: Target folder does not exist!", con = err_file)
    } else {
      if (params$each > max_each) {
        cat("Warning: too many repetitions: ", params$each, ".\n", sep = "")
        params$each <- max_each
      }
      if (params$iterations > max_iter) {
        cat("Warning: too many iterations: ", params$iterations, ".\n", sep = "")
        params$iterations <- max_iter
      }
      if (is.null(params$resolution))
        params$resolution <- default_resolution
      
      # Run VQGAN:  
      res <- try(generate(text = params$text, 
                          style = params$style, 
                          in_file = params$in_file,
                          out_file = params$out_file, 
                          out_folder = params$out_folder, 
                          iterations = params$iterations,
                          each = params$each,
                          portrait = params$portrait,
                          resolution = params$resolution,
                          vqgan_path = vqgan_path))

      if (alexmisc::failed(res)) {
        cat("Error executing VQGAN-CLIP.\n")
        writeLines("Error: Target folder does not exist!", con = err_file)
      } else {
        cat("Done.\n")
        file.rename(filename, paste0(filename, ".done"))
      }
      
      if (delay > 0)
        Sys.sleep(delay)
    }
  }
  
  invisible(params)
}

get_task_files <- function(path = "C:/Users/yo54pow/Nextcloud/Projects/vqgan-clip",
                           task_path = file.path(path, "tasks"),
                           recursive = TRUE,
                           exclude_readme = TRUE,
                           priority_folder = NULL) {
  fnms1 <- fnms2 <- c()
  
  if (!is.null(task_path)) {
    fnms1 <- dir(path = task_path, pattern = "\\.txt$", 
                 recursive = recursive, full.names = TRUE) %>%
      stringr::str_subset("sample.txt", negate = TRUE)
  }
  if (!is.null(path)) {
    fnms2 <- dir(path = path, pattern = "^task_.*\\.txt$", 
                 recursive = recursive, full.names = TRUE) %>%
      stringr::str_subset("/sample\\.txt$", negate = TRUE) %>%
      stringr::str_subset("/task_sample\\.txt$", negate = TRUE)
  }
  
  # Merge file lists, remove duplicates:
  # (Files in the tasks folder that start with "task_" would be
  # selected by both of the above filters...)
  fnms <- c(fnms1, fnms2) %>% 
    unique() %>%
    stringr::str_subset("_ERROR.txt$", negate = TRUE)
  
  if (exclude_readme) 
    fnms <- fnms %>% 
    stringr::str_subset("README.txt$", negate = TRUE)
  
  # Tasks from this folder go first, all others in random order:
  sel_prio <- rep(FALSE, length(fnms))
  if (!is.null(priority_folder)) {
    sel_prio <- fnms %>% 
      stringr::str_detect(
        paste0("/", priority_folder, "/"))
  }
  fnms <- c(fnms[sel_prio], 
            sample(fnms[!sel_prio]))
  fnms
}
