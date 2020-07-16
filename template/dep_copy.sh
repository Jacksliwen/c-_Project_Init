#!/bin/bash
DEP_LIST=$( ldd $1 | awk '{if (match($3,"/")){ print $3}}' )  
mkdir lib
cp -L -n $DEP_LIST lib

