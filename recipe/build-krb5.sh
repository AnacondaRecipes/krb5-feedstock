#!/bin/bash
set -e

# krb5 package uses files: section - all files are already built by libkrb5
# conda-build will automatically separate files based on the files: sections 