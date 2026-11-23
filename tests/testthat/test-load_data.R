test_that("load_remote_rdata closes the connection after loading", {
  tmp <- tempfile(fileext = ".RData")
  sleepdiary <- data.frame(id = 1)
  save(sleepdiary, file = tmp)

  before <- rownames(showConnections(all = TRUE))

  out <- load_remote_rdata(paste0("file://", tmp), "sleepdiary")

  after <- rownames(showConnections(all = TRUE))

  expect_s3_class(out, "data.frame")
  expect_equal(out$id, 1)
  expect_setequal(after, before)
})

test_that("load_remote_rdata explains a missing expected object", {
  tmp <- tempfile(fileext = ".RData")
  other_object <- data.frame(id = 1)
  save(other_object, file = tmp)

  expect_error(
    load_remote_rdata(paste0("file://", tmp), "sleepdiary"),
    "Expected object `sleepdiary` is absent",
    class = "melidos_data_load_error"
  )
})

test_that("load_remote_rdata rejects invalid files and objects without leaking connections", {
  before <- rownames(showConnections(all = TRUE))
  tmp <- tempfile(fileext = ".RData")
  writeLines("not an RData file", tmp)
  expect_error(
    suppressWarnings(load_remote_rdata(paste0("file://", tmp), "x")),
    class = "melidos_data_load_error"
  )
  x <- 1
  save(x, file = tmp)
  expect_error(
    load_remote_rdata(paste0("file://", tmp), "x"),
    "must be a data frame"
  )
  expect_setequal(rownames(showConnections(all = TRUE)), before)
})

test_that("load_data applies site-specific revisions and records provenance", {
  seen <- character()
  local_mocked_bindings(load_remote_rdata = function(url_string, object_name) {
    seen <<- c(seen, url_string)
    data.frame(Id = "example")
  })
  refs <- c(TUM = strrep("a", 40), RISE = strrep("b", 40))
  out <- load_data("sleepdiaries", c("TUM", "RISE"), ref = refs)
  expect_s3_class(out, "melidos_data")
  expect_identical(names(out), c("TUM", "RISE"))
  expect_true(grepl(
    paste0("/", refs[[1]], "/data/imported/continuous/sleepdiaries.RData"),
    seen[[1]],
    fixed = TRUE
  ))
  expect_true(grepl(
    paste0("/", refs[[2]], "/data/imported/continuous/sleepdiaries.RData"),
    seen[[2]],
    fixed = TRUE
  ))
  provenance <- attr(out, "melidos_sources")
  expect_identical(provenance$revision, unname(refs))
  expect_identical(provenance$object, c("sleepdiary", "sleepdiary"))
  expect_identical(provenance$status, c("loaded", "loaded"))
  one <- load_data("demographics", "TUM", ref = "v1")
  expect_s3_class(one, "data.frame")
  expect_identical(attr(one, "melidos_sources")$revision, "v1")
})

test_that("failed sites cannot disappear silently during loading or flattening", {
  local_mocked_bindings(load_remote_rdata = function(url_string, object_name) {
    if (grepl("Broszio", url_string)) {
      rlang::abort("BAUA download failed", class = "melidos_data_load_error")
    }
    data.frame(Id = "TUM_S001")
  })
  expect_error(
    load_data("demographics", c("BAUA", "TUM")),
    "BAUA download failed"
  )
  expect_warning(
    out <- load_data("demographics", c("BAUA", "TUM"), on_failure = "warn"),
    "BAUA download failed"
  )
  expect_null(out$BAUA)
  expect_identical(attr(out, "melidos_sources")$status, c("failed", "loaded"))
  expect_error(flatten_data(out), "invalid site data: BAUA")
})

test_that("invalid revision specifications fail before download", {
  expect_error(
    load_data("demographics", "TUM", ref = NA_character_),
    "nonempty"
  )
  expect_error(
    load_data("demographics", c("TUM", "RISE"), ref = c(TUM = "main")),
    "per selected site"
  )
  expect_error(
    load_data("demographics", "TUM", ref = c("main", "tag")),
    "single unnamed"
  )
})

test_that("a failed single site retains its identity and source metadata", {
  local_mocked_bindings(load_remote_rdata = function(url_string, object_name) {
    rlang::abort("TUM download failed", class = "melidos_data_load_error")
  })
  expect_warning(
    out <- load_data("demographics", "TUM", on_failure = "warn"),
    "TUM download failed"
  )
  expect_s3_class(out, "melidos_data")
  expect_identical(names(out), "TUM")
  expect_null(out$TUM)
  sources <- attr(out, "melidos_sources")
  expect_identical(sources$site, "TUM")
  expect_identical(sources$status, "failed")
  expect_error(flatten_data(out), "invalid site data: TUM")
})

test_that("unavailable MPI modalities produce empty, typed source metadata", {
  local_mocked_bindings(load_remote_rdata = function(...) {
    stop("Unavailable modalities must not be downloaded")
  })
  expect_message(out <- load_data("health", "MPI"), "Remove site MPI")
  expect_s3_class(out, "melidos_data")
  expect_length(out, 0L)
  expect_identical(attr(out, "melidos_sources")$status, character())
})

test_that("flattening retains source metadata and column labels", {
  local_mocked_bindings(load_remote_rdata = function(...) {
    data.frame(Id = structure("example", label = "Participant"))
  })
  loaded <- load_data("demographics", c("TUM", "RISE"))
  flattened <- flatten_data(loaded)
  expect_identical(
    attr(flattened, "melidos_sources"),
    attr(loaded, "melidos_sources")
  )
  expect_identical(attr(flattened$Id, "label"), "Participant")
})
