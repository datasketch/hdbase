
#' @export
hdbase_table_update <- function(hb, table_slug = NULL, table = NULL, ...){
  if(is.null(table)) stop("Needs a data.frame or hdtable to updata hdbase")
  hb$hdtables[[table_slug]] <- hdtable(table, slug = table_slug, ...)
  hb
}

#' @export
hdbase_table_delete <- function(hb, table_slug = NULL){
  hb$hdtables[[table_slug]] <- NULL
  hb
}

