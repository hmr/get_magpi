#!/bin/bash
# vim: ft=sh ff=unix fenc=utf-8 ts=2 sw=2 et :

# get_magpi.sh
# Downloads all issued MagPi .
# Required: curl, wget
#
# AUTHOR: H.Maruyama
# ORIGIN: 2020-11-27

# Usage: Move to download directory and execute this script.

set -u

DEBUG=1
URL_LIST_FILE="_url_list.txt"

function dbgout {
  [ "${DEBUG}" = "0" ] || return

  echo "$@"
}

#
echo "Making URL list."
while true
do
  ISSUE=$((${ISSUE:=0} + 1))
  echo "Issue #${ISSUE}"
  unset MAGPI_FILE URL1 RESPONSE URL2 HTTP_STATUS
  MAGPI_FILE=$(printf "MagPi%02d.pdf" "${ISSUE}")
  if grep -q "${MAGPI_FILE}" "${URL_LIST_FILE}"; then
    echo "  seems to be found in the download list. skip."
    continue
  fi

  URL1="https://magpi.raspberrypi.org/issues/${ISSUE}/pdf/download"
  RESPONSE=$(curl -s -w '\n%{http_code}' "${URL1}")
  # URL2=$(echo "${RESPONSE}" | grep "c-link" | grep -o "https://.*\.pdf")
  URL2=$(echo "${RESPONSE}" | grep "c-link" | grep -o "/.*\.pdf")
  HTTP_STATUS=$(echo "${RESPONSE}" | tail -n 1)

  # Exit the loop if http request was error.
  [ "${HTTP_STATUS}" != "200" ] && echo "  is not issued yet." && break
  # Abort if URL to download is empty.
  [ -z "$URL2" ] && echo "  SOMETHING WRONG. ABORT" && exit 1
  URL2="https://magpi.raspberrypi.org${URL2}"
  # Make output file if it didn't exist.
  [ -e "${URL_LIST_FILE}" ] || touch "${URL_LIST_FILE}"

  # Skip if the URL already exists in the file.
  dbgout "URL2=${URL2}"
  if grep -q "${URL2}" "${URL_LIST_FILE}"; then
    echo "  is found in the download list. skip."
    continue
  fi
  dbgout "  HTTP Status: ${HTTP_STATUS}"
  echo   "  URL to PDF : ${URL2}"

  echo "${URL2}" >> ${URL_LIST_FILE}
done

# Download the PDF file.
echo "--------------------------------------------------"
echo "Start downloading MagPi PDF file."
wget -nc -i ${URL_LIST_FILE}

