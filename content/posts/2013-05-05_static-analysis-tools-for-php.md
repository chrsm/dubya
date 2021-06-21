---
title: "[archive] Static analysis tools for PHP"
description: ""
date: "2013-05-05"
indexes: [ "post" ]
groups: [ "post" ]
---

I believe in writing code that is easy to understand, easy to test, and easy to refactor.

Yes, I realize that the statement above is pretty general and open to interpretation. Not everyone needs external tools to ensure quality in their code...but, I work on things from time to time that have absolutely no tests. No unit tests, no functional tests, no browser tests, no code quality analysis. Needless to say, some of those things make me want to tear my eyes out. Frankly, though, when a project hits success, there is rarely time to go back and ensure quality of old code - instead, we find ourselves merely bolting on new things. <em>Writing software does not have to be this way.</em>

For whatever reason, this happens a lot more frequently in the PHP world. I'm guilty of not writing tests and checking how I write code, sometimes, too. Things are bright, though, for the PHP community - for quite some time now, we've had fantastic tools that assist us in writing better code. The fact that these tools are available is evident to all - but, if you've found yourself wondering just why you'd want to use some of them, read on and explore your options. I will do my best to explain what each tool is for, as well as explain how I've built these in to my workflow.

I won't cover tools like PHPUnit here, since they're not necessarily automated - while unit tests can help you uncover bugs or prevent regressions, they still need to be written first.

*Note: This post is extremely dry, and I apologize for that in advance. If you want more or specific information, feel free to contact me - I'd love to hear from you.*

