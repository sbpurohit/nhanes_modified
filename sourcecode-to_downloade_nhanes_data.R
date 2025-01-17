library(foreign)

nhanes_modified <- function(nh_table, includelabels = FALSE, translated = FALSE, 
                            cleanse_numeric = FALSE, nchar = 128, adjust_timeout = TRUE) {
  nht <- tryCatch({
    #nh_year <- .get_year_from_nh_table(nh_table) # Retrieve year from table name
    
    # Define the year_table
    year_table <- list("G" = 2011, "H" = 2013, "I" = 2015, "J" = 2017)
    # Extract the second part from the split string
    tab_len<-unlist(strsplit(nh_table, "_"))
    # Assign tab_char based on the length of the split
    if(length(tab_len) == 2) {
      tab_char <- tab_len[2]  # Extract the second part
    } else if(length(tab_len) == 3) {
      tab_char <- tab_len[3]  # Extract the third part
    } else {
      stop("Invalid table format")
    }
        # Match the extracted part with the year_table
    nh_year <- year_table[[tab_char]]
    
    # Construct the modified URL
    url <- paste0("https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/", nh_year, 
                  "/DataFiles/", nh_table, ".xpt")
    
    # Estimate timeout
   # min_timeout <- estimate_timeout(url, factor = adjust_timeout)
  #  if (is.finite(min_timeout) && min_timeout > 0) {
  #    oopt <- options(timeout = max(min_timeout, getOption("timeout")))
  #    on.exit(options(oopt))
  #  }
    
    tf <- tempfile() # Temporary file for download
    
    # Log access if enabled
    nhanesOptions <- function(option) {
      if (option == "log.access") {
        return(TRUE)  # Or FALSE, depending on your preference
      }
    }
    if (isTRUE(nhanesOptions("log.access"))) 
      message("Downloading: ", url)
    
    # Download the file
    download.file(url, tf, mode = "wb", quiet = TRUE)
    
    # Read the data using read.xport
    nh_df <- read.xport(tf)
    
    # Translate columns if required
    if (translated) {
      suppressWarnings(suppressMessages({
        nh_df <- nhanesTranslate(nh_table, colnames = colnames(nh_df)[2:ncol(nh_df)], 
                                 data = nh_df, nchar = nchar, cleanse_numeric = cleanse_numeric)
      }))
    }
    
    # Add labels if requested
    if (includelabels) {
      xport_struct <- lookup.xport(tf)
      column_names <- xport_struct[[1]]$name
      column_labels <- xport_struct[[1]]$label
      names(column_labels) <- column_names
      if (identical(names(nh_df), column_names)) {
        for (name in column_names) {
          attr(nh_df[[name]], "label") <- column_labels[which(names(column_labels) == name)]
        }
      } else {
        message(paste0("Column names and labels are not consistent for table ", 
                       nh_table, ". No labels added"))
      }
    }
    
    return(nh_df)
  })
}
