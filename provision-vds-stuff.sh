
#-------------------------------------------------------------------------
#
# This example assumes the correct driver (likely Simulator) is previously set up
#
# this sets up weewx with a default config to get the skins running
#   - definitely run this from a 'sudo bash' shell
#    
#-------------------------------------------------------------------------

# for finding wee_extension the easy way
export PATH="$PATH:/home/weewx/bin:/usr/share/weewx/bin"

# uncomment only 'one' of the next two lines
#   export WEEWX_USER_DIR="/usr/share/weewx/bin/user"     # for packaged variants
export WEEWX_USER_DIR="/home/weewx/bin/user"              # for setup.py

# work in a scratch dir
cd /var/tmp

# several of my skins need $alltime which this enables
# this is just a stashed copy of stats.py from weewx 3.8.1
git clone https://github.com/vinceskahan/weewx-stats-extension weewx-stats-extension/
cp weewx-stats-extension/stats.py ${WEEWX_USER_DIR}/stats.py

# my personal bootstrap-driven skin
git clone https://github.com/vinceskahan/vds-weewx-bootstrap-skin vds-weewx-bootstrap-skin/
cd vds-weewx-bootstrap-skin
wee_extension --install .
cd -

# my memory-usage extension
git clone https://github.com/vinceskahan/vds-weewx-v3-mem-extension vds-weewx-v3-mem-extension/
cd vds-weewx-v3-mem-extension
wee_extension --install .
cd -

# my lastrain extension (needed for local skin)
git clone https://github.com/vinceskahan/vds-weewx-lastrain-extension vds-weewx-lastrain-extension/
cd vds-weewx-lastrain-extension
wee_extension --install .
cd -

# kludge city - my local skin pi.py script uses a hard-coded ip address for the outside raspi
# (to do: ip address of the pi should be in weewx.conf, extension needs a lot of refactoring)
echo "192.168.1.20 r r.local" >> /etc/hosts

# my local skin with all external pi interfaces and the above extensions assumed enabled
git clone https://github.com/vinceskahan/vds-weewx-local-skin vds-weewx-local-skin/
cd vds-weewx-local-skin
wee_extension --install .
cd -

# restart weewx at the end
service weewx restart

#-------------------------------------------------------------------------
#
# at this point:
#  - webcam.jpg linked into many pages is missing as viewed by a browser
#        crontab pulls that from the webcam raspi
#           which requires some local ssh setup as a prerequisite
#           (to do: serve this via nginx and wget the file via cron)
#  - station name, location, lat/lon are not set up
#        for this example, not required
#  - rsync skin is not set up yet
#        for this example, don't want to mess up real copies on my site
#        rsync assumes ssh is set up for the key to work automagically to user@server
#  - registering to the weewx map is disabled
#        for this example, don't want to register
#  - forecast is not installed
#      - NWS requires 'lid' and 'foid' set for the desired location to forecast for
#      - other forecast types I don't use require their own custom editing
#      - the forecast skin is just an example which requires some custom template files created
#          (todo: should ideally have a configured custom skin on github for this)
#  - various other uploaders and downloaders are not configured
#
#-------------------------------------------------------------------------
# manual edits in weewx.conf required to actually finish the job
#-----------------------------------------------------------------
#
# [Station]
#   location = "Federal Way, Washington
#   latitude = "47.310"
#   longitude = "-122.360"
#   altitude = "365, foot"
#   station_url = "http://www.skahan.net/weewx/"
#
# [Vantage]
#   type = serial
#   port = /dev/ttyUSB0
#   baud_rate = 19200
#
# [[StationRegistry]]
#   register_this_station = "true"
#
# --- we feed CWOP, PWSweather, and WUnderground currently --
#
# [[CWOP]]
#   enable = true
#   station = <mystationid>
#
# [[PWSweather]]
#   enable = true
#   station = <mystationid>
#   password = <mypassword>
#
# [WUnderground]]
#   enable = true
#   station = my_station_id
#   password = my_password
#   rapidfile = False
#
# --- rsync requires some configuration re: the remote end ---
#     and assumes /root/.ssh/config is set up to load the
#     correct key to match what the remote server expects.
#
#     The /root/.ssh/config file would look something like:
#        Host my.fqdn.here
#           IdentityFile /root/.ssh/my_private_key_filename
#           user myRemoteUserName
#
# [[RSYNC]]
#   delete = 0
#   server = my.fqdn.here   # or ip address
#   path = /path/goes/here
#   user = myRemoteUserName
#   log_success = true
#   log_failure = true
#
# --- for fiddling with MQTT publishing of weewx data occasionally ---
#     this requires a remote broker with a hostname of 'mqtt.local'
#     as resolved by the weewx computer, or use an ip address if needed
#
# [[MQTT]]
#   server_url = mqtt://mqtt.local:1883/
#   append_units_label = false
#
# --- this likely doesn't matter due to bugs and hard-coded-ness in the extension ---
#     Take the default the extension uses and it likely works ok...
#
# [PiMonitor]
#   remote_url = http://pi.ip.address/pi.json
#
# --- for forecast we use the NWS forecast since we're near a major airport ---
#
# [Forecast]
#   [[NWS]]
#     lid = WAZ558
#     foid = SEW
#
#----------------------------------------------------
#
# other setup to do to complate the job:
#    regenerate /root/.ssh tree        (use the MacbookAir as a starting point)
#    set up root crontab and /root/bin (see dropbox for the files)
#    substitute the correct keys and passwords in above of course, as needed
#    verify you can ssh into the pi to grab the webcam pix
#    verify you can ssh into the AWS box that we push to via rsync
#        
#----------------------------------------------------
