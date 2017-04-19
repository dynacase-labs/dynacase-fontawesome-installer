# BuildTools for dynacase installer packages

## Usage

Use this as a submodule as dir `build` in the sources of the installer.

The sources must contain the following files:

-   `configure.in`
    
    initialize it from [`configure.in.sample`](configure.ac.sample)
    
    +   You __must__ fill `LIB_NAME` and `NPM_PACKAGE`.
    
    +   You __can__ change `PACKAGE`, `VERSION` and `RELEASE`

-   `VERSION`
    
    This file contains the version number of the __bower package__ to retrieve

-   `RELEASE`
    
    This file contains the __dynacase module__ release number

## version bump

To update lib version:

1.  update version in `VERSION`
2.  `autoconf && ./configure && make update`

## Commands

Once the files are configured, use the following commands in your sources:

1.  `autoconf`
2.  `./configure`
3.  `make`
    
    make automatically outputs the list of available recipes.

## Customization

In case you need to customize the way src are generated, you can add a `custom/Makefile` file in your sources,
and define the recipe `custom` in this file.