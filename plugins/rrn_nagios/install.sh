#!/bin/sh
clear

# Welcome banner

echo
echo Welcome to Reliable Response Notification
echo Nagios Integration
echo --------------------------------------------
echo Please press enter to continue
read eof

# License

more <<"EOF"
Reliable Response, LLC
License Agreement

1.  LICENSE TO USE.  
Reliable Response grants you a non-exclusive and non-transferable license for the internal use only of the accompanying software and documentation and any error corrections provided by Reliable Response (collectively "Software"), by the number of users and the class of computer hardware for which the corresponding fee has been paid.

2.  RESTRICTIONS.  
Software is confidential and copyrighted. Title to Software and all associated intellectual property rights is retained by Reliable Response and/or its licensors. Except as specifically authorized in any Supplemental License Terms, you may not make copies of Software, other than a single copy of Software for archival purposes.  Unless enforcement is prohibited by applicable law, you may not modify, decompile, or reverse engineer Software. Reliable Response, LLC. disclaims any express or implied warranty of fitness for such uses.  No right, title or interest in or to any trademark, service mark, logo or trade name of Reliable Response or its licensors is granted under this Agreement.

3.  LIMITED WARRANTY.  
Reliable Response warrants to you that for a period of ninety (90) days from the date of purchase, as evidenced by a copy of the receipt, the media on which Software is furnished (if any) will be free of defects in materials and workmanship under normal use.  Except for the foregoing, Software is provided "AS IS".  Your exclusive remedy and Reliable Response's entire liability under this limited warranty will be at Reliable Response's option to replace Software media or refund the fee paid for Software.

4.  DISCLAIMER OF WARRANTY.  
UNLESS SPECIFIED IN THIS AGREEMENT, ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT ARE DISCLAIMED, EXCEPT TO THE EXTENT THAT THESE DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

5.  LIMITATION OF LIABILITY.  
TO THE EXTENT NOT PROHIBITED BY LAW, IN NO EVENT WILL RELIABLE RESPONSE OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR SPECIAL, INDIRECT, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF OR RELATED TO THE USE OF OR INABILITY TO USE SOFTWARE, EVEN IF RELIABLE RESPONSE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.  In no event will Reliable Response's liability to you, whether in contract, tort (including negligence), or otherwise, exceed the amount paid by you for Software under this Agreement.  The foregoing limitations will apply even if the above stated warranty fails of its essential purpose.

6.  Termination.  
This Agreement is effective until terminated.  You may terminate this Agreement at any time by destroying all copies of Software.  This Agreement will terminate immediately without notice from Reliable Response if you fail to comply with any provision of this
Agreement.  Upon Termination, you must destroy all copies of Software.

9.  Governing Law.  
Any action related to this Agreement will be governed by Colorado law and controlling U.S. federal law.  No choice of law rules of any jurisdiction will apply.

10. Severability. 
If any provision of this Agreement is held to be unenforceable, this Agreement will remain in effect with the provision omitted, unless omission would frustrate the intent of the parties, in which case this Agreement will immediately terminate.

11. Integration.  
This Agreement is the entire agreement between you and Reliable Response relating to its subject matter.  It supersedes all prior or contemporaneous oral or written communications, proposals, representations and warranties and prevails over any conflicting or additional terms of any quote, order, acknowledgment, or other communication between the parties relating to its subject matter during the term of this Agreement.  No modification of this Agreement will be binding, unless in writing and
signed by an authorized representative of each party.

For inquiries please contact: 
Reliable Response, LLC
1600 Broadway, Suite 2400
Denver, Colorado 80202
EOF

# make sure the user agrees

agreed=
while [ x$agreed = x ]; do
    echo
    echo "Do you agree to the above license terms? [yes or no] "
    read reply leftover
    case $reply in
        y* | Y*)
            agreed=1;;
        n* | N*)
    echo "If you don't agree to the license you can't install this software";
    exit 1;;
    esac
done

# Find the path to Nagios configuration
NAGIOSPATH=""
if [ -d /etc/nagios ]
then
	NAGIOSPATH="/etc/nagios/"
