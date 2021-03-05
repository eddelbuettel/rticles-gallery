#!/usr/bin/r

styles <- list.files(path=system.file("rmarkdown", "templates", package="rticles"), recursive=FALSE)

library(rmarkdown)
tdir <- tempdir(TRUE)
cat("Tempdir is ", tdir, "\n")

## create the pdf files and copy them to docs/
for (s in styles) {

    setwd(tdir)

    article_rmd <- paste0(s, "_demo.Rmd")
    article_dir <- paste0(s, "_demo")

    cwd <- getwd()

    if (dir.exists(article_dir)) {
        cat("Skipping ", article_dir, "\n")
    } else if (file.exists(article_rmd)) {
        cat("Skipping ", article_rmd, "\n")
    } else {
        draft(article_dir, template=s, package="rticles", edit=FALSE)
        if (dir.exists(article_dir)) {
            setwd(article_dir)
            try(render(article_rmd))
            setwd(cwd)
        }
    }

    if (!dir.exists("docs")) {
        dir.create("docs")
    }

    article_pdf <- paste0(s, "_demo.pdf")
    if (dir.exists(article_dir)) {
        setwd(article_dir)
        if (file.exists(article_pdf)) {
            cat("Copying ", article_pdf, "\n")
            file.copy(article_pdf, "../docs", overwrite=TRUE)
        }
        setwd(cwd)
    }
}


if (nchar(unname(Sys.which("convert"))) == 0) {
    stop("Need 'convert' to create gif files.", call.=FALSE)
}

if (dir.exists("docs")) {
    cwd <- getwd()
    setwd("docs")
    pdfs <- list.files(".", pattern=".pdf$")
    for (p in pdfs) {
        s <- gsub("_demo.pdf", "", p)
        g <- gsub(".pdf$", ".gif", p)
        if (!file.exists(g)) {
            cmd <- paste("convert -density 127 -delay 200", p, g)
            cat("Running '", cmd, "'\n")
            system(cmd)
        }
        cat("- ", s, " [![", s, "](", g, ")](", p, ")\n", sep="")
    }
    setwd(cwd)
}

## all:  convert -density 127 -delay 200 *pdf newall.gif
