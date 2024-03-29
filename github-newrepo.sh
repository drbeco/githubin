#!/bin/bash

# **************************************************************************
# * (C)opyright 2016-2017         by Ruben Carlo Benante                   *
# *                                                                        *
# * This program is free software; you can redistribute it and/or modify   *
# *  it under the terms of the GNU General Public License as published by  *
# *  the Free Software Foundation version 2 of the License.                *
# *                                                                        *
# * This program is distributed in the hope that it will be useful,        *
# *  but WITHOUT ANY WARRANTY; without even the implied warranty of        *
# *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
# *  GNU General Public License for more details.                          *
# *                                                                        *
# * You should have received a copy of the GNU General Public License      *
# *  along with this program; if not, write to the                         *
# *  Free Software Foundation, Inc.,                                       *
# *  59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
# *                                                                        *
# * Contact author at:                                                     *
# *  Ruben Carlo Benante                                                   *
# *  rcb@beco.cc                                                           *
# **************************************************************************

Help()
{
    cat << EOF
    ${0} - Creates a git repository
    Usage: ${0} [-h|-V] | [-v...] {-f|-g} -r reponame -u username  -t { "token" | "tokenfile" }
  
    Options:
      -h, --help       Show this help.
      -V, --version    Show version.
      -v, --verbose    Turn verbose mode on (cumulative).
      -f, --faculty    Uses Faculty/University template.
      -g, --general    Uses general template.
      -r, --repo       Repository (directory) name.
      -u, --user       Your Github username.
      -t, --token      Your token or a file with it (defaults to AUTHTOKEN file).

    Exit status:
       0, if ok.
       1, some error occurred.
  
    Todo:
            Long options not implemented yet.
  
    Author:
            Written by Ruben Carlo Benante <rcb@beco.cc>  

EOF
    exit 1
}
# Another usage function example
# usage() { echo "Usage: $0 [-h | -c] | [-a n -i m], being n>m" 1>&2; exit 1; }

Copyr()
{
    echo "${0} - 20160908.175403"
    echo
    echo 'Copyright (C) 2016 Ruben Carlo Benante <rcb@beco.cc>, GNU GPL version 2'
    echo '<http://gnu.org/licenses/gpl.html>. This  is  free  software:  you are free to change and'
    echo 'redistribute it. There is NO WARRANTY, to the extent permitted by law. USE IT AS IT IS. The author'
    echo 'takes no responsability to any damage this software may inflige in your data.'
    echo
    exit 1
}

