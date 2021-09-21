# More Information on Contributing to Enigma Engine

Enigma Engine utilizes a GitFlow style. New features are developed in `feature/<name>` branches and merged into `develop` via pull requests. `stable` regularly fast-forward to the latest commit of `develop` when a new release is pushed.

The default repository is set to `stable`; this means that users who first come to the repos see the guaranteed working branch. However, this means that Pull Requests will default to merge into `stable` instead of `develop`, and these will be broken unless you select `develop` as the target branch when making the pull request.
