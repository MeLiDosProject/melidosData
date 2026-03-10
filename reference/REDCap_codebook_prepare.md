# Prepare a REDCap codebook for downstream processing

Cleans HTML formatting from codebook labels and optionally filters the
codebook to selected REDCap forms.

## Usage

``` r
REDCap_codebook_prepare(
  codebook,
  strings_to_ignore = codebook_strings_to_ignore,
  form.filter = NULL,
  field.label = `Field Label`,
  form.col = `Form Name`
)
```

## Arguments

- codebook:

  A REDCap data dictionary as a data frame.

- strings_to_ignore:

  A regular expression used in
  [`stringr::str_remove_all()`](https://stringr.tidyverse.org/reference/str_remove.html)
  to remove formatting fragments from field labels.

- form.filter:

  Optional character vector of REDCap form names to keep.

- field.label:

  Unquoted column containing question labels.

- form.col:

  Unquoted column containing the form name (for filtering)

## Value

A cleaned codebook tibble/data frame.

## Examples

``` r
codebook_path <- system.file("ext", "DataDictionary_sleepdiary.csv",
  package = "melidosData"
)
codebook <- utils::read.csv(codebook_path, check.names = FALSE)
cleaned <- REDCap_codebook_prepare(codebook)
cleaned$`Field Label`
#>  [1] "Record ID"                                                             
#>  [2] "What time did you get into bed?"                                       
#>  [3] "What time did you try to go to sleep?"                                 
#>  [4] "How long did it take you to fall asleep? Please answer in minutes"     
#>  [5] "How many times did you wake up, not counting your final awakening?"    
#>  [6] "In total, how long did these awakenings last? Please answer in minutes"
#>  [7] "What time was your final awakening? i.,e. when did you wake up today?" 
#>  [8] "What time did you get out of bed for the day?"                         
#>  [9] "How would you rate the quality of your sleep?"                         
#> [10] "Any comments?"                                                         
#> [11] "Today is..."                                                           
#> [12] "UUID"                                                                  
#> [13] "Start Date"                                                            
#> [14] "End Date"                                                              
#> [15] "Schedule Date"                                                         
#> [16] "Status"                                                                
#> [17] "Supplemental Data (JSON)"                                              
#> [18] "Serialized Result"                                                     
#compate the original one
codebook$`Field Label`
#>  [1] "Record ID"                                                                                                                        
#>  [2] "What time did you get into bed?"                                                                                                  
#>  [3] "What time did you try to go to sleep?"                                                                                            
#>  [4] "<div class=\"rich-text-field-label\"><p>How long did it take you to fall asleep? <em>Please answer in minutes</em></p></div>"     
#>  [5] "How many times did you wake up, not counting your final awakening?"                                                               
#>  [6] "<div class=\"rich-text-field-label\"><p>In total, how long did these awakenings last? <em>Please answer in minutes</em></p></div>"
#>  [7] "What time was your final awakening? i.,e. when did you wake up today?"                                                            
#>  [8] "What time did you get out of bed for the day?"                                                                                    
#>  [9] "How would you rate the quality of your sleep?"                                                                                    
#> [10] "Any comments?"                                                                                                                    
#> [11] "Today is..."                                                                                                                      
#> [12] "UUID"                                                                                                                             
#> [13] "Start Date"                                                                                                                       
#> [14] "End Date"                                                                                                                         
#> [15] "Schedule Date"                                                                                                                    
#> [16] "Status"                                                                                                                           
#> [17] "Supplemental Data (JSON)"                                                                                                         
#> [18] "Serialized Result"                                                                                                                
```
