<?php
  
  $con = mysql_connect("localhost", "tymepass_userr" , "}v88&G!uZ^{M");
  $db = mysql_selectdb("tymepass_new_db", $con);
  
  $res1 = mysql_query("select NOW() from user");
  $res1 = mysql_query("select id, creatorId, title ,startTime from events WHERE `reminder` != 0 AND notified=0  AND `servertime` > NOW() AND  `servertime` < NOW() + INTERVAL `reminderTime` MINUTE");

   require_once 'urbanairship.php';
   $APP_MASTER_SECRET = 'mmbSDVQpSQi5tE0fTWMB7w';
   $APP_KEY = 'C07mrwNUTcOqKqH9l2UFTg';
  //  mail("jason@mobispector.com", "Cron Mail", date("d-m-y H:i:s"));
    if (!empty($res1)) {
  while($row1 = mysql_fetch_assoc($res1))
  {
        $userid = $row1['creatorId'];
        $title = $row1['title'];
        $eventID =  $row1['id'];
        $startTime = $row1['startTime'];
        mysql_query("UPDATE events SET `notified` = '1' where id='$eventID'");
        $users = mysql_query("select toUser from invitation WHERE  `eventId` = '$eventID' ");
        while($row = mysql_fetch_assoc($users))
        {
           $userid .= "," . $row['toUser'] ;    
        }
        
        $users = mysql_query("select deviceId  from user WHERE `iCallSync` = '0'   AND  `serverId` in({$userid})");
       

        while($tokens = mysql_fetch_assoc($users))
        {
            $deviceToken =   $tokens['deviceId'];
           
           $tt = date("h:i A", strtotime($startTime));
            if($deviceToken !="00000000" && $deviceToken !="")
            {
                $airship = new Airship($APP_KEY, $APP_MASTER_SECRET);
                $airship->register($deviceToken, 'Tymepass');
                $broadcast_message = array('aps' => array('alert' => "$title \n is happening shortly", 'messageType' => "Event", "sound" => "default", "serverId" =>$eventID));
                $airship->push($broadcast_message, array($deviceToken));
            }
        }
                      
  }                                   
  }
  
  /*
  
  
    $res1 = mysql_query("select NOW() from user");
  $res1 = mysql_query("select id, creatorId, title ,startTime from events WHERE `reminder` = 0 AND notified=0  AND `servertime` > NOW() AND  `servertime` < NOW() + INTERVAL 15 MINUTE");

   require_once 'urbanairship.php';
   $APP_MASTER_SECRET = 'mmbSDVQpSQi5tE0fTWMB7w';
   $APP_KEY = 'C07mrwNUTcOqKqH9l2UFTg';
  while($row1 = mysql_fetch_assoc($res1))
  {
    
        $userid = $row1['creatorId'];
        $title = $row1['title'];
        $eventID =  $row1['id'];
        $startTime = $row1['startTime'];
        mysql_query("UPDATE events SET `notified` = '1' where id='$eventID'");
        $users = mysql_query("select toUser from invitation WHERE  `eventId` = '$eventID' ");
        while($row = mysql_fetch_assoc($users))
        {
           $userid .= "," . $row['toUser'] ;    
        }
        
        $users = mysql_query("select deviceId  from user WHERE  `serverId` in({$userid})");
       

        while($tokens = mysql_fetch_assoc($users))
        {
            $deviceToken =   $tokens['deviceId'];
           
           $tt = date("h:i A", strtotime($startTime));
            if($deviceToken !="00000000" && $deviceToken !="")
            {
                $airship = new Airship($APP_KEY, $APP_MASTER_SECRET);
                $airship->register($deviceToken, 'Tymepass');
                $broadcast_message = array('aps' => array('alert' => "$title \n  Today at $tt", 'messageType' => "Event", "sound" => "default"));
                $airship->push($broadcast_message, array($deviceToken));
            }
        }
                      
  } 
  */
