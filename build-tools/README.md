# BuildTools for dynacase installer packages

## Initialisation

Use this as a submodule as dir `build-tools` in the sources of the installer.

The sources must contain the following files:

-   `configure.in`
    
    initialize it from [`configure.in.sample`](configure.in.sample)
    
    +   You __must__ fill `LIB_NAME` and `NPM_PACKAGE`.
    
    +   You __can__ change `PACKAGE`, `VERSION` and `RELEASE`

-   `VERSION`
    
    This file contains the version number of the __NPM package__ to retrieve

-   `RELEASE`
    
    This file contains the __dynacase module__ release number

## Usage

Basic usage is:

1.  update version in `VERSION`
2.  `autoconf && ./configure && make all && make upload`

## Commands

Running `make` with no target outputs help for available targets.

Main targets include:

-   `all`: shortcut for `zip` and `webinst`
-   `zip`: Generate zip
-   `webinst`: Generate webinst
-   `upload`: Upload zip file anakeen third party repo
-   `clean`: remove uncommited stuff
-   `clean-all`: remove uncommited stuff and cache

## Customization

In case you need to customize the way zip or webinst are generated, you can add a `custom/Makefile` file in your sources,
and define 2 custom recipes in this file :

-   `custom_webinst`
    
    Called right before webinst generation.
    Webinst src are in `$(CACHE_WEBINST_DIR)`
    
-   `custom_zip`
    
    Called right before zip generation.
    Zip src are in `$(CACHE_ZIP_DIR)` (lib files are in `$(CACHE_ZIP_DIR)/$(LIB_NAME)`)