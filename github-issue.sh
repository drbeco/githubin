#!/bin/bash
#
# **************************************************************************
# * (C)opyright 2017         by Ruben Carlo Benante  @drbeco               *
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
#
# github-issue.sh
# 
# Add the same issue to a list of repositories
#
# Usage:
#
#    $ github-issue.h -i "issue title" -b "issue body" -o "repo owner"
#       -l "label" -m "milestone"
#       -r "repo" OR -p "prefix-"
#       -a "assignee" OR -s
#       -f ./github-sufixes.txt
#       -u "login" -t {"token" | "tokenfile"}
#

Help()
{
    cat << EOF
    github-issue.sh - Creates a git issue on 

    Usage:
    github-issue.sh [ -v... ] [ -h | -V | -n ] -i "Issue title" -b "The issue body goes here" -o "RepoOwner"
                    [ -l "label" ] [ -m "milestone" ]
                    { -r "SingleRepo" | -p "RepoPrefix-" }
                    [ -a "SingleAssignee" | -s ]
                    {[ -f ./github-sufixes.txt ]}
                    -u "login" -t { "token" | "tokenfile" }

    Options:
    
      Informative:
        -h, --help       Show this help.
        -V, --version    Show version.
        -v, --verbose    Turn verbose mode on (cumulative).
        -n, --dry-run    Just print the fields, but do not run.

      Mandatory:
        -i, --issue      The issue title.
        -b, --body       The issue body of message.
        -o, --owner      Repository owner name (person or organization).

        -r, --repo       Repository name.
        -p, --prefix     Repository has a prefix, and sufix comes from stdin (or redirected file). Not to be used with -r.

        -f, --file       A text file with sufixes for the repository name.
                         If the sufixes happen to be github usernames, one can use the -s option to assign the issue to each correponding name.
                         This option is mandatory in the presence of -p and it is forbidden in the presence of -r.

        -u, --user       The user that will run the API.

      Optionals:
        -l, --label      Label to attach (default "task").
        -m, --milestone  The milestone number to associate.

        -a, --assignee   Associate all the issues with the same given user.
        -s, --sufix      Used with -p, given sufix is also the assignee. Not to be used with -a or -r.

        -t, --token      The user's API authentication token or a file containing the token. If not given, the script will look into AUTHTOKEN file. If it is given as a filename, the script will get the token from it. If the file doesn't exist, the script will understand that the given string is the actual token.

    Exit status:
       0, if ok.
       1, some error occurred.
  
    Todo:
            Long options not implemented yet.

    Author:
            Written by Ruben Carlo Benante <rcb@beco.cc>  
            Date: 2017-04-22

EOF
    exit 1
}
# Another usage function example
# usage() { echo "Usage: $0 [-h | -c] | [-a n -i m], being n>m" 1>&2; exit 1; }

