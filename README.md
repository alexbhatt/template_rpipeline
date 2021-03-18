# Reproducible Analytic Pipeline Template: R

This repository contains a template for the creation of reproducible analytic pipelines (RAPs) in R. 
It utelises a few tools which you should become familliar with.
Read this from top to bottom, the importance of each tools is ordered (with a tie for the last 2).


## [Git](https://guides.github.com/introduction/git-handbook/)

__If you are coding and not using Git, you are doing it wrong.__
If you are only going to use one of these tools, this is the one.
Git is a version control system which allows us to store a copy of the codebase online in a GitHub (public) or GitLab (internal) account. 
This enables us to have a snapshot of our code as we work on it, and to safely make changes, and allow revisions and sharing.
Once you have Git installed on your machine, you will be able to take a copy of this template to get started.

Folder structure is an overlooked thing, but can make your life easier. 
I have a single folder called `/repos` where I store all my git repositories. 
These can be anywhere on your machine, just ensure that you're __not__ saving any data locally.
I would encourage you to save your data in a database (like SQL) instead of a `.csv`, especially if it contains any personal/patient idenfiable (PII) data. 
This way, you _never_ store PII data on your computer.

```
C:/
|--- Users/
     |--- alexbhatt/
          |--- repos/
               |--- project1/
               |--- project2/
	       |--- project3/

```

Open GitBash in the folder where you save your projects.
This will save a copy of this template in your folder, where you can rename and start working.

```sh
# download the template
	git clone https://github.com/alexbhatt/template_rpipeline.git
# rename the folder
	mv template_rpipeline new_project_name
# go into the folder
	cd new_project_name
# rename the project file
	mv r_project.Rproj project_name.Rproj
```

On GitLab or GitHub, make a new repository, look for the `+` sign. 
This will give you a new home for the project work going forwards.
Each new project, or purpose gets it own repository.

Okay, back in GitBash, enter the following using the Git HTTPS url.
This will connect your code on your machine from this template to the new Git repository for your project.

```sh
	git remote set-url origin HTTPS_URL
```

## .Rproj

Working in R (and RStudio) you have access to projects, you should __always__ use them.
These create directory with a `.Rproj` file within. 
Importantly, these allow us to make references to the directory within our code, instead of having to reference full file paths within our system, regardless of OS.
Like Git, each new project or purpose gets its own `.Rproj`.

### [renv](https://rstudio.github.io/renv/articles/renv.html)

Renv is a package control system within R. 
It is already installed and ready to go in this template.
This means that each `.Rproj` has its own copy of each of the packages used. 
Why you ask? 

+ So that you dont run into issues down the road where you try to run your code, but package X has been updated, and broken your pipeline. 
+ So that you can share your analysis with others, and the packages they have installed will be exactly the same as what you have installed, always.

This template has already had `renv::init()` run which starts the process. To install a new package use the following in R:

```r
# if its a CRAN package
	renv::install("packagename")
# if its a GitHub package
	renv::install("alexbhatt/epidm")
# if its a GitLab package
	options(renv.config.gitlab.host = "http://my-gitlab-server")
	renv::install("gitlab::USER/pkgRepo")

# once you have installed all your packages
	renv::snapshot()
```

`renv::snapshot()` saves a file in the directory `renv.lock` which is used by `renv::restore()` to download and install all the relevant packages within the project.

### [targets](https://books.ropensci.org/targets/)

You like DAGS?
Well `targets` seems to be the R package for managing directed aycylic graphs (DAGS) for analytic pipelines.
It is already installed and ready to go in this template.
This means you can setup a workflow, using a series of package-defined and user-defined functions as a RAP.
Just define a list in the `_targets.R` file and let `targets` do the rest to help you execute, debug and run your pipeline.
I'll add to this later once I have a better understanding.

## Docker

We've got package management through `renv` and pipeline management through `targets`. 
Docker gives us environment management. This includes version control of R itself.
We use `docker` so that we can create a container (like a virtual machine) which has all the dependencies for the pipeline independent of your local machine.
This also allows us to export our analysis to a cloud or high-performance computer cluster.
The container is created by following the instructions within the `Dockerfile`.
Of note is that these are built in Linux, so you may need to adapt your code slightly to run within this environment. 
