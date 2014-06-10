Deploop: The Hadoop Deploy System
=================================

Work in progress ... coming soon.

Project info
------------

More info in doc folder.


Pull request flow
------------------

Clone the repository from your project fork:

$ git clone https://github.com/deploop/deploop.git

The clone has as active branch the "development branch"

$ git branch
* development

Yo have to make your changes in the "development branch".

$ git add .

$ git commit -m "...."

$ git push origin

When you are ready to purpose a change to the original repository, you have
to use the "Pull Request" button from GitHub interface.

The point is the pull request have to go to the "development branch" so the pull
request revisor can check the change, pull to original "development branch", and 
the last step is to push this "development pull request" to the "master branch".

So the project has two branches:

1. The "master branch": The deployable branch, only hard tested code and ready to use.
2. The "development branch": Where the work is made and where the pull request has to make.