* [PHP Mess Detector](#phpmd)
* [PHP Copy/Paste Detector](#phpcpd)
* [PHP CodeSniffer](#phpcs)
* [PHP Analyzer](#phpalizer)
* [Pfff](#pfff)
* [How I use these tools in every day work](#build)

<h2 id="phpmd">PHP Mess Detector</h2>
[PHP Mess Detector](http://phpmd.org/) (PHPMD) is pretty similar to PDepend, and provides reporting for bugs, unused code and overly complex functionality. It's very useful for identifying spots that could use some refactoring.

PHPMD can be invoked from the command line like so:

    phpmd {directory} {report format} {rules}

    $ phpmd . text codesize,unusedcode 

    /src/xxxxxx/api/src/base/Model.php:75    The method __toArray() has a Cyclomatic Complexity of 12. The configured cyclomatic complexity threshold is 10.
    /src/xxxxxx/api/src/controller/Users.php:235    Avoid unused parameters such as '$request'.
    /src/xxxxxx/api/src/controller/Users.php:246    Avoid unused local variables such as '$x'.
    /src/xxxxxx/api/src/controller/Users.php:246    Avoid unused local variables such as '$undeclared'.
    /src/xxxxxx/api/src/base/Controller.php    -    Unexpected token: [, line: 88, col: 56, file: /src/xxxxxx/api/src/base/Controller.php.

The project I'm running PHPMD on isn't very large at the moment, so I added some issues that it could pick up on. 
I only used the code size and unused code rules, but [there are a few more](http://phpmd.org/rules/) that are available. 
Each one of these can either be ignored or configured to taste - for example, the minimum name length for a method on a class with stock PHPMD is three. 
I lowered this to two in one specific subset of what I run the tool on.

As an aside, if you are unfamiliar with [cyclomatic complexity](http://en.wikipedia.org/wiki/Cyclomatic_complexity), [take a few minutes to read](http://pdepend.org/documentation/software-metrics/cyclomatic-complexity.html) about it. 
It is inevitable that you will have some code that is too complicated, but absolutely unnecessary to refactor. 
That being said, you may not always be the person working on your code - so do it anyways!

<h2 id="phpcpd">PHP Copy/Paste Detector</h2>
[PHP Copy/Paste Detector](https://github.com/sebastianbergmann/phpcpd) does exactly what its name implies - it detects code that is duplicated throughout your codebase. 
This is useful because it identifies areas that can instead be refactored to share code, reducing the amount of overall lines of code in your project! 
I like to think that this leads to a more solid, well tested codebase as it is trivial to identify bugs in one area vs several.

PHPCPD can be invoked via the command line like so:

    phpcpd {directory or file}

PHPCPD also has some useful command line switches that you can use to adjust its analysis. For example, you can control the minimum lines of code that must be the same in order to trigger output (--minimum-lines) or a minimum amount of tokens (--minimum-tokens), exclude directories (--exclude) or only check specific files (--names). If you want to see the exact code that is duplicated, you can also use the --verbose switch to write the code to stdout.

Here's a somewhat contrived example from the same project as above.

    phpcpd --verbose .
    phpcpd 1.4.1 by Sebastian Bergmann.

    Found 2 exact clones with 23 duplicated lines in 4 files:

    - /src/xxxx/api/src/model/Xxxx.php:9-25
    /src/xxxx/api/src/model/Xxxx.php:9-25

    namespace app\model;

    use app\base\Model;

    use morph\property\String;
    use morph\property\Integer;

    class Xxxx extends Model
    {

        public function __construct($id = null)
        {
            parent::__construct($id);

            $this-&gt;addProperty(new String('name'))->addValidator('name', 'string,min:3,max:255');

    - /src/xxxx/api/src/model/Xxxxx.php:65-72
    /src/xxxx/api/src/model/Xxxxx.php:53-60

            if ((string) $x->id() == (string) $id) {
                unset($this->xxxx[$index]);
                break;
            }
        }

        return $this;

    1.38% duplicated lines out of 1666 total lines of code.

    Time: 0 seconds, Memory: 3.50Mb

As you can see, it picks up two models that have similar code dealing with removing data from an property set.
Instead of having this code in two separate places, it could either be moved to the models' parent or into a trait 
(if it was functionality that it begged to be in a trait, of course).


<h2 id="phpcs">PHP CodeSniffer</h2>
[PHP CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer) is probably the best tool at the moment; ridiculously easy to set up, and the default standards are easy to extend 
or replace with your own. Because of this, it's a no-brainer for teams consisting of more than a few people. 
It also ships with PSR-1 and PSR-2 standards, so maintaining an open-source, PSR-compatible project is just a matter of installing and running it against your project 
(and, of course, following its advice). It also has the ability to tokenize JavaScript and CSS.

PHPCS is easily invoked from the command line via:

    phpcs --standard={comma-separated rulesets} {directory}

With PHPCS' output, it is trivial to maintain style guidelines in any project. Example output from the same project I'm boring you all with so far:

    $ phpcs --standard=PSR1,PSR2 .
    FILE: /src/xxxx/api/src/exception/Xxx.php
    --------------------------------------------------------------------------------
    FOUND 1 ERROR(S) AFFECTING 1 LINE(S)
    --------------------------------------------------------------------------------
    15 | ERROR | The closing brace for the class must go on the next line after | | the body
    --------------------------------------------------------------------------------

    Time: 0 seconds, Memory: 5.25Mb

As someone working with another developer, style consistency is truly helpful. 
No two people code exactly the same, and when <em>everyone</em> injects their own way of doing things into the code, things tend to get messy. 
This is why PHPCS is so great - you don't have to use the standards that ship with it as it is easy to write your own. 
When all of your codebase follows the same standard, anyone can drop in and be able to read the code without having to mentally switch to the last developer 
to touch the code's style.

<h2 id="phpalizer">PHP Analyzer</h2>
[PHP Analyzer](https://scrutinizer-ci.com/docs/tools/php/php-analyzer/) is actually relatively new and is only two months old as of this moment. 
Don't mistake its age for immaturity, though - the tool has a ton of things it checks for (and a few it can fix automatically). I won't take the time to list them all.

You can invoke PHP analyzer via the CLI like so:

    phpalizer run {directory}

Depending on the size of your codebase, the analysis can take a long time, especially when it attempts type interference. 
There are a few things it does not yet understand, which I'll describe after the following example output.

    $ phpalizer run .
    Messeduponpurpose.php
    =============
    Line 25: The variable ``$b`` does not exist. Did you forget to declare it?
    Line 27: The assignment to ``$a`` is dead and can be removed.

    model/Xxxxx.php
    =================
    Line 16: There is at least one abstract method in this class. Maybe declare it as abstract, or implement the remaining methods: isValid, getInvalidData

    model/BrokenUser.php
    ==============
    Line 17: There is at least one abstract method in this class. Maybe declare it as abstract, or implement the remaining methods: isValid, getInvalidData
    Line 56: ``str_split($password, 72)`` cannot be passed to ``array_shift()`` as the parameter ``$array`` expects a reference.

    httpkernel/ControllerResolver.php
    =================================
    Line 22: There is one abstract method ``setApplication`` in this class; you could implement it, or declare this class as abstract.

    Done

The first example, "Messeduponpurpose.php", is actually bad code. There's a function that uses variables which don't exist, as well as accepting arguments which are never used. 
The immediate next example is completely wrong, which I believe is due to PHP Analyzer's lack of grasping traits (when used by a parent, and not the actual object it is currently checking). The "BrokenUser" model gets the same treatment. 
The second issue it mentions about str_split and array_shift is actually a non-issue.

<h2 id="pfff">Pfff</h2>
[Pfff](https://github.com/facebook/pfff) is not a single tool, but a collection of tools written by Facebook. 
Honestly, it's a great collection of tools that can be used for grepping, patching, or analyzing code in whole
or in small chunks. The show-stopping issue with the toolset is that *it does not understand namespaces*.
It's unfortunate, but apparently Facebook does not use namespace their code at all, and so it is not on the developer's
priority list. PHP Analyzer is a great replacement for basic analysis, but sgrep and spatch would be very interesting to use
on large projects that are namespaced. For those of us with projects that don't use namespaces, however, the tools are insanely powerful.

Unfortunately, the pfff tools are also tricky to build on some systems. 
I built it on a virtual machine using Debian's experimental packages and moved them over to the host - your mileage may vary.

The pfff toolchain allows you to perform static *and* dynamic analysis of your projects and build visual interpretations of it all - 
quickly, unlike most of the other tools mentioned here.

Unfortunately, I can't share any examples here since I've already thoroughly taken advantage of everything it has to offer. That being said, I still recommend that you check it out and use it on anything that you can.

<h2 id="build">How I use these tools in every day work</h2>
I'm a fan of [Grunt](http://gruntjs.com/), a task runner written in JavaScript. Yes, it is funny that most of the tools mentioned here are actually written *in PHP*, 
except for Grunt, but I think that diversity is healthy. I also tend to prefer Git for source control, and building a pre-commit hook that runs certain tasks is super simple. 
If the tests fail, then it won't allow me to check in my code. Take a look at my post on [using Grunt for PHP](/post/using-grunt-for-php) to see what I have in my Gruntfile.js.

    $ cd {repo}

    $ nano .git/hooks/pre-commit
        grunt precommit

And that's it. Really. If any of the tasks in the pre-commit step fail, I'll see some errors and be forced to fix them before
committing anything that can lead to a broken build. Prior to my learning git-svn (yes, I have to use SVN on some projects still), 
I wrote a simple bash script that did pretty much the same as the above. If you're forced to use SVN for work, but can install
software on your own machine, I strongly suggest that you instead learn to use git-svn and just use a pre-commit hook.
It will save you a lot of headaches. If you're not a fan of Grunt, you can use Phing, Ant, or a simple script that just
checks the return code or output of each tool.

I'm in the process of working on using the same virtual machine I used to build pfff to save a history of each commit someone makes to any of the repositories I have access to - a sort of "private" continuous testing server. Once that's done, I will probably make another post about how I set it up.

<h2>That's a wrap</h2>
Again, I'll reiterate my note from the beginning: this post is pretty dry. 
I'm going to continue to expand on each of these tools in future posts, as well as write some bad, 
but exemplary code that you may see in the wild which these tools can help you pick up. 
If you start running them now, though, you can start seeing for yourself just how useful they all are.
