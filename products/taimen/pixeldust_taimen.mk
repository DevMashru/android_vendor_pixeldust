# Copyright (C) 2019 The PixelDust Project
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
#  limitations under the License.

# Bootanimation
BOOTANIMATION := 1440

# Release name
PRODUCT_RELEASE_NAME := Pixel2XL
export TARGET_DEVICE := taimen

# We have our own power HAL
TARGET_USES_DEVICE_SPECIFIC_POWERHAL := true

# Use the AOSP stack
TARGET_USES_AOSP := true

# Use the sepolicies which are being shipped with our device
TARGET_EXCLUDE_QCOM_VENDOR_SEPOLICY := true

# Generic CAF packages
include device/qcom/common/common.mk

# Include common PixelDust stuff
include vendor/pixeldust/configs/pixeldust_phone.mk

# Include optional stuff (e.g. prebuilt apps)
include vendor/pixeldust/configs/system_optional.mk

# Google Apps
#$(call inherit-product, vendor/googleapps/googleapps.mk)

# Inherit device configuration
$(call inherit-product, device/google/taimen/aosp_taimen.mk)

-include device/google/taimen/device-carbon.mk

# Device identifier. This must come after all inclusions
PRODUCT_NAME := pixeldust_taimen
PRODUCT_BRAND := google
PRODUCT_MODEL := Pixel 2 XL
TARGET_MANUFACTURER := LGE
PRODUCT_RESTRICT_VENDOR_FILES := false

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=taimen \
    PRIVATE_BUILD_DESC="taimen-user 9 PQ3A.190505.001 5373320 release-keys"

BUILD_FINGERPRINT := google/taimen/taimen:9/PQ3A.190505.001/5373320:user/release-keys

PRODUCT_PROPERTY_OVERRIDES += \
    ro.carbon.maintainer="nitin1438"
	ro.pixeldust.device="taimen"

$(call inherit-product-if-exists, vendor/google/taimen/taimen-vendor.mk)

# Copy device specific prebuilt files.
PRODUCT_COPY_FILES += \
    vendor/pixeldust/prebuilt/etc/apns-conf.xml:system/etc/apns-conf.xml

# Use SDCLANG
TARGET_USE_SDCLANG := true