#!/bin/bash

# This script must be called from the root of the repository.
#
# This script depends on having hugo in your system.

set -e
set -x

rm -rf public

# Download theme

if [ ! -d themes/hugo-theme-stack ]; then
    mkdir -p themes/hugo-theme-stack
    wget https://github.com/CaiJimmy/hugo-theme-stack/archive/refs/tags/v3.33.0.tar.gz
    tar -xzvf v3.33.0.tar.gz -C themes/hugo-theme-stack --strip-components=1
    rm v3.33.0.tar.gz
fi

hugo --cleanDestinationDir --baseURL https://skylyrac.net/
