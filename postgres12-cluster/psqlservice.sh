#!/bin/bash

return_fail() {
  echo -e "HTTP/1.1 503 Service Unavailable\r\n"
  echo -e "Content-Type: text/plain\r\n"
  echo -e "Content-Length: 40\r\n"
  echo -e "Connection: close\r\n"
  echo -e "\r\n"
  echo -e "PostgreSQL standby is running\r\n"
  echo -e "\r\n"
  exit 1
}

return_ok() {
  echo -en "HTTP/1.1 200 OK\r\n"
  echo -en "Content-Type: text/plain\r\n"
  echo -en "Content-Length: 29\r\n"
  # echo -en "Connection: close\r\n"
  echo -en "\r\n"
  echo -en "PostgreSQL primary is running.\r\n"
  echo -en "\r\n"
  exit 0
}

if /usr/local/bin/db_check_master.sh; then
  return_ok
fi

return_fail
