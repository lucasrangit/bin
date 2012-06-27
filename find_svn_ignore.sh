#!/bin/bash
# Recursively find and set svn:ignore on files or folders.
# If the file was already version it will be removed from the repository
# and keep the local copy (can be overridden).
# This does not perform the final commit so you can review the changes
# using svn status.
#
# $1 pattern to ignore
# $2 remove the ignored files locally as well (optional)
# $3 path to start from
#
# Example: find_svn_ignore "*.bak" --remove .
#
pushd $3
for a in `find . -name $1`
do
	svn info ${a%/*} > /dev/null 2>&1;
	if [ "$?" -ne "0" ]; then
		echo "Skipping ${a%/*} because it is not under version control.";
		continue;
	fi;
	echo "Ignoring ${a##*/} in ${a%/*}";
	svn propget svn:ignore ${a%/*} > svnignore.tempfile;
	echo "$1" >> svnignore.tempfile;
	svn propset -q svn:ignore -F svnignore.tempfile ${a%/*};
	rm svnignore.tempfile;
	if [ "$2" = "--remove" ]; then
		# Remove file from working directory and repository 
		svn rm --force -q ${a##*/}; 
	else
		# Remove file from repository only
		svn rm --force --keep-local ${a##*/};
	fi;
done
popd
