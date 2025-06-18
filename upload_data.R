library(googledrive)
upload_data <- function(.data, filename, overwrite = FALSE, ...){
  folder_id <- googledrive::as_id("1IpjXXogvpm8IU1z3SdNUaUe0F1SyA9_k")
  path <- file.path(tempdir(), filename)
  write_csv(.data, path = path, ...)

  upload_res <- googledrive::drive_upload(media = path, name = filename,
                                          path = folder_id, overwrite = overwrite)
  upload_url <- upload_res$drive_resource[[1]]$webViewLink
  folder_link <- paste0("https://drive.google.com/drive/folders/", folder_id)

  return(cli::cli_text("Upload successful. See file at {.href [this link]({upload_url})}, and folder at {.href [this link]({folder_link})}."))
}
