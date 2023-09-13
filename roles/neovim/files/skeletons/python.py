#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import sys


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
    return parser.parse_args(sys.argv[1:])


def main(args: argparse.Namespace) -> None:
    input_file = args.input_file
    print(args)
    print(input_file)


if __name__ == "__main__":
    main(args=parse_cmdline_args())
