#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 AleCl1210 <139965580+AleCl1210@users.noreply.github.com>
# shellcheck shell=sh

# Make the system-wide GE-Proton build visible to Steam in login shells too
# (the systemd environment.d drop-in covers graphical sessions; this covers
# terminals and other shells for good measure).
# See mkosi.extra/usr/lib/environment.d/70-kde-linux-gaming.conf.
STEAM_EXTRA_COMPATIBILITY_PATHS="${STEAM_EXTRA_COMPATIBILITY_PATHS:-/usr/share/steam/compatibilitytools.d}"
export STEAM_EXTRA_COMPATIBILITY_PATHS
