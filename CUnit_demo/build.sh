#!/bin/bash -x

gcc cunit_demo.c -lc -lcunit -L"/usr/local/lib" -o cunit_demo
