#!/bin/bash

readonly MY_EMAIL='cjk2017@cjk.autoidlab.jp'
readonly MAIL_COMMAND='/usr/bin/mail'

while read line
do
  name=`echo ${line} | cut -d ',' -f 1`
  email=`echo ${line} | cut -d ',' -f 2`
  url=`echo ${line} | cut -d ',' -f 3`
  letter="Hello ${name},\n\nYour can change your password from\n${url}\n\nDon't show this to others\nThank you!"
  echo -e ${letter} | ${MAIL_COMMAND} -s "Secret login url for CJK Workshop 2017" -r ${MY_EMAIL} ${email}
done
