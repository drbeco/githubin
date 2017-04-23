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
#    $ github-issue.h -i {"issue title" | "issue-file.txt"} [-b "issue body"] -o "repo owner"
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
    github-issue.sh [ -v... ] [ -h | -V | -n ] 
                    -i { "Issue title" | "issue-file" }
                    -o "RepoOwner"
                    [ -b "The issue body goes here" ]
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
        -i, --issue      The issue title or an issue-file. If a file is given, its content will be used as title (first line) and body.
        -o, --owner      Repository owner name (person or organization).
        -b, --body       The issue body of message. If to -i is given a file, this option is not used.

        -r, --repo       Repository name.
        -p, --prefix     Repository has a prefix, and sufix comes from stdin (or redirected file). Not to be used with -r.

        -f, --file       A text file with sufixes for the repository name.
                         If the sufixes happen to be github usernames, one can use the -s option to assign the issue to each correponding name.
                         This option is mandatory in the presence of -p and it is forbidden in the presence of -r.

        -u, --user       The user that will run the API.

      Optionals:
        -l, --label      Label to attach (default "task").
        -m, --milestone  The milestone number to associate. 
                         If it doesn't exist:
                            * for a single repository, the script will exit with error 1
                            * for multiple repositories, the script will ignore the ones where the milestone doesn't exist and use it in the ones where it does exit.

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
 

    # verbose : the level of verbosity
    if [ "$verbose" -gt 0 ]; then
        echo Starting git-issue.sh script, by beco, version 20170422.163806...
    fi
    if [ "$verbose" -gt 1 ]; then
        echo Verbose level: $verbose
    fi
    
    if [ "$dryrun" -eq 1 ]; then
        echo "Dry-run: no data will be sent. If milestone is used, data will be sent just for asking if it exists."
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
    # issue has title, or is it a file
    if [ -z "$issue" ]; then
        echo 'You must give -i "issue title" or -i "issue-filename.txt"'
        if [ "$verbose" -gt 0 ]; then
            echo
            Help
        else
            echo 'For more help type: github-issue.sh -h'
        fi
        exit 1
    else
        if [ -f "$issue" ]; then
            title="$(head -1 $issue)"
            body="$(tail -n+2 $issue | gawk '{printf "%s\\n", $0}' | gawk '{ gsub(/"/,"\\\"") } 1')"
            #body1=`echo "$body0" | gawk '{printf "%s\\n", $0}'`
        else
            title="$issue"
        fi
    fi

    # if there is no body, raise an error
    if [ -z "$body" ]; then
        echo 'You must give -b "The body of the issue"'
        if [ "$verbose" -gt 0 ]; then
            echo
            Help
        else
            echo 'For more help type: github-issue.sh -h'
        fi
        exit 1
    fi

    # repository owner
    if [ -z "$owner" ]; then
        echo 'You must give -o "repository owner"'
        if [ "$verbose" -gt 0 ]; then
            echo
            Help
        else
            echo 'For more help type: github-issue.sh -h'
        fi
        exit 1
    fi

    # user is set
    if [ -z "$user" ]; then
        echo 'You must give the API github username -u "username"'
        if [ "$verbose" -gt 0 ]; then
            echo
            Help
        else
            echo 'For more help type: github-issue.sh -h'
        fi
        exit 1
    fi

    # Exclusive or: a repository name or a prefix to a repository name
    if [ -z "$repo" -a -z "$prefix" -o -n "$repo" -a -n "$prefix" ]; then
        echo 'Use one and only one of the two options -r and -p (i.e, give a repository name XOR a prefix)'
        if [ "$verbose" -gt 0 ]; then
            echo
            Help
        else
            echo 'For more help type: github-issue.sh -h'
        fi
        exit 1
    fi

    # assignee-sufix not with assignee or repo
    if  [ -n "$assignee" -o -n "$repo" ] && [ "$asufix" -eq 1 ]; then
        echo 'You must not use -s (assignee-sufix) togheter with -a (assignee) or -r (repo)'
        if [ "$verbose" -gt 0 ]; then
            echo
            Help
        else
            echo 'For more help type: github-issue.sh -h'
        fi
        exit 1
    fi
    #if [ "$verbose" -gt 1 ]; then
    #echo "A single assignee for all repos: $assignee"
    #fi
    #if [ "$verbose" -gt 1 ]; then
    #echo "Assignees are grabed from file"
    #fi
    
    # File must be given if using -p
    if [ ! -f "$file" -a -z "$repo" ]; then
        echo 'Please provide -f "sufixes-file" to grab the sufixes when giving a -p "prefix"'
        if [ "$verbose" -gt 0 ]; then
            echo
            Help
        else
            echo 'For more help type: github-issue.sh -h'
        fi
        exit 1
    fi

    # File must NOT be given if using -r
    if [ -n "$file" -a -n "$repo" ]; then
        echo 'You can not use a -f "sufixes-file" when given the repository name with -r "repo"'
        if [ "$verbose" -gt 0 ]; then
            echo
            Help
        else
            echo 'For more help type: github-issue.sh -h'
        fi
        exit 1
    fi

    # Default labe="bug" and milestone="1"
    if [ -z "$label" ]; then
        label="task"
        if [ "$verbose" -gt 0 ]; then
            echo "Using default label $label"
            echo
        fi
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
        if [ "$verbose" -gt 1 ]; then
            echo "Using token file $tokenfile"
        fi
    else
        tok="$token"
        if [ "$verbose" -gt 1 ]; then
            echo "Using token $token"
        fi
    fi

    #Check if the asked milestone exists
    if [ -n "$milestone" ]; then
        # single issue in a repo
        if [ -n "$repo" ];  then
            curl -u "${user}:${tok}" -i https://api.github.com/repos/"${owner}"/"${repo}"/milestones/"${milestone}" | grep "Status: 20[0-6]"
            milexists=$?
            if [ "$milexists" -eq 1 ]; then
                echo "Milestone $milestone does not exist"
                if [ "$dryrun" -eq 0 ]; then
                    exit 1
                fi
            fi
        fi
    fi

    #issue="" body="" label="" milestone="" owner="" repo="" prefix="" assignee="" asufix=0
   
    head0="{\"title\":\"$title\", \"body\":\"$body\", \"labels\":[\"$label\"]"
    headmile="$head0, \"milestone\":\"$milestone\""
    if [ -n "$milestone" ]; then
        head="$headmile" #title, body, labels, milestone
    else
        head="$head0" #title, body, labels
    fi

    # Debug
    # set -x

    # single issue in a repo
    if [ -n "$repo" ];  then
        if [ "$verbose" -gt 1 ]; then
            echo "A single repo $repo will be used"
            echo
        fi
        if [ -n "$assignee" ]; then
            theend=", \"assignee\":\"$assignee\"}"
        else
            theend="}"
        fi
        field="$head$theend"
        if [ "$dryrun" -eq 1 ]; then
            echo curl -u \'"${user}:${tok}"\' -X POST -d \'"${field}"\' -i https://api.github.com/repos/"${owner}"/"${repo}"/issues
            echo
        else
            # run curl to create the issue
            curl -u "${user}:${tok}" -X POST -d "${field}" -i https://api.github.com/repos/"${owner}"/"${repo}"/issues | grep "Status: 20[0-6]"
            success=$?
            if [ "$verbose" -gt 0 -a "$success" -eq 1 ]; then
                echo "Error creating issue"
                echo
            fi
        fi
    else # read from file the suffix (may or may not be also the assignee)
        if [ "$verbose" -gt 1 ]; then
            echo "A list of repositories will be created with suffix read from file $file"
            echo
        fi
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
                echo curl -u \'"${user}:${tok}"\' -X POST -d \'"${field}"\' -i https://api.github.com/repos/"${owner}"/"${prefix}${suf}"/issues
                echo
            else
                # check milestone
                if [ -n "$milestone" ]; then
                    curl -u "${user}:${tok}" -i https://api.github.com/repos/"${owner}"/"${prefix}${suf}"/milestones/"${milestone}" | grep "Status: 20[0-6]"
                    milexists=$?
                    if [ "$milexists" -eq 1 ]; then
                        echo "Milestone $milestone does not exist"
                        field="$head0$theend" #head0 = title, body, labels
                    fi
                fi

                # run curl to create the issue
                curl -u "${user}:${tok}" -X POST -d "${field}" -i https://api.github.com/repos/"${owner}"/"${prefix}${suf}"/issues | grep "Status: 20[0-6]"
                success=$?
                if [ "$verbose" -gt 0 -a "$success" -eq 1 ]; then
                    echo "Error creating issue"
                    echo
                fi
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

