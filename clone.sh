#!/bin/bash
set -ex

repos=(
    clouddriver
    deck
    echo
    fiat
    front50
    gate
    halyard
    igor
    kayenta
    orca
    rosco
    spinnaker.github.io
    )

mkdir -p $2
cd $2

for repo in "${repos[@]}"
do
    git clone git@github.com:$1/$repo

    cd $repo

    git remote add upstream git@github.com:spinnaker/$repo
    git fetch upstream

    cd ..
done
