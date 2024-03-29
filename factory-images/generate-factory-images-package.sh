#!/bin/sh

# Copyright (C) 2011 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# 185293 = GWK74
# 299849 = IMM76D
# 397360 = JRO02C
# 398337 = JRO03C
# 438695 = JRO03R

source ../../../common/clear-factory-images-variables.sh
PRODUCT=sojus
DEVICE=crespo4g
BUILD=438695
VERSION=jro03r
SRCPREFIX=signed-
BOOTLOADER=d720sprlc1
BOOTLOADERSRC=bootloader.pr.img
RADIO=d720sprlf2
RADIOSRC=radio.pr.img
source ../../../common/generate-factory-images-common.sh
