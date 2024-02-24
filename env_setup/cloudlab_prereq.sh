#!/bin/bash

if [ ! -n "$(grep "^github.com " ~/.ssh/known_hosts)" ]; then ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null; fi
rm -rf argocd-setup
git clone git@github.com:Gisaldjo/argocd-setup.git
cd argocd-setup/env_setup
./env_setup.sh
