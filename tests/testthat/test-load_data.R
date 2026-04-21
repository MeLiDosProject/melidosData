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

test_that("load_remote_rdata returns NULL when object is not present", {
  tmp <- tempfile(fileext = ".RData")
  other_object <- data.frame(id = 1)
  save(other_object, file = tmp)

  out <- load_remote_rdata(paste0("file://", tmp), "sleepdiary")

  expect_null(out)
})
