=========
crashplan
=========

Salt formula to install and configure crashplan.

.. note::

    See the full `Salt Formulas installation and usage instructions
    http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html`_.

    See pillar.example, defaults.yaml for setup.

    Download and add Crashplan binaries to `files/`.

Available states
================

.. contents::
    :local:


``crashplan``
-------------

Manages package download, install, running (including updates) for crashplan.


How it Works
------------
Because crashplan does not have a public repo for installer packages, we
manually distribute the binaries from files/ (you can download these from your
crashplan login).

A version is staged in /var/opt/crashplan/<version>, and this directory is used
to detect if a new version has been installed (e.g. there will be another
version dir).

We run the uninstall crashplan script - which removes the service but keeps the
data, then run the install for the new package.

archive.extracted will only download these fairly large packages once as long
as they remain in the minion cache, which is persistent across reboots and state
runs by default. If the cache is deleted, the file will be re-downloaded
regardless of whether it needs to be reinstalled or not.

Todo
----
* Currently, only default install options as well as installation dir cannot be
  changed. Don't change these in pillar!
* Only linux machines are supported now. OSX/Windows will be implemented later.