# Example of a function
main()
{
    verbose=0
    faculty=0
    general=0
    tokenarg=""
    #getopt example with switch/case
    while getopts "hVvfgr:u:t:" FLAG; do
        case "${FLAG}" in
            h)
                Help
                ;;
            V)
                Copyr
                ;;
            v)
                let verbose=verbose+1
                ;;
            f)
                faculty=1
                ;;
            g)
                general=1
                ;;
            r)
                repo="${OPTARG}"
                ;;
            u)
                user="${OPTARG}"
                ;;
            t)
                tokenarg="${OPTARG}"
                ;;
            *)
                Help
                ;;
        esac
    done

    if [ "$faculty" -eq "$general" ]; then
        echo 'Error: use one and only one of -f or -g, they are mutually exclusive.'
        echo
        Help
    fi

    dirroot=`dirname ${0}`
    if [ "$faculty" -eq 1 ]; then
        srcfrom="${dirroot}/newrepo-template/university"
    else
        srcfrom="${dirroot}/newrepo-template/general"
    fi

    if [ -z "$user" -o -z "$repo" ]; then
        echo You must give -u user_name and -r repository_name
        echo
        Help
    fi
  
    if [ "$verbose" -gt 0 ]; then
        echo Starting "${0}" script, by beco, version 20170504.222818...
    fi
    if [ "$verbose" -gt 1 ]; then
        echo Verbose level: "$verbose"
    fi
  
    # Token from file or command line
    olddir=`pwd`
    cd ${dirroot}
    tokenfile=""
    if [ -z "$tokenarg" ]; then
        if [ -f ./AUTHTOKEN ]; then
            tokenfile="./AUTHTOKEN"
        fi  
    else
        if [ -f "$tokenarg" ]; then
            tokenfile="$tokenarg"
        fi  
    fi  
    if [ -n "$tokenfile" ]; then
        read tok <  "$tokenfile"
        if [ "$verbose" -gt 1 ]; then
            echo "Using token file $tokenfile"
        fi  
    else
        tok="$tokenarg"
        if [ "$verbose" -gt 1 ]; then
            echo "Using token $tok"
        fi  
    fi  

    # ------------------------------------------------------------

    echo "Creating folder $repo"
    cd $olddir
    mkdir "$repo"
    cd "$repo"

    echo 'Initializing repo: git init'
    git init

    echo 'Copying files: AUTHORS, LICENSE, README.md and makefile'
    cp -- "$srcfrom/"* . > /dev/null 2>&1 

    echo 'Copying exN.c, exN.h and .gitignore'
    cp -- "$srcfrom/c/"* .
    mv -- gitignore .gitignore
    #TODO .gitattributes
    
    echo 'Copying .github files (guidelines) CODE-OF-CONDUCT, CONTRIBUTING, ISSUE_TEMPLATE, PULL_REQUEST_TEMPLATE'
    mkdir .github
    cp -- "$srcfrom/github/"* .github/

    echo 'Creating tags'
    ctags -R
    #make tags > /dev/null
    
    echo 'Adding, commiting and pushing'
    git add .
    git commit -m "First commit: imported by ${0} using ${srcfrom}"

    baseurl='https://api.github.com/'
    echo "Creating remote repository at Github $user/$repo.git"
    if [ "$user" == "drbeco" ]; then
        echo User $user
        exturl='user/repos'
        totalurl=${baseurl}${exturl}
        # curl -u "${user}:${tok}" https://api.github.com/user/repos -d "{\"name\":\"$repo\", \"private\":\"true\"}" 2>&1 | grep "full_name"
        curl -H "Authorization: token ${tok}" -d "{\"name\":\"$repo\", \"private\":\"true\"}" ${totalurl} # 2>&1 | grep "full_name"
    else
        echo Organization $user
        exturl="${user}/repos"
        totalurl=${baseurl}${exturl}
        # curl -u "${user}:${tok}" https://api.github.com/orgs/$user/repos -d "{\"name\":\"$repo\", \"private\":\"true\"}" 2>&1 | grep "full_name"
        curl -H "Authorization: token ${tok}" -d "{\"name\":\"$repo\", \"private\":\"true\"}" ${totalurl} # 2>&1 | grep "full_name"
    fi

    created=$?

    if [ "${created}" == "1" ]; then
        echo "Could not create remote repository."
        echo "Please do it manually: create repository, add master and develop branchs and push the current working directory."
        echo "0> At github site, choose create new repository $repo"
        echo "1>$ git remote add origin git@github.com:$user/$repo.git"
        echo "2>$ git push -u origin master"
        echo "3>$ git co -b develop"
        echo "4>$ git push -u origin develop"
        echo
        echo "Program aborting."
        exit 1
    fi

    #user="drbeco:${tok}" ; repo="t3test" ; 
    #curl -u "$user" https://api.github.com/user/repos -d "{\"name\":\"$repo\"}"

    echo 'Pushing to the remote GitHub repository'
    #git remote add origin git@github.com:drbeco/t3test.git
    git remote add origin "git@github.com:$user/$repo.git"
    git push -u origin master

    echo 'Creating a remote develop branch'
    git co -b develop
    git push -u origin develop

}

#Calling main with all args
main "$@"
echo Success
exit 0

#/* -------------------------------------------------------------------------- */
#/* vi: set ai et ts=4 sw=4 tw=0 wm=0 fo=croql : SHELL config for Vim modeline */
#/* Template by Dr. Beco <rcb at beco dot cc> Version 20160714.124739          */

