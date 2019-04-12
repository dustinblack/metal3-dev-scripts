# Braindump soup-to-nuts log of lab work

## Prerequisites

* Start with a CentOS/RHEL 7.4+ host with virtualization tools.

## Clone repo

```
# git clone https://github.com/dustinblack/metalshift-chimera
# cd metalshift-chimera
```

## Setup pull secret

> Note: `config_*.sh` is already in the `.gitignore` file.

Doing this here for the root user, but note that the scripts look for `config_${USER}.sh`

```
# cp config_example.sh config_root.sh
```

## Simplest no-edit deployment

The Makefile is basically just a wrapper script to run the numbered shell scripts. So in the very simplest terms, you can:

```
# make
````

And that's it. :)
