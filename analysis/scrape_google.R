library(rvest)

scrape_google_stories <- function(){
  stories_index <- read_html("https://startups.google.com/alumni/stories/") |>
    html_elements("#glue-filter-result-container .glue-grid.glue-cards li") |>
    map_dfr(\(story){
      anchor <- html_element(story, "a")
      tibble(
        type = html_attr(story, "data-glue-filter-content"),
        industry = html_attr(story, "data-glue-filter-industry"),
        product = html_attr(story, "data-glue-filter-product"),
        region = html_attr(story, "data-glue-filter-region"),
        name = html_attr(anchor, "data-label"),
        href = html_attr(anchor, "href")
      )
    })

  get_text <- function(x, selector){
    x |>
      html_elements(selector) |>
      html_text() |>
      str_trim() |>
      paste0(collapse = "\n")
  }
  stories <- map_dfr(stories_index$href, \(story_href){
    Sys.sleep(0.5)
    story <- read_html(paste0("https://startups.google.com", story_href))

    tibble(
      href = story_href,
      story_title =  get_text(story, ".story-header--title"),
      story_subtitle = get_text(story, ".story-content--standfirst"),
      story_text = get_text(story, ".content-body"),
      products_used = get_text(story, ".sidebar-product-name") |>
        paste0(collapse = ","),
      website_url = story |>
        html_element(".story-bottom--follow-container a") |>
        html_attr("href")
    )
  }, .progress = TRUE)

  stories_index |>
    left_join(stories, by = "href")
}


