#!/bin/bash
echo $(($((16#$(cat /dev/urandom | head -n 50 | od -x | cut -b 8-12,14-18 | xargs | sed 's/ //g' | cut -b 1-14)))%6 + 1))
