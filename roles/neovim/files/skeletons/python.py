#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import sys
import io


def parse_cmdline_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="my-prog.py",
        description="My description",
        epilog="",
    )
    parser.add_argument(
        "-i",
        "--input_file",
          type=argparse.FileType("r"),
        help="The input file",
        required = False,
        default=sys.stdin,
    )

    parser.add_argument(
        "-o",
        "--output",
        type=argparse.FileType("w"),
        help="The output file",
        default=sys.stdout
    )
    return parser.parse_args(sys.argv[1:])


def main(args: argparse.Namespace) -> None:
    input_file: io.TextIOWrapper = args.input_file
    output_file: io.TextIOWrapper = args.output

    print(args)
    print(input_file.name)
    print(output_file.name)


if __name__ == "__main__":
    main(args=parse_cmdline_args())
