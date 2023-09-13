#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import io
import logging
import sys


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def parse_cmdline_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="my-prog.py",
        description="My description",
        epilog="",
    )

    ##
    ## Positional args
    ##
    parser.add_argument(
        "input_file",
        type=argparse.FileType(mode="r", encoding="utf-8"),
        nargs="?",
        help="The input file",
        default=sys.stdin,
    )

    ##
    ## Special arguments
    ##
    parser.add_argument(
        "--log",
        type=str.upper,
        dest="log_level",
        nargs="?",
        choices=[
            "DEBUG",
            "INFO",
            "WARN",
            "WARNING",
            "ERROR",
            "CRITICAL",
        ],
        help="Logging level",
        default="WARNING",
    )

    parser.add_argument(
        "--log-file",
        type=str,
        dest="log_file",
        nargs="?",
        help="Log file",
        default=None,
    )

    parser.add_argument(
        "-o",
        "--output",
        type=argparse.FileType(mode="w", encoding="utf-8"),
        dest="output_file",
        nargs="?",
        help="The output file",
        default=sys.stdout,
    )

    return parser.parse_args(sys.argv[1:])


def main(args: argparse.Namespace) -> None:
    input_file: io.TextIOWrapper = args.input_file
    output_file: io.TextIOWrapper = args.output_file

    ## Echo
    print(input_file.read(), file=output_file)


def setup_logging(args: argparse.Namespace):
    logging_handlers: list[logging.Handler] = [logging.StreamHandler()]
    if args.log_file:
        logging_handlers.append(
            logging.FileHandler(args.log_file, mode="w", encoding="utf-8")
        )
    logging.basicConfig(
        handlers=logging_handlers,
        format="%(asctime)s - %(filename)s:%(lineno)s - %(levelname)s - %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S%z",
        level=getattr(logging, args.log_level.upper()),
    )
    logging.info(f"Command line args namespace: {args}")


if __name__ == "__main__":
    args = parse_cmdline_args()
    setup_logging(args=args)
    main(args=args)
