
#' @title Create a hdtable data base
#' @description Create a hdbase object from a data frame or a list of data frames.
#' The main value of a hdbase is the metadata associated to a data base.
#'
#' - name: Name for the hdtable data frame, setted on _name_ argument
#' - description: Description for the hdtable data frame, setted on _description_ argument
#' - hdtables: A list of hdtables
#' - slug: a custom slug can be added to the hdbase
#' @param x A data frame
#' @param hdtable_type The type of hdtable to create
#' @param dic a custom variable dictionary can be added. [create_dic()] can help you with that.
#' @param name a custom name can be added
#' @param nam a custom description can be added
#' @param slug a custom slug can be added. If not, hdtable will try creating one.
#' @param meta Custom Metadata can be added
#'
#' @examples
#' hdtable(mtcars, hdtable_type = "Num", name = "MTCars")
#'
#' @return A hdtable object

#' @export
hdbase <- function(ts,
                   name = NULL,
                   description = NULL,
                   slug = NULL,
                   formats = NULL,
                   meta = NULL,
                   dic = NULL,
                   lazy = FALSE,
                   ...){

  name <- name %||% deparse(substitute(ts))

  if(is.character(ts)){
    path <- ts
    if(!dir.exists(path)){
      stop("No path found")
    }
    csv_files <- list.files(path, pattern = "\\.csv$", full.names = TRUE)
    if(length(csv_files) == 0){
      stop("No csv files found")
    }
    csv_files <- csv_files[!grepl("\\.dic\\.csv$", csv_files)]
    large_data <- any(purrr::map_lgl(csv_files, is_large_data))

    if(!large_data){
      nms <- tools::file_path_sans_ext(basename(csv_files))
      hdts <- purrr::map(csv_files, function(file){
        d <- vroom::vroom(file, show_col_types = FALSE)
        hdtable(d, lazy = lazy)
      })
      names(hdts) <- nms
    }else{
      nms <- tools::file_path_sans_ext(basename(csv_files))
      hdts <- purrr::map(csv_files, function(file){
        dic <- vroom::vroom(gsub(".csv", ".dic.csv", file), show_col_types = F)
        name <- tools::file_path_sans_ext(basename(file))
        hdtable(d = file, dic = dic, name = name, lazy = lazy)
      })
      names(hdts) <- nms
    }

  } else if(is.data.frame(ts)){
    hdt <- hdtable(ts, dic = dic,
                   name = name, description = description,
                   slug = slug, formats = formats,
                   lazy = lazy)
    hdts <- list(hdt)
  } else if(is_hdtable(ts)){
    hdts <- list(ts)
  } else{
    hdts <- ts
  }

  if(are_data_frames(hdts)){
    if(is.null(names(hdts)))
      stop("List of data.frames must be named")
    nms <- names(hdts)

    if(!is.null(dic)){
      if(!are_dics(dic)){
        stop("When input is list of dataframes dic must be a list of dic")
      }
      params <- purrr::transpose(list(hdts = hdts, dic = dic, name = nms))
      hdts <- purrr::map(params, function(p){
        hdtable(p$hdts, dic = p$dic, name = p$name, lazy = lazy)
      })
    }else{
      hdts <- purrr::map2(hdts, nms, ~ hdtable(.x, name = .y, lazy = lazy))
    }



  }

  if(!are_hdtables(hdts)){
    stop("Must be a list of hdtables")
  }
  meta <- c(meta, list(...))

  if(all(dstools::is.empty(meta))) meta <- NULL

  hdbaseClass$new(hdts,
                  name = name, description = description,
                  slug = slug,
                  formats = formats,
                  lazy = lazy,
                  meta = meta)


}


#' @title is_hdbase
#' @description test for objects of type "hdbase"
#'
#' @param x object to be coerced or tested
#'
#' @return returns TRUE or FALSE depending on whether its argument is of type hdbase or not.
#'
#' @examples
#' some_base <- hdbase(mtcars)
#' is_hdbase(some_base)
#'
#' @export
is_hdbase <- function(x) {
  inherits(x, "hdbase")
}


#' @title hdbase_hdtables
#' @description get hdtables from base
#'
#' @param x an hdbase object
#'
#' @return returns a list of hdtables from the hdbase
#'
#' @examples
#' some_base <- hdbase(mtcars)
#' is_hdbase(some_base)
#'
#' @export
hdbase_hdtables <- function(b){
  b$hdtables
}

#' @title hdbase_hdtables_types
#' @description get hdtables from base
#'
#' @param x an hdbase object
#'
#' @return returns a list of hdtables from the hdbase
#'
#' @examples
#' some_base <- hdbase(mtcars)
#' is_hdbase(some_base)
#'
#' @export
hdbase_hdtables_types <- function(b){
  purrr::map(b$hdtables, function(h) h$hdtable_type)
}




