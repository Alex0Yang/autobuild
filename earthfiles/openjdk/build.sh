#!/usr/bin/env bash

set -e

source ../_common.sh

function build(){
    earthly -P --build-arg DATE_TAG=${DATE_TAG} --push +all
}

install_pkg
init_earthly
build