Copyr()
{
    echo 'git-issue.sh - 20160908.175403'
    echo
    echo 'Copyright (C) 2017 Ruben Carlo Benante <rcb@beco.cc>, GNU GPL version 2'
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
    issue=""
    body=""
    label=""
    milestone=""
    owner=""
    repo=""
    prefix=""
    assignee=""
    asufix=0
    file=""
    dryrun=0
    user=""
    token=""

    #getopt example with switch/case
    local OPTIND
    while getopts "hVvni:b:o:l:m:r:p:a:sf:u:t:" FLAG; do
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
            i)
                issue="${OPTARG}"
                ;;
            b)
                body="${OPTARG}"
                ;;
            l)
                label="${OPTARG}"
                ;;
            m)
                milestone="${OPTARG}"
                ;;
            o)
                owner="${OPTARG}"
                ;;
            r)
                repo="${OPTARG}"
                ;;
            p)
                prefix="${OPTARG}"
                ;;
            a)
                assignee="${OPTARG}"
                ;;
            s)
                asufix=1
                ;;
            u)
                user="${OPTARG}"
                ;;
            t)
                token="${OPTARG}"
                ;;
            n)
                dryrun=1
                ;;
            f)
                file="$OPTARG"
                ;;
            *)
                Help
                ;;
        esac
    done
  
    # issue has title, body and repository owner
    if [ -z "$issue" -o -z "$body" -o -z "$owner" ]; then
        echo 'You must give: -i "issue title", -b "issue body" and -o "repository owner"'
        echo 'For more help type: github-issue.sh -h'
        exit 1
    fi

    # user is set
    if [ -z "$user" ]; then
        echo 'You must give the API github username -u "username"'
        echo 'For more help type: github-issue.sh -h'
        exit 1
    fi

    # Exclusive or: a repository name or a prefix to a repository name
    if [ -z "$repo" -a -z "$prefix" -o -n "$repo" -a -n "$prefix" ]; then
        echo 'Use one and only one of the two options -r and -p (i.e, give a repository name XOR a prefix)'
        echo 'For more help type: github-issue.sh -h'
        exit 1
    fi

    # assignee-sufix not with assignee or repo
    if  [ -n "$assignee" -o -n "$repo" ] && [ "$asufix" -eq 1 ]; then
        echo 'You must not use -s (assignee-sufix) togheter with -a (assignee) or -r (repo)'
        echo 'For more help type: github-issue.sh -h'
        exit 1
    fi
    
    # File must be given if using -p
    if [ ! -f "$file" -a -z "$repo" ]; then
        echo 'Please provide -f "sufixes-file" to grab the sufixes when giving a -p "prefix"'
        echo 'For more help type: github-issue.sh -h'
        exit 1
    fi

    # File must NOT be given if using -r
    if [ -n "$file" -a -n "$repo" ]; then
        echo 'You can not use a -f "sufixes-file" when given the repository name with -r "repo"'
        echo 'For more help type: github-issue.sh -h'
        exit 1
    fi

    # Default labe="bug" and milestone="1"
    if [ -z "$label" ]; then
        label="task"
    fi

    # Token from file or command line
    tokenfile=""
    if [ -z "$token" ]; then
        if [ -f ./AUTHTOKEN ]; then
            tokenfile="./AUTHTOKEN"
        fi
    else
        if [ -f "$token" ]; then
            tokenfile="$token"
        fi
    fi
    if [ -n "$tokenfile" ]; then
        read tok <  "$tokenfile"
    else
        tok="$token"
    fi

    if [ "$verbose" -gt 0 ]; then
        echo Starting git-issue.sh script, by beco, version 20170422.163806...
    fi
    if [ "$verbose" -gt 1 ]; then
        echo Verbose level: $verbose
    fi
    
    #curl -u "$user:$tok"
    # -X POST -d 
    #    '{
    #       "title":"Criar issues", 
    #       "body":"Crie varios issues.",
    #       "assignee":"someuserhere", 
    #       "milestone":"1", 
    #       "labels":["task"]
    #       "assignees":[{"login":"someuser"}]
    #     }' 
    # -i https://api.github.com/repos/drbeco/tgit/issues 

    #issue="" body="" label="" milestone="" owner="" repo="" prefix="" assignee="" asufix=0
   
    head0="{\"title\":\"$issue\", \"body\":\"$body\", \"labels\":[\"$label\"]"
    if [ -n "$milestone" ]; then
        head="$head0, \"milestone\":\"$milestone\""
    else
        head="$head0"
    fi

    # single issue in a repo
    if [ -n "$repo" ];  then
        if [ -n "$assignee" ]; then
            theend=", \"assignee\":\"$assignee\"}"
        else
            theend="}"
        fi
        field="$head$theend"
        if [ "$dryrun" -eq 1 ]; then
            echo curl -u "$user:$tok" -X POST -d "$field" -i https://api.github.com/repos/"$owner"/"$repo"/issues
        else
            curl -u "$user:$tok" -X POST -d "$field" -i https://api.github.com/repos/"$owner"/"$repo"/issues
        fi
    else # read from file the suffix (may or may not be also the assignee)
        while read suf; do            
            if [ -n "$assignee" ]; then
                theend=", \"assignee\":\"$assignee\"}"
            else
                if [ "$asufix" -eq 1 ]; then
                    theend=", \"assignee\":\"$suf\"}"
                else
                    theend="}"
                fi
            fi
            field="$head$theend"
            if [ "$dryrun" -eq 1 ]; then
                echo curl -u "$user:$tok" -X POST -d "$field" -i https://api.github.com/repos/"$owner"/"$prefix$suf"/issues
            else
                curl -u "$user:$tok" -X POST -d "$field" -i https://api.github.com/repos/"$owner"/"$prefix$suf"/issues
            fi
        done < "$file"
    fi
}

#Calling main with all args
main "$@"
echo Success
exit 0

#/* -------------------------------------------------------------------------- */
#/* vi: set ai et ts=4 sw=4 tw=0 wm=0 fo=croql : SHELL config for Vim modeline */
#/* Template by Dr. Beco <rcb at beco dot cc> Version 20160714.124739          */
