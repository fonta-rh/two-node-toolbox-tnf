#!/bin/bash
. ./profile.env

cp pull_secret.json dev-scripts
pushd dev-scripts
  make clean
popd
