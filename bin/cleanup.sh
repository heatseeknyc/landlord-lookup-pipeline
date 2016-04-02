#!/bin/bash -ue
find . -name '*.pyc' | xargs \rm -f
find . -name '__pycache__' | xargs \rm -rf
