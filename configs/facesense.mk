# Copyright (C) 2020 The PixelDust Project
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

# Build ParanoidFaceSense
TARGET_ENABLE_FACE_SENSE := true

PRODUCT_PACKAGES += \
    ParanoidFaceSense

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.face.sense_service=$(TARGET_ENABLE_FACE_SENSE)

# Permissions
PRODUCT_COPY_FILES += \
    vendor/pixeldust/config/permissions/pa-default-permissions.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/default-permissions/pa-default-permissions.xml

