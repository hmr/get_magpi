#!/bin/bash
# vim: ft=bash ff=unix fenc=utf-8 ts=2 sw=2 et :

# get_magpi.sh
# Downloads all issued MagPi .
# Required: curl, wget
#
# AUTHOR: H.Maruyama
# ORIGIN: 2020-11-27

set -u

DEBUG=0
URL_LIST_FILE="_url_list.txt"

function dbgout {
  [ "${DEBUG}" = "0" ] || return

  echo $@
}

declare -a ADD_URL_ARR
#
echo "Making URL list."
while true
do
  ISSUE=$((${ISSUE:=0} + 1))
  echo "Issue #${ISSUE}"
  unset URL1 RESPONSE URL2 HTTP_STATUS
  URL1="https://magpi.raspberrypi.org/issues/${ISSUE}/pdf/download"
  RESPONSE=$(curl -s -w '\n%{http_code}' "${URL1}")
  URL2=$(echo "${RESPONSE}" | grep "c-link" | grep -o "https://.*\.pdf")
  HTTP_STATUS=$(echo "${RESPONSE}" | tail -n 1)

  # Exit loop if http request was error
  [ "${HTTP_STATUS}" != "200" ] && break
  # Make output file if it didn't exist.
  [ -e "${URL_LIST_FILE}" ] || touch "${URL_LIST_FILE}"

  # Skip if the URL already exists in the file.
  if grep -q "${URL2}" "${URL_LIST_FILE}"; then
    echo "  exists in the file. skip."
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

