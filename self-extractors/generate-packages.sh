#!/bin/sh

# Copyright (C) 2010 The Android Open Source Project
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

# 138179 = IRJ89
# 146649 = IRK18
# 185907 = IRK76
# 236517 = IML70C
# 237179 = IML73
# 237867 = IML74B
# 238432 = IML74E
# 238649 = IML74G
# 239410 = IML74K
# 262866 = IMM30D
# 299849 = IMM76D
# 345519 = IMM76L
# end ics-mr1
# start jb-dev
# 391496 = JRN83D
# 397816 = JRN03B
# 398337 = JRN03C
# 405518 = JRN03H
# 438695 = JRN03R
# 485486 = JZO54K
# end jb-dev
BRANCH=jb-dev
if test $BRANCH=ics-mr1
then
  ZIP=sojus-ota-345519.zip
  BUILD=imm76l
fi # ics-mr1
if test $BRANCH=jb-dev
then
  ZIP=sojus-ota-485486.zip
  BUILD=jzo54k
fi # jb-dev
ROOTDEVICE=crespo
DEVICE=crespo4g
MANUFACTURER=samsung

for COMPANY in akm broadcom cypress imgtec nxp samsung widevine
do
  echo Processing files from $COMPANY
  rm -rf tmp
  FILEDIR=tmp/vendor/$COMPANY/$DEVICE/proprietary
  mkdir -p $FILEDIR
  mkdir -p tmp/vendor/$MANUFACTURER/$ROOTDEVICE
  case $COMPANY in
  akm)
    TO_EXTRACT="\
            system/vendor/lib/libakm.so \
            "
    ;;
  broadcom)
    TO_EXTRACT="\
            system/vendor/bin/gpsd \
            system/vendor/firmware/bcm4329.hcd \
            system/vendor/lib/hw/gps.s5pc110.so \
            "
    ;;
  cypress)
    TO_EXTRACT="\
            system/vendor/firmware/cypress-touchkey.bin \
            "
    ;;
  imgtec)
    TO_EXTRACT="\
            system/vendor/bin/pvrsrvinit \
            system/vendor/lib/egl/libEGL_POWERVR_SGX540_120.so \
            system/vendor/lib/egl/libGLESv1_CM_POWERVR_SGX540_120.so \
            system/vendor/lib/egl/libGLESv2_POWERVR_SGX540_120.so \
            system/vendor/lib/hw/gralloc.s5pc110.so \
            system/vendor/lib/libglslcompiler.so \
            system/vendor/lib/libIMGegl.so \
            system/vendor/lib/libpvr2d.so \
            system/vendor/lib/libpvrANDROID_WSEGL.so \
            system/vendor/lib/libPVRScopeServices.so \
            system/vendor/lib/libsrv_init.so \
            system/vendor/lib/libsrv_um.so \
            system/vendor/lib/libusc.so \
            "
    ;;
  nxp)
    TO_EXTRACT="\
            system/vendor/firmware/libpn544_fw.so \
            "
    ;;
  samsung)
    TO_EXTRACT="\
            system/app/SprintMenu.apk \
            system/app/SystemUpdateUI.apk \
            system/app/WiMAXHiddenMenu.apk \
            system/app/WiMAXSettings.apk \
            system/lib/libsecril-client.so \
            system/lib/libWiMAXNative.so \
            system/vendor/firmware/wimaxfw.bin \
            system/vendor/firmware/wimaxloader.bin \
            system/vendor/firmware/wimax_boot.bin \
            system/vendor/lib/libsec-ril.so \
            system/vendor/lib/libSECmWiMAXcAPI.so \
            system/vendor/lib/wimax_service.jar \
            "
    ;;
  widevine)
    TO_EXTRACT="\
            system/lib/libdrmdecrypt.so \
            "
    ;;
  esac
  echo \ \ Extracting files from OTA package
  for ONE_FILE in $TO_EXTRACT
  do
    echo \ \ \ \ Extracting $ONE_FILE
    unzip -j -o $ZIP $ONE_FILE -d $FILEDIR > /dev/null || echo \ \ \ \ Error extracting $ONE_FILE
    if test $ONE_FILE = system/vendor/bin/gpsd -o $ONE_FILE = system/vendor/bin/pvrsrvinit
    then
      chmod a+x $FILEDIR/$(basename $ONE_FILE) || echo \ \ \ \ Error chmoding $ONE_FILE
    fi
  done
  echo \ \ Setting up $COMPANY-specific makefiles
  cp -R $COMPANY/staging/* tmp/vendor/$COMPANY/$DEVICE || echo \ \ \ \ Error copying makefiles
  echo \ \ Setting up shared makefiles
  cp -R root/* tmp/vendor/$MANUFACTURER/$ROOTDEVICE || echo \ \ \ \ Error copying makefiles
  echo \ \ Generating self-extracting script
  SCRIPT=extract-$COMPANY-$DEVICE.sh
  cat PROLOGUE > tmp/$SCRIPT || echo \ \ \ \ Error generating script
  cat $COMPANY/COPYRIGHT >> tmp/$SCRIPT || echo \ \ \ \ Error generating script
  cat PART1 >> tmp/$SCRIPT || echo \ \ \ \ Error generating script
  cat $COMPANY/LICENSE >> tmp/$SCRIPT || echo \ \ \ \ Error generating script
  cat PART2 >> tmp/$SCRIPT || echo \ \ \ \ Error generating script
  echo tail -n +$(expr 2 + $(cat PROLOGUE $COMPANY/COPYRIGHT PART1 $COMPANY/LICENSE PART2 PART3 | wc -l)) \$0 \| tar zxv >> tmp/$SCRIPT || echo \ \ \ \ Error generating script
  cat PART3 >> tmp/$SCRIPT || echo \ \ \ \ Error generating script
  (cd tmp ; tar zc --owner=root --group=root vendor/ >> $SCRIPT || echo \ \ \ \ Error generating embedded tgz)
  chmod a+x tmp/$SCRIPT || echo \ \ \ \ Error generating script
  ARCHIVE=$COMPANY-$DEVICE-$BUILD-$(md5sum < tmp/$SCRIPT | cut -b -8 | tr -d \\n).tgz
  rm -f $ARCHIVE
  echo \ \ Generating final archive
  (cd tmp ; tar --owner=root --group=root -z -c -f ../$ARCHIVE $SCRIPT || echo \ \ \ \ Error archiving script)
  rm -rf tmp
done
