# Recursively find, remove, and set svn:ignore on files or folders. 
# For safety, you must perform an svn status and an svn commit yourself.
#
# $1 is the pattern to ignore
# $2 is the starting directory (optional)
# $3 is a flag to remove the ignored files locally (optional)
#
# Example: recursive_svn_ignore "*.bak" . --remove
#
recursive_svn_ignore () 
{
    cd "$2";
    svn info > /dev/null 2>&1;
    if [ "$?" -ne "0" ]; then
      echo "Skipping `pwd` because it is not under version control.";
      return 1;
    fi;
    # Check if pattern matches
    ls -l $1 > /dev/null 2>&1;
    if [ "$?" = "0" ]; then
        for f in "$1"; do
            if [ "$3" = "--remove" ]; then
              # Remove file from working directory and repository 
              svn rm --force -q $f; 
            else
              # Remove file from repository only
              svn rm --force --keep-local $f;
            fi;
        done
        echo "Adding "$1" in `pwd` to svn:ignore list";
        svn propget svn:ignore . > svnignore.tempfile;
        echo "$1" >> svnignore.tempfile;
        svn propset -q svn:ignore -F svnignore.tempfile .;
        rm svnignore.tempfile;
    fi;
    # Recurse
    for d in *
    do
        if [ -d "$d" ]; then
            ( recursive_svn_ignore "$1" "$d" )
        fi;
    done
}
