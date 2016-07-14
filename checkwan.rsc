#===============script check wan start===============
#-------------edit-------------
:local wan 2
#note!! max wan = 4
:local pingcount  5
:local pingok 5
:local pingintervalprobe  3
#-------------edit-------------

:global pingprobefail
:global pingprobefaillast
:global wanstatus
:local wstatuslist ""
:local pingprobefaillist ""
:local pingresult 
:local urlcheck "'',http://myip.dnsomatic.com,http://myip.dnsdynamic.com,http://myip.dtdns.com,http://ip.3322.org"
:local ipcheck "'',67.215.92.215,84.45.76.100,209.240.78.125,61.160.239.25"
:local intcheck "'',ether1,ether2,ether3,ether4"
:local rcheck "'',checkwan1,checkwan2,checkwan3,checkwan4"
:set urlcheck [:toarray $urlcheck]
:set ipcheck [:toarray $ipcheck]
:set intcheck [:toarray $intcheck]
:set rcheck [:toarray $rcheck]

:if ($pingprobefail->0=nil) do={ :set pingprobefail {0;0;0;0;};}
:for w from=1 to=$wan do={
  	:if ([/interface get value-name=running [find name=($intcheck->$w)]] = true) do={
    	:do {
       		:put ($ipcheck->$w)
       		:set pingresult [/ping  ($ipcheck->$w) count=$pingcount interface=($intcheck->$w) routing-table=($rcheck->w) ]
    	} on-error={
       		:log info "Failure to ping wan$w"
       		:set pingresult 0
    	}
  	} else={
	  	:log info "Interface wan$w is not running"
	  	:set ($pingprobefail->($w-1)) $pingintervalprobe
	    :set pingresult 0
  	}
  
	:if ($pingresult >= $pingok) do={
		:if ($pingprobefail->($w-1)>0) do={
	    	:set ($pingprobefail->($w-1)) ($pingprobefail->($w-1)-1)
	    	:log info ("Wan$w Unstable (".($pingprobefail->($w-1))."/".$pingintervalprobe.")")	
    	}
  	} else={ 
	    :if ($pingprobefail->($w-1)<pingintervalprobe) do={
	      	:set ($pingprobefail->($w-1)) ($pingprobefail->($w-1)+1)
	      	:log info ("Wan$w Unstable (".($pingprobefail->($w-1))."/".$pingintervalprobe.")")
	    }
  	}
}

:if ($pingprobefaillast->0=nil) do={ :set pingprobefaillast {0;0;0;0;};}
:for w from=1 to=$wan do={
  :if ($pingprobefaillast->($w-1)=1 && $pingprobefail->($w-1)=0) do={
    :log info ("Wan$w Up")
    :set wstatuslist ("$wstatuslist".","."down")
#start edit action wan   
  
#end  edit action wan 
  }
  :if ($pingprobefaillast->($w-1)=($pingintervalprobe-1) && $pingprobefail->($w-1)=$pingintervalprobe) do={
    :log info ("Wan$w Down")
    
#start edit action wan   
  
#end  edit action wan     
  }

}

:for w from=1 to=$wan do={
	:set ($pingprobefaillast->($w-1)) ($pingprobefail->($w-1))
	:if (($pingprobefail->($w-1))=0) do={
		:set wstatuslist ("$wstatuslist".","."up")
	} else={
    	:if (($pingprobefail->($w-1))=$pingintervalprobe) do={
    		:set wstatuslist ("$wstatuslist".","."down")	
    	} else={
    		:set wstatuslist ("$wstatuslist".","."unstable")
    	}
    }
  	:global wanstatus [:toarray $wstatuslist]
}

#===============script check wan end===============
