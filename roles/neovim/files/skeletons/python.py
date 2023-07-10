#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse

def main(args: argparse.Namespace):
    pass


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog="my-prog.py",
        description="My description",
        epilog="",
    )

    parser.add_argument("input_file", type=str, help="The input file")
    parser.add_argument("-o", "--output", type=str, help="The output file", required=True)
    args = parser.parse_args()
    main(args)
