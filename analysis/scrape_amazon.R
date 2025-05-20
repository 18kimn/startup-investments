scrape_amazon_showcase <- function(){
  max_results <- 50
  base_url <- "https://aws.amazon.com/startups/directory-api/v1/search/startups"
  initial_result <- paste0(base_url, "?maxResults=", max_results, "&sortBy=MOST_LIKES") |>
    read_json()
  total_results <- initial_result$totalResults
  next_token <- initial_result$nextToken
  results <- initial_result$startups
  while(length(results) < as.numeric(total_results) & !is.null(next_token)){
    Sys.sleep(1)
    message("Retrieved ", length(results), " out of ", total_results, " total results ...")
    result <- paste0("https://aws.amazon.com/startups/directory-api/v1/search/startups?maxResults=", max_results, "&nextToken=", URLencode(next_token, reserved = T), "&sortBy=MOST_LIKES") |>
      read_json()
    next_token <- result$nextToken
    results <- c(results, result$startups)
  }

  map_dfr(results, \(result){
    # Make into lists of length one for tibble-ifying
    result$industries <- list(unlist(result$industries))
    result$technologies <- list(unlist(result$technologies))
    as_tibble(result)
  }) |>
    mutate(showcaseUrl = paste0("https://aws.amazon.com/startups/showcase/startup-details/", id))
}
