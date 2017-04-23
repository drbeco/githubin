# githubin

## Automation of github tasks using API

### github-issue.sh

This script helps a teacher to apply the same issue in a bunch of repositories with the same name structure, just like github classroom creates.

It may be used in group or individual assigments.

#### Group assigments

The prefix is given by the teacher, and the sufix is chosen by the students (or the teacher)

Suppose you have an assignment with the following groups (repositories)

* YourOrg/Pacman-dandy
* YourOrg/Pacman-candy
* YourOrg/Pacman-landy

To use the script and create the same issue in all three repositories you will need:

1. A file with all three sufixes, each one in one single line

> **FILENAME: mysufixes.txt**

> dandy

> candy

> landy

2. A file with your API authenticantion token (defaults its names to AUTHTOKEN if not given)

3. Run the script with the following arguments:

```
./github-issue.sh -i "Issue Title" -o "YourOrg" -b "The body of the issue. You can use \n for newlines." -p "Pacman" -u "Teacher" -f ./mysufixes.txt
```

#### Individual assignments

Suppose you created an individual assignment with all 30 of your students. The github classroom will structure the repository names as:

* YourOrg/SpaceWar-JohnDoe
* YourOrg/SpaceWar-MaryAnn
* YourOrg/SpaceWar-JackXen

and so on... with all your students' names. You will need:

1. A file with all the students logins, one per line:

> **FILENAME: mystudents.txt**

> JohnDoe

> MaryAnn

> JackXen

2. Your authenticantion file (AUTHTOKEN) with your token (keep it secret!)

3. Run the command:

```
./github-issue.sh -i "Issue Title" -o "YourOrg" -b "The body of the issue. You can use \n for newlines." -p "SpaceWar" -u "Teacher" -f ./mystudents.txt
```

---

You can add another options.

* -a "assignee" : to assign all the issues to one single person
* -s : to assign each issue to the student (individual assignment given by the sufix)
* -l "label" : to attach a label. If you skip this, it will attach the label "task"
* -m N : to attach a milestone to the issue.

---

Try -h for more help


## Author

* Prof. Dr. Ruben Carlo Benante
* Email: rcb@beco.cc
* Date: 2017-04-22
* License: GNU/GPL v2.0

