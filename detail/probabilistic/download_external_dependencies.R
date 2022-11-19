library("tools")

source("file_manipulation.R")

# Populates variables cache.dir, src.dir, test.dir and test.deps.dir,
# and the cache.dependencies function.
source("directories.R")

package.name <- "probabilistic"

src.dir <- file.path(package.name, "src")
deps.dir <- file.path(src.dir, "external")
if (!dir.exists(deps.dir)) {
  dir.create(deps.dir)
}

# Boost R Package Dependency and Testing
boost.cache.path <- cache.dependency(
  url = "https://boostorg.jfrog.io/artifactory/main/release/1.80.0/source/boost_1_80_0.tar.gz"
)
boost.dep.path <- file.path(src.dir, "boost")  # Keep at /src to prevent paths over 100 chars.
create_and_copy(
  from = dir(boost.cache.path, full.names = TRUE),
  to = boost.dep.path,
  recursive = TRUE
)

# pytorch
# Install python packages needed for compilation even if source code has
# already been downloaded. This is needed for the docker container.
# pip3 has its own cache, so this doesn't take too long if installation
# of these python dependencies has already occurred.
system2(
  "pip3",
  args = c(
    "install",
    "astunparse",
    "numpy",
    "ninja",
    "pyyaml",
    "mkl",
    "mkl-include",
    "setuptools",
    "cmake",
    "cffi",
    "typing",
    "typing_extensions",
    "future",
    "six",
    "requests",
    "dataclasses"
  )
)
if (!dir.exists(file.path("probabilistic", "src", "pytorch"))) {
  gwd <- getwd()
  setwd(file.path("probabilistic", "src"))
  system2("git", c("clone", "--recursive", "https://github.com/pytorch/pytorch.git"))
  setwd(file.path("pytorch"))
  system2("git", c("checkout", "tags/v1.13.0"))
  system2("git", c("submodule", "sync"))
  system2("git", c("submodule", "update", "--init", "--recursive", "--jobs", "0"))
  cmakelists <- readLines(con = "CMakeLists.txt")
  cmakelists <- append(cmakelists, "include(\"../pytorch_header.cmake\")", after = 0)
  cmakelists <- append(cmakelists, "include(\"../pytorch_footer.cmake\")")
  writeLines(text = cmakelists, con = "CMakeLists.txt")
  setwd(gwd)
}

faddeeva.cache.path <- file.path(cache.dir, "Faddeeva")
if (!dir.exists(faddeeva.cache.path)) {
  faddeeva.src.path <- file.path(faddeeva.cache.path, "src")
  faddeeva.include.path <- file.path(faddeeva.cache.path, "include")
  dir.create(faddeeva.cache.path)
  dir.create(faddeeva.src.path)
  dir.create(faddeeva.include.path)
  download.file(url = "http://ab-initio.mit.edu/Faddeeva.cc", destfile = file.path(faddeeva.src.path, "Faddeeva.cc"))
  download.file(url = "http://ab-initio.mit.edu/Faddeeva.hh", destfile = file.path(faddeeva.include.path, "Faddeeva.hh"))
}
create_and_copy(
  from = dir(faddeeva.cache.path, full.names = TRUE),
  to = file.path(deps.dir, "Faddeeva"),
  recursive = TRUE
)

