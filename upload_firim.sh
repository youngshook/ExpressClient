#/bin/sh

# compress application.
if [ "${CONFIGURATION}" = "Release" ]; then

# Local Display App Name And Default Icon@2x.png ------------ need developer custom
DISPLAY_NAME="钱喵喵"
ICON_NAME="Icon@2x.png"

#Clear
/bin/rm "/tmp/firim.log"
/bin/rm "/tmp/${PRODUCT_NAME}.ipa"

LOG="/tmp/firim.log"
echo  "find Archives Distribution  ${PRODUCT_NAME}.app file ...1 " >> $LOG
DATE=$( /bin/date +"%Y-%m-%d" )
ARCHIVE=$( /bin/ls -t "${HOME}/Library/Developer/Xcode/Archives/${DATE}" | /usr/bin/grep xcarchive | /usr/bin/sed -n 1p )
APP="${HOME}/Library/Developer/Xcode/Archives/${DATE}/${ARCHIVE}/Products/Applications/${PRODUCT_NAME}.app"
echo  "Step Done ----------1" >> $LOG

echo  "Gets the configuration of ${DISPLAY_NAME} from Info.plist ...2 " >> $LOG
#SIGNING_IDENTITY="iPhone Distribution: <Your Name>>"
#PROVISIONING_PROFILE="${HOME}/Library/MobileDevice/Provisioning Profiles/<filename>>.mobileprovision"
SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
PATH_TO_ARTWORK="${SRCDIR}/${ICON_NAME}"
#Get Version
VERSION_SHORT=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${APP}/Info.plist")
VERSION_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${APP}/Info.plist")
VERSION=`echo ${VERSION_SHORT}Build${VERSION_BUILD}`
#appId
APPID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "${APP}/Info.plist")
echo  "Step Done ----------2" >> $LOG 

#Package ipa file 
echo  "Package .ipa for ${PRODUCT_NAME}...3 " >> $LOG
/bin/cp ${PATH_TO_ARTWORK} /tmp/iTunesArtwork
#if need set sign, add (--sign "${SIGNING_IDENTITY}" --embed "${PROVISIONING_PROFILE}")
xcrun -sdk iphoneos PackageApplication -v "${APP}" -o "/tmp/${PRODUCT_NAME}.ipa"
echo  "Step Done ----------3" >> $LOG

#get last commit if have
gitcommit=`git --git-dir="${SRCDIR}/.git" log -1 --oneline --pretty=format:'%s'`

echo  "Uploading to Fir.im  ....4 " >> $LOG
fir_upload_url=`curl "http://fir.im/api/upload_url?appid="${APPID}` 
POST_FILE=`echo ${fir_upload_url}| ruby -e "require 'rubygems'; require 'json'; puts JSON[STDIN.read]['postFile'];"`
POST_ICON=`echo ${fir_upload_url}| ruby -e "require 'rubygems'; require 'json'; puts JSON[STDIN.read]['postIcon'];"`
SHORT_URL=`echo ${fir_upload_url}| ruby -e "require 'rubygems'; require 'json'; puts JSON[STDIN.read]['short'];"`
curl -T /tmp/${PRODUCT_NAME}.ipa ${POST_FILE} -X PUT
curl -T /tmp/iTunesArtwork ${POST_ICON} -X PUT
POST_DATA='appid='${APPID}'&short='${SHORT_URL}'&version='${VERSION}'&name='${DISPLAY_NAME}
if [ "${gitcommit}" ]; then
gitcommit=$(perl -MURI::Escape -e 'print uri_escape("'"${gitcommit}"'");' "$2")
POST_DATA=${POST_DATA}'&changelog='${gitcommit}
fi
r=`curl -X POST -d ${POST_DATA} -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" "http://fir.im/api/finish"`
SHORT=`echo ${r}| ruby -e "require 'rubygems'; require 'json'; puts JSON[STDIN.read]['short'];"`

#Open Download Url
open "http://fir.im/${SHORT}"

echo  "finish load ----------OK" >> $LOG
echo  "To visit Http://fir.im/${SHORT} download!" >> $LOG

fi
exit 0
