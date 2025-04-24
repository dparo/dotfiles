#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -eou pipefail

go clean -modcache
go clean -cache

npm cache clean --force
