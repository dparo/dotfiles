#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse


def parse_cmdline_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="my-prog.py",
        description="My description",
        epilog="",
    )

    parser.add_argument(
        "input_file", type=argparse.FileType("r"), help="The input file"
    )
    parser.add_argument(
        "-o",
        "--output",
        type=argparse.FileType("w"),
        help="The output file",
        required=True,
    )
    return parser.parse_args()


def main(args_namespace: argparse.Namespace):
    args = args_namespace.vars()
    print(args)


if __name__ == "__main__":
    args = parse_cmdline_args()
    main(args)
