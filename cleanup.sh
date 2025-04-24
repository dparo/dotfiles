#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -eou pipefail

go clean -modcache
npm cache clean --force