elif [ -d /usr/local/etc/nagios ]
then
	NAGIOSPATH="/usr/local/etc/nagios"
elif [ -d /usr/local/nagios/etc ]
then
        NAGIOSPATH="/usr/local/nagios/etc"
fi
echo -n "Location of Nagios Configuration Directory? [$NAGIOSPATH] "
read INPUT
if [ x$INPUT != x ]
then
	NAGIOSPATH=$INPUT
fi

while [ ! -f $NAGIOSPATH/nagios.cfg ]
do
	echo -n "Location of Nagios Configuration Directory? [$NAGIOSPATH] "
	read INPUT
	if [ x$INPUT != x ]
	then
		NAGIOSPATH=$INPUT
	fi
done

# Find the directory where to place the SOAP client
BINDIR=""
if [ -d /usr/local/bin ]
then
	BINDIR="/usr/local/bin/"
elif [ -d /usr/bin ]
then
	BINDIR="/usr/bin"
fi
echo -n "Location to place SendNagiosNotification executable? [$BINDIR] "
read INPUT
if [ x$INPUT != x ]
then
	BINDIR=$INPUT
fi

while [ ! -d $BINDIR ]
do
	echo -n "Location to place SendNagiosNotification executable? [$BINDIR] "
	read INPUT
	if [ x$INPUT != x ]
	then
		BINDIR=$INPUT
	fi
done

# Find the Reliable Response hostname
RRHOST="notification"
echo -n "Reliable Response Notification Hostname? [$RRHOST] "
read INPUT
if [ x$INPUT != x ]
then
	RRHOST=$INPUT
fi

RRUSER="admin"
echo -n "User to login to Reliable Response Notification? [$RRUSER] "
read INPUT
if [ x$INPUT != x ]
then
        RRUSER=$INPUT
fi

RRPWD="password"
echo -n "Password to use when logging into Reliable Response Notification? [$RRPWD] "
read INPUT
if [ x$INPUT != x ]
then
        RRPWD=$INPUT
fi


NURL=http://`hostname`/nagios
echo -n "URL of the Nagios server? [$NURL] "
read INPUT
if [ x$INPUT != x ]
then
        NURL=$INPUT
fi

NUSER="guest"
echo -n "User to login to Nagios? [$NUSER] "
read INPUT
if [ x$INPUT != x ]
then
        NUSER=$INPUT
fi

NPWD="password"
echo -n "Password to use when logging into Nagios? [$NPWD] "
read INPUT
if [ x$INPUT != x ]
then
        NPWD=$INPUT
fi

# Check is SOAP::Lite is installed
output=`perl -MSOAP::Lite -e1 2>&1`
if [ -n "$output" ]
then
        echo "Nagios integration relies on SOAP::Lite."
	echo "Do you want to install SOAP::Lite from CPAN now."

	read reply leftover
	case $reply in
        y* | Y*)
            agreed=1;;
        n* | N*)
	    agreed=0;;
	esac;
fi
if [ $agreed==1 ]
then
	perl -MCPAN -e install SOAP::Lite
else
	echo "Skipping SOAP::Lite installation.  Please install this manually"
fi

echo Installing SendNagiosNotification executable

