#!/usr/bin/sh -ex

export PIP_RESOLVER_DEBUG=1
pip install -r requirements_$1.txt
