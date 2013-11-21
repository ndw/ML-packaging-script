ML-packaging-script
===================

MarkLogic 7 ships with a
[new REST API](http://docs.marklogic.com/REST/packaging) to work with
packages. Packages allow you to move database and application server
settings between clusters.

For example, if you've been developing a new version of an application
on your development machine, you can make a package that contains all
of the databases and application servers related to that application.
Download that package as a ZIP file, move it to your staging cluster,
and install it. Now your staging cluster has all the correct settings,
no tedious poking about in the
[Admin UI](http://docs.marklogic.com/guide/admin/admin_inter)
required.

The easiest way to create and install packages is with the
[Configuration Manager](http://docs.marklogic.com/guide/admin/config_manager#chapter)
UI.

Except, I'm not really a UI kind of guy. And there's a rest API. So I
can create a package straight from the shell:

```
curl -s -X POST --digest -u admin:admin --data-ascii @/dev/null \
-H "Accept: application/xml" -H "Content-Type: application/xml" \
http://localhost:8002/manage/v2/packages?pkgname=myNewPackage
```

Except, ugh. Typing all that is tedious and error prone.

Enter `pkg.sh`, a collection of handy Bash functions to make using
the packaging API easier.

Just source it into your shell:

```
. pkg.sh
```

Then you can create a package like this:

```
pkg_create myNewPackage
```

Add the settings for the Documents database to it:

```
pkg_add_database_config myNewPackage Documents
```

Download it:

```
pkg_get myNewPackage /tmp/package.zip
```

And on the target cluster, I can load that package:

```
pkg_create myNewPackage /tmp/package.zip
```

And install it:

```
pkg_install myNewPackage
```

If you want to see what the package will change, you can run
`pkg_diff` before doing the install. It's easier to see the differences in
the UI, though, so if you aren't sure what the package does, it's probably
better to do the install half in the UI.

Anyway, here are the commands you get:

```
pkg_help
pkg_database_configuration      [-xml|-json] database [filename]
pkg_all_database_configurations [-xml|-json] [filename]
pkg_server_configuration        [-xml|-json] [-modules] group server [filename]
pkg_all_server_configurations   [-xml|-json] [filename]
pkg_list                   [-xml|-json] [start] [length]
pkg_create                 [-xml|-json] pkgname [filename]
pkg_exists                 pkgname
pkg_get                    pkgname [filename]
pkg_add                    [-xml|-json] pkgname filename
pkg_delete                 pkgname
pkg_list_databases         [-xml|-json] pkgname [start] [length]
pkg_database_exists        [-xml|-json] pkgname database
pkg_get_database           [-xml|-json] pkgname database [filename]
pkg_add_database           [-xml|-json] pkgname database filename
pkg_add_database_config    [-xml|-json] pkgname database [database...]
pkg_delete_database        [-xml|-json] pkgname database
pkg_list_servers           [-xml|-json] pkgname [start] [length]
pkg_server_exists          [-xml|-json] pkgname group server
pkg_get_server             [-xml|-json] [-modules] pkgname group server [filename]
pkg_add_server             [-xml|-json] [-modules] pkgname group server filename
pkg_add_server_config      [-xml|-json] [-modules] pkgname group server [server...]
pkg_delete_server          [-xml|-json] pkgname group server
pkg_post                   pkgname filename
pkg_diff                   [-xml|-json] [-only] pkgname [filename]
pkg_errors                 [-xml|-json] [-installable] pkgname
pkg_valid                  [-xml|-json] pkgname
pkg_install                [-xml|-json] pkgname
pkg_revert                 [-xml|-json] ticketnumber

-xml|-json specifies the required return type. The format of data
posted is determined by the filename (.json=JSON, anything else=XML)
```

Configuration
-------------

Before you source `pkg.sh`, set the environment variables `MLUSER` and `MLPASS` to
the username and password of the MarkLogic user that will be performing the
package commands.

You can also set `BASE` to change the base URI of the package REST API. There
are a couple of other settings at the top of `pkg.sh` that you might want to
check out.

Most (but not all) commands take an undocumented initial `-d` option
that will display the actual curl command invoked.

Share and enjoy!
----------------

(Oh, and if you convert the Bash functions to some other shell, feel free
to send a pull request and I'll add 'em. Or, you know, just use bash.)