echo "#!/usr/bin/perl -w">$BINDIR/SendNagiosNotification
echo "use SOAP::Lite;">>$BINDIR/SendNagiosNotification
echo "use Getopt::Long;">>$BINDIR/SendNagiosNotification
echo "">>$BINDIR/SendNagiosNotification
echo "my \$subject = '';">>$BINDIR/SendNagiosNotification
echo "my \$message = '';">>$BINDIR/SendNagiosNotification
echo "my \$recipient = '';">>$BINDIR/SendNagiosNotification
echo "">>$BINDIR/SendNagiosNotification
echo "my \$uri = \"http://$RRUSER:$RRPWD\@$RRHOST:8080/notification/SendSOAPNotification.jws\";">>$BINDIR/SendNagiosNotification
echo "">>$BINDIR/SendNagiosNotification
echo "my \$nagiosurl = \"$NURL/cgi-bin/cmd.cgi\";">>$BINDIR/SendNagiosNotification
echo "my \$isservice = '';">>$BINDIR/SendNagiosNotification
echo "my \$hostname = '';">>$BINDIR/SendNagiosNotification
echo "my \$objectname = '';">>$BINDIR/SendNagiosNotification
echo "">>$BINDIR/SendNagiosNotification
echo "GetOptions ('subject=s' => \\\$subject, 'message=s' => \\\$message, 'recipient=s' => \\\$recipient, 'uri=s' => \\\$uri, 'isservice=s' => \\\$isservice, 'hostname=s' => \\\$hostname, 'objectname=s' => \\\$objectname);">>$BINDIR/SendNagiosNotification
echo "">>$BINDIR/SendNagiosNotification
echo "if (\$isservice =~ /^[yYtT]/) {">>$BINDIR/SendNagiosNotification
echo "	\$issservice = \"true\";	">>$BINDIR/SendNagiosNotification
echo "} else {">>$BINDIR/SendNagiosNotification
echo "	\$issservice = \"false\";">>$BINDIR/SendNagiosNotification
echo "}">>$BINDIR/SendNagiosNotification
echo "SOAP::Lite">>$BINDIR/SendNagiosNotification
echo "  -> uri(\$uri)">>$BINDIR/SendNagiosNotification
echo "  -> proxy(\$uri)">>$BINDIR/SendNagiosNotification
echo "  -> sendNagiosNotification(SOAP::Data->type(string => \$recipient), ">>$BINDIR/SendNagiosNotification
echo "  SOAP::Data->type(string => \$subject), ">>$BINDIR/SendNagiosNotification
echo "  SOAP::Data->type(string => \$message),">>$BINDIR/SendNagiosNotification
echo "  SOAP::Data->type(string => \$nagiosurl),">>$BINDIR/SendNagiosNotification
echo "  SOAP::Data->type(string => \"$NUSER\"),">>$BINDIR/SendNagiosNotification
echo "  SOAP::Data->type(string => \"$NPWD\"),">>$BINDIR/SendNagiosNotification
echo "  SOAP::Data->type(boolean => \$isservice),">>$BINDIR/SendNagiosNotification
echo "  SOAP::Data->type(string => \$hostname),">>$BINDIR/SendNagiosNotification
echo "  SOAP::Data->type(string => \$objectname)">>$BINDIR/SendNagiosNotification
echo ");">>$BINDIR/SendNagiosNotification
chmod 755 $BINDIR/SendNagiosNotification

echo Backing up nagios.cfg
cp $NAGIOSPATH/nagios.cfg $NAGIOSPATH/nagios.rrnbak

echo Installing Reliable Response Notification definitions in reliableresponse.cfg
echo "define command {">$NAGIOSPATH/reliableresponse.cfg
echo "        command_name notify-by-reliable">>$NAGIOSPATH/reliableresponse.cfg
echo "        command_line $BINDIR/SendNagiosNotification -s \"** \$NOTIFICATIONTYPE\$ alert - \$HOSTALIAS\$/\$SERVICEDESC\$ is \$SERVICESTATE\$ **\" -m \"***** Nagios  *****\\n\\nNotification Type: \$NOTIFICATIONTYPE\$\\n\\nService: \$SERVICEDESC\$\\nHost: \$HOSTALIAS\$\\nAddress: \$HOSTADDRESS\$\\nState: \$SERVICESTATE\$\\n\\nDate/Time: \$LONGDATETIME\$\\n\\nAdditional Info:\\n\\n\$SERVICEOUTPUT\$\" -r \$CONTACTADDRESS1\$ --isservice=\"True\" --hostname=\"\$HOSTNAME\$\" --objectname=\"\$SERVICEDESC\$\"">>$NAGIOSPATH/reliableresponse.cfg
echo "        }">>$NAGIOSPATH/reliableresponse.cfg

echo Adding reliableresponse.cfg to the end of nagios.cfg
echo cfg_file=/usr/local/nagios/etc/reliableresponse.cfg >> $NAGIOSPATH/nagios.cfg
# Done!
echo Thank you for installing the Reliable Response Notification plugin for Nagios
echo
echo Please restart Nagios to see the changes take effect

