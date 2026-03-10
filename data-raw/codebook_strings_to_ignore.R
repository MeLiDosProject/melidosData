## code to prepare `codebook_strings_to_ignore` dataset goes here

codebook_strings_to_ignore <-
  "<div class=\"rich-text-field-label\">|<span style=\"font-weight: normal;\">|<span style=\"text-decoration: underline;\">|</span>|<p>|<br />|<em>|</em>|</p>|</div>"

usethis::use_data(codebook_strings_to_ignore, overwrite = TRUE)
